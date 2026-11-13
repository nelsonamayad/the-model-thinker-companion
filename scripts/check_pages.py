"""Load rendered pages in headless Chrome and fail on runtime errors.

    quarto render
    python scripts/check_pages.py                          # every page in _site/
    python scripts/check_pages.py _site models/sir-model.html index.html
    python scripts/check_pages.py --readouts _site models/sir-model.html

`quarto render` only checks OJS syntax. A misspelled helper, a bad Plot
option, a missing CSV or a broken import shows up only when the page runs in
a browser, as a red error box (class "observablehq--error"). This script
serves the site on a local port, loads each page in headless Chrome, lets the
simulations run, and checks that:

  - no page shows an OJS error box
  - every model page (models/*.html) drew at least one labelled chart
    (an <svg> or <canvas> with an aria-label)

--readouts also prints the text under each chart, to check what the default
settings show. Set CHROME to the browser binary if it isn't found. Adapted
from the sibling project's script (gelman-lexicon).
"""

import argparse
import concurrent.futures
import functools
import glob
import http.server
import os
import re
import shutil
import socketserver
import subprocess
import sys
import tempfile
import threading

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
CHART = re.compile(r"<(?:svg|canvas)[^>]*aria-label=")


def find_chrome():
    if os.environ.get("CHROME"):
        return os.environ["CHROME"]
    for name in ["google-chrome", "google-chrome-stable", "chromium", "chromium-browser", "chrome"]:
        path = shutil.which(name)
        if path:
            return path
    for path in [r"C:\Program Files\Google\Chrome\Application\chrome.exe",
                 r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
                 "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"]:
        if os.path.exists(path):
            return path
    sys.exit("Chrome not found. Set the CHROME environment variable to the browser binary.")


class QuietHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, *args):
        pass


def text_of(html):
    return re.sub(r"\s+", " ", re.sub(r"<[^>]+>", "", html)).strip()


def check_page(chrome, base, page, budget):
    """Return (problems, readouts) for one page."""
    is_entry = page.startswith("models/")
    dom = ""
    for _ in range(3):  # a slow first load sometimes dumps the page before OJS runs
        profile = tempfile.mkdtemp(prefix="check-pages-")
        try:
            dom = subprocess.run(
                [chrome, "--headless=new", "--disable-gpu", "--no-sandbox", "--no-first-run",
                 f"--user-data-dir={profile}", f"--virtual-time-budget={budget}", "--dump-dom",
                 f"{base}/{page}"],
                capture_output=True, text=True, encoding="utf-8", errors="replace", timeout=240).stdout
        except subprocess.TimeoutExpired:
            dom = ""
        finally:
            shutil.rmtree(profile, ignore_errors=True)
        loaded = "</html>" in dom and ("observablehq--error" in dom or not is_entry or CHART.search(dom))
        if loaded:
            break
    if not dom:
        return ["page did not load (Chrome timed out or crashed)"], []
    problems = []
    errors = re.findall(r'class="[^"]*observablehq--error[^"]*"[^>]*>(.*?)</', dom, re.S)
    for e in errors[:4]:
        problems.append(f"OJS error: {text_of(e)[:200]}")
    if is_entry and not CHART.search(dom):
        problems.append("no labelled chart was drawn")
    readouts = [text_of(r)[:600] for r in re.findall(r'class="sim-readout">(.*?)</div>', dom, re.S)]
    return problems, readouts


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("site", nargs="?", default=os.path.join(ROOT, "_site"), help="rendered site folder (default: _site)")
    ap.add_argument("pages", nargs="*", help="pages relative to the site folder (default: all)")
    ap.add_argument("--jobs", type=int, default=4, help="pages checked in parallel (default: 4)")
    ap.add_argument("--budget", type=int, default=15000, help="virtual milliseconds each page may run (default: 15000)")
    ap.add_argument("--readouts", action="store_true", help="print the text under each chart")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

    site = os.path.abspath(args.site)
    if not os.path.isdir(site):
        sys.exit(f"{site} not found. Run `quarto render` first.")
    pages = [p.replace(os.sep, "/") for p in args.pages] or sorted(
        os.path.relpath(p, site).replace(os.sep, "/")
        for p in glob.glob(os.path.join(site, "**", "*.html"), recursive=True)
        if "site_libs" not in p)

    server = socketserver.ThreadingTCPServer(("127.0.0.1", 0), functools.partial(QuietHandler, directory=site))
    threading.Thread(target=server.serve_forever, daemon=True).start()
    base = f"http://127.0.0.1:{server.server_address[1]}"
    chrome = find_chrome()

    failed = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=max(1, args.jobs)) as pool:
        futures = {page: pool.submit(check_page, chrome, base, page, args.budget) for page in pages}
        for page in pages:
            problems, readouts = futures[page].result()
            for _ in range(2):  # re-check failures one at a time: a real error fails every time
                if not problems:
                    break
                problems, readouts = check_page(chrome, base, page, args.budget)
            if problems:
                failed += 1
                print(f"FAIL {page}")
                for p in problems:
                    print(f"     {p}")
            elif args.readouts or len(pages) <= 10:
                print(f"ok   {page}")
            if args.readouts:
                for r in readouts:
                    print(f"     > {r}")
    server.shutdown()
    print(f"{len(pages)} pages checked, {failed} with problems")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
