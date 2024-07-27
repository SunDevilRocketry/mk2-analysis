% Orifice_diameter
% Nate Young (nfyoung1@asu.edu)
% 07/3/2024

Cd = input('Please input the Discharge Coefficent (Cd) >> ');
mdot_ori = input('Please input the mass flow rate of the orifice (mdot_ori) >> ');
roe = input('Please input the density (roe) >> ');
dP = input('Please input the pressure drop across the orifice (dP) >> ');


Do = mfo(Cd,mdot_ori,roe,dP);

disp(['The diameter of the orifice is (Do): ', num2str(Do)])

function Do = mfo(Cd,mdot_ori,roe,dP)

Do = sqrt(mdot_ori.* (Cd.*pi./4.* sqrt(2.*roe.*dP)).^-1); 

end