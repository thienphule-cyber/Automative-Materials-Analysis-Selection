function [epsF, brittle] = materialDuctility(mat)
% Illustrative failure strain (engineering strain at fracture) of a material.
% ILLUSTRATIVE values only: replace with datasheet elongation data when available.
%
% epsF    : failure strain [-]
% brittle : true if the material is treated as brittle (elastic energy only)

switch mat.Name
    case 'Grey Cast Iron',    epsF = 0.005;
    case 'Steel AISI 1045',   epsF = 0.12;
    case 'AHSS DP600',        epsF = 0.15;
    case 'Aluminium 6061-T6', epsF = 0.12;
    case 'Aluminium A356-T6', epsF = 0.03;
    case 'PP',                epsF = 0.30;
    case 'ABS',               epsF = 0.15;
    case 'CFRP',              epsF = 0.015;
    otherwise                 % fallback by material class
        switch mat.Class
            case 'Composite', epsF = 0.015;
            otherwise,        epsF = 0.10;
        end
end

brittle = epsF < 0.02;
end