
#' create a local taxonomic database
#'

#' @param authorities a list (character vector) of authorities to be included in the
#'  database. By default, will install `itis`.  See details for a list of recognized
#'  authorities. Use `authorities="all"` to install all available authorities automatically.
#' @param schema format of the database to import.
#' @param lines number of lines that can be safely read in to memory at once. Leave
#' at default or increase for faster importing if you have plenty of spare RAM.
#' @param overwrite Should we overwrite existing tables? Default is `FALSE`.  Change
#'  to "ask" for interactive interface, or `TRUE` to force overwrite (i.e. updating
#'  a local database upon new release.)
#' @param dbdir a location on your computer where the database should be installed.
#'  Defaults to user data directory given by [rappdirs::user_data_dir]().
#' @param db connection to a database.  By default, taxadb will set up its own
#' fast [MonetDBLite::MonetDBLite]() connection.
#' @details
#'  Authorities recognized by taxadb are:
#'  - `itis`: Integrated Taxonomic Information System, <https://www.itis.gov/>
#'  - `ncbi`:  National Center for Biotechnology Information, <https://www.ncbi.nlm.nih.gov/taxonomy>
#'  - `col`: Catalogue of Life, <http://www.catalogueoflife.org/>
#'  - `tpl`: The Plant List, <http://www.theplantlist.org/>
#'  - `gbif`: Global Biodiversity Information Facility, <https://www.gbif.org/>
#'  - `fb` FishBase, <http://fishbase.org>
#'  - `slb`, SeaLifeBase, <http://sealifebase.org>
#'  - `wd`, Wikidata: <https://www.wikidata.org/>
#'  - `ott` OpenTree Taxonomy: <https://github.com/OpenTreeOfLife/reference-taxonomy>
#' @return path where database has been installed (invisibly)
#' @export
#' @importFrom utils download.file
#' @importFrom DBI dbConnect dbDisconnect
#' @importFrom arkdb unark streamable_readr_tsv
#' @importFrom MonetDBLite MonetDBLite
#' @importFrom readr cols
#' @examples \dontrun{
#'   # tmp <- tempdir()
#'   # create_db(authorities = "itis", dbdir = tmp)
#'
#' }
td_create <- function(authorities = "itis",
                      schema = c("dwc"),
                      overwrite = FALSE,
                      lines = 1e6,
                      dbdir =  rappdirs::user_data_dir("taxadb"),
                      db = td_connect(dbdir)
                      ){

  recognized_authorities = KNOWN_AUTHORITIES
  if (authorities == "all") {
    authorities <- recognized_authorities
  }
  stopifnot(all(authorities %in% recognized_authorities))

  ## supports vectorized schema and authorities lists.
  files <- paste0(authorities, ".tsv.bz2")
  dest <- file.path(dbdir, files)

  new_dest <- dest
  new_files <- files

  if (!overwrite) {
    drop <- vapply(dest, file.exists, logical(1))
    new_dest <- dest[!drop]
    new_files <- files[!drop]
  }

  if (length(new_files) >= 1L) {
    ## FIXME eventually these should be Zenodo URLs
    urls <- paste0("https://github.com/cboettig/taxadb/",
                   "releases/download/dwc/",
                   "dwc", ".2f", new_files)

    ## Gabor recommends we drop-in curl::download_file instead here!
    ## or something fancier with curl_fetch_multi
    ## method must be specified for download.file to work w/ vectors
    utils::download.file(urls,
                         new_dest,
                         method = "libcurl",
                         quiet = TRUE)
  }

  ## silence readr progress bar in arkdb
  progress <- getOption("readr.show_progress")
  options(readr.show_progress = FALSE)

  ## silence MonetDBLite complaints about reserved SQL characters
  suppress_msg({
  arkdb::unark(dest,
               db_con = db,
               lines = 1e6,
               streamable_table = arkdb::streamable_readr_tsv(),
               overwrite = overwrite,
               col_types = readr::cols(.default = "c"))
  })

  # reset readr progress bar.
  options(readr.show_progress = progress)

  ## Set id as primary key in each table? automatic in MonetDB
  # lapply(DBI::dbListTables(db$con), function(table)
  # glue::glue("ALTER TABLE {table} ADD PRIMARY KEY ({key});",
  #            table = table, key = "id"))

  invisible(dbdir)
}

