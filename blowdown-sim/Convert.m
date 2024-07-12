classdef Convert
    methods(Static)
        function bar = psia_to_bar(psia)
            bar = psia / 14.5038;
        end

        function m2 = in_diameter_to_m2(in_diameter)
            m2 = pi * (in_diameter / 39.3701 / 2)^2;
        end

        function m = in_to_m(inches)
            m = inches / 39.3701;
        end

        function m3 = gal_to_m3(gal)
            m3 = gal / 264.172;
        end

        function K = C_to_K(C)
            K = C + 273.15;
        end

        function N = lbf_to_N(lbf)
            N = lbf / 0.224809;
        end

        function psia = bar_to_psia(bar)
            psia = bar * 14.5038;
        end

        function in_diameter = m2_to_in_diameter(m2)
            in_diameter = 2 * sqrt(m2 / pi) * 39.3701;
        end

        function gal = m3_to_gal(m3)
            gal = m3 * 264.172;
        end

        function C = K_to_C(K)
            C = K - 273.15;
        end

        function lbf = N_to_lbf(N)
            lbf = N * 0.224809;
        end
    end
end