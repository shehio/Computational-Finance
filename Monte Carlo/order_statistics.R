# Formula is provided here: https://en.wikipedia.org/wiki/Order_statistic
nsim = 10 * 1000

# Get the maximum of the two unifromly random samples; assuming IID
order_statistic_2_2 = mean(sqrt(runif(nsim)))
print(order_statistic_2_2)

# Histogram
hist(sqrt(runif(nsim)))

# empirical
u1 = runif(nsim)
u2 = runif(nsim)
m = pmax(u1, u2)
print(mean(m))


# Get the minimum of the two unifromly random samples; assuming IID
order_statistic_2_1 = mean(1 - sqrt(runif(nsim)))
print(order_statistic_2_1)

# Histogram
hist(1 - sqrt(runif(nsim)))


# empirical
u1 = runif(nsim)
u2 = runif(nsim)
m = pmin(u1, u2)
print(mean(m))

# Get the minimum of the three exponentially random samples; assuming IID
lambda = 1
order_statistic_3_1 = mean(-log(runif(nsim) ** 2)/6)
print(order_statistic_3_1)

# Histogram
hist(-log(runif(nsim) ** 2)/6)

# empirical
lambda = 1
r1 = rexp(nsim, lambda)
r2 = rexp(nsim, lambda)
r3 = rexp(nsim, lambda)
print(mean(pmin(r1, r2, r3)))