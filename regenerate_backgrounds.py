from __future__ import annotations
import argparse
import base64
import concurrent.futures
import io
import os
import sys
from pathlib import Path
import google.genai as genai
import PIL.Image
DEFAULT_API_KEY = os.environ.get("ANTIGRAVITY_API_KEY", "sk-antigravity-local-key")
DEFAULT_API_ENDPOINT = os.environ.get(
    "ANTIGRAVITY_API_ENDPOINT", "http://127.0.0.1:8045"
)
DEFAULT_MODEL = os.environ.get("GEMINI_IMAGE_MODEL", "gemini-3.1-flash-image")
REBIRTH_IMAGES = {
    "day_2": {
        "filename": "rebirth_day_2.png",
        "prompt": (
            "SUBJECT: A vintage red Coca-Cola branded radio. It is large, occupying the centre of the frame, roughly the same size as the guitar in the reference image. "
            "The radio body is a warm brick-red colour with cream/silver panel details and a round glowing amber tuning dial on the right side. "
            "Scattered immediately around its base are a few small screwdrivers and loose copper wires — repair tools, kept small so the radio remains dominant. "
            "The background is the same warm medium-grey stone brick wall as the reference — well-lit, clearly textured, NOT dark. "
            "Warm golden ambient light fills the entire scene, just as bright as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No text, no legible letters, no numbers anywhere."
        ),
    },
    "day_3": {
        "filename": "rebirth_day_3.png",
        "prompt": (
            "SUBJECT: A large, colourful hand-sewn pillow made from repurposed floral-patterned fabric — small pastel flowers on a warm cream/tan background. "
            "The pillow is plump and centred, roughly the same size as the guitar in the reference — filling 60–70% of the inner frame. "
            "Visible hand-stitched seams run along the edges. The pillow rests on a simple wooden surface. "
            "The floral fabric is BRIGHT and COLOURFUL — warm pinks, yellows, and greens — contrasting beautifully with the stone wall behind it. "
            "The background is the same warm medium-grey stone brick wall as the reference — clearly lit and textured. "
            "Warm golden ambient light fills the whole scene evenly, as bright as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No text, no legible letters, no numbers anywhere."
        ),
    },
    "day_4": {
        "filename": "rebirth_day_4.png",
        "prompt": (
            "SUBJECT: A large handmade cardboard sign leaning against the stone wall. The sign has a crude wi-fi arc symbol drawn on it in marker, "
            "and two lines of squiggly handwriting below — rendered as abstract wavy marks, NOT legible text. "
            "Beside the sign sits a single sunflower with a drooping head, its yellow petals bright and vivid, glowing with warm golden light — "
            "as large and vibrant as the sunflower in the reference image. "
            "The cardboard is a warm tan-brown colour and the sunflower yellow is the visual centrepiece, matching the brightness of the reference. "
            "The background is the same warm medium-grey stone brick wall as the reference — well-lit, clearly textured, NOT dark. "
            "Warm golden ambient light fills the whole scene evenly, as bright and warm as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No legible text, no letters, no numbers anywhere."
        ),
    },
    "day_5": {
        "filename": "rebirth_day_5.png",
        "prompt": (
            "SUBJECT: A glowing makeshift night lamp — a translucent white/cream plastic bag loosely wrapped around a short cylindrical tube or bottle, "
            "standing upright and centred in the frame, roughly as large as the guitar in the reference. "
            "The bag glows with a bright warm amber-gold light from within, like a paper lantern — its glow is BRIGHT and WARM, not dim. "
            "The warm amber glow illuminates the scene generously, spreading golden light across the stone wall behind it. "
            "The background is the same warm medium-grey stone brick wall as the reference — clearly visible and textured, NOT dark. "
            "The overall scene is warm and bright, filled with golden ambient light — matching the brightness level of Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No legible text, no letters, no numbers anywhere."
        ),
    },
    "day_6": {
        "filename": "rebirth_day_6.png",
        "prompt": (
            "SUBJECT: A pot of blooming pink hyacinths sitting on a wooden surface, with a small restored teddy bear leaning against it. "
            "The hyacinths are vibrant pink-purple with lush green leaves, filling the centre of the frame. "
            "The teddy bear is small, patched with visible stitching — a warm brown colour, lovingly repaired. "
            "A few small wrapped Christmas presents with red ribbons sit nearby, adding festive warmth. "
            "The background is the same warm medium-grey stone brick wall as the reference — well-lit, clearly textured, NOT dark. "
            "Warm golden ambient light fills the entire scene, as bright as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No text, no legible letters, no numbers anywhere."
        ),
    },
    "day_7": {
        "filename": "rebirth_day_7.png",
        "prompt": (
            "SUBJECT: A collection of rescued old objects arranged artfully on a wooden table — a small vintage clock, a chipped ceramic vase with a single flower, "
            "and a worn leather-bound book, all showing signs of age but lovingly cleaned and displayed. "
            "The objects fill the centre of the frame, roughly the same size as the guitar in the reference. "
            "Each item has a subtle warm glow, suggesting new life and purpose. "
            "The background is the same warm medium-grey stone brick wall as the reference — well-lit, clearly textured, NOT dark. "
            "Warm golden ambient light fills the entire scene, as bright as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No text, no legible letters, no numbers anywhere."
        ),
    },
    "day_8": {
        "filename": "rebirth_day_8.png",
        "prompt": (
            "SUBJECT: A whimsical handmade hot air balloon wall decoration, crafted from repurposed materials — the balloon envelope is made from colourful patchwork fabric "
            "in pastel blues, pinks, and yellows, with a tiny woven basket hanging below on thin strings. "
            "The balloon appears to float upward in the frame, filling 60-70% of the inner area. "
            "It has a dreamy, ethereal quality — light and hopeful. Small sparkles or golden dust motes float around it. "
            "The background is the same warm medium-grey stone brick wall as the reference — well-lit, clearly textured, NOT dark. "
            "Warm golden ambient light fills the entire scene, as bright as Day 1. "
            "Subtle hanging vines on the left and right inner edges, same as reference. "
            "No text, no legible letters, no numbers anywhere."
        ),
    },
}
REBIRTH_IMAGE_BASE_PROMPT = """
Generate a square pixel art illustration for the game's 'FSM 30-Day Rebirth Challenge' that EXACTLY matches the brightness, colour palette, and composition of the provided Day 1 reference image.

CRITICAL — match the reference image in every way:
- BRIGHTNESS: The reference is BRIGHT and WARM overall. The stone-wall background is clearly visible as a medium warm-grey — NOT dark, NOT black, NOT a dungeon. The entire scene is well-lit with ambient golden-warm light filling the whole frame.
- COLOUR PALETTE: Warm golden-browns dominate (like the wooden frame and the guitar body in the reference). The background stone bricks are a mid-tone warm grey, visible and textured. Rich warm amber/gold tones throughout.
- SUBJECT SIZE: The central object must be LARGE — filling roughly 60–70% of the inner frame area, just as the guitar fills Day 1. Do not make the subject small.
- COMPOSITION: The subject is centred inside a weathered dark-brown wooden frame with glowing orange/amber runic characters on all four sides — top, bottom, left, right — identical to the reference. Subtle hanging vines or roots appear on the left and right inner edges, exactly as in the reference.
- LIGHTING: Warm ambient light illuminates the whole scene evenly. There is NO spotlight-in-darkness effect. The background is lit, not shadowed into blackness.
- STYLE: High-quality pixel art, same pixel density and rendering style as the reference.
- No legible text, UI elements, letters, or numbers in the final image.
""".strip()
def extract_generated_image(response: object, debug: bool = False) -> PIL.Image.Image:
    if debug:
        print(f"  [debug] response type={type(response).__name__}")
        cands = getattr(response, "candidates", None)
        print(
            f"  [debug] candidates={cands!r}"
            if cands is None
            else f"  [debug] {len(cands)} candidate(s)"
        )
    candidates = getattr(response, "candidates", None) or []
    for candidate in candidates:
        content = getattr(candidate, "content", None)
        parts = getattr(content, "parts", None) or []
        image = _extract_image_from_parts(parts, debug=debug)
        if image is not None:
            return image
    parts = getattr(response, "parts", None) or []
    image = _extract_image_from_parts(parts, debug=debug)
    if image is not None:
        return image
    raise RuntimeError("The model response did not contain an inline image payload.")
def _extract_image_from_parts(parts, debug: bool = False) -> PIL.Image.Image | None:
    for part in parts:
        inline_data = getattr(part, "inline_data", None)
        if inline_data is None:
            continue
        data = getattr(inline_data, "data", None)
        if not data:
            continue
        mime_type = getattr(inline_data, "mime_type", "<unknown>")
        if debug:
            data_repr = (
                repr(data[:64]) if isinstance(data, (bytes, str)) else repr(data)
            )
            print(
                f"  [debug] inline_data mime_type={mime_type!r} "
                f"data type={type(data).__name__} "
                f"len={len(data)} first64={data_repr}"
            )
        if isinstance(data, str):
            candidates = [base64.b64decode(data)]
        else:
            try:
                b64_decoded = base64.b64decode(data)
            except Exception:
                b64_decoded = None
            candidates = [data] if b64_decoded is None else [data, b64_decoded]
        for raw_bytes in candidates:
            try:
                with io.BytesIO(raw_bytes) as buffer:
                    img = PIL.Image.open(buffer)
                    img.load()  
                    return img.copy()
            except Exception as exc:
                if debug:
                    print(f"  [debug] PIL failed on candidate: {exc}")
                continue
    return None
def parse_args() -> argparse.Namespace:
    repo_root = Path(__file__).resolve().parent
    default_blank_bg = (
        repo_root
        / "1.Codebase"
        / "src"
        / "assets"
        / "rebirth_challenge"
        / "rebirth_day_1.png"
    )
    default_output_dir = (
        repo_root / "1.Codebase" / "src" / "assets" / "rebirth_challenge"
    )
    parser = argparse.ArgumentParser(
        description="Generate rebirth challenge illustrations using Day 1 as reference."
    )
    parser.add_argument("--blank-bg", type=Path, default=default_blank_bg)
    parser.add_argument("--output-dir", type=Path, default=default_output_dir)
    parser.add_argument("--model", default=DEFAULT_MODEL)
    parser.add_argument("--api-key", default=DEFAULT_API_KEY)
    parser.add_argument("--api-endpoint", default=DEFAULT_API_ENDPOINT)
    parser.add_argument("--day-id", default=None)
    parser.add_argument("--skip-existing", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--parallel", type=int, default=2)
    parser.add_argument(
        "--debug",
        action="store_true",
        help="Print raw response structure and inline_data details for each request.",
    )
    return parser.parse_args()
def generate_rebirth_images(args: argparse.Namespace) -> int:
    blank_bg_path = args.blank_bg.resolve()
    output_dir = args.output_dir.resolve()
    if not blank_bg_path.is_file():
        print(f"Reference image not found: {blank_bg_path}", file=sys.stderr)
        return 1
    if args.day_id:
        day_ids = [d.strip() for d in args.day_id.split(",")]
        unknown = [d for d in day_ids if d not in REBIRTH_IMAGES]
        if unknown:
            print(f"Unknown day ID(s): {', '.join(unknown)}", file=sys.stderr)
            return 1
        targets = {d: REBIRTH_IMAGES[d] for d in day_ids}
    else:
        targets = REBIRTH_IMAGES
    print(f"Generating rebirth images using reference: {blank_bg_path}")
    client = genai.Client(
        api_key=args.api_key,
        http_options={"base_url": args.api_endpoint},
    )
    ref_img = PIL.Image.open(blank_bg_path)
    output_dir.mkdir(parents=True, exist_ok=True)
    def process_day(day_id, info):
        dest = output_dir / info["filename"]
        if args.skip_existing and dest.exists():
            return "skipped"
        full_prompt = f"{REBIRTH_IMAGE_BASE_PROMPT}\n\n{info['prompt']}"
        print(f"Generating {day_id}...")
        try:
            response = client.models.generate_content(
                model=args.model,
                contents=[full_prompt, ref_img],
            )
            img = extract_generated_image(response, debug=args.debug)
            img.save(dest, format="PNG")
            return "success"
        except Exception as e:
            print(f"Failed {day_id}: {e}")
            return "failed"
    with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as executor:
        results = list(executor.map(lambda x: process_day(*x), targets.items()))
    print(
        f"Finished. Success: {results.count('success')}, Failed: {results.count('failed')}"
    )
    return 0
if __name__ == "__main__":
    raise SystemExit(generate_rebirth_images(parse_args()))
