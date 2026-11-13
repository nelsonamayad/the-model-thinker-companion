"""Run the nlrx experiments in abm/ (NetLogo 6.4 must be installed).

    python scripts/run_abm.py                    # every experiment
    python scripts/run_abm.py schelling-segregation

Each abm/<slug>.R sources abm/_nlrx.R, runs its NetLogo model across the
experiment's parameter values and seeds, and writes data/<slug>.csv. Runs
are slow (one Java start per run); expect minutes per model. Commit the CSVs.
"""

import argparse
import glob
import os
import subprocess
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from run_r import find_rscript  # noqa: E402

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def main():
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("slugs", nargs="*")
    args = ap.parse_args()
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    rscript = find_rscript()
    paths = [os.path.join(ROOT, "abm", f"{s}.R") for s in args.slugs] or sorted(
        p for p in glob.glob(os.path.join(ROOT, "abm", "*.R")) if not os.path.basename(p).startswith("_"))
    bad = 0
    for p in paths:
        print(f"== {os.path.basename(p)}", flush=True)
        r = subprocess.run([rscript, "--vanilla", p], cwd=ROOT)
        if r.returncode:
            bad += 1
            print(f"FAIL {os.path.basename(p)}")
    print(f"{len(paths)} experiments run, {bad} failed")
    sys.exit(1 if bad else 0)


if __name__ == "__main__":
    main()
