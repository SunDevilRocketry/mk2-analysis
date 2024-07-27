import math



# Parameters for stream 1
num_ox_elements = 5
dP1 = 260  # psi
density1 = 1142  # kg/m^3
mdot1 = 0.25029  # kg/s

# Parameters for stream 2
num_fuel_elements = 5
dP2 = 260  # psi
density2 = 775  # kg/m^3
mdot2 = 0.13595  # kg/s

# Angle between streams
impingement_angle = 45  # degrees

# Parameters for film cooling
num_channels_film = 15
dP_film = 260  # psi
density_film = 775  # kg/m^3
mdot_film = 0.38624 * 0.1  # kg/s


def calculate_stream_properties(dP, density, mdot, num_channels):
  dP_pa = dP * 6894.75729  # 1 psi = 6894.75729 Pa
  velocity = math.sqrt(2 * dP_pa / density)  # m/s
  area = mdot / math.sqrt(2 * density * dP_pa)  # m^2
  radius = math.sqrt(area / math.pi / num_channels)  # m
  momentum_flux = mdot * velocity  # kg*m/s^2 or N
  return momentum_flux, velocity, radius


def calculate_new_angle(m1, m2, angle):
  angle_rad = math.radians(angle)
  x_component = m1 + m2 * math.cos(angle_rad)
  y_component = m2 * math.sin(angle_rad)
  new_angle = math.atan2(y_component, x_component)
  new_angle_deg = math.degrees(new_angle)
  return new_angle_deg


# Calculate momentum fluxes and other parameters
m1, v1, r1 = calculate_stream_properties(dP1, density1, mdot1, num_ox_elements)
m2, v2, r2 = calculate_stream_properties(dP2, density2, mdot2, num_fuel_elements)
_, _, r_film = calculate_stream_properties(dP_film, density_film, mdot_film,
                                           num_channels_film)

# Calculate new angle
result = calculate_new_angle(m1, m2, impingement_angle)

# Print results
print(f"Stream 1:")
print(f"  Momentum flux: {m1:.2f} N")
print(f"  Velocity: {v1:.2f} m/s")
print(f"  Diameter: {r1 * 2 * 39.37:.6f} inches")

print(f"\nStream 2:")
print(f"  Momentum flux: {m2:.2f} N")
print(f"  Velocity: {v2:.2f} m/s")
print(f"  Diameter: {r2 * 2 * 39.37:.6f} inches")

print(f"\nThe new angle relative to the first stream is: {result:.2f} degrees")

print(f"\Film cooling:")
print(f"  Diameter: {r_film * 2 * 39.37:.6f} inches")
