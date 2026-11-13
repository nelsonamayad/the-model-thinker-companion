# Shared nlrx setup for the agent-based experiments in abm/.
#
# Each abm/<slug>.R does:
#   source("abm/_nlrx.R")
#   nl <- nl_model("<slug>")
#   nl@experiment <- experiment(...)   # metrics, variables, constants
#   nl@simdesign <- simdesign_ff(nl, nseeds = 6)
#   save_results(run_experiment(nl), "<slug>", keep = c(...))
#
# Run from the project root: Rscript abm/<slug>.R
# (or python scripts/run_abm.py <slug>). Needs NetLogo 6.4.0; set
# NETLOGO_HOME if it is not in one of the usual places below.

suppressPackageStartupMessages(library(nlrx))

netlogo_home <- function() {
  candidates <- c(
    Sys.getenv("NETLOGO_HOME"),
    file.path(Sys.getenv("LOCALAPPDATA"), "Programs", "NetLogo 6.4.0"),
    "C:/Program Files/NetLogo 6.4.0",
    path.expand("~/NetLogo 6.4.0"),
    "/opt/NetLogo-6.4.0"
  )
  for (p in candidates) {
    if (nzchar(p) && dir.exists(p)) {
      return(normalizePath(p, winslash = "/"))
    }
  }
  stop("NetLogo 6.4.0 not found: install it or set NETLOGO_HOME.")
}

# The Windows build of NetLogo 6.4 bundles a Java runtime without java.exe,
# which the netlogo-headless.bat that nlrx calls expects. NetLogo's own
# headless launcher on Windows is NetLogo_Console.exe --headless, so nlrx is
# given a folder whose netlogo-headless.bat forwards to it.
nl_model <- function(slug, jvmmem = 1024) {
  home <- netlogo_home()
  nlpath <- home
  if (.Platform$OS.type == "windows") {
    nlpath <- file.path(tempdir(), "netlogo-shim")
    dir.create(nlpath, showWarnings = FALSE)
    console <- normalizePath(file.path(home, "NetLogo_Console.exe"),
      winslash = "\\"
    )
    writeLines(
      c("@echo off", sprintf('"%s" --headless %%*', console)),
      file.path(nlpath, "netlogo-headless.bat")
    )
  }
  model <- normalizePath(file.path("abm", paste0(slug, ".nlogo")),
    winslash = "/"
  )
  nl(
    nlversion = "6.4.0", nlpath = nlpath, modelpath = model,
    jvmmem = jvmmem
  )
}

# Run every row of the design with every seed, in parallel R sessions.
run_experiment <- function(nl, workers = NULL) {
  if (is.null(workers)) {
    workers <- max(1, min(8, parallel::detectCores() - 2))
  }
  future::plan(future::multisession, workers = workers)
  on.exit(future::plan(future::sequential), add = TRUE)
  started <- Sys.time()
  results <- run_nl_all(nl)
  message(
    nrow(results), " result rows in ",
    round(as.numeric(difftime(Sys.time(), started, units = "mins")), 1),
    " min"
  )
  results
}

# Tidy the column names ("[step]" -> "step", "percent-similar" ->
# "percent_similar", "random-seed" -> "random_seed"), keep the columns the
# page needs and write data/<slug>.csv.
save_results <- function(results, slug, keep) {
  df <- as.data.frame(results)
  names(df) <- gsub("^\\[|\\]$", "", names(df))
  names(df) <- gsub("[^A-Za-z0-9]+", "_", names(df))
  missing <- setdiff(keep, names(df))
  if (length(missing)) {
    stop("columns not in the results: ", paste(missing, collapse = ", "))
  }
  df <- df[, keep, drop = FALSE]
  dir.create("data", showWarnings = FALSE)
  out <- file.path("data", paste0(slug, ".csv"))
  utils::write.csv(df, out, row.names = FALSE)
  message("wrote ", out, " (", nrow(df), " rows)")
  invisible(df)
}
