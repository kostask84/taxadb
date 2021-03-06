% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/td_connect.R
\name{td_connect}
\alias{td_connect}
\title{Connect to the taxadb database}
\usage{
td_connect(dbdir = rappdirs::user_data_dir("taxadb"))
}
\arguments{
\item{dbdir}{Path to the database.}
}
\value{
Returns a \code{src_dbi} connection to the database
}
\description{
Connect to the taxadb database
}
\details{
Primarily useful when a lower-level interface to the
database is required.  Most \code{taxadb} functions will connect
automatically without the user needing to call this function.
}
\examples{
\dontrun{

db <- connect_db()

}
}
