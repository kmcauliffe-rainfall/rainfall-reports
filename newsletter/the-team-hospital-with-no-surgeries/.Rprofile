# Source from each report folder's .Rprofile (see README).
.d <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
for (i in 1:6) {
  if (file.exists(file.path(.d, "renv.lock"))) {
    Sys.setenv(RENV_PROJECT = .d)
    source(file.path(.d, "renv/activate.R"))
    break
  }
  parent <- dirname(.d)
  if (identical(parent, .d)) break
  .d <- parent
}
