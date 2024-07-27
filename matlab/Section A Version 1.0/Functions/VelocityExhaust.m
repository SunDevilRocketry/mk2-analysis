% VelocityExhaust
% Nate Young
% updated 07/06/2024


function Ve = VelocityExhaust(Pc,Tc,gammae,R,pe)

Ve = sqrt(2.*gammae./(gammae-1) .* R.*Tc.* (1 - (pe./Pc).^((gammae-1)./gammae)));

end