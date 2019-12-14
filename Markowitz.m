assignment()

% plot the following:
% 1. the boundary of the mean-variance frontier,
% 2. all points corresponding to individual assets,
% 3. the global minimum variance portfolio.

function assignment()
 prices = get_prices();
 [mu_annualized, sigma_annualized] = preprocess(prices);

 % a
 efficient_frontier(mu_annualized, sigma_annualized, 'blue')
 
 n = 1000
 mus = zeros(n, 1)
 sigmas = zeros(n, 1)

 % b
 hold on
 for gamma = 1 : n
 [mu, sigma] = eff_frontier_with_no_short_selling(mu_annualized, sigma_annualized, gamma * 0.1);
 mus(gamma) = mu;
 sigmas(gamma) = sigma;
 end
 plot(sqrt(sigmas), mus, 'red')

 % c
 hold on
 for gamma = 1 : n
 [mu, sigma] = eff_frontier_with_constraints(mu_annualized, sigma_annualized, gamma);
 mus(gamma) = mu;
 sigmas(gamma) = sigma;
 end
 plot(sqrt(sigmas), mus, 'green')
end

function prices = get_prices()
    if(~exist('prices','var') || size(prices) ~= [1509, 10])
         prices = zeros(1509, 10);
         stocks = ["MSFT", "AAPL", "ORCL", "EBAY", "GOOG", "INTC", "BBBY", "MMM", "TEVA", "GE"];
         for i = 1:length(stocks)
            stock = stocks(i);
            data = getMarketData(char(stock), '1-Jan-2012', '31-Dec-2017', '1d', 5);
            prices(:, i) = data;
         end
    end
end

%% arithmatic returns
function [mu_annualized, sigma_annualized] = preprocess(prices)
 arithmatic_returns = prices(2:end, :) ./ prices(1:end-1, :) - 1;
 mu_daily = mean(arithmatic_returns);
 sigma_daily_matrix = cov(arithmatic_returns);
 rho_daily = corrcov(sigma_daily_matrix);
 sigma_daily_vector = sqrt(diag(sigma_daily_matrix));
 
 %% annulaized returns
 days = 252;
 % µ(a)i = (µ(d)i + 1)N +1 1
 mu_annualized = (mu_daily + 1) .^ days - 1;
 mu_annualized = mu_annualized';
 % ?(a)i,j?(a)i?(a)j=(?(d)i,j?(d)i?(d)j+ (?(d)i+ 1)(?(d)j+ 1))N?(?(d)i+1)N(?(d)j+ 1)N.
 sigma_annualized = (sigma_daily_matrix + (mu_daily + 1)' * (mu_daily + 1)).^ days ...
 - ((mu_daily + 1) .^ days)' * ((mu_daily + 1) .^ days);
end

function efficient_frontier(mu_annaulized, sigma_annualized, color)
 assets = length(mu_annaulized);
 scatter(sqrt(diag(sigma_annualized)), mu_annaulized, '*');
 hold on
 inverseAnnualizedCovariance = inv(sigma_annualized);
 B = mu_annaulized' * inverseAnnualizedCovariance * ones(assets, 1);
 A = sum(sum(inverseAnnualizedCovariance));
 C = mu_annaulized' * inverseAnnualizedCovariance * mu_annaulized;
 % solving for the global minimum variance portfolio
 mu_gm = B/A; % expected return
 sigma2_gm = 1/A;
 voltality = sqrt(sigma2_gm)
 pi = inv(sigma_annualized) * ones(assets, 1) / A;
 psi = A * C - B^2;
 
 % plot the efficient frontier from mu = -3 to mu = 3
 mu_p = linspace(-3, 3, 1000);
 sigma_p = sqrt(sigma2_gm + ((mu_p - mu_gm) .^ 2) / (psi * sigma2_gm));
 plot(sigma_p, mu_p, color);
 scatter(voltality, mu_gm, color);
 
 
 rf = 0.005;
 sigma2_t = ((sigma2_gm) ^ 3 * psi) / (mu_gm - rf) ^ 2 + sigma2_gm
 mu_t = ((sigma2_gm) ^ 2 * psi) / (mu_gm - rf) + mu_gm
 scatter([sqrt(sigma2_t)], [mu_t], '*')
 m = (mu_t - rf) / sqrt (sigma2_t);  % sharpe ratio
 x = linspace(0, 2, 100);
 y = m * x + rf;
 plot(x, y);
end

function [mu, sigma] = eff_frontier_with_no_short_selling(mu_annualized, sigma_annualized, gamma)
 % no short selling means the lower bound should be zero
 w = optimvar('w', 10, 1, 'LowerBound', 0);

 problem = optimproblem('ObjectiveSense','max');
 problem.Objective = w' * mu_annualized - gamma / 2 * w' * sigma_annualized * w;
 options = optimoptions(problem);
 options.Display = 'off';
 cons1 = sum(w) == 1;
 problem.Constraints.cons1 = cons1;
%  showproblem(problem);
 pi = solve(problem, 'Options', options);
 pi = pi.w;
 mu = pi' * mu_annualized;
 sigma = pi' * sigma_annualized * pi;
end

function [mu, sigma] = eff_frontier_with_constraints(mu_annualized, sigma_annualized, gamma)
 w = optimvar('w', 10, 1);

 problem = optimproblem('ObjectiveSense','max');
 options = optimoptions(problem);
 options.Display = 'off';
 problem.Objective = w' * mu_annualized - gamma / 2 * w' * sigma_annualized * w;
 cons1 = sum(w) == 1;
 cons2 = w(1) + w(2) >= 0.05;
 cons3 = w(1) + w(2) <= 0.1;

 problem.Constraints.cons1 = cons1;
 problem.Constraints.cons2 = cons2;
 problem.Constraints.cons3 = cons3;
%  showproblem(problem);
 pi = solve(problem, 'Options', options);
 pi = pi.w;
 mu = pi' * mu_annualized;
 sigma = pi' * sigma_annualized * pi;
end