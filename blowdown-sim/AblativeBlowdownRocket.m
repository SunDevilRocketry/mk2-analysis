classdef AblativeBlowdownRocket
    properties
        cea
        nominal_chamber_pressure
        of_ratio
        initial_throat_area
        nozzle_exit_area
        ablative_coeff
        fuel
        oxid
    end
    
    methods
        function obj = AblativeBlowdownRocket(NamedArgs)
            arguments
                NamedArgs.cea
                NamedArgs.nominal_chamber_pressure_psia
                NamedArgs.oxid_fuel_ratio
                NamedArgs.initial_throat_diam_inches
                NamedArgs.nozzle_exit_diam_inches
                NamedArgs.ablative_coeff_barm2K_s
                NamedArgs.fuel
                NamedArgs.oxid
            end
            obj.cea                 = NamedArgs.cea;
            obj.nominal_chamber_pressure = Convert.psia_to_bar(NamedArgs.nominal_chamber_pressure_psia);
            obj.of_ratio            = NamedArgs.oxid_fuel_ratio;
            obj.initial_throat_area = Convert.in_diameter_to_m2(NamedArgs.initial_throat_diam_inches);
            obj.nozzle_exit_area    = Convert.in_diameter_to_m2(NamedArgs.nozzle_exit_diam_inches);
            obj.ablative_coeff      = NamedArgs.ablative_coeff_barm2K_s;  % bar*m2*K/s
            obj.fuel                = NamedArgs.fuel;
            obj.oxid                = NamedArgs.oxid;
        end
    end
end
