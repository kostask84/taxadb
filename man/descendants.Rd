% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/descendants.R
\name{descendants}
\alias{descendants}
\title{Get all members (descendants) of a given rank level}
\usage{
descendants(name = NULL, rank = NULL, id = NULL,
  authority = KNOWN_AUTHORITIES, collect = TRUE, db = td_connect())
}
\arguments{
\item{name}{taxonomic name (e.g. "Aves")}

\item{rank}{taxonomic rank name.}

\item{id}{alternately users can provide a vector of species ids.
IDs must be prefixed matching the requested authority.  See \code{id}
column returned by most \code{taxadb} functions for examples.}

\item{authority}{from which authority should the hierachy be returned?
Default is 'itis'.}

\item{collect}{logical, default \code{TRUE}. Should we return an in-memory
data.frame (default, usually the most convenient), or a reference to
lazy-eval table on disk (useful for very large tables on which we may
first perform subsequent filtering operations.)}

\item{db}{a connection to the taxadb database. See details.}
}
\value{
a data.frame with id and name of all matching species
}
\description{
Get all members (descendants) of a given rank level
}
