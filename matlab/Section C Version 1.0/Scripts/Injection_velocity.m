% Injection_velocity
% Nate Young (nfyoung1@asu.edu)
% 07/3/2024

disp('*Assuming both fuel and oxidisor injected as incompressible liquids*')
mdot_ori = input('Please input the mass flow rate of the orifice (mdot_ori) >> ');
roe = input('Please input the density (roe) >> ');

calcAo = input('Do you already have the Area of the orifice exit? (y/n) >> ',"s");

if strcmpi(calcAo, 'y')
    Ao = input('Please input the Area (Ao) >> ');
else
    Do = input('Please input the Orifice Diameter (Do) >> ');
    Ao = pi/4 .* Do.^2;
end

Vinj = VI(mdot_ori,roe,Ao);

disp(['The injection velocity is (Vinj): ', num2str(Vinj)])

function Vinj = VI(mdot_ori,roe,Ao)

Vinj = mdot_ori./(roe.*Ao); 

end