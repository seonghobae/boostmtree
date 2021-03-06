\name{boostmtree}
\alias{boostmtree}
\alias{boostmtree}
\title{Boosted multivariate trees for longitudinal data}
\description{
  Multivariate extension of Friedman's gradient descent boosting method
  to longitudinal data using multivariate tree base learners (Pande et
  al., 2017).  Covariate-time interactions are modeled using penalized
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
   svd.tol = 1e-6,
   forest.tol = 1e-3,
   verbose = TRUE,
   cv.flag = FALSE,
   eps = 1e-5,
   importance = FALSE,
   mod.grad = TRUE,
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
    \item{svd.tol}{Tolerance value used in the SVD calculation of the
      penalty matrix.  For experts only.}
    \item{forest.tol}{Tolerance used for forest weighted least squares
      solution.  Experimental and for experts only.}
    \item{verbose}{Should verbose output be printed?}
    \item{cv.flag}{Should in-sample cross-validation (CV) be used to determine
      optimal stopping using out of bag data?}
     \item{eps}{Tolerance value used for determining the optimal
       \code{M}. Applies only if \command{cv.flag} = TRUE.  For experts only.}
    \item{importance}{Should variable importance (VIMP) be determined using out of bag data?}
    \item{mod.grad}{Use a modified gradient? See details below.}
    \item{...}{Further arguments passed to or from other methods.}
}
\details{

  Each individual has observed y-values, over possibly different time
  points, with possibly differing number of time points.  Given y, the
  time points, and x, the conditional mean time profile of y is
  estimated using gradient boosting in which the gradient is derived
  from a criterion function involving a working variance matrix for y
  specified as an equicorrelation matrix with parameter \emph{rho}
  multiplied by a variance parameter \emph{phi}. Multivariate trees are
  used for base learners and weighted least squares is used for solving
  the terminal node optimization problem.  This provides solutions to
  the core parameters of the algorithm.  For ancillary parameters, a
  mixed-model formulation is used to estimate the smoothing parameter
  associated with the B-splines used for the time-interaction effect,
  although the user can manually set the smoothing parameter as well.
  Ancillary parameters \emph{rho} and \emph{phi} are estimated using GLS
  (generalized least squares).

  In the original boostmtree algorithm (Pande et al., 2017), the
  equicorrelation parameter \emph{rho} is used in two places in the
  algorithm: (1) for growing trees using the gradient, which depends
  upon \emph{rho}; and (2) for solving the terminal node optimization
  problem which also uses the gradient.  However, Pande (2017) observed
  that setting \emph{rho} to zero in the gradient used for growing trees
  improved performance of the algorithm, especially in high dimensions.
  For this reason the default setting used in this algorithm is to set
  \emph{rho} to zero in the gradient for (1).  The \code{rho} in the
  gradient for (2) is not touched.  The option \code{mod.grad} specifies
  whether a modified gradient is used in the tree growing process and is
  TRUE by default.

  By default, trees are grown from a bootstrap sample of the data --
  thus the boosting method employed here is a modified example of
  stochastic gradient descent boosting (Friedman, 2002).  Stochastic
  descent often improves performance and has the added advantage that
  out-of-sample data (out-of-bag, OOB) can be used to calculate
  variable importance (VIMP).

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

  The method can impute the missing observations in x (covariates) using
  on the fly imputation. Details regarding can be found in the
  \pkg{randomForestSRC} package. If missing values are present in the
  \code{tm}, \code{id} or \code{y}, the user should either impute or
  delete these values before executing the function.

  Finally note \code{cv.flag} can be used for an in-sample
  cross-validated estimate of prediction error.  This is used to
  determine the optimized number of boosting iterations \emph{Mopt}.
  The final mu predictor is evaluated at this value and is
  cross-validated.  The prediction error returned via \command{err.rate}
  is standardized by the overall standard deviation of y.  } \value{ An
  object of class \code{(boostmtree, grow)} with the following
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
     \item{mu}{List with each component containing the estimated mean
       values for an individual.  That is, each component contains the
       estimated time-profile for an individual.  When in-sample
       cross-validation is requested using \command{cv.flag}=TRUE, the
       estimated mean is cross-validated and evaluated at the optimal
       number of iterations \code{Mopt}.}
     \item{lambda}{Smoothing parameter.}
     \item{phi}{Variance parameter.}
     \item{rho}{Correlation parameter.}
     \item{baselearner}{List of length \emph{M} containing the base learners.}
     \item{membership}{List of length \emph{M}, with each component
       containing the terminal node membership for a given boosting
       iteration.}
     \item{D}{Design matrix for time.}
     \item{d}{Degree of the piecewise B-spline polynomial.}
     \item{pen.ord}{Penalization difference order.}
     \item{K}{Number of terminal nodes.}
     \item{M}{Number of boosting iterations.}
     \item{nu}{Boosting regularization parameter.}
     \item{ntree}{Number of trees.}
     \item{err.rate}{In-sample standardized estimate of l1-error and RMSE.}
     \item{rmse}{In-sample standardized RMSE at optimized \code{M}.}
     \item{Mopt}{The optimized \code{M}.}
     \item{vimp}{Variable importance at optimized M.}
     \item{forest.tol}{Forest tolerance value (needed for prediction).}
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
  Blackstone E.H., Ishwaran H. (2017).  Boosted multivariate trees for
  longitudinal data, \emph{Machine Learning}, 106(2): 277--305.

  Pande A. (2017).  \emph{Boosting for longitudinal data}.  Ph.D. Dissertation,
  Miller School of Medicine, University of Miami.
}
\seealso{
  \command{\link{marginalPlot}}
  \command{\link{partialPlot}},
  \command{\link{plot.boostmtree}},
  \command{\link{predict.boostmtree}},
  \command{\link{print.boostmtree}},
  \command{\link{simLong}},
  \command{\link{vimpPlot}}
}
\examples{
##------------------------------------------------------------
## synthetic example
## 0.8 correlation, quadratic time with quadratic interaction
##-------------------------------------------------------------
#simulate the data (use a small sample size for illustration)
dta <- simLong(n = 50, N = 5, rho =.80, model = 2)$dtaL

#basic boosting call (M set to a small value for illustration)
boost.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y, M = 20)

#print results
print(boost.grow)

#plot.results
plot(boost.grow)

\dontrun{
##------------------------------------------------------------
## same synthetic example as above but with in-sample cross-validation
## estimate for RMSE and vimp
##-------------------------------------------------------------
dta <- simLong(n = 50, N = 5, rho =.80, model = 2)$dtaL
boost.cv.grow <- boostmtree(dta$features, dta$time, dta$id, dta$y, M = 300,
                 cv.flag = TRUE, importance = TRUE)
plot(boost.cv.grow)
print(boost.cv.grow)
vimpPlot(object = boost.cv.grow, ymaxlim = 20, ymaxtimelim = 20,
         xaxishead = c(3,3), yaxishead = c(65,65),
         cex.xlab = 1, subhead.cexval = 1.2)
##----------------------------------------------------------------------------
## spirometry data
##----------------------------------------------------------------------------
data(spirometry, package = "boostmtree")

#boosting call: cubic B-splines with 15 knots
spr.obj <- boostmtree(spirometry$features, spirometry$time, spirometry$id, spirometry$y,
                        M = 100, nu = .025, nknots = 15)
plot(spr.obj)


##----------------------------------------------------------------------------
## sneaky way to use boostmtree for (univariate) regression: boston housing
##----------------------------------------------------------------------------

if (library("mlbench", logical.return = TRUE)) {

  ## assemble the data
  data(BostonHousing)
  x <- BostonHousing; x$medv <- NULL
  y <- BostonHousing$medv
  trn <- sample(1:nrow(x), size = nrow(x) * (2 / 3), replace = FALSE)

  ## run boosting in univariate mode
  o <- boostmtree(x = x[trn,], y = y[trn])
  o.p <- predict(o, x = x[-trn, ], y = y[-trn])
  print(o)
  plot(o.p)

  ## run boosting in univariate mode to obtain RMSE and vimp
  o.cv <- boostmtree(x = x, y = y, M = 100, cv.flag = TRUE, importance = TRUE)
  print(o.cv)
  plot(o.cv)
  vimpPlot(o.cv,ymaxlim = 10,cex.xlab = 1)
}

}}
\keyword{boosting}

