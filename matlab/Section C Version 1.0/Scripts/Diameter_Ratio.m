% Diameter_ratio
% Nate Young (nfyoung1@asu.edu)
% 07/3/2024

disp('(B=1.577 for an unlike triplet element)')
B = input('Please input experimental multiplier (B) >> ');
roe_ox = input('Please input the density of fuel (roe_f) >> ');
roe_f = input('Please input density of fuel (roe_f) >> ');
mdot_ox = input('Please input mass flow rate of the oxidizer (mdot_ox) >> ');
mdot_f = input('Please input mass flow rate of the fuel (mdot_f) >> ');


Rd = Drat(B,roe_ox,roe_f,mdot_ox,mdot_f);


disp(['The ideal diameter Ratio (Rd): ', num2str(Rd)])

function Rd = Drat(B,roe_ox,roe_f,mdot_ox,mdot_f)

Rd = B.*(roe_ox./roe_f .* (mdot_ox./mdot_f).^2).^1.75;

end