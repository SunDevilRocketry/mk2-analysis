Cv = 0.03; % gpm water @ 1 psi
dP = 475; % psi
density = 1142; % kg/m3


% This function takes a "Cv" value (really Q0) which must be reported
% in gal/min for water for a 1 psi drop over the valve. The function
% will return a delta_bar value after calculating the result in psi.
% Here is the derivation:
%   Known: Cv=Q*sqrt(Gf/dP) where Q is volumetric flow, Gf is specific
%   gravity, dP is pressure loss. Cv is a constant.
%   From the manufacturer, we have some Q0*sqrt(1/1 psi), which is
%   known to be equal to the general case. Thus:
%       Q/Q0 = sqrt(dP*1 / 1 psi * Gf)
%       (Q/Q0)^2 = dP / 1 psi * Gf with Gf = rho/rho_water
%       dP (in psi) = (Q/Q0)^2 * (rho/rho_water).
%   Nicely, the units for rho don't matter nor do Q--although Q & Q0
%   need to be consistent. We will convert the output to bar.
%   
%   For the purpose of being easy to read, I demand Q in gal/min & rho
%   in kg/m3
rho_water = 1000; % kg/m3
Gf = density/rho_water; % dimensionless
Q = Cv * sqrt(dP/Gf);
fprintf("Volumetric flow=%.3f gpm\n", Q);
fprintf("Volumetric flow=%.3f mL/s\n", 1e6*Convert.gal_to_m3(Q)/60);