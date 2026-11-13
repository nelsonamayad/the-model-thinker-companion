"""Static checks on every model entry. Run before committing:

    python scripts/check_models.py

Checks, for each models/<slug>.qmd:
  - required front matter, a known family, engine and REDCAPE uses
  - the body sections, in order, and a formulation box
  - every Plot.plot starts with ariaLabel and ariaDescription; every
    drawGrid call passes an ariaLabel
  - a readout cell (class "sim-readout")
  - links under "Related models" point to existing entries
  - the reference implementation exists: R/<slug>.R for equation-based
    models; abm/<slug>.nlogo, abm/<slug>.R and data/<slug>.csv for
    agent-based models (and the page reads that CSV)
  - the generated callout and code block are present (run build_site.py)
  - no trace of the book's files (images or EPUB paths)
  - R reference scripts keep lines to 80 characters
"""

import glob
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from build_site import FAMILY, ENGINES, USES, CODE_START, parse_front, read  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SECTIONS = ["## The idea", "## Formulation", "## Interactive model", "## Takeaways", "## Uses",
            "## Related models", "## Sources"]
REQUIRED = ["title", "date", "description", "order", "chapter", "chapter-title", "pages", "family",
            "engine", "tool", "reference", "uses", "categories", "verified"]


def check(path, slugs):
    slug = os.path.splitext(os.path.basename(path))[0]
    text = read(path)
    meta, body, _ = parse_front(text)
    problems = []
    if meta is None:
        return ["no front matter"]
    for k in REQUIRED:
        if k not in meta or meta[k] in ("", []):
            problems.append(f"front matter: missing {k}")
    if meta.get("family") not in FAMILY:
        problems.append(f"unknown family {meta.get('family')!r}")
    if meta.get("engine") not in ENGINES:
        problems.append(f"unknown engine {meta.get('engine')!r}")
    uses = meta.get("uses", [])
    if not isinstance(uses, list) or not uses or any(u not in USES for u in uses):
        problems.append(f"uses must be a list drawn from {USES}")
    pos = [body.find("\n" + s + "\n") for s in SECTIONS]
    for s, p in zip(SECTIONS, pos):
        if p < 0:
            problems.append(f"missing section '{s}'")
    found = [p for p in pos if p >= 0]
    if found != sorted(found):
        problems.append("sections out of order")
    if ".model-box" not in body:
        problems.append("no ::: {.model-box} in Formulation")
    for m in re.finditer(r"Plot\.plot\(\{\s*", body):
        nxt = body[m.end():m.end() + 400]
        if not nxt.startswith("ariaLabel:") or "ariaDescription:" not in nxt:
            problems.append("a Plot.plot does not start with ariaLabel and ariaDescription")
    for m in re.finditer(r"drawGrid\(", body):
        if "ariaLabel" not in body[m.end():m.end() + 300]:
            problems.append("a drawGrid call has no ariaLabel")
    if "sim-readout" not in body:
        problems.append("no readout (sim-readout)")
    rel = body.split("\n## Related models\n", 1)[-1].split("\n## ", 1)[0]
    for target in re.findall(r"\]\(([a-z0-9-]+)\.qmd", rel):
        if target not in slugs:
            problems.append(f"Related models: no entry '{target}'")
    if "book-source" not in body or CODE_START not in body:
        problems.append("generated callout or code block missing: run scripts/build_site.py")
    if re.search(r"OEBPS|Art_P\d|\.epub", body):
        problems.append("references the book's files")
    if meta.get("engine") == "Agent-based":
        for f in [f"abm/{slug}.nlogo", f"abm/{slug}.R", f"data/{slug}.csv"]:
            if not os.path.exists(os.path.join(ROOT, f)):
                problems.append(f"missing {f}")
        if f'FileAttachment("../data/{slug}.csv")' not in body:
            problems.append(f"page does not read data/{slug}.csv")
    else:
        rp = os.path.join(ROOT, "R", f"{slug}.R")
        if not os.path.exists(rp):
            problems.append(f"missing R/{slug}.R")
        else:
            for i, line in enumerate(read(rp).split("\n"), 1):
                if len(line) > 80:
                    problems.append(f"R/{slug}.R:{i} longer than 80 characters")
    return problems


def main():
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    paths = sorted(glob.glob(os.path.join(ROOT, "models", "*.qmd")))
    slugs = {os.path.splitext(os.path.basename(p))[0] for p in paths}
    orders = {}
    bad = 0
    for p in paths:
        meta, _, _ = parse_front(read(p))
        if meta and meta.get("order"):
            orders.setdefault(meta["order"], []).append(os.path.basename(p))
        problems = check(p, slugs)
        if problems:
            bad += 1
            print(f"FAIL {os.path.relpath(p, ROOT)}")
            for pr in problems:
                print(f"     {pr}")
    for o, files in orders.items():
        if len(files) > 1:
            bad += 1
            print(f"FAIL order {o} used by {', '.join(files)}")
    print(f"{len(paths)} entries checked, {bad} with problems")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
