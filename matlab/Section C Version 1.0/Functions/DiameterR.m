% B: some experimentally determined coefficient
% roe_ox: oxidizer orifice radius
% roe_f: fuel orifice radius

% orifice sizing ratio from Elverum and Morey
% prescribe 𝐵 = 1.577 for an unlike triplet element.

function Rd = DiameterR(B,roe_ox,roe_f,mdot_ox,mdot_f)

Rd = B.*(roe_ox./roe_f .* (mdot_ox./mdot_f).^2).^1.75;

end