% Chamber_Volume
% Nate Young
% updated 07/04/2024

%Script to call Volume of combustion chamber from length

At = input('Please Enter Throat Area (At) >> '); 
Lstar = input('Please enter characteristic length (Lstar) >> '); 

Vc = ChamberVolume(Lstar,At); % Call the function


disp(['The chamber volume is (Vc) ', num2str(Vc)]) % Display the result

function Vc = ChamberVolume(Lstar,At)
Vc = Lstar.*At; 
end