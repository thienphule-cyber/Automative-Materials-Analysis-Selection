function s = manufacturingScore(mat)
% Manufacturability score (0..100, higher = easier / cheaper to manufacture).
% ILLUSTRATIVE ratings only (formability, joining, tooling, scrap rate).
% Replace with your own assessment and cite the source in the README.

switch mat.Name
    case 'Grey Cast Iron',    s = 70;   % easy casting, poor weldability
    case 'Steel AISI 1045',   s = 85;   % forging, machining, welding
    case 'AHSS DP600',        s = 80;   % stamping with springback issues
    case 'Aluminium 6061-T6', s = 75;   % extrusion, machining, harder to weld
    case 'Aluminium A356-T6', s = 85;   % good castability
    case 'PP',                s = 95;   % injection moulding
    case 'ABS',               s = 95;   % injection moulding
    case 'CFRP',              s = 30;   % layup, long cycle time, joining
    otherwise                           % fallback by material class
        switch mat.Class
            case 'Polymer',   s = 90;
            case 'Composite', s = 30;
            otherwise,        s = 70;
        end
end
end