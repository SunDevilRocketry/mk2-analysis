clear;

% Set to false if you want to just plot old results
run_model = true;

% Set to something other than 0 if you want it to quit after some time
quit_after_iters = 0;

% Engine parameters/constants
Rocket = AblativeBlowdownRocket(...
    cea = Cea('data.csv'),... % load data
    oxid_fuel_ratio                         = 1.5,...
    nominal_chamber_pressure_psia           = 315.0,... 
    initial_throat_diam_inches              = 1.18,... % RPA
    nozzle_exit_diam_inches                 = 2.65,... % RPA
    ablative_coeff_barm2K_s                 = 0.0,... % placeholder
    fuel=Propellent(...
        pressure_intial_psia                    = 515,...
        tankage_volume_gal                      = 2.5,...
        initial_volume_gal                      = 1.0,...
        ball_valve_Cv_gal_min_water_at_1_psi    = 5.5,... % https://www.mcmaster.com/46325K28/
        injector_Cda_dimensionless              = 0.00250,... % Tuned for 150 psi drop at t=0
        density_kg_m3                           = 775,... % https://en.wikipedia.org/wiki/Ethanol_(data_page) @ 37C
        dynamic_viscosity_Ns_m2                 = 0.00144,... % https://www.engineeringtoolbox.com/absolute-viscosity-liquids-d_1259.html
        ullage_heat_capacity_ratio              = 1.4,... % Diatomic nitrogen
        line = Line('half-inch-thin-wall-swagelok.csv', length_inches=72, id_inches=0.430)...
        ),...
    oxid=Propellent(...
        pressure_intial_psia                    = 515,...
        tankage_volume_gal                      = 2.5,...
        initial_volume_gal                      = 1.0,...
        ball_valve_Cv_gal_min_water_at_1_psi    = 5.5,... % https://www.mcmaster.com/46325K28/
        injector_Cda_dimensionless              = 0.00300,... % Tuned for 150 psi drop at t=0
        density_kg_m3                           = 1142,... % https://www.engineeringtoolbox.com/oxygen-d_1422.html @ boiling
        dynamic_viscosity_Ns_m2                 = 7.02*10^-6,... % https://www.engineeringtoolbox.com/oxygen-O2-dynamic-kinematic-viscosity-temperature-pressure-d_2081.html
        ullage_heat_capacity_ratio              = 1.4,... % Diatomic nitrogen
        line = Line('half-inch-thin-wall-swagelok.csv', length_inches=24, id_inches=0.430)...
        )...
    );

% Logging
logs = Logs();

% Iteration constants & intitial values
iters = 0;
dt = 0.001; % seconds
iter_damp = 0.25;
Pcs = Rocket.nominal_chamber_pressure;
Vfs = Rocket.fuel.initial_volume;
Vos = Rocket.oxid.initial_volume;
Ats = Rocket.initial_throat_area;

% Multivariate Runge-Kutta 4th order:
while run_model
    Pc_prev = Pcs(end);
    Vf_prev = Vfs(end);
    Vo_prev = Vos(end);
    At_prev = Ats(end);
    % Calculate k1 terms
    k1_state = State(Rocket, ...
        Pc_prev, ...
        Vf_prev, ...
        Vo_prev, ...
        At_prev ...
        );
    k1_Vf = dt * k1_state.get_instanteous_change_in_fuel_volume();
    k1_Vo = dt * k1_state.get_instanteous_change_in_oxid_volume();
    k1_At = dt * k1_state.get_instantaneous_change_in_throat_area();
    % Calculate k2 terms
    k2_state = State(Rocket, ...
        Pc_prev, ...
        Vf_prev + 0.5*k1_Vf, ...
        Vo_prev + 0.5*k1_Vo, ...
        At_prev + 0.5*k1_At ...
        );
    % Find converged k2 pressure by simple iteration
    for iter=0:10000
        % Test to see if we've converged
        p_diff = k2_state.estimate_chamber_pressure() - k2_state.chamber_pressure;
        if abs(Convert.bar_to_psia(p_diff)) > 2.5
            fprintf("High initial p_diff (=%0.1f psi) when beginning convergence indicates that chamber pressure is unlikely to be as designed; check tank pressure & losses.\n", Convert.bar_to_psia(p_diff));
            return;
        end
        if abs(p_diff) < 1e-7
            break
        end
        % Update estimate & try again
        k2_state = State(Rocket, ...
            k2_state.chamber_pressure + iter_damp*p_diff, ...
            k2_state.fuel_volume, ...
            k2_state.oxid_volume, ...
            k2_state.eroded_thoat_area);
    end
    k2_Vf = dt * k2_state.get_instanteous_change_in_fuel_volume();
    k2_Vo = dt * k2_state.get_instanteous_change_in_oxid_volume();
    k2_At = dt * k2_state.get_instantaneous_change_in_throat_area();
    % Calculate k3 terms
    k3_state = State(Rocket, ...
        Pc_prev, ...
        Vf_prev + 0.5*k2_Vf, ...
        Vo_prev + 0.5*k2_Vo, ...
        At_prev + 0.5*k2_At ...
        );
    % Find converged k3 pressure by simple iteration
    for iter=0:10000
        p_diff = k3_state.estimate_chamber_pressure() - k3_state.chamber_pressure;
        if abs(p_diff) < 1e-7
            break
        end
        k3_state = State(Rocket, ...
            k3_state.chamber_pressure + iter_damp*p_diff, ...
            k3_state.fuel_volume, ...
            k3_state.oxid_volume, ...
            k3_state.eroded_thoat_area);
    end
    k3_Vf = dt * k3_state.get_instanteous_change_in_fuel_volume();
    k3_Vo = dt * k3_state.get_instanteous_change_in_oxid_volume();
    k3_At = dt * k3_state.get_instantaneous_change_in_throat_area();
    % Calculate k4 terms
    k4_state = State(Rocket, ...
        Pc_prev, ...
        Vf_prev + k3_Vf, ...
        Vo_prev + k3_Vo, ...
        At_prev + k3_At ...
        );
    % Find converged k4 pressure by simple iteration
    for iter=0:10000
        p_diff = k4_state.estimate_chamber_pressure() - k4_state.chamber_pressure;
        if abs(p_diff) < 1e-7
            break
        end
        k4_state = State(Rocket, ...
            k4_state.chamber_pressure + iter_damp*p_diff, ...
            k4_state.fuel_volume, ...
            k4_state.oxid_volume, ...
            k4_state.eroded_thoat_area);
    end
    k4_Vf = dt * k4_state.get_instanteous_change_in_fuel_volume();
    k4_Vo = dt * k4_state.get_instanteous_change_in_oxid_volume();
    k4_At = dt * k4_state.get_instantaneous_change_in_throat_area();
    % Update variables & iterate to find new pressure
    new_state = State(Rocket, ...
        Pc_prev, ...
        Vf_prev + (1/6)*(k1_Vf + 2*k2_Vf + 2*k3_Vf + k4_Vf), ...
        Vo_prev + (1/6)*(k1_Vo + 2*k2_Vo + 2*k3_Vo + k4_Vo), ...
        At_prev + (1/6)*(k1_At + 2*k2_At + 2*k3_At + k4_At) ...
        );
    % Iterate to find new pressure
    for iter=0:10000
        p_diff = new_state.estimate_chamber_pressure() - new_state.chamber_pressure;
        if abs(p_diff) < 1e-7
            break
        end
        new_state = State(Rocket, ...
            new_state.chamber_pressure + iter_damp*p_diff, ...
            new_state.fuel_volume, ...
            new_state.oxid_volume, ...
            new_state.eroded_thoat_area);
    end
    % Store values
    Pcs = [Pcs new_state.chamber_pressure];
    Vfs = [Vfs new_state.fuel_volume];
    Vos = [Vos new_state.oxid_volume];
    Ats = [Ats new_state.eroded_thoat_area];
    % Store logging
    logs = logs.log_from_state(dt, new_state);
    % Print
    fprintf("Time: %.3f s. Chamber pressure/temp: %.1f psia/%.0f C.\n\tFuel volume: %.3f gal. Fuel losses (line/bv/inj): %.1f/%.1f/%.1f psi.\n\tOxid volume: %.3f gal. Oxid losses (line/bv/inj): %.1f/%.1f/%.1f psi.\n", ...
        logs.time(end), ...
        logs.chamber_pressure_psia(end), ...
        logs.chamber_temperature_C(end), ...
        logs.fuel_volume_gal(end), ...
        logs.fuel_line_drop_psia(end), ...
        logs.fuel_bv_drop_psia(end), ...
        logs.fuel_injector_drop_psia(end), ...
        logs.oxid_volume_gal(end), ...
        logs.oxid_line_drop_psia(end), ...
        logs.oxid_bv_drop_psia(end), ...
        logs.oxid_injector_drop_psia(end));
    % Exit
    iters = iters+1;
    if quit_after_iters ~= 0 && iters >= quit_after_iters
        break
    end

% Plot results
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultLineLineWidth', 2.4, ...
    'DefaultLineMarkerSize', 20, 'DefaultAxesGridLineStyle', '-', ...
    'DefaultAxesGridAlpha', 0.5, 'DefaultAxesLineWidth', 1.2, ...
    'DefaultAxesBox', 'on');

figure('Units', 'inches', 'Position', [5 5 15 10]);
    if new_state.fuel_volume <= 0
        break
    end
    if new_state.oxid_volume <= 0
        break
    end
end

% Exit early to not produce empty plots
if quit_after_iters ~= 0 && quit_after_iters < 1000
    return
end

% Read results from file instead of produce them
if run_model==true
    % Output results
    results = struct(logs);
    fields = fieldnames(results);
    for i = 1:numel(fields)
        results.(fields{i}) = results.(fields{i})';
    end
    results.t_time_s = logs.time';
    writetable(struct2table(results), 'results.csv');
else
    % Plot without running
    results = readtable('results.csv');
end

% Plot results
set(gcf, 'DefaultAxesFontSize', 12, 'DefaultLineLineWidth', 2.4, ...
    'DefaultLineMarkerSize', 20, 'DefaultAxesGridLineStyle', '-', ...
    'DefaultAxesGridAlpha', 0.5, 'DefaultAxesLineWidth', 1.2, ...
    'DefaultAxesBox', 'on');

figure('Units', 'inches', 'Position', [5 5 15 10]);
num_subplots_y = 3;
num_subplots_x = 3;
% Pressures
subplot(num_subplots_y, num_subplots_x, 1);
hold on
plot(results.time, results.chamber_pressure_psia);
plot(results.time, results.fuel_pressure_psia);
plot(results.time, results.oxid_pressure_psia);
grid on
legend('Chamber', 'Fuel', 'Oxidizer');
ylabel('Pressure (psia)');
xlabel('Time (s)');
hold off
% Losses
subplot(num_subplots_y, num_subplots_x, 2);
hold on
plot(results.time, results.fuel_line_drop_psia);
plot(results.time, results.oxid_line_drop_psia);
plot(results.time, results.fuel_bv_drop_psia);
plot(results.time, results.oxid_bv_drop_psia);
plot(results.time, results.fuel_injector_drop_psia);
plot(results.time, results.oxid_injector_drop_psia);
grid on
legend('Fuel Line', 'Oxidizer Line', 'Fuel Ball Valve', 'Oxidizer Ball Valve', 'Fuel Injector', 'Oxidizer Injector');
ylabel('Pressure Loss (psia)');
xlabel('Time (s)');
hold off
% Thrust
subplot(num_subplots_y, num_subplots_x, 3);
plot(results.time, results.thrust_lbf);
grid on
ylabel('Thrust (lbf)');
xlabel('Time (s)');
% Volumes
subplot(num_subplots_y, num_subplots_x, 4);
hold on
plot(results.time, results.fuel_volume_gal);
plot(results.time, results.oxid_volume_gal);
grid on
legend('Fuel', 'Oxidizer');
ylabel('Volume (gal)');
xlabel('Time (s)');
hold off
% Volumetric flow
subplot(num_subplots_y, num_subplots_x, 5);
hold on
plot(results.time, results.fuel_volumetric_gpm);
plot(results.time, results.oxid_volumetric_gpm);
grid on
legend('Fuel', 'Oxidizer');
ylabel('Volumetric Flow Rate (gpm)');
xlabel('Time (s)');
hold off
% Temperature
subplot(num_subplots_y, num_subplots_x, 6);
plot(results.time, results.chamber_temperature_C);
grid on
ylabel('Chamber Temperature (C)');
xlabel('Time (s)');
% Velocities
subplot(num_subplots_y, num_subplots_x, 7);
hold on
plot(results.time, results.fuel_line_velocity_mps);
plot(results.time, results.oxid_line_velocity_mps);
plot(results.time, results.fuel_injector_velocity_mps);
plot(results.time, results.oxid_injector_velocity_mps);
grid on
legend('Fuel Line', 'Oxidizer Line', 'Fuel Injector', 'Oxidizer Injector');
ylabel('Velocity (m/s)');
xlabel('Time (s)');
hold off
% Reynolds in Line
subplot(num_subplots_y, num_subplots_x, 8);
semilogy(results.time, results.fuel_line_reynolds_Re, results.time, results.oxid_line_reynolds_Re);
grid on
legend('Fuel', 'Oxidizer');
ylabel('Re in main line (1)');
xlabel('Time (s)');
% Exit Pressure
subplot(num_subplots_y, num_subplots_x, 9);
plot(results.time, results.exit_pressure_psia);
grid on
ylabel('Exit Pressure (psia)');
xlabel('Time (s)');
% Export
print('-dpng', '-r500', 'plt.png', '-opengl');