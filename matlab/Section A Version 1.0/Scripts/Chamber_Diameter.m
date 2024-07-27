% Chamber_Diameter
% Nate Young (nfyoung1@asu.edu)
% updated 07/04/2024

%Diameter of the chamber 

AskMat = input('Are you using matrix inputs? (y/n) >> ',"s");

if strcmpi(AskMat,'y')
    Dt = input('Please input Diameter of the Throat (Dt) >> ');
    cva = input("Please input convergence angle (cva) >> ");
    Vc = input('Please input the chamber volume (Vc) >> ');
    Lstar = input('Please input the chamber length (Lstar) >> ');
    disp('Note that a "guess matrix" of equal length is needed')
    x0 = input('Please input an initial guess >> ');

    if ~isequal(size(Dt), size(cva), size(Vc), size(Lc), size(x0))
        disp('Error: All input matrices must be of the same size.')
    end

    Dc = zeros(size(Dt));
    
    for i = 1:length(Dt)
        Dc(i) = fzero(@(d) fDc(d, Dt(i), cva(i), Vc(i), Lstar(i)), x0(i));
    end

    disp(['The Diameter of the Chamber is (Dc) ', num2str(Dc)])

elseif strcmpi(AskMat,'n')
    Dt = input('Please input Diameter of the Throat (Dt) >> ');
    cva = input("Please input convergence angle (cva) >> ");
    Vc = input('Please input the chamber volume (Vc) >> ');
    Lstar = input('Please input the chamber length (Lstar) >> ');
    disp('Note that range can also be inputed')
    x0 = input('Please input an initial guess >> ');
    Dc = fzero(@(d) fDc(d, Dt, cva, Vc, Lstar), x0);

    disp(['The Diameter of the Chamber is (Dc) ', num2str(Dc)])
else
    disp('Error try again')
end


function f = fDc(d, Dt, cva, Vc, Lc)
f = sqrt((Dt.^2 + (24/pi) .*tan(cva) .*Vc) ./ (d+6 .*tan(cva) .*Lc)) - d;
end
