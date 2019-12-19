# Write your own poisson sample generation method
poisson = function(nsim, lambda)
{
  X = rep(0, nsim)
  for (i in 1:nsim)
  {
    sum = 0; k = 0
    repeat
    {
      sum = sum + rexp(1, lambda);
      if(sum > 1)
      {
        break
      }
      k = k + 1
    }
    X[i] = k
  }
  return(X)
}

nsim = 10 * 1000
lambda = 2
mean(poisson(nsim, lambda))
mean(rpois(nsim, lambda))

var(poisson(nsim, lambda))
var(rpois(nsim, lambda))