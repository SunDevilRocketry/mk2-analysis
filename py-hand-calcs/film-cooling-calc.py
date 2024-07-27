of_total = 1.473
film_fraction = 0.2
rho_fuel = 775
rho_ox = 1142

inv_of_chamber = (1/of_total) - 2*film_fraction*rho_fuel/rho_ox

print("Combustion OF:", 1/inv_of_chamber)