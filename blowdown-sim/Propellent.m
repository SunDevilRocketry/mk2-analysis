classdef Propellent    
    properties
        pressure_intial
        tankage_volume
        initial_volume
        ball_valve_cv
        injector_cda
        density
        dynamic_viscosity
        ullage_gamma
        line
    end
    methods
        function obj = Propellent(NamedArgs)
            arguments
                NamedArgs.pressure_intial_psia
                NamedArgs.tankage_volume_gal
                NamedArgs.initial_volume_gal
                NamedArgs.ball_valve_Cv_gal_min_water_at_1_psi
                NamedArgs.injector_Cda_dimensionless
                NamedArgs.density_kg_m3
                NamedArgs.dynamic_viscosity_Ns_m2
                NamedArgs.ullage_heat_capacity_ratio
                NamedArgs.line
            end
            obj.pressure_intial = Convert.psia_to_bar(NamedArgs.pressure_intial_psia);
            obj.tankage_volume  = Convert.gal_to_m3(NamedArgs.tankage_volume_gal);
            obj.initial_volume  = Convert.gal_to_m3(NamedArgs.initial_volume_gal);
            obj.ball_valve_cv   = NamedArgs.ball_valve_Cv_gal_min_water_at_1_psi;
            obj.injector_cda    = NamedArgs.injector_Cda_dimensionless;
            obj.density         = NamedArgs.density_kg_m3;
            obj.dynamic_viscosity = NamedArgs.dynamic_viscosity_Ns_m2;
            obj.ullage_gamma    = NamedArgs.ullage_heat_capacity_ratio;
            obj.line            = NamedArgs.line;
        end
            

        function m3_s = get_volumetric_flow(self, mass_flow_kg_s)
            m3_s = mass_flow_kg_s / self.density;
        end

        function bar = get_tank_pressure(self, current_volume_m3)
            V_tilde = (self.tankage_volume - current_volume_m3)...
                / (self.tankage_volume - self.initial_volume);
            bar = self.pressure_intial * power(V_tilde, -self.ullage_gamma);
        end

        function delta_bar = get_bv_pressure_drop(self, mass_flow_kg_s)
            % This function takes a "Cv" value (really Q0) which must be reported
            % in gal/min for water for a 1 psi drop over the valve. The function
            % will return a delta_bar value after calculating the result in psi.
            % Here is the derivation:
            %   Known: Cv=Q*sqrt(Gf/dP) where Q is volumetric flow, Gf is specific
            %   gravity, dP is pressure loss. Cv is a constant.
            %   From the manufacturer, we have some Q0*sqrt(1/1 psi), which is
            %   known to be equal to the general case. Thus:
            %       Q/Q0 = sqrt(dP*1 / 1 psi * Gf)
            %       (Q/Q0)^2 = dP / 1 psi * Gf with Gf = rho/rho_water
            %       dP (in psi) = (Q/Q0)^2 * (rho/rho_water).
            %   Nicely, the units for rho don't matter nor do Q--although Q & Q0
            %   need to be consistent. We will convert the output to bar.
            %   
            %   For the purpose of being easy to read, I demand Q in gal/min * rho
            %   in kg/m3
            rho_water = 1000; % kg/m3
            Q = 60*Convert.m3_to_gal(self.get_volumetric_flow(mass_flow_kg_s)); % dimensionless
            delta_bar = Convert.psia_to_bar( ...
                    (Q/self.ball_valve_cv)^2 * (self.density/rho_water) ...
                );
        end

        function delta_bar = get_injector_pressure_drop(self, mass_flow_kg_s)
            % This one uses the mdot = CdA * sqrt(2 rho dp) equation
            % instead--> dp = 1/2 (mdot/CdA)^2 / rho
            delta_bar = 0.5 * (mass_flow_kg_s / self.injector_cda)^2 / self.density;
        end

        function delta_bar = get_line_pressure_drop(self, mass_flow_kg_s)
            delta_bar = self.line.get_pressure_drop( ...
                self.get_volumetric_flow(mass_flow_kg_s), ...
                self.density);
        end

        function m_s = get_line_velocity(self, mass_flow_kg_s)
            m_s = mass_flow_kg_s / self.density / self.line.area;
        end

        function Re = get_line_reynolds(self, mass_flow_kg_s)
            Re = self.get_line_velocity(mass_flow_kg_s) * self.density * self.line.diameter / self.dynamic_viscosity;
        end

        function m_s = get_injector_velocity(self, mass_flow_kg_s)
            dp = self.get_injector_pressure_drop(mass_flow_kg_s);
            % Bernoulli
            m_s = sqrt(dp/self.density + 0.5*self.get_line_velocity(mass_flow_kg_s)^2);
        end
    end
end

