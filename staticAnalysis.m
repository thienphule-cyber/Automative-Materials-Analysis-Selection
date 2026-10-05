function r = staticAnalysis(mat, lc)
% Static analysis of one material under one load case (analytical 1D models).
%
% mat : material struct from getMaterial (E in GPa, Yield/UTS in MPa)
% lc  : load case struct from defineLoadCase
%
% Assumptions: linear elastic, isotropic, small deformation, uniform section,
% stress concentrations and buckling are NOT considered.

sp = sectionProperties(lc.section);
E  = mat.E * 1e9;          % GPa -> Pa
Sy = mat.Yield;            % MPa
L  = lc.L / 1000;          % mm -> m
F  = lc.F;

delta = NaN;               % deflection [m]
twist = NaN;               % angle of twist [rad]

switch lc.type
    case 'axial'
        sigma = F / sp.A;                    % sigma = F/A
        delta = F*L / (sp.A*E);              % delta = FL/(AE)

    case 'cantilever'
        M     = F*L;                         % max moment at the fixed end
        sigma = M*sp.c / sp.I;               % sigma = Mc/I
        delta = F*L^3 / (3*E*sp.I);          % delta = FL^3/(3EI)

    case 'simply'
        M     = F*L/4;                       % max moment at mid-span
        sigma = M*sp.c / sp.I;
        delta = F*L^3 / (48*E*sp.I);         % delta = FL^3/(48EI)

    case 'torsion'
        if isnan(sp.J)
            error('Torsion requires a circular or tube section.');
        end
        T     = F;                           % torque [N*m]
        tau   = T*sp.c / sp.J;               % tau = Tc/J
        sigma = sqrt(3)*tau;                 % von Mises equivalent stress
        G     = E / (2*(1 + mat.Poisson));   % shear modulus
        twist = T*L / (G*sp.J);              % theta = TL/(GJ)

    otherwise
        error('Unknown load type: %s', lc.type);
end

sigma_MPa = abs(sigma) / 1e6;                % Pa -> MPa
strain    = abs(sigma) / E;                  % epsilon = sigma/E (elastic)
FoS       = Sy / sigma_MPa;                  % FoS = sigma_y / sigma_max

% Deflection check (skipped for torsion or if deflRatio is Inf)
deflLimit = L / lc.deflRatio;                % [m]
if isnan(delta) || isinf(lc.deflRatio)
    deflOK = true;
else
    deflOK = abs(delta) <= deflLimit;
end

strengthOK = FoS >= lc.FoSReq;

% Pack results
r.Material   = mat.Name;
r.Stress_MPa = sigma_MPa;
r.Strain     = strain;
r.Defl_mm    = abs(delta)*1000;
r.DeflLim_mm = deflLimit*1000;
r.Twist_deg  = rad2deg(twist);
r.Yield_MPa  = Sy;
r.FoS        = FoS;
r.Mass_kg    = mat.Density * sp.A * L;       % mass of the member
r.StrengthOK = strengthOK;
r.DeflOK     = deflOK;
r.Status     = ternary(strengthOK && deflOK, 'PASS', 'FAIL');
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end