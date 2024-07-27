% ExpansionRatio (7)
% Nate Young
% Updated 07/06/2024

% mach area rlnship
% Me = mach at exit
function epsilon = ExpansionRatio(Me,gammae)
epsilon = 1./Me .*(2./(gammae+1) .* (1+(gammae-1)./2 .* Me.^2)).^((gammae+1)./(2.*(gammae-1)));
end