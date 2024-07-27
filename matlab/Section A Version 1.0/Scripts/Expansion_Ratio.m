% Expansion_ratio (7)
% Nate Young
% Updated 07/06/2024

Me = input('Please input the exit Mach number (Me) >> ');
gammae = input('Please input specfic heat ratio of exhaust products (gammae) >> '); %%% is this gamma e?

epsilon = esp(Me,gammae);

disp(['The expansion ratio is (epsilon) >> ', num2str(epsilon)])

At = input('Please input throat area (At) >> ');

Ae = epsilon.*At;

disp(['Nozzle exit area (Ae) >> ', num2str(Ae)])

function epsilon = esp(Me,gammae)

epsilon = 1./Me .*(2./(gammae+1) .* (1+(gammae-1)./2 .* Me.^2)).^((gammae+1)./(2.*(gammae-1)));

end