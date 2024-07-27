% Propellant_mdot
% Nate Young (nfyoung1@asu.edu)
% updated 07/06/2024

% eqn 8 from manuscript

function mdot = PropMdot(Pc,At,R,Tc,gamma)

mdot = Pc.*At./sqrt(R.*Tc) .* (gamma .* 2./(gamma+1)).^(1/2);

end