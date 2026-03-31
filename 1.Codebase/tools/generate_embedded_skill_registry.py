#!/usr/bin/env python3
"""Generate 1.Codebase/generated/embedded_skill_registry.gd from the skill files.

Run from the repository root:
    python3 1.Codebase/tools/generate_embedded_skill_registry.py

The generated file embeds all skill markdown bodies (en / zh / de) so that
the SkillManager can fall back to it on web/HTML5 builds where DirAccess
directory scanning is unavailable.
"""

import os
import sys

# Resolve paths relative to the repository root
_SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
_REPO_ROOT = os.path.join(_SCRIPT_DIR, "..", "..")
SKILLS_BASE = os.path.join(_REPO_ROOT, "1.Codebase", "src", "skills")
OUTPUT_PATH = os.path.join(_REPO_ROOT, "1.Codebase", "generated", "embedded_skill_registry.gd")


def read_file(path: str) -> str:
    try:
        with open(path, "r", encoding="utf-8") as f:
            return f.read()
    except OSError as e:
        print(f"  WARNING: could not read {path}: {e}", file=sys.stderr)
        return ""


def parse_skill_file(content: str):
    """Return (metadata_dict, body_str) from a SKILL.md file."""
    metadata: dict = {}
    if not content.startswith("---"):
        return metadata, content
    end_marker = content.find("\n---", 3)
    if end_marker == -1:
        return metadata, content
    frontmatter = content[4:end_marker].strip()
    body = content[end_marker + 5:].strip()

    current_key = ""
    in_array = False
    array_items: list = []

    for line in frontmatter.split("\n"):
        stripped = line.strip()
        if not stripped:
            continue
        if in_array:
            if stripped.startswith("- "):
                array_items.append(stripped[2:].strip())
                continue
            metadata[current_key] = array_items
            in_array = False
            array_items = []
        if not in_array:
            colon_pos = stripped.find(":")
            if colon_pos > 0:
                current_key = stripped[:colon_pos].strip()
                value = stripped[colon_pos + 1:].strip()
                if not value:
                    in_array = True
                    array_items = []
                else:
                    metadata[current_key] = value

    if in_array and array_items:
        metadata[current_key] = array_items

    return metadata, body


def escape_gdscript(s: str) -> str:
    """Escape a string for embedding inside a GDScript double-quoted literal."""
    s = s.replace("\\", "\\\\")
    s = s.replace('"', '\\"')
    s = s.replace("\n", "\\n")
    s = s.replace("\t", "\\t")
    return s


def collect_skills(skills_base: str) -> dict:
    skills = {}
    for folder_name in sorted(os.listdir(skills_base)):
        skill_dir = os.path.join(skills_base, folder_name)
        if not os.path.isdir(skill_dir):
            continue
        content_en = read_file(os.path.join(skill_dir, "SKILL.md"))
        if not content_en:
            continue
        metadata, body_en = parse_skill_file(content_en)
        if not metadata:
            continue
        skill_name = metadata.get("name", folder_name)
        _, body_zh = parse_skill_file(read_file(os.path.join(skill_dir, "SKILL.zh.md")))
        _, body_de = parse_skill_file(read_file(os.path.join(skill_dir, "SKILL.de.md")))
        skills[skill_name] = {
            "metadata": metadata,
            "folder": folder_name,
            "body_en": body_en,
            "body_zh": body_zh,
            "body_de": body_de,
        }
    return skills


def generate(skills: dict) -> str:
    lines = [
        "# AUTO-GENERATED — do not edit by hand.",
        "# Regenerate with: python3 1.Codebase/tools/generate_embedded_skill_registry.py",
        "# This file embeds all skill data for web/HTML5 builds that cannot use DirAccess.",
        "extends RefCounted",
        "",
        "static func get_skills() -> Dictionary:",
        "\treturn {",
    ]

    for skill_name, data in skills.items():
        meta = data["metadata"]
        folder = data["folder"]
        body_en = data["body_en"]
        body_zh = data["body_zh"]
        body_de = data["body_de"]

        triggers = meta.get("purpose_triggers", [])
        if isinstance(triggers, str):
            triggers = [triggers]
        elif not isinstance(triggers, list):
            triggers = []
        triggers_str = "[" + ", ".join(f'"{t}"' for t in triggers) + "]"
        description = escape_gdscript(str(meta.get("description", "")))

        lines += [
            f'\t\t"{skill_name}": {{',
            f'\t\t\t"name": "{skill_name}",',
            f'\t\t\t"description": "{description}",',
            f'\t\t\t"folder": "{folder}",',
            f'\t\t\t"purpose_triggers": {triggers_str},',
            '\t\t\t"content": {',
            f'\t\t\t\t"en": "{escape_gdscript(body_en)}",',
            f'\t\t\t\t"zh": "{escape_gdscript(body_zh)}",',
            f'\t\t\t\t"de": "{escape_gdscript(body_de)}",',
            '\t\t\t},',
            '\t\t},',
        ]

    lines += ["\t}", ""]
    return "\n".join(lines)


def main() -> int:
    if not os.path.isdir(SKILLS_BASE):
        print(f"ERROR: skills directory not found: {SKILLS_BASE}", file=sys.stderr)
        return 1

    skills = collect_skills(SKILLS_BASE)
    if not skills:
        print("ERROR: no skills found", file=sys.stderr)
        return 1

    content = generate(skills)
    os.makedirs(os.path.dirname(OUTPUT_PATH), exist_ok=True)
    with open(OUTPUT_PATH, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"Generated {OUTPUT_PATH}")
    print(f"  Skills ({len(skills)}): {', '.join(skills.keys())}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
