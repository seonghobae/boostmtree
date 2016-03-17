\name{boostmtree}
\alias{boostmtree}
\alias{boostmtree}
\title{Boosted multivariate trees for longitudinal data}
\description{
  Multivariate extension of Friedman's (2001) gradient descent boosting
  method to longitudinal data using multivariate tree base
  learners.  Covariate-time interactions are modeled using penalized
  B-splines (P-splines) with estimated adaptive smoothing parameter.
}
\usage{
 boostmtree(x,
   tm,
   id,
   y,
   M = 200,
   nu = 0.05,
   K = 5,
   nknots = 10,
   d = 3,
   pen.ord = 3,
   lambda,
   lambda.max = 1e6,
   lambda.iter = 2,
   importance = FALSE,
   svd.tol = 1e-6,
   forest.tol = 1e-3,
   verbose = TRUE,
   ...)
}
\arguments{
    \item{x}{Data frame (or matrix) containing the x-values.   Rows
      must be duplicated to match the number of time points for an individual.
      That is, if individual \emph{i} has \emph{n[i]} outcome y-values,
      then there must be \emph{n[i]} duplicate rows of \emph{i}'s x-value.}
    \item{tm}{Vector of time values, one entry for each row in \code{x}.}
    \item{id}{Unique subject identifier, one entry for each row in \code{x}.}
    \item{y}{Observed y-value, one entry for each row in \code{x}.}
    \item{M}{Number of boosting iterations}
    \item{nu}{Boosting regularization parameter.  A value in (0,1].}
    \item{K}{Number of terminal nodes used for the multivariate tree learner.}
    \item{nknots}{Number of knots used for the B-spline for modeling the
    time interaction effect.}
    \item{d}{Degree of the piecewise B-spline polynomial (no time
      effect is fit when d < 1).}
    \item{pen.ord}{Differencing order used to define the penalty with
      increasing values implying greater smoothness.}
    \item{lambda}{Smoothing (penalty) parameter used for B-splines with
      increasing values associated with increasing
      smoothness/penalization. If missing, or non-positive, the value is
      estimated adaptively using a mixed models approach.}
    \item{lambda.max}{Tolerance used for adaptively estimated lambda
      (caps it).  For experts only.}
    \item{lambda.iter}{Number of iterations used to estimate lambda
      (only applies when lambda is not supplied and adaptive smoothing
      is employed).}
    \item{importance}{Calculate importance values for the x-variables?
      Currently not implemented (use \command{predict.boostmtree} instead).}
    \item{svd.tol}{Tolerance value used in the SVD calculation of the
      penalty matrix.  For experts only.}
    \item{forest.tol}{Tolerance used for forest weighted least squares
      solution.  Experimental and for experts only.}
    \item{verbose}{Should verbose output be printed?}
    \item{...}{Further arguments passed to or from other methods.}
}
\details{
  Each individual has observed y-values over possibly different time
  points, and with possibly differing number of time points.  Given the
  observed y-values, the time points, and the x-value for each
  individual, the conditional mean time profile of y is estimated using
  gradient boosting in which the gradient is derived from a criterion
  function involving a working variance matrix for y specified as an
  equicorrelation matrix with parameter \emph{rho} multiplied by a
  variance parameter \emph{phi}.  Multivariate trees are used for the
  base learner and weighted least squares are used to approximate the
  matching pursuit optimization.  A mixed-model formulation is used to
  estimate the smoothing parameter associated with the B-splines used
  for the time-interaction effect, although the user can manually set
  the smoothing parameter as well.

  By default, trees are grown from a bootstrap sample of the data --
  thus the boosting method employed here is a modified example of
  stochastic gradient descent boosting (Friedman, 2002).  Stochastic
  descent often improves performance and has the added advantage that
  out-of-sample data (out-of-bag, OOB) can be used to calculate
  variable importance (VIMP).  This feature will be implemented in
  future releases.

   The package implements R-side parallel processing by replacing
  the R function \command{lapply} with \command{mclapply} found in the
  \pkg{parallel} package.  You can set the number of cores accessed by
  \command{mclapply} by issuing the command \command{options(mc.cores =
    x)}, where \command{x} is the number of cores.  The options command
  can also be placed in the users .Rprofile file for convenience.  You
  can, alternatively, initialize the environment variable
  \command{MC_CORES} in your shell environment.

  As an example, issuing the following options command uses all
  available cores for R-side parallel processing:
  
  \command{options(mc.cores=detectCores())}
  
  However, be cautious when setting \command{mc.cores}.  This can create
  not only high CPU usage but also high RAM usage, especially when using
  functions \command{partialPlot} and \command{predict}.
}
\value{
     An object of class \code{(boostmtree, grow)} with the following
     components:

     \item{x}{The x-values, but with only one row per individual
       (i.e. duplicated rows are removed). Values sorted on \code{id}.}
     \item{xvar.names}{X-variable names.}
     \item{time}{List with each component containing the time
       points for a given individual. Values sorted on \code{id}.}
     \item{id}{Sorted subject identifier.}
     \item{y}{List with each component containing the observed
       y-values for a given individual. Values sorted on \code{id}.}
     \item{ymean}{Overall mean of y-values for all individuals.}
     \item{ysd}{Overall standard deviation of y-values for all individuals.}
     \item{gamma}{List of length \emph{M}, with each component
       containing the boosted tree fitted values.}
     \item{beta}{Matrix of estimated coefficient values for each
       individual.}
     \item{mu}{List with each component containing the estimated mean
       values for an individual.  That is, each component contains the
       estimated time-profile for an individual.}
     \item{lambda}{Smoothing parameter.}
     \item{phi}{Variance parameter.}
     \item{rho}{Correlation parameter.}
     \item{baselearner}{List of length \emph{M} containing the base learners.}
     \item{membership}{List of length \emph{M}, with each component
       containing the terminal node membership for a given boosting
       iteration.}
     \item{vimp}{Variable importance (relative RMSE).  Not currently implemented}
     \item{D}{Design matrix for time.}
     \item{d}{Degree of the piecewise B-spline polynomial.}
     \item{pen.ord}{Penalization difference order.}
     \item{K}{Number of terminal nodes.}
     \item{M}{Number of boosting iterations.}
     \item{nu}{Boosting regularization parameter.}
     \item{ntree}{Number of trees.}
}
\author{
  Hemant Ishwaran, Pande A. and Udaya B. Kogalur
}
\references{
  Friedman J.H. (2001). Greedy function approximation: a gradient
  boosting machine, \emph{Ann. of Statist.}, 5:1189-1232.
  
  Friedman J.H. (2002). Stochastic gradient boosting.
  \emph{Comp. Statist. Data Anal.}, 38(4):367--378.

  Pande A., Li L., Rajeswaran J., Ehrlinger J., Kogalur U.B.,
  Blackstone E.H., Ishwaran H. (2016).  Boosted multivariate trees for
  longitudinal data.
}
\seealso{
  \command{\link{partialPlot}},
  \command{\link{plot.boostmtree}},
  \command{\link{predict.boostmtree}},
  \command{\link{print.boostmtree}},
  \command{\link{simLong}}
}
\examples{
##------------------------------------------------------------
## Synthetic example
## high correlation, quadratic time with quadratic interaction
##-------------------------------------------------------------
#simulate the data
dta <- simLong(n = 50, N = 5, rho =.80, model = 2)$dtaL

#basic boosting call (M is set to a small value here purely for illustration)
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y, M = 20)

#print results
print(boost.grow)

#plot.results
plot(boost.grow)

\dontrun{
##----------------------------------------------------------------------------
## spirometry data
##----------------------------------------------------------------------------
data(spirometry, package = "boostmtree")

#boosting call: cubic B-splines with 15 knots
spr.obj <- boostmtree(spirometry$features, spirometry$time, spirometry$id, spirometry$y,
                        M = 100, nu = .025, nknots = 15)
plot(spr.obj)
}
}
\keyword{boosting}
