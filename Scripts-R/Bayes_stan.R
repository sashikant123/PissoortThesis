#setwd('/home/piss/Documents/Extreme/R resources/IRM')
# load("C:\\Users\\Piss\\Documents\\LINUX\\Documents\\Extreme\\R resources\\IRM\\data1.RData")
# setwd("C:\\Users\\Piss\\Documents\\LINUX\\PissoortRepo\\PissoortThesis\\stan")
#setwd('/home/piss/PissoortRepo/PissoortThesis/stan')
# load("/home/piss/Documents/Extreme/R resources/IRM/data1.Rdata")
repo <- '/home/proto4426/Documents/Thesis/PissoortThesis/stan/'

library("rstantools")

options(mc.cores=parallel::detectCores()) # all available cores
# can be used without needing to manually specify the cores argument.

library("rstan")
library(bayesplot)
library(mvtnorm)

library(PissoortThesis)
data('max_years')

#######
fn <- function(par, data) -log_post0(par[1], par[2], par[3], data)
param <- c(mean(max_years$df$Max),log(sd(max_years$df$Max)), 0.1 )
opt <- nlm(fn, param, data = max_years$data,
           hessian=T, iterlim = 1e5)

start0 <- list() ;  k <- 1
while(k < 2) { # starting value is randomly selected from a distribution
  # that is overdispersed relative to the target
  sv <- as.numeric(rmvnorm(1, opt$estimate, 50 * solve(opt$hessian)))
  svlp <- log_post0(sv[1], sv[2], sv[3], max_years$data)
  if(is.finite(svlp)) {
    start0[[k]] <- as.list(sv) ;  names(start0[[k]]) <- c("mu", "logsig","xi")
    k <- k + 1
  }
}

# ## Change logsig in sigma (for some models)
# for(i in 1:(k-1)){
#   start0[[i]]$sigma <- exp(start0[[i]]$logsig)
#   #start[[i]] <-
#   }

fit_stan <- stan(file = paste0(repo,'gev.stan',collapse = ""),
                  data = list(n = length(max_years$data), y = max_years$data),
                 iter = 2000, chains = 1, warmup = 500, init = rev(start0),
                 cores = 8, control = list(adapt_delta = .9,
                                           max_treedepth = 15))
fit_stan
summary(fit_stan)
pairs(fit_stan)
sampler_par <- get_sampler_params(fit_stan, inc_warmup = TRUE)
summary(do.call(rbind, sampler_par), digits = 2)
lapply(sampler_par, summary, digits = 2)

lookup(Inf)

fit_summary <- summary(fit_stan)
## Traceplot
arrayfit <- as.array(fit_stan)
arrayfit[["iterations"]] <- 501:2000
dimnames(arrayfit)[[1]]

color_scheme_set("darkgray")

g_xi <- mcmc_trace(arrayfit, pars = "xi", size = 0.5) +
  geom_vline(xintercept = 1500, col = "red",
             linetype = "dashed", size = 0.6) +
  geom_hline(aes(yintercept = unname(fit_summary$summary[2,1])),
             col = "green",
             linetype = "dashed", size = .7)

g_logsig <- mcmc_trace(arrayfit, pars = "logsig", size =0.5) +
  geom_vline(xintercept = 1500, col = "red",
             linetype = "dashed", size = 0.6) +
  geom_hline(aes(yintercept = unname(fit_summary$summary[1,1])),
             col = "green",
             linetype = "dashed", size = .7)

g_mu <- mcmc_trace(arrayfit, pars = "mu", size = 0.5) +
  geom_vline(xintercept = 1500, col = "red",
             linetype = "dashed", size = 0.6) +
  geom_hline(aes(yintercept = unname(fit_summary$summary[3,1])),
             col = "green",
             linetype = "dashed", size = .7)

## To Compare chains with Gibbs sampler and MH
plots_hmc <- grid.arrange(g_mu, g_logsig, g_xi, ncol = 1,
             top = textGrob("Using Hamiltonian Monte Carlo",
                            gp = gpar(col ="darkolivegreen4",
                                      fontsize = 25, font = 4)))



##### Nonstationary Model with Linear trend
##########################################"
data <- max_years$data


fn <- function(par, data) -log_post1(par[1], par[2], par[3],
                                     par[4],rescale.time = T, data)
param <- c(mean(max_years$df$Max), 0, log(sd(max_years$df$Max)), -0.1 )
opt <- optim(param, fn, data = max_years$data,
             method = "BFGS", hessian = T)

tt <- ( min(max_years$df$Year):max(max_years$df$Year) -
          mean(max_years$df$Year) ) / length(max_years$data)
start <- list() ; k <- 1
while(k < 5) {
  sv <- as.numeric(rmvnorm(1, opt$par, 50 * solve(opt$hessian)))
  svlp <- log_post1(sv[1], sv[2], sv[3], sv[4], max_years$data)
  print(svlp)
  if(is.finite(svlp)) {
    start[[k]] <- sv;  names(start[[k]]) <- c("mu0", "mu1", "sigma","xi")
    k <- k + 1
  }
}

fit_lin <- stan(file = paste0(repo, 'gev_lin.stan'),
                data = list(n = length(max_years$data),
                            y = max_years$data, tt = tt),
              #init=start,
              iter = 2000, chains = 4, warmup = 100, cores = 8,
               control = list(adapt_delta = .99))
fit_lin
sampler_params <- get_sampler_params(fit_lin, inc_warmup = TRUE)
summary(do.call(rbind, sampler_params), digits = 2)
lapply(sampler_params, summary, digits = 2)





############# Diagnostics + visualization with bayesplot package

library(bayesplot) # Mainly for use with Stan


mcmc_intervals(param.chain, pars = c("logsig", "xi"))
# Bring back mu
mcmc_areas(
  param.chain,
  pars = c("mu1", "logsig", "xi"),
  prob = 0.9, # 80% intervals
  prob_outer = 0.99, # 99%
  point_est = "mean"
)
color_scheme_set("brightblue")
grid.arrange( mcmc_dens(param.chain, pars = c("mu", "mu1")),
              mcmc_dens(param.chain, pars = c("logsig", "xi")),
              nrow = 2)
str(gibbs.trend$out.ind)
str(param.chain)
un.out <- unlist(gibbs.trend$out.ind,use.names = T, recursive = F)
matrix(unlist(gibbs.trend$out.ind), ncol = 4, byrow = F)
unlst <- do.call(rbind, gibbs.trend$out.ind )

array.post <- array(unlist(t(gibbs.trend$out.ind)), dim = c(4000/4+1, 4, 3 ))
# dimnames = list(c(NULL,
#           c("mu", "mu1", "logsig", "xi"),
#           c("chain:1", "chain:2", "chain:3", "chain:4"))))
dim(array.post)
dimnames(array.post) <- list(iterations = NULL,
                             parameters = c("mu", "mu1", "logsig", "xi"),
                             chains = c("chain:1", "chain:2", "chain:3"))

array.post <- aperm(array.post, perm = c("iterations", "chains", "parameters"))
dimnames(array.post)
str(array.post)
color_scheme_set("green")
mcmc_hist_by_chain( array.post,
                    pars = c("mu", "mu1", "logsig", "xi"))


mcmc_dens_overlay(array.post, pars = c("mu", "mu1"))


color_scheme_set("mix-blue-red")
mcmc_trace(posterior, pars = c("wt", "sigma"),
           facet_args = list(ncol = 1, strip.position = "left"))
