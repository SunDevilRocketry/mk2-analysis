% ChamberDiameter
% Nate Young (nfyoung1@asu.edu)
% updated 07/04/2024

% Dt: throat diameter
% cva: converging half-angle
% Vc: chamber volume
% Lc: length of chamber
% x0: initial guess for nonlinear solver

function Dc = ChamberDiameter(Dt, cva, Vc, Lc, x0)

    if ~isequal(size(Dt), size(cva), size(Vc), size(Lc), size(x0))
        disp('Error: All input matrices must be of the same size.')
    end
   
    Dc = zeros(size(Dt));
    
    for i = 1:length(Dt)
        Dc(i) = fzero(@(d) fDc(d, Dt(i), cva(i), Vc(i), Lc(i)), x0(i));
    end

end



% solve eqn 5 from the manuscript
% Braeunig, R. A., “Rocket Propulsion,” Rocket & Space Technology, retrieved 25 April 2020.
% http://www.braeunig.us/space/index.htm

function f = fDc(d, Dt, cva, Vc, Lc)
    f = sqrt((Dt.^2 + (24/pi) * tan(cva) * Vc) / (d + 6 * tan(cva) * Lc)) - d;
end

% this is literally just solving for the diameter of a shape with given
% volume and geometry that of a cylinder (the chamber) with the converging
% section of the nozzle attached (makes the equation gross)