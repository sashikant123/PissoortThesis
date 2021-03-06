% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/NeuralNetsFunc.R
\name{gevcdn}
\alias{gevcdn}
\alias{gevcdn.fit2}
\alias{gevcdn.bag2}
\alias{hyp.tan}
\title{Rebuilding of the function from \code{GEVcdn} package}
\usage{
gevcdn.fit2(x, y, iter.max = 1000, n.hidden = 2, Th = gevcdn.logistic,
  fixed = NULL, init.range = c(-0.25, 0.25),
  scale.min = .Machine$double.eps, beta.p = 3.3, beta.q = 2,
  sd.norm = Inf, n.trials = 5, method = c("BFGS", "Nelder-Mead"),
  max.fails = 100, silent = F, ...)

gevcdn.bag2(x, y, iter.max = 1000, iter.step = 10, n.bootstrap = 30,
  n.hidden = 3, Th = gevcdn.logistic, fixed = NULL,
  init.range = c(-0.25, 0.25), scale.min = .Machine$double.eps,
  beta.p = 3.3, beta.q = 2, sd.norm = Inf, method = c("BFGS",
  "Nelder-Mead"), max.fails = 100, silent = TRUE, ...)

hyp.tan(x)
}
\arguments{
\item{x}{covariate matrix with number of rows equal to the number
of samples and number of columns equal to the number of variables.}

\item{y}{column matrix of target values with number of rows equal7
to the # of samples}

\item{sd.norm}{Weight penalty regularization : sd parameter
for normal distribution prior for the magnitude of input-hiddenlayer
 weights; equivalent to weight penalty regularization.#'}
}
\value{
A personalized ggplot2 theme object to add to every builded plots.
}
\description{
this rebuilded version allows us to :
1. Better understand what is going on  and
2. Speed-up function by e.g. reduce unuseful loops or remove printing methods
}
\details{
See other function's details in the GEVcdn package
}
\references{
Cannon, A.J., 2010. A flexible nonlinear modelling framework for nonstationary generalized
extreme value analysis in hydroclimatology. Hydrological Processes, 24: 673-685. DOI: 10.1002/hyp.7506
}
