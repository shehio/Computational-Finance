function sum = f(guess, coupon_per_years, years, interest, principal, yields)
sum = 0;
coupons = coupon_per_years * years;
stop_index = length(years) - 1;
syms k;

for i = 1 : stop_index - 1
    % The function in which k changes.
    func = interest * exp(-k / coupon_per_years * yields(i));

    % Define the domain interval in which k changes.
    a = coupons(i) + 1;
    b = coupons(i + 1);

    symbolic_sum = symsum(func, k, a, b);
    sum = sum + double(symbolic_sum);
end
func = interest * exp(-k / coupon_per_years * guess);
a = coupons(stop_index) + 1;
b = coupons(stop_index + 1);
sum = sum + double(symsum(func, k, a, b) + ...
    (1) * exp(- years(stop_index + 1) * guess) - principal);