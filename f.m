function sum = f(guess, coupon_per_years, years, interest, price, stop_index, yields)
syms k
coupons = coupon_per_years * years;
sum = 0;
for i = 1:stop_index - 1
    % The function in which k changes.
    func = interest * exp(-k/coupon_per_years * yields(i));
    
    % Define the domain interval in which k changes.
    a = coupons(i) + 1;
    b = coupons(i + 1);
    
    symbolic_sum = symsum(func, k, a, b);
    added_term = double(symbolic_sum);
    sum = sum + added_term;
end
func = interest * exp(-k/coupon_per_years * guess);
a = coupons(stop_index) + 1;
b = coupons(stop_index + 1);
sum = sum + double(symsum(func, k, a, b) + (1) * exp(- years(stop_index + 1) * guess) - price);