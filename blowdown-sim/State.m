classdef State    
    properties
        % Constants
        rocket
        % State variables
        chamber_pressure
        fuel_volume
        oxid_volume
        eroded_thoat_area
    end
    
    methods
        function obj = State(RocketConsts, chamber_pressure, fuel_volume, oxid_volume, eroded_thoat_area)
            % Constants
            obj.rocket = RocketConsts;
            % State Variables
            obj.chamber_pressure = chamber_pressure;
            obj.fuel_volume = fuel_volume;
            obj.oxid_volume = oxid_volume;
            obj.eroded_thoat_area = eroded_thoat_area;
        end

        % Alias functions so we don't have to call
        % self.rocket.cea.interp_whatever(self.chamber_pressure) every time        
        function K = get_chamber_temperature(self)
            K = self.rocket.cea.interp_temperature_chamb(self.chamber_pressure);
        end        
        function kg_m3 = get_throat_density(self)
            kg_m3 = self.rocket.cea.interp_density_throat(self.chamber_pressure);
        end        
        function gamma = get_throat_gamma(self)
            gamma = self.rocket.cea.interp_gamma_throat(self.chamber_pressure);
        end        
        function m_s = get_throat_velocity(self)
            m_s = self.rocket.cea.interp_sonic_throat(self.chamber_pressure);
        end

        function kg_s = get_mass_flow_in_throat(self) 
            % Note that in pseudoequilibrium this mdot holds throughout the
            % entire system: nozzle exit/chamber/injector/plumbing/etc
            kg_s = self.get_throat_velocity()...
                * self.get_throat_density()...
                * self.eroded_thoat_area;
        end

        % Assuming fixed O/F for now...
        function kg_s = get_fuel_mass_flow(self)
            kg_s = 1 / (1 + self.rocket.of_ratio)...
                * self.get_mass_flow_in_throat();
        end
        function kg_s = get_oxid_mass_flow(self)
            kg_s = self.rocket.of_ratio / (1 + self.rocket.of_ratio)...
                * self.get_mass_flow_in_throat();
        end

        function m3 = get_fuel_pressure(self)
            m3 = self.rocket.fuel.get_tank_pressure(self.fuel_volume);
        end
        function m3 = get_oxid_pressure(self)
            m3 = self.rocket.oxid.get_tank_pressure(self.oxid_volume);
        end

        function m_s = get_fuel_line_velocity(self)
            m_s = self.rocket.fuel.get_line_velocity(self.get_fuel_mass_flow());
        end
        function m_s = get_oxid_line_velocity(self)
            m_s = self.rocket.oxid.get_line_velocity(self.get_oxid_mass_flow());
        end
        function m_s = get_fuel_injector_velocity(self)
            m_s = self.rocket.fuel.get_injector_velocity(self.get_fuel_mass_flow());
        end
        function m_s = get_oxid_injector_velocity(self)
            m_s = self.rocket.oxid.get_injector_velocity(self.get_oxid_mass_flow());
        end

        function Re = get_fuel_line_reynolds(self)
            Re = self.rocket.fuel.get_line_reynolds(self.get_fuel_mass_flow());
        end
        function Re = get_oxid_line_reynolds(self)
            Re = self.rocket.oxid.get_line_reynolds(self.get_oxid_mass_flow());
        end

        function bar = get_fuel_line_drop(self)
            bar = self.rocket.fuel.get_line_pressure_drop(self.get_fuel_mass_flow());
        end
        function bar = get_fuel_bv_drop(self)
            bar = self.rocket.fuel.get_bv_pressure_drop(self.get_fuel_mass_flow());
        end
        function bar = get_fuel_injector_drop(self)
            bar = self.rocket.fuel.get_injector_pressure_drop(self.get_fuel_mass_flow());
        end
        function bar = get_oxid_line_drop(self)
            bar = self.rocket.oxid.get_line_pressure_drop(self.get_oxid_mass_flow());
        end
        function bar = get_oxid_bv_drop(self)
            bar = self.rocket.oxid.get_bv_pressure_drop(self.get_oxid_mass_flow());
        end
        function bar = get_oxid_injector_drop(self)
            bar = self.rocket.oxid.get_injector_pressure_drop(self.get_oxid_mass_flow());
        end

        function bar = estimate_chamber_pressure(self)
            % This will be not in agreement with the self.chamber_pressure
            % value, but that's the point. We need to iterate until these
            % two values match--due to the nonlinearity of the minor losses
            % (& the nonlinearity of chamber pressure-->mdot) we can't do
            % this in one step.
            % Output for debugging.
            fuel_estimate = self.get_fuel_pressure() ...
                - self.get_fuel_line_drop() ...
                - self.get_fuel_bv_drop() ...
                - self.get_fuel_injector_drop();
            oxid_estimate = self.get_oxid_pressure() ...
                - self.get_oxid_line_drop() ...
                - self.get_oxid_bv_drop() ...
                - self.get_oxid_injector_drop();
            % Also, because we're assuming a constant OF ratio, we're
            % going to have to do some disgusting stuff to make this
            % work--the way we'll resolve this is by taking the average of
            % the fuel & ox pressure drops & treat this as real...
            bar = mean([fuel_estimate oxid_estimate]);
        end

        function m3_s = get_instanteous_change_in_fuel_volume(self)
            m3_s = -self.rocket.fuel.get_volumetric_flow(self.get_fuel_mass_flow());
        end
        function m3_s = get_instanteous_change_in_oxid_volume(self)
            m3_s = -self.rocket.oxid.get_volumetric_flow(self.get_oxid_mass_flow());
        end
        function m2_s = get_instantaneous_change_in_throat_area(self)
            % This probably ought to be changed to throat pressure and
            % throat temperature!
            m2_s = self.rocket.ablative_coeff...
                * self.eroded_thoat_area...
                * self.chamber_pressure...
                * self.get_chamber_temperature();
        end

        function Me = get_exit_mach(self)
            k = self.get_throat_gamma(); % Assuming gamma doesn't change
            expansion_ratio = self.rocket.nozzle_exit_area / self.eroded_thoat_area;
            AeAstar = @(Me) (1/Me)*((2/(k+1))*(1+((k-1)/2)*Me^2))^((k+1)/(2*(k-1)));
            Me = fzero(@(Me) AeAstar(Me)-expansion_ratio, 1.5); % Start guessing at Me=1.5;
        end

        function m_s = get_exit_velocity(self) %note I have NO CLUe where this came from
            % k = 1.2; % big assumption lol
            % expansion_ratio = self.rocket.nozzle_exit_area / self.eroded_thoat_area;
            % val = 1 + (k-1)/2 * (power(expansion_ratio, (k+1)/k) - 1);
            % if val < 0
            %     exit(1);
            % end
            % m_s = self.get_throat_velocity() * sqrt(val);
            m_s = self.get_throat_velocity()*self.get_exit_mach(); %assumes sonic doesn't change
        end

        function bar = get_exit_pressure(self)
            Me = self.get_exit_mach();
            k = self.get_throat_gamma();
            bar = self.chamber_pressure*power(1+(k-1)/2*Me^2, -k/(k-1));
        end

        function N = get_thrust(self)
            N = self.get_mass_flow_in_throat() * self.get_exit_velocity();
        end

        function of = get_o_f_ratio(self)
            of = self.get_oxid_mass_flow()/self.get_fuel_mass_flow();
        end
    end
end

