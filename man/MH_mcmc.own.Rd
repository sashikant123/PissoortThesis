% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/BayesFunc.R
\name{MH_mcmc.own}
\alias{MH_mcmc.own}
\title{Metropolis-Hastings algorithm for GEV}
\usage{
MH_mcmc.own(start, varmat.prop, data = max_years$data, iter = 2000,
  burnin = ceiling(iter/2 + 1))
}
\arguments{
\item{start}{numeric vector of length 3 containing the starting values for the parameters theta=
(location, LOG-scale and shape). It is advised explore different ones, and typically take the MPLE}

\item{varmat.prop}{The proposal's variance : controlling the cceptance rate.
To facilitate convergence, it
is advised to target an acceptance rate of around 0.25 when all components of theta are updated
simultaneously, and 0.40 when the components are updated one at a time.}

\item{data}{numeric vector containing the GEV in block-maxima}

\item{iter}{The number of iterations of the algorithm. Must e high enough to ensure convergence}
}
\value{
A named list containing
\describe{
\item{\code{mean.acc_rates} : the mean of the acceptance rates}
\item{\code{out.chain} : The generated chain}
}
}
\description{
When the parameter \code{start} is of length 2, the computations are automaically
made for a Gumbel model.
}
\examples{
data("max_years")
fn <- function(par, data) -log_post0(par[1], par[2], par[3], data)
param <- c(mean(max_years$df$Max),log(sd(max_years$df$Max)), 0.1 )
# opt <- optim(param, fn, data = max_years$data,
#              method="BFGS", hessian = TRUE)
opt <- nlm(fn, param, data = max_years$data,
           hessian=T, iterlim = 1e5)
start <- opt$estimate
Sig <- solve(opt$hessian)
ev <- eigen( (2.4/sqrt(2))^2 * Sig)
varmat <- ev$vectors \%*\% diag(sqrt(ev$values)) \%*\% t(ev$vectors)
# (MH)
set.seed(100)
mh.mcmc1 <- MH_mcmc.own(start, varmat \%*\% c(.1,.3,.4))
}
\author{
Antoine Pissoort, \email{antoine.pissoort@student.uclouvain.be}
}
