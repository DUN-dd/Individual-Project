import re
from pathlib import Path
tex_path = Path(r'C:\Users\dunc4\Documents\GitHub\Individual-Project\2.Report\Final_Report.tex')
md_path = Path(r'C:\Users\dunc4\Documents\GitHub\Individual-Project\2.Report\Final_Report.md')
text = tex_path.read_text(encoding='utf-8')
start = text.find(r'\\begin{document}')
if start != -1:
    text = text[start + len(r'\\begin{document}'):]
end = text.find(r'\\end{document}')
if end != -1:
    text = text[:end]
lines = []
for line in text.splitlines():
    if re.match(r'^\\s*%', line):
        continue
    lines.append(line)
text = '\n'.join(lines)
def repl_lst(m):
    caption = m.group(1).strip()
    body = m.group(2).strip('\n')
    return f'```\n{body}\n```\n\n*Code: {caption}*\n'
text = re.sub(r'\\\\begin\\{lstlisting\\}\\[caption=\\{(.*?)\\}\\](.*?)\\\\end\\{lstlisting\\}', repl_lst, text, flags=re.S)
for k, v in {
    r'\\begin{titlepage}':'', r'\\end{titlepage}':'',
    r'\\begin{multicols}{2}':'', r'\\end{multicols}':'',
    r'\\begin{center}':'', r'\\end{center}':'',
    r'\\begin{figure}[H]':'', r'\\end{figure}':'',
    r'\\begin{subfigure}[b]{0.3\\linewidth}':'', r'\\begin{subfigure}[b]{0.18\\linewidth}\\centering':'',
    r'\\end{subfigure}':'', r'\\centering':'', r'\\hfill':'',
    r'\\clearpage':'', r'\\newpage':'', r'\\tableofcontents':'',
    r'\\pagenumbering{arabic}':'', r'\\setcounter{page}{1}':''
}.items():
    text = text.replace(k, v)
text = re.sub(r'\\\\includegraphics\\[(.*?)\\]\\{(.*?)\\}', r'![image](\\2)', text)
text = re.sub(r'\\\\caption\\*\\{(.*?)\\}', r'*\\1*', text, flags=re.S)
text = re.sub(r'\\\\caption\\{(.*?)\\}', r'*Figure: \\1*', text, flags=re.S)
text = re.sub(r'\\\\label\\{.*?\\}', '', text)
text = re.sub(r'\\\\section\\*\\{(.*?)\\}', r'# \\1', text)
text = re.sub(r'\\\\section\\{(.*?)\\}', r'# \\1', text)
text = re.sub(r'\\\\subsection\\*\\{(.*?)\\}', r'## \\1', text)
text = re.sub(r'\\\\subsection\\{(.*?)\\}', r'## \\1', text)
text = re.sub(r'\\\\subsubsection\\*\\{(.*?)\\}', r'### \\1', text)
text = re.sub(r'\\\\subsubsection\\{(.*?)\\}', r'### \\1', text)
text = text.replace(r'\\begin{itemize}', '').replace(r'\\end{itemize}', '')
text = text.replace(r'\\begin{enumerate}', '').replace(r'\\end{enumerate}', '')
text = re.sub(r'^\\s*\\\\item\\s+', '- ', text, flags=re.M)
text = text.replace(r'\\begin{tabular}{rl}', '').replace(r'\\end{tabular}', '')
text = text.replace('&', ' | ')
text = text.replace(r'\\\\', '\n')
for _ in range(6):
    text = re.sub(r'\\\\texttt\\{([^{}]*)\\}', r'`\\1`', text)
    text = re.sub(r'\\\\textbf\\{([^{}]*)\\}', r'**\\1**', text)
    text = re.sub(r'\\\\textit\\{([^{}]*)\\}', r'*\\1*', text)
    text = re.sub(r'\\\\emph\\{([^{}]*)\\}', r'*\\1*', text)
    text = re.sub(r'\\\\url\\{([^{}]*)\\}', r'<\\1>', text)
text = re.sub(r'\\\\(ref|cite|citep|citet)\\{([^{}]*)\\}', r'\\2', text)
text = re.sub(r'\\\\hspace\\{[^}]*\\}', '', text)
text = re.sub(r'\\\\vspace\\*?\\{[^}]*\\}', '', text)
text = re.sub(r'\\\\multicolumn\\{[^}]*\\}\\{[^}]*\\}\\{([^{}]*)\\}', r'\\1', text)
text = re.sub(r'\\\\[a-zA-Z]+(?:\\[[^\\]]*\\])?\\{([^{}]*)\\}', r'\\1', text)
text = re.sub(r'\\\\[a-zA-Z]+', '', text)
text = text.replace(r'\\%', '%').replace(r'\\_', '_').replace(r'\\&', '&').replace(r'\\$', '$')
text = text.replace(r'\\#', '#').replace(r'\\{', '{').replace(r'\\}', '}')
text = text.replace('~', ' ').replace('---', '-').replace('--', '-')
text = text.replace('`<!-- -->`{=html}', '')
text = re.sub(r'\n{3,}', '\n\n', text)
text = re.sub(r'[ \t]+\n', '\n', text)
text = re.sub(r'\n\s+\n', '\n\n', text)
text = text.strip() + '\n'
md_path.write_text(text, encoding='utf-8')
print(f'Wrote {md_path} with {len(text)} chars')
