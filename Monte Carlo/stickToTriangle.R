# Consider taking a stick of length 1 meter and randomly breaking it in 2 places, U1 and U2, where
# U1 and U2 are iid U(0, 1) random variables.
# What is the probability that you will be able to make a triangle with the 3 pieces?

IsValidTriangle = function(a, b, c)
{
  return (a + b > c
          && c + a > b 
          && c + b > a)
}

MC_StickToTriangles = function(n)
{
  u1 = runif(n)
  a = u1
  u2 = runif(n)
  b = u2 - a
  c = 1 - u2
  
  j = 0
  for (i in 1:n){
    if(IsValidTriangle(a[i], b[i], c[i]))
    {
      j = j + 1
    }
  }
  return(2 * j / n)
}

ns = c(10, 100, 1000, 10 * 1000, 100 * 1000, 1000 * 1000, 10 * 1000 * 1000)
for (i in 1:length(ns))
{
  n = ns[i]
  print(paste("Simulation with n number of samples: ", n, ", P(valid triangles) = ", MC_StickToTriangles(n)))
}