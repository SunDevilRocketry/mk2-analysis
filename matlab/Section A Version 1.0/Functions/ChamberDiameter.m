% ChamberDiameter
% Nate Young (nfyoung1@asu.edu)
% updated 07/04/2024

function Dc = ChamberDiameter(Dt, cva, Vc, Lc, x0)

    if ~isequal(size(Dt), size(cva), size(Vc), size(Lc), size(x0))
        disp('Error: All input matrices must be of the same size.')
    end
   
    Dc = zeros(size(Dt));
    
    for i = 1:length(Dt)
        Dc(i) = fzero(@(d) fDc(d, Dt(i), cva(i), Vc(i), Lc(i)), x0(i));
    end

end

function f = fDc(d, Dt, cva, Vc, Lc)
    f = sqrt((Dt.^2 + (24/pi) * tan(cva) * Vc) / (d + 6 * tan(cva) * Lc)) - d;
end
