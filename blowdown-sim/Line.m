classdef Line
    properties
        gpm
        psi_drop_per_100_ft
        length_ft
        area
        diameter
        coeffs
    end
    
    methods
        function obj = Line(filename, NamedArgs)
            arguments
                filename
                NamedArgs.id_inches
                NamedArgs.length_inches
            end
            % Load data from file
            data = readtable(filename, 'Delimiter', ',', 'Format', '%f%f%f%f%f');
            
            % Convert to a struct
            data = table2struct(data, 'ToScalar', true);
            
            % Assign properties
            obj.gpm = data.gpm;
            obj.psi_drop_per_100_ft = data.psi_drop_per_100_ft;
            obj.length_ft = NamedArgs.length_inches/12;
            obj.area = Convert.in_diameter_to_m2(NamedArgs.id_inches);
            obj.diameter = Convert.in_to_m(NamedArgs.id_inches);

            % Extrapolate by fitting an function to the data of form 
            % f(x) = ax^2 + bx + c, Only take some of the data because
            % that's the only stuff that looks fittable.
            n = length(obj.gpm);
            n_start = ceil(2*n/3);            
            % Perform quadratic regression
            obj.coeffs = polyfit(obj.gpm(n_start:end), ...
                obj.psi_drop_per_100_ft(n_start:end), ...
                2);
        end
        
        function delta_bar = get_pressure_drop(self, volumetric_flow_m3_s, fluid_density_kg_m3)
            % Values obtained by digitization of this pdf: 
            % https://www.swagelok.com/-/media/Distributor-Media/L-N/Michigan/Webinars/TvP/Tube-Fitters-Manual-Flow-and-Pressure-Charts
            % with this tool: https://plotdigitizer.com/app
            % Equations from that pdf also
            specific_gravity = fluid_density_kg_m3 / 1000;
            Q_water_gpm = 60*Convert.m3_to_gal(volumetric_flow_m3_s * sqrt(specific_gravity));
            
            if Q_water_gpm < min(self.gpm) || Q_water_gpm > max(self.gpm)
                % Extrapolate outside the data range
                delta_psi_per_100_ft = self.coeffs(1) ...
                    + self.coeffs(2)*Q_water_gpm ...
                    + self.coeffs(3)*Q_water_gpm^2;
            else
                % Interpolate within the data range
                delta_psi_per_100_ft = interp1(self.gpm, self.psi_drop_per_100_ft, Q_water_gpm);
            end

            delta_bar = Convert.psia_to_bar(self.length_ft * delta_psi_per_100_ft / 100);
        end
    end
end