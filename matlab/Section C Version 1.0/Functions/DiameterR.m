function Rd = DiameterR(B,roe_ox,roe_f,mdot_ox,mdot_f)

Rd = B.*(roe_ox./roe_f .* (mdot_ox./mdot_f).^2).^1.75;

end