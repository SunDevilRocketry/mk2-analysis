% Throat_Area
% Nate Young (nfyoung1@asu.edu)
% updated 07/04/24

%inputs
Cf = input('Please enter Coefficient of Thrust (Cf) >> ');
F = input('Please enter Thrust in lbf (F) >> ');
Pc = input('Please enter the nozzle stagnation pressure in psig (Pc) >> ');

At = ThroatArea(Cf, Pc, F); % Call the function

disp(['The throat area (At) is ', num2str(At), ' square inches']); % Display the result


function At = ThroatArea(Cf,Pc,F)

At = F./(Cf.*Pc);

end

