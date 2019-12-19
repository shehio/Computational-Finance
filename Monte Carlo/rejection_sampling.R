# Sample from the function f(x) = 2 * (1 - x) in the interval from 0 to 1.
# We're using the function g(x) = u(x) as our candidate distribution
# Notice that a few things  will change if (a, b) -the bound in which we sample the function f(x)- change.

Nsim = 100 * 1000

# Get the maximum of the function we need to sample from.
M = round(optimize(f = function(x) {2 * (1-x)}, interval = c(0, 1), maximum = TRUE)$objective)

u = runif(Nsim, max = M)
y = runif(Nsim)
x = y[u < 2 * (1 - y)]
hist(x)
mean(x)