clear
clc

So = 100;
Xo = 0;
Qo = 10;

k = 0.1;
b = 0.01;
sigma = 1;
alpha = 0.5;

T = 1;
Ndt = 1000;
dt = T / Ndt;
t = 0:dt:T;

beta_k = 10;
theta = 0.1;
kappao = 0.1;
eta = 0.1;

gammas = 0.0:0.3:5;

for i = 1:length(gammas)
    rng(1);
    
    N_MC = 1000;

    Z = randn(N_MC, Ndt);
    dB = Z * sqrt(dt);
    
    Z = randn(N_MC, Ndt);
    dZ = Z * sqrt(dt);
    
    
    Q = NaN(N_MC, Ndt + 1);
    S = NaN(N_MC, Ndt + 1);
    X1 = NaN(N_MC, Ndt + 1);
    X2 = NaN(N_MC, Ndt + 1);
    kappa = NaN(N_MC, Ndt + 1);
    
    Q(:, 1) = Qo;
    S(:, 1) = So;
    X1(:, 1) = Xo;
    X2(:, 1) = Xo;
    kappa(:, 1) = kappao;

    A = sqrt(gammas(i) * sigma ^ 2);
    B = 1 / sqrt(2 * k);

    omega = 2 * A * B;
    beta = A / B;
    n = 2 * alpha - b;
    phi_p = beta + n;
    phi_m = beta - n;

    for j = 1:Ndt
        u_t = beta * (phi_m * exp(-omega/2 * (T - t(j))) - phi_p * exp(omega/2 ...
            * (T - t(j)))) / (phi_m * exp(-omega/2 * (T - t(j))) + phi_p * exp(omega/2 ...
            * (T - t(j))));
        nu = u_t / (2 * k) * Q(:, j);
            
        kappa(:, j + 1) = kappa(:, j) + ...
            beta_k * (theta - kappa(:, j)) * dt + eta * dZ(:, j);
        
        if (rem(j, 10) == 0)
            kappa(:, j + 1);
        end
        
        Q(:, j + 1) = Q(:, j) + nu * dt;
        S(:, j + 1) = S(:, j) + b * nu * dt + sigma * dB(:, j);
        X1(:, j + 1) = X1(:, j) - (S(:, j) + k * nu) .* nu * dt;
        X2(:, j + 1) = X2(:, j) - (S(:, j) + kappa(:, j) .* nu) .* nu * dt;
    end

    W1 = X1(:, end) + Q(:, end) .* S(:, end) - alpha * Q(:, end) .^ 2;
    W1_mean(i) = mean(W1);
    W1_std(i) = std(W1);
    
    
    W2 = X2(:, end) + Q(:, end) .* S(:, end) - alpha * Q(:, end) .^ 2;
    W2_mean(i) = mean(W2);
    W2_std(i) = std(W2);
end

fig = figure(1);
clf(fig)
hold on
plot(W1_std, W1_mean, 'o-', 'linewidth', 2)
plot(W2_std, W2_mean, 'o-', 'linewidth', 2)
legend({'W1 (constant K)','W2 (stochastic kappa)'},'Location','southwest')
title('Liquidating according to Almgren-Chriss Model.')
xlabel('Wealth std') 
ylabel('Wealth mean after liquidation') 