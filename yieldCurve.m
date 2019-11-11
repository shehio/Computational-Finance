% There are five bonds traded in the market with maturities
% T = 1, 2, 3, 5, 10. The bonds also pay semi-annual coupons of size
% 2% of their face value.

% At time 0 the bond prices are:
% Maturity (years):     1      2     3       5     10
% Bond Price:        1.0298 1.0194 1.0004 0.9570 0.8861

% Estimate a yield curve for all times of the form m / 2 for m ? {1, . . . , 20}
% Use the bootstrapping method illustrated in lecture.
% For each bond also compute the yield-to-maturity, the Macauly duration, and the duration.

clear;
clc;

years = [0 1 2 3 5 10];
prices = [0 1.0298 1.0194 1.0004 0.9570 0.8861];

initial_guess = 0.1;
coupons_per_year = 2;
interest = 0.02;
yields = [];

for i = 1 : length(years) - 1
    fun = @(x) f(x, coupons_per_year, years, interest, prices(i + 1), i, yields);
    yields = [yields fzero(fun, initial_guess)];
end

yields
% =========================

years = [1 2 3 5 10];
prices = [1.0298 1.0194 1.0004 0.9570 0.8861];
yields_to_maturity = [];

for i = 1 : length(years)
    fun = @(x) g(x, coupons_per_year, years(i), interest, prices(i));
    yields_to_maturity = [yields_to_maturity fzero(fun, initial_guess)];
end

yields_to_maturity
% =========================

syms k
m_durations = [];
for i = 1 : length(years)
    % Tn = k/coupons_per_year;
    Tn = years(i);
    func = k/coupons_per_year * interest * exp(-k/coupons_per_year * yields_to_maturity(i));
    a = 1;
    b = coupons_per_year * years(i) - 1;

    added_term = Tn * (1 + interest) * exp(- Tn * yields_to_maturity(i));
    d = (double(symsum(func, k, a,  b)) + added_term) / prices(i);
    m_durations = [m_durations d];
end

m_durations
% =========================

durations = [];
for i = 1 : length(years)
    % Tn = k/coupons_per_year;
    Tn = years(i);
    func = k / coupons_per_year * interest * exp(-k /coupons_per_year * yields(i));
    a = 1;
    b = coupons_per_year * years(i) - 1;
    added_term = Tn * (1 + interest) * exp(- Tn * yields(i));
    d = double(symsum(func, k, a, b) + added_term) / prices(i);
    durations = [durations d];
end

durations
% =========================


y = repelem(yields,[3 3 3 5 10]);
y1 = y(1:3);
x1 = linspace(0,2, 3);
plot(x1, y1)
hold on
y2 = y(4:6);
x2 = linspace(2, 4, 3);
plot(x2, y2);
y3 = y(7:9);
x3 = linspace(4, 6, 3);
plot(x3, y3);
y4 = y(10:14);
x4 = linspace(6, 10, 5);
plot(x4, y4);
y5 = y(15:24);
x5 = linspace(10, 20, 10);
plot(x5, y5);
xlabel("Time");
ylabel("Yield");