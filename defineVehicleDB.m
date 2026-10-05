function [spec, par] = defineVehicleDB()
% Vehicle component database. Each component is idealised as ONE equivalent
% 1D structural member (same models as Phases 2-4).
%
% Columns:
%   Component, Category : must match the names used in createComponentDB
%   SecType, Dim1, Dim2 : section type and dimensions [mm]
%                         'rect' = b x h, 'tube' = do x di, 'circ' = d (Dim2 unused)
%   L                   : member length [mm]
%   LoadType, F         : 'axial' | 'cantilever' | 'simply' | 'torsion',
%                         F in N (N*m for torsion)
%   FoSReq, DeflRatio   : required factor of safety, allowable deflection = L/DeflRatio
%   Top                 : operating temperature [degC]
%   Restraint           : thermal restraint factor (0 = free, 1 = fully constrained)
%   R, Kf               : fatigue load ratio and stress concentration factor
%   CyclesPerKm         : significant load cycles per km
%   nICE, nHybrid, nBEV : quantity per vehicle (0 = not fitted; fractional values
%                         represent a scaled component, e.g. a smaller hybrid battery)
%
% ALL VALUES ARE ILLUSTRATIVE ASSUMPTIONS: replace with your own data.

vars = {'Component','Category','SecType','Dim1','Dim2','L','LoadType','F', ...
    'FoSReq','DeflRatio','Top','Restraint','R','Kf','CyclesPerKm', ...
    'nICE','nHybrid','nBEV'};

data = {
    'Engine Block',      'Engine',         'tube',  120, 100,  250, 'axial',      150000, 2.0, 1000, 110, 0.20,  0.1, 1.5,   50, 1,   1,   0;
    'Crankshaft',        'Engine',         'circ',   35,   0,  300, 'torsion',       400, 2.0,  Inf, 100, 0.00, -1.0, 1.5, 1000, 1,   1,   0;
    'Connecting Rod',    'Engine',         'rect',   20,  12,  150, 'axial',       20000, 2.0, 1000, 120, 0.00, -1.0, 1.3, 1000, 4,   4,   0;
    'Gear Housing',      'Transmission',   'rect',   80,  15,  100, 'cantilever',   2000, 1.5,  100, 100, 0.10,  0.1, 1.2,  100, 1,   1,   1;
    'Driveshaft',        'Transmission',   'tube',   40,  32, 1000, 'torsion',       400, 2.0,  Inf,  80, 0.00, -1.0, 1.3, 1000, 1,   1,   1;
    'Chassis Rail',      'Chassis',        'tube',   60,  52,  800, 'simply',      6000, 1.5,  200,  80, 0.00,  0.1, 1.5,  200, 2,   2,   2;
    'Suspension Arm',    'Suspension',     'rect',   40,  25,  250, 'cantilever',   2000, 1.5,   50,  80, 0.00,  0.1, 1.3,  200, 4,   4,   4;
    'Brake Disc',        'Braking',        'tube',  300, 160,   20, 'axial',      300000, 1.5, 1000, 400, 0.10,  0.1, 1.5,  300, 4,   4,   4;
    'Brake Caliper',     'Braking',        'rect',   40,  25,  120, 'cantilever',   1500, 1.5,  100, 150, 0.10,  0.1, 1.5,  300, 4,   4,   4;
    'Bumper',            'Exterior',       'tube',   60,  54, 1000, 'simply',      1000, 1.5,  100,  60, 0.10,  0.1, 1.5,   20, 2,   2,   2;
    'Body Panel',        'Exterior',       'rect',  500,   3,  500, 'simply',       200, 1.5,   50,  80, 0.05,  0.1, 1.5,  100, 6,   6,   6;
    'Dashboard',         'Interior',       'rect',  200,  10,  300, 'cantilever',     20, 1.5,   20,  50, 0.10,  0.1, 1.5,   20, 1,   1,   1;
    'Seat Frame',        'Interior',       'tube',   40,  36,  350, 'cantilever',   1000, 1.5,   50,  60, 0.00,  0.1, 1.5,   50, 2,   2,   2;
    'Battery Enclosure', 'EV System',      'rect', 1500,  15, 1000, 'simply',     11800, 1.5,  100,  85, 0.10,  0.1, 1.5,  200, 0,   0.3, 1;
    'Motor Housing',     'EV System',      'tube',  220, 200,  300, 'cantilever',   3000, 1.5,  100, 120, 0.20,  0.1, 1.5,  300, 0,   1,   1;
    'Radiator',          'Thermal System', 'rect',  400,   3,  400, 'simply',         30, 1.5,   50, 105, 0.00,  0.1, 1.5,  100, 1,   1,   1;
    'Exhaust Manifold',  'Thermal System', 'tube',   60,  50,  300, 'cantilever',    500, 1.5,   50, 450, 0.05,  0.1, 1.5,  300, 1,   1,   0;
    };

spec = cell2table(data, 'VariableNames', vars);

% Global parameters shared by all components
par.Tref     = 20;       % stress-free (assembly) temperature [degC]
par.Tamb     = 25;       % ambient temperature [degC]
par.ks       = 0.8;      % surface finish factor
par.kz       = 0.85;     % size factor
par.kr       = 0.897;    % reliability factor (90%)
par.designKm = 200000;   % required design life [km]
end