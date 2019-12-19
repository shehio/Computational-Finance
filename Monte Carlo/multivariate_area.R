monte_carlo_area = function(f_xy, n, a, b, c, d)
{
  x = runif(n, a, b)
  y = runif(n, c, d)
  estimates = f_xy(x, y)
  mc_estimator = mean(estimates)
  mc_variance = var(estimates)
  return(c(mc_estimator, mc_variance))
}

ns = c(10, 100, 1000, 10 * 1000, 100 * 1000, 1000 * 1000, 10 * 1000 * 1000)
for (i in 1:length(ns))
{
  n = ns[i]
  e_xy2 = function(x, y) exp((x + y) ** 2)
  struct = monte_carlo_area(e_xy2, n, 0, 1, 0, 1)
  E_x = struct[1]
  V_x = struct[2]
  print(paste("Area of f(x) = x from 0 to 1: ", E_x, ", with variance: ", V_x))
}