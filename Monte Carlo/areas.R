## The function g is the function we're interested in. It's a function in x and y.
## The function f is the hel[er function
## N is the number of simulations we use, the higher the more accurate our estimate is.
monte_carlo_area = function(f_x, n, a, b)
{
  x = runif(n, a, b)
  return(mean(f_x(x)))
}

ns = c(10, 100, 1000, 10 * 1000, 100 * 1000, 1000 * 1000, 10 * 1000 * 1000)
for (i in 1:length(ns))
{
  n = ns[i]
  
  Ux  = function(x) 1
  E_uniform = monte_carlo_area(Ux, n, 0, 1)
  print(paste("Area of f(x) = 1 from 0 to 1: ", E_uniform, ", for n = ", n))

  linear  = function(x) x
  E_x = monte_carlo_area(linear, n, 0, 1)
  print(paste("Area of f(x) = x from 0 to 1: ", E_x, ", for n = ", n))
  
  quadratic  = function(x) x ** 2
  E_x2 = monte_carlo_area(quadratic, n, 0, 1)
  print(paste("Area of f(x) = x ^ 2 from 0 to 1: ", E_x2, ", for n = ", n))
  
  sinusoidal  = function(x) sin(x)
  E_sin = monte_carlo_area(sinusoidal, n, 0, 1)
  print(paste("Area of f(x) = sin(x) from 0 to 1: ", E_sin, ", for n = ", n))
  
  exponential  = function(x) exp(x)
  E_exp = monte_carlo_area(exponential, n, 0, 1)
  print(paste("Area of f(x) = e ^ x from 0 to 1: ", E_exp, ", for n = ", n))
}
