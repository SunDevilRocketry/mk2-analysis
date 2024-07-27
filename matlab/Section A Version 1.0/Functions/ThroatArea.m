% ThroatArea
% Nate Young (nfyoung1@asu.edu)
% updated 07/04/24

% F: thrust
% Pc: chamber pressure
% Cf: coeff of pressure 

function At = ThroatArea(Cf,Pc,F)

At = F./(Cf.*Pc);

end
