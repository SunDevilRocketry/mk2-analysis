% MeExit
% Nate Young (nfyoung1@asu.edu)
% updated 07/06/2024

function Me = MeExit(Pc,gammae,gamma,pe)

Me = sqrt(2./(gamma-1) .*((Pc./pe).^(gammae-1./gammae)-1));

end