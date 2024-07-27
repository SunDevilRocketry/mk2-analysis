% Valve_ratio_error
% Nate Young (nfyoung1@asu.edu)
% 07/3/2024

Rd = input('Please input the ideal diameter ratio (Rd) >> ');
Df = input('Please input the diameter of the fuel orifices (Df) >> ');
Dox = input('Please input the diameter of the oxidizer orifices (Dox) >> ');

eR = erR(Rd,Df,Dox);

disp(['The error between ideal and derived ratios is (eR)): ', num2str(eR)])

function eR = erR(Rd,Df,Dox)

eR = abs( Df./Dox - Rd );

end