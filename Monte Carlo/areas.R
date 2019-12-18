## The function g is the function we're interested in. It's a function in x and y.
## The function f is the hel[er function
## N is the number of simulations we use, the higher the more accurate our estimate is.
monte_carlo_area = function(f_x, n, a, b)
{
  x = runif(n, a, b)
  estimates = f_x(x)
  mc_estimator = mean(estimates)
  mc_variance = var(estimates)
  return(c(mc_estimator, mc_variance))
}

ns = c(10, 100, 1000, 10 * 1000, 100 * 1000, 1000 * 1000, 10 * 1000 * 1000)
for (i in 1:length(ns))
{
  n = ns[i]
  print(paste("n = ", n))
  Ux  = function(x) 1
  struct = monte_carlo_area(Ux, n, 0, 1)
  E_uniform = struct[1]
  V_uniform = struct[2]
  print(paste("Area of f(x) = 1 from 0 to 1: ", E_uniform, ", with variance: ", V_uniform))

  linear  = function(x) x
  struct = monte_carlo_area(linear, n, 0, 1)
  E_x = struct[1]
  V_x = struct[2]
  print(paste("Area of f(x) = x from 0 to 1: ", E_x, ", with variance: ", V_x))
  
  quadratic  = function(x) x ** 2
  struct = monte_carlo_area(quadratic, n, 0, 1)
  E_x2 = struct[1]
  V_x2 = struct[2]
  print(paste("Area of f(x) = x from 0 to 1: ", E_x2, ", with variance: ", V_x2))
  
  sinusoidal  = function(x) sin(x)
  struct = monte_carlo_area(sinusoidal, n, 0, 1)
  E_sin = struct[1]
  V_sin = struct[2]
  print(paste("Area of f(x) = x from 0 to 1: ", E_sin, ", with variance: ", V_sin))
  
  exponential  = function(x) exp(x)
  struct = monte_carlo_area(exponential, n, 0, 1)
  E_exp = struct[1]
  V_exp = struct[2]
  print(paste("Area of f(x) = x from 0 to 1: ", E_exp, ", with variance: ", V_exp))
}
