"""Run the R reference implementations in R/ and report failures.

    python scripts/run_r.py                 # every script
    python scripts/run_r.py sir-model bass-model --show   # some, with output

Each script runs in a temporary folder (so base-graphics output goes to a
throwaway Rplots.pdf). Rscript is found on the PATH, at RSCRIPT, or in the
usual Windows install folder.
"""

import argparse
import concurrent.futures
import glob
import os
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def find_rscript():
    if os.environ.get("RSCRIPT"):
        return os.environ["RSCRIPT"]
    if shutil.which("Rscript"):
        return shutil.which("Rscript")
    found = sorted(glob.glob(r"C:\Program Files\R\R-*\bin\Rscript.exe"))
    if found:
        return found[-1]
    sys.exit("Rscript not found. Put it on the PATH or set RSCRIPT.")


def run(rscript, path):
    tmp = tempfile.mkdtemp(prefix="run-r-")
    try:
        p = subprocess.run([rscript, "--vanilla", path], cwd=tmp, capture_output=True, text=True,
                           encoding="utf-8", errors="replace", timeout=600)
        return p.returncode, p.stdout + p.stderr
    except subprocess.TimeoutExpired:
        return 1, "timed out"
    finally:
        shutil.rmtree(tmp, ignore_errors=True)


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("slugs", nargs="*")
    ap.add_argument("--show", action="store_true", help="print each script's output")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    rscript = find_rscript()
    paths = [os.path.join(ROOT, "R", f"{s}.R") for s in args.slugs] or sorted(glob.glob(os.path.join(ROOT, "R", "*.R")))
    bad = 0
    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as pool:
        results = {p: pool.submit(run, rscript, p) for p in paths}
        for p in paths:
            code, out = results[p].result()
            name = os.path.basename(p)
            if code:
                bad += 1
                print(f"FAIL {name}\n{out.strip()[-1500:]}")
            else:
                print(f"ok   {name}")
                if args.show:
                    print("     " + out.strip().replace("\n", "\n     "))
    print(f"{len(paths)} scripts run, {bad} failed")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
