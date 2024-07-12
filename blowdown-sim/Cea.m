classdef Cea
    properties
        p_chamb
        t_chamb
        rho_throat
        gam_throat
        son_throat
    end
    
    methods
        function obj = Cea(filename)
            % Load data from file
            data = readtable(filename, 'Delimiter', ',', 'Format', '%f%f%f%f%f');
            
            % Convert to a struct
            data = table2struct(data, 'ToScalar', true);
            
            % Assign properties
            obj.p_chamb = data.p_chamb;
            obj.t_chamb = data.t_chamb;
            obj.rho_throat = data.rho_throat;
            obj.gam_throat = data.gam_throat;
            obj.son_throat = data.son_throat;
        end
        
        function temperature_chamb = interp_temperature_chamb(obj, chamber_pressure)
            temperature_chamb = interp1(obj.p_chamb, obj.t_chamb, chamber_pressure);
        end
        
        function density_throat = interp_density_throat(obj, chamber_pressure)
            density_throat = interp1(obj.p_chamb, obj.rho_throat, chamber_pressure);
        end
        
        function gamma_throat = interp_gamma_throat(obj, chamber_pressure)
            gamma_throat = interp1(obj.p_chamb, obj.gam_throat, chamber_pressure);
        end
        
        function sonic_throat = interp_sonic_throat(obj, chamber_pressure)
            sonic_throat = interp1(obj.p_chamb, obj.son_throat, chamber_pressure);
        end
    end
end