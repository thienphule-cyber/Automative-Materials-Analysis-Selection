function T = createMaterialDB()
vars = {'Name','Class','Density','E','Yield','UTS','Poisson', ...
    'k','cp','alpha','Fatigue','Cost'};

data = {
    'Grey Cast Iron',    'Metal',   7200, 110, 165, 250, 0.26,  46,  460, 11.0, 100,  1.0;
    'Steel AISI 1045',   'Metal',   7850, 205, 530, 625, 0.29,  49,  486, 11.5, 280,  1.0;
    'AHSS DP600',        'Metal',   7850, 205, 400, 600, 0.29,  45,  480, 12.0, 300,  1.3;
    'Aluminium 6061-T6', 'Metal',   2700,  69, 276, 310, 0.33, 167,  896, 23.6,  96,  3.0;
    'Aluminium A356-T6', 'Metal',   2680,  72, 165, 230, 0.33, 151,  963, 21.5,  75,  3.0;
    'PP',                'Polymer',  905, 1.5,  30,  35, 0.42, 0.22, 1700, 100,   12,  1.5;
    'ABS',               'Polymer', 1050, 2.3,  40,  44, 0.35, 0.18, 1400,  90,   15,  2.0;
    'CFRP',              'Composite',1550, 70, 600, 600, 0.30,   5,  800,   2,  300, 40.0;
    };

T = cell2table(data, 'VariableNames', vars);
T.Properties.VariableUnits = {'','','kg/m^3','GPa','MPa','MPa','-', ...
    'W/(m*K)','J/(kg*K)','1e-6/K','MPa (1e7 chu ky)','USD/kg'};
end