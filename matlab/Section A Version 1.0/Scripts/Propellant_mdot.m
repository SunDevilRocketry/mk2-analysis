% Propellant_mdot
% Nate Young (nfyoung1@asu.edu)
% updated 07/06/2024

disp(['Note: This deals with the ideal gas constant so please give units asked for' ...
    ' Or manually change R'])
Pc = input('Please input the Nozzle Stagnation Pressure in psi (Pc) >> ');
At = input('Please input Throat Area in square inches (At) >> ');
Tc = input('Please input chamber Temperature in degrees Fahrenheit (Tc) >> ');
gamma = input('Please input specific heat ratio of chamber (gamma) >> ');

Tc = Tc + 459.67; %Conversion to Rankine

%ideal gas constant
R = 10.73159; %ft^3 psi R^-1 lb-mol^-1
R = R * 1728.0070744076086; % Converstion to inch^3 from ft^3

mdot = mpdot(Pc,At,R,Tc,gamma);

disp(['The propellant Mass flow rate is (mdot): ', num2str(mdot),' lb/s'])


function mdot = mpdot(Pc,At,R,Tc,gamma)

mdot = Pc.*At./sqrt(R.*Tc) .* (gamma .* 2./(gamma+1)).^(1/2);

end



