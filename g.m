function y = f(guess, coupons_per_year, years, interest, price)
syms k
coupons = coupons_per_year * years;
func = interest * exp(-k / coupons_per_year * guess);
a = 1;
b = coupons;
y = double(symsum(func, k, a, b) + 1 * exp(- years * guess) - price);