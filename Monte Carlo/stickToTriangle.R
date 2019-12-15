# Question 3.1
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
  return(2 * j/n)
}

ns = c(10, 100, 1000, 10 * 1000, 100 * 1000, 1000 * 1000, 10 * 1000 * 1000)
for (i in 1:length(ns))
{
  n = ns[i]
  print(paste("n: ", n, "P(triangles) = ", MC_StickToTriangles(n)))
}