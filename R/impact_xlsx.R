# Minimal XLSX reader (same approach as repo R/06_cms_roster.R).

read_xlsx_grid <- function(path, sheet = 1L) {
  exdir <- file.path(tempdir(), paste0("xlsx-", as.integer(Sys.time())))
  on.exit(unlink(exdir, recursive = TRUE), add = TRUE)
  utils::unzip(path, exdir = exdir)

  shared <- character()
  shared_path <- file.path(exdir, "xl", "sharedStrings.xml")
  if (file.exists(shared_path)) {
    doc <- xml2::read_xml(shared_path)
    xml2::xml_ns_strip(doc)
    shared <- vapply(
      xml2::xml_find_all(doc, "//si"),
      function(node) paste0(xml2::xml_text(xml2::xml_find_all(node, ".//t")), collapse = ""),
      character(1)
    )
  }

  sheet_path <- file.path(exdir, "xl", "worksheets", paste0("sheet", sheet, ".xml"))
  doc <- xml2::read_xml(sheet_path)
  xml2::xml_ns_strip(doc)

  grid <- list()
  for (c in xml2::xml_find_all(doc, "//c")) {
    ref <- xml2::xml_attr(c, "r")
    v <- xml2::xml_find_first(c, "v")
    if (inherits(v, "xml_missing")) next
    val <- xml2::xml_text(v)
    if (!is.na(xml2::xml_attr(c, "t")) && xml2::xml_attr(c, "t") == "s") {
      val <- shared[as.integer(val) + 1L]
    }
    grid[[ref]] <- val
  }
  grid
}

cell <- function(grid, col, row) {
  grid[[paste0(col, row)]]
}

read_team_roster_xlsx <- function(path) {
  grid <- read_xlsx_grid(path, 1L)
  header_row <- NA_integer_
  for (r in 1:20) {
    for (col in LETTERS[1:9]) {
      if (identical(cell(grid, col, r), "Hospital CCN")) {
        header_row <- r
        break
      }
    }
    if (!is.na(header_row)) break
  }
  if (is.na(header_row)) stop("TEAM list: no Hospital CCN header")
  r <- header_row + 1L
  out <- list()
  while (!is.null(cell(grid, "B", r)) && nzchar(cell(grid, "B", r))) {
    out[[length(out) + 1L]] <- list(
      participation = cell(grid, "A", r),
      ccn = cell(grid, "B", r),
      hospital = cell(grid, "C", r),
      cbsa_code = cell(grid, "D", r),
      cbsa = cell(grid, "E", r),
      state = cell(grid, "F", r)
    )
    r <- r + 1L
  }
  dplyr::bind_rows(out)
}

read_cjrx_roster_xlsx <- function(path) {
  grid <- read_xlsx_grid(path, 1L)
  ccns <- character()
  for (ref in names(grid)) {
    val <- grid[[ref]]
    if (grepl("^[0-9]{5,6}$", val)) ccns <- c(ccns, val)
  }
  unique(ccns)
}

read_target_prices <- function(path) {
  grid <- read_xlsx_grid(path, 2L)
  rows <- list()
  r <- 11L
  while (!is.null(cell(grid, "C", r))) {
    drg <- cell(grid, "C", r)
    tp <- suppressWarnings(as.numeric(cell(grid, "I", r)))
    if (!is.na(tp)) rows[[length(rows) + 1L]] <- tibble::tibble(drg = as.character(drg), target_price = tp)
    r <- r + 1L
  }
  dplyr::bind_rows(rows)
}
