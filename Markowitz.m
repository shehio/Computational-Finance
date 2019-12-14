assignment(prices)

% plot the following:
% 1. the boundary of the mean-variance frontier,
% 2. all points corresponding to individual assets,
% 3. the global minimum variance portfolio.

function assignment(prices)
%  prices = get_prices();
    [mu_annualized, sigma_annualized] = preprocess(prices);
    riskFreeRate = 0.005;
    hold on

%      a
     [mu_p, sigma_p, mu_gm, sigma2_gm, psi] = ...
         efficient_frontier(mu_annualized, sigma_annualized);
     %  scatter(sqrt(diag(sigma_annualized)), mu_annaulized, '*');
      color = 'blue';
      plot(sigma_p, mu_p, color);  
      scatter(sqrt(sigma2_gm), mu_gm, 'o', color);

    
    [mu_tangency, sigma2_tangency, mus, sigmas] = ...
        calculate_tangency_portfolio(mu_gm, sigma2_gm, riskFreeRate, psi);
    color = 'red';
    scatter(sqrt(sigma2_tangency), mu_tangency, '*', color);
    plot(sigmas, mus, color);

     n = 1000;
     mus = zeros(n, 1);
     sigmas = zeros(n, 1);

     % b
     for gamma = 1:n
         [mu, sigma] = eff_frontier_with_no_short_selling(...
             mu_annualized, sigma_annualized, gamma * 0.1);
         mus(gamma) = mu;
         sigmas(gamma) = sigma;
     end
     color = 'black';
     plot(sqrt(sigmas), mus, color)
    
     % c
     for gamma = 1 : n
         [mu, sigma] = eff_frontier_with_constraints(...
             mu_annualized, sigma_annualized, gamma);
         mus(gamma) = mu;
         sigmas(gamma) = sigma;
     end
     color = 'green';
     plot(sqrt(sigmas), mus, color)
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
function [mu_annualized, sigma_annualized, sigma2_gm, mu_gm] = preprocess(prices)
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

function [mu_p, sigma_p, mu_gm, sigma2_gm, psi] = efficient_frontier(mu_annaulized, sigma_annualized)
 assets = length(mu_annaulized);
 inverseAnnualizedCovariance = inv(sigma_annualized);
 B = mu_annaulized' * inverseAnnualizedCovariance * ones(assets, 1);
 A = sum(sum(inverseAnnualizedCovariance));
 C = mu_annaulized' * inverseAnnualizedCovariance * mu_annaulized;
 
 % solving for the global minimum variance portfolio
 mu_gm = B/A; % expected return
 sigma2_gm = 1/A;
 pi = inv(sigma_annualized) * ones(assets, 1) / A;
 psi = A * C - B^2;
 
 % plot the efficient frontier from mu = -3 to mu = 3, that is for many
 % gammas
 mu_p = linspace(-3, 3, 1000);
 sigma_p = sqrt(sigma2_gm + ((mu_p - mu_gm) .^ 2) / (psi * sigma2_gm));
end

function [mu_tangency, sigma2_tangency, mus, sigmas] = ...
    calculate_tangency_portfolio(mu_gm, sigma2_gm, riskFreeRate, psi)
        sigma2_tangency = ((sigma2_gm) ^ 3 * psi) / (mu_gm - riskFreeRate) ^ 2 + sigma2_gm;
        mu_tangency = ((sigma2_gm) ^ 2 * psi) / (mu_gm - riskFreeRate) + mu_gm;
        m = (mu_tangency - riskFreeRate) / sqrt (sigma2_tangency);  % sharpe ratio
        x = linspace(0, 2, 100);
        y = m * x + riskFreeRate;

        mus = y;
        sigmas = x;
end


function [mu, sigma] = eff_frontier_with_no_short_selling(mu_annualized, sigma_annualized, gamma)
 % no short selling means the lower bound should be zero
 w = optimvar('w', 10, 1, 'LowerBound', 0);
 problem = optimproblem('ObjectiveSense','max');
 options = optimoptions('quadprog','Display','off');
 
 problem.Objective = w' * mu_annualized - gamma / 2 * w' * sigma_annualized * w;
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
 options = optimoptions('quadprog','Display','off');
 
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