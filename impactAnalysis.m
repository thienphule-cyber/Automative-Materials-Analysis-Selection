function r = impactAnalysis(mat, ic)
% Energy absorption of one material under a simple impact model (analytical).
%
% mat : material struct from getMaterial
% ic  : impact case from defineImpactCase
%
% Model: simply supported beam, central load (three-point bending),
% quasi-static energy balance (this is NOT a crash simulation).
%   Ductile materials (rigid-plastic hinge with elastic start):
%       elastic stiffness  k  = 48*E*I/L^3
%       yield load         Fy = 4*Sy*I/(c*L)
%       plastic load       Fp = 4*Mp/L,  Mp = sigma_flow*Zp,
%                          sigma_flow = (Sy + UTS)/2  (strain hardening)
%       usable deformation d_cap = min(stroke, epsF*L)
%       (hinge rotation ~ 2*epsF, so midspan deflection ~ epsF*L)
%   Brittle materials: only elastic strain energy up to fracture at UTS.
%   SEA = E_absorbed / mass of the member.
%
% Assumptions: strain-rate effects, local buckling, section collapse and
% impact-induced temperature changes are NOT considered.

sp  = sectionProperties(ic.section);
Zp  = plasticModulus(ic.section);        % plastic section modulus [m^3]
E   = mat.E * 1e9;                       % Pa
Sy  = mat.Yield * 1e6;                   % Pa
UTS = mat.UTS * 1e6;                     % Pa
L   = ic.L / 1000;                       % m
str = ic.stroke / 1000;                  % m

[epsF, brittle] = materialDuctility(mat);

k = 48 * E * sp.I / L^3;                 % elastic stiffness [N/m]

if brittle
    Fy   = 4 * UTS * sp.I / (sp.c * L);  % fracture load (elastic) [N]
    Fp   = Fy;
    dEl  = Fy / k;
    dCap = dEl;                          % no plastic deformation
else
    Fy   = 4 * Sy * sp.I / (sp.c * L);   % first yield load [N]
    Fp   = 4 * ((Sy + UTS)/2) * Zp / L;  % plastic collapse load [N]
    dEl  = Fy / k;
    dCap = min(str, epsF * L);           % usable deformation [m]
end

% --- Energy capacity and energy demand ------------------------------------
Ecap = absorbedEnergy(dCap, k, Fy, Fp, dEl);      % [J]
Eel  = 0.5 * Fy * dEl;                            % elastic energy at yield [J]

Ereq = ic.Ereq;
if Ereq <= Eel
    dReq = sqrt(2 * Ereq / k);                    % still in elastic range
else
    dReq = dEl + (Ereq - Eel) / Fp;               % plastic range
end

% --- Mass, SEA and lightweighting indices ---------------------------------
mass = mat.Density * sp.A * L;                    % member mass [kg]
SEA  = Ecap / mass / 1e3;                         % [kJ/kg]
mEq  = ic.Ereq / (SEA * 1e3);                     % mass needed to absorb Ereq [kg]
cost = mEq * mat.Cost;                            % cost of equivalent mass [USD]

capOK = Ecap >= Ereq;

% --- Force-deformation curve for plotting ---------------------------------
if dCap > dEl
    dCurve = [0 dEl dEl dCap];
    FCurve = [0 Fy  Fp  Fp];
else
    dCurve = [0 dCap];
    FCurve = [0 k*dCap];
end

% --- Pack results ------------------------------------------------------------
r.Material      = mat.Name;
r.Mass_kg       = mass;
r.Brittle       = brittle;
r.EpsF          = epsF;
r.DuctLimited   = ~brittle && (epsF*L < str);     % ductility limits the stroke
r.Ereq_kJ       = Ereq / 1e3;
r.Ecap_kJ       = Ecap / 1e3;
r.EnergyRatio   = Ecap / Ereq;
r.Fpeak_kN      = max(FCurve) / 1e3;
r.DefReq_mm     = dReq * 1e3;
r.DefCap_mm     = dCap * 1e3;
r.SEA_kJkg      = SEA;
r.EqMass_kg     = mEq;
r.EqCost_USD    = cost;
r.MassSaving_pct   = NaN;                         % filled in phase5_main
r.EqMassSaving_pct = NaN;                         % filled in phase5_main
r.d_mm          = dCurve * 1e3;
r.F_kN          = FCurve / 1e3;
r.Status        = ternary(capOK, 'PASS', 'FAIL');
end

function Eabs = absorbedEnergy(d, k, Fy, Fp, dEl)
% Energy absorbed up to deformation d (elastic + plastic plateau)
if d <= dEl
    Eabs = 0.5 * k * d^2;
else
    Eabs = 0.5 * Fy * dEl + Fp * (d - dEl);
end
end

function Zp = plasticModulus(sec)
% Plastic section modulus [m^3] for the supported section types
d = sec.dims / 1000;
switch lower(sec.type)
    case 'rect', Zp = d(1) * d(2)^2 / 4;
    case 'circ', Zp = d(1)^3 / 6;
    case 'tube', Zp = (d(1)^3 - d(2)^3) / 6;
    otherwise,   error('Unknown section type: %s', sec.type);
end
end

function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end