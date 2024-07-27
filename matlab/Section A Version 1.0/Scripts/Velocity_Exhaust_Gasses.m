% Velocity_Exhaust_Gasses
% Nate Young
% updated 07/06/2024

Pc = input('Please input the Nozzle Stagnation Pressure in psi (Pc) >> ');
Tc = input('Please input chamber Temperature in degrees Fahrenheit (Tc) >> ');
gammae = input('Please input specific heat ratio of exhaust products (gammae) >> ');
Tc = Tc + 459.67; %Conversion to Rankine

%ideal gas constant
R = 10.73159; %ft^3 psi R^-1 lb-mol^-1

pe = 14.12; %psi (atm pressure in tempe)

%velocity of exhaust gasses

Ve = ve(Pc,Tc,gammae,R,pe);

disp(['The velocity of exaust gasses (Ve): ', num2str(Ve), 'ft/s'])

function Ve = ve(Pc,Tc,gammae,R,pe)

Ve = sqrt(2.*gammae./(gammae-1) .* R.*Tc.* (1 - (pe./Pc).^((gammae-1)./gammae)));

end