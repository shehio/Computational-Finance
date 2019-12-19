calculate_option_payoff_from_normal_samples = function(initial_price, strike_price, volatiltiy, time_in_years, risk_free_rate, normal_samples)
{
  projected_asset_price = 
    initial_price * exp(risk_free_rate - 0.5 * (volatiltiy ** 2) * time_in_years + volatiltiy * normal_samples * sqrt(time_in_years))
  payoff = exp(-risk_free_rate * time_in_years) * pmax(projected_asset_price - strike_price, 0)
  return(payoff)
}



monte_carlo_european_call_antithetic_variates =
  function(initial_price = 100, strike_price = 100, volatiltiy = 0.2, time_in_years = 1, risk_free_rate = 0.002, simulation_number = 10000)
{
  z1 = rnorm(simulation_number/2)
  z2 = - z1
  
  # probably create a lambda to only pass z's
  payoff1 = calculate_option_payoff_from_normal_samples(initial_price, strike_price, volatiltiy, time_in_years, risk_free_rate, z1)
  payoff2 = calculate_option_payoff_from_normal_samples(initial_price, strike_price, volatiltiy, time_in_years, risk_free_rate, z2)
  payoff = (payoff1 + payoff2) / 2
  
  # important statistics regarding the estimate
  price = mean(payoff)
  std_error = 1.96 * sd(payoff) / sqrt(n / 2)
  lower_bound = price - std_error
  upper_bound = price + std_error
  
  return (c(price = price, std_error = std_error, lower_bound = lower_bound, upper_bound = upper_bound))
}

print(monte_carlo_european_call_antithetic_variates())


# Now, how can use this to calculate a butterfly option?