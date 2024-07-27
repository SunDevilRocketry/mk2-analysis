% Me_Exit
% Nate Young (nfyoung1@asu.edu)
% updated 07/06/2024

disp(['Note: Pc MUST be in psi or will have to change atmospheric pressure' ...
    ' in script manually '])
Pc = input('Please input the Nozzle Stagnation Pressure (Pc) (psi) >> ');
gammae = input('Please input specfic heat ratio of exhaust products (gammae) >> ');
gamma = input('Please input specfic heat ratio of chamber (gamma) >> ');

%add input
pe = 14.12; %psi (atm pressure in tempe)
disp('Saved variable pe which corresponds to Atmospheric Pressure in Tempe in psi')

Me = me(Pc,gammae,gamma,pe);

disp(['The Mach number of gasses at the exit plane of nozzle is >> ', num2str(Me)]) 

function Me = me(Pc,gammae,gamma,pe)

Me = sqrt(2./(gamma-1) .*((Pc./pe).^(gammae-1./gammae)-1));

end