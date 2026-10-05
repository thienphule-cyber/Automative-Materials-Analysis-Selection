function C = createComponentDB()
data = {
    'Engine',         'Engine Block',      {'Grey Cast Iron','Aluminium A356-T6'};
    'Engine',         'Crankshaft',        {'Steel AISI 1045'};
    'Engine',         'Connecting Rod',    {'Steel AISI 1045','Aluminium 6061-T6'};
    'Transmission',   'Gear Housing',      {'Aluminium A356-T6','Grey Cast Iron'};
    'Transmission',   'Driveshaft',        {'Steel AISI 1045','CFRP'};
    'Chassis',        'Chassis Rail',      {'AHSS DP600','Aluminium 6061-T6','CFRP'};
    'Suspension',     'Suspension Arm',    {'Steel AISI 1045','Aluminium 6061-T6'};
    'Braking',        'Brake Disc',        {'Grey Cast Iron'};
    'Braking',        'Brake Caliper',     {'Aluminium A356-T6','Grey Cast Iron'};
    'Exterior',       'Bumper',            {'PP','ABS','Aluminium 6061-T6','AHSS DP600'};
    'Exterior',       'Body Panel',        {'AHSS DP600','Aluminium 6061-T6','CFRP'};
    'Interior',       'Dashboard',         {'PP','ABS'};
    'Interior',       'Seat Frame',        {'AHSS DP600','Aluminium 6061-T6'};
    'EV System',      'Battery Enclosure', {'Aluminium 6061-T6','AHSS DP600','CFRP'};
    'EV System',      'Motor Housing',     {'Aluminium A356-T6'};
    'Thermal System', 'Radiator',          {'Aluminium 6061-T6'};
    'Thermal System', 'Exhaust Manifold',  {'Grey Cast Iron'};
    };

C = cell2table(data, 'VariableNames', {'Category','Component','Materials'});
end