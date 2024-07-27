% PMangle
% Nate Young
% updated 07/04/2024

function vme = PMangle(Me,gammae)

vme = (gammae+1)./(gammae-1).* atan(sqrt((gammae-1)./(gammae+1).*(Me.^2-1))) ...
    - atan(sqrt(Me.^2-1));

end