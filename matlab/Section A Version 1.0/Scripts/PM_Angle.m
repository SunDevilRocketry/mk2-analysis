% PM_angle
% Nate Young
% updated 07/04/2024
% Prandtl-Meyer_Angle (v) & Convergant angle (alpha)

%inputs

Me = input('Please Input the Mach number of gas at the exit (Me) >>');
gammae = input(['Please input the specific heat ratio of exhaust products ' ...
    'at the exit (gammae) >>'] );

%Call function
vme = PMA(gammae,Me);

%Display Results
disp(['Prandtl-Meyer Angle is (vme)', num2str(vme)]) % Display the result

%Ask about Convergent Angle
calccva = input(['Do you want to calulate the Convergent Angle (Alpha) for ' ...
    'this Prandtl-Meyer Angle (vme) ? (y/n) >> '],"s");

if strcmpi(calccva, 'y')
    vme;
    alpha = vme./2;
    disp(['The Convergent Angle is (alpha)', num2str(alpha),])  % Display the result
else
    disp('Calculation ended');
end



function vme = PMA(Me,gammae)

vme = (gammae+1)./(gammae-1).* atan(sqrt((gammae-1)./(gammae+1).*(Me.^2-1))) ...
    - atan(sqrt(Me.^2-1));

end
