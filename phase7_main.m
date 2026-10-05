%% PHASE 7 - Vehicle-Level Analysis (command-line report)
clear; clc; close all;

S = load('materialLibrary.mat');  T = S.T;  C = S.C;
[spec, par] = defineVehicleDB();

% Use the Phase 6 weights if available, otherwise the default weights
crit = defineSelectionCriteria(25, 25, 15, 10, 15, 10);
if isfile('phase6_results.mat')
    P6 = load('phase6_results.mat');
    if isfield(P6, 'sel') && isfield(P6.sel, 'crit'), crit = P6.sel.crit; end
end

%% ---- USER INPUT ---------------------------------------------------------
vehType = 'BEV';          % 'ICE' | 'Hybrid' | 'BEV'
mode    = 'Optimised';    % 'Baseline' | 'Optimised'

custom = containers.Map('KeyType','char','ValueType','char');
% Manual override example (must be a candidate of that component):
% custom('Battery Enclosure') = 'CFRP';
% -------------------------------------------------------------------------

%% Analyse the selected vehicle
V  = analyzeVehicle(T, C, spec, par, crit, vehType, mode, custom);
tb = V.Tbl;

fprintf('\n=== VEHICLE ANALYSIS: %s | %s ===\n\n', vehType, mode);
fprintf('%-18s %4s %-18s %9s %10s %8s %7s %11s %6s\n', ...
    'Component','Qty','Material','Mass[kg]','Cost[USD]','Stress','FoSgov','Life[km]','Status');
for i = 1:height(tb)
    fprintf('%-18s %4.1f %-18s %9.2f %10.1f %8.1f %7.2f %11.2e %6s', ...
        tb.Component{i}, tb.Qty(i), tb.Material{i}, tb.MassTotal(i), ...
        tb.CostTotal(i), tb.Stress(i), tb.FoSGov(i), tb.LifeKm(i), tb.Status{i});
    if strcmp(tb.Status{i}, 'FAIL'), fprintf('  <-- fails: %s', tb.FailReason{i}); end
    fprintf('\n');
end

fprintf('\nTotal equivalent mass : %.1f kg\n', V.totalMass);
fprintf('Total material cost   : %.0f USD\n', V.totalCost);
fprintf('Minimum governing FoS : %.2f\n', V.minFoS);
fprintf('Components failing    : %d / %d\n', V.nFail, height(tb));
fprintf('Average material score: %.1f / 100\n', V.avgScore);

fprintf('\nMass by category:\n');
for k = 1:numel(V.catNames)
    fprintf('  %-16s %8.1f kg (%4.1f%%)\n', V.catNames{k}, V.massByCat(k), ...
        100*V.massByCat(k)/V.totalMass);
end
fprintf('\nMass by material class:\n');
for k = 1:numel(V.classNames)
    fprintf('  %-16s %8.1f kg (%4.1f%%)\n', V.classNames{k}, V.massByClass(k), ...
        100*V.massByClass(k)/V.totalMass);
end

%% Compare all vehicle types, Baseline vs Optimised
types = {'ICE','Hybrid','BEV'};
modes = {'Baseline','Optimised'};
noOverride = containers.Map('KeyType','char','ValueType','char');
M = zeros(3,2);  K = zeros(3,2);  NF = zeros(3,2);
for a = 1:3
    for b = 1:2
        Vx = analyzeVehicle(T, C, spec, par, crit, types{a}, modes{b}, noOverride);
        M(a,b) = Vx.totalMass;  K(a,b) = Vx.totalCost;  NF(a,b) = Vx.nFail;
    end
end

fprintf('\n=== VEHICLE COMPARISON ===\n');
fprintf('%-8s %12s %12s %9s %12s %12s %9s\n', 'Vehicle', ...
    'Mass base', 'Mass opt', 'Saving', 'Cost base', 'Cost opt', 'Fails(opt)');
for a = 1:3
    fprintf('%-8s %9.1f kg %9.1f kg %8.1f%% %8.0f USD %8.0f USD %9d\n', ...
        types{a}, M(a,1), M(a,2), 100*(M(a,1)-M(a,2))/M(a,1), K(a,1), K(a,2), NF(a,2));
end

%% Plots - selected vehicle
cn = categorical(tb.Component);
cn = reordercats(cn, tb.Component);

figure('Name', sprintf('Phase 7 - %s (%s)', vehType, mode));

subplot(2,3,1);
labels = cellfun(@(c,m) sprintf('%s %.0f%%', c, 100*m/V.totalMass), ...
    V.classNames(:), num2cell(V.massByClass(:)), 'UniformOutput', false);
pie(V.massByClass, labels);
title('Mass by material class');

subplot(2,3,2);
bar(categorical(V.catNames), V.massByCat);
ylabel('Mass [kg]'); title('Mass by category'); grid on;

subplot(2,3,3);
[ms, si] = sort(tb.MassTotal, 'descend');
sn = categorical(tb.Component(si));  sn = reordercats(sn, tb.Component(si));
bar(sn, ms);
ylabel('Mass [kg]'); title('Component mass breakdown'); grid on; xtickangle(45);

subplot(2,3,4);
b = bar(cn, tb.FoSGov);  b.FaceColor = 'flat';
for i = 1:height(tb)
    if strcmp(tb.Status{i}, 'PASS'), b.CData(i,:) = [0.2 0.7 0.3];
    else,                            b.CData(i,:) = [0.85 0.25 0.25]; end
end
yline(1, 'r--');
ylabel('Governing FoS'); title('Safety factor (green = PASS, red = FAIL)');
grid on; xtickangle(45);

subplot(2,3,5);
bar(cn, min(tb.LifeKm, 1e7));
set(gca, 'YScale', 'log');
yline(par.designKm, 'r--', 'Design life');
ylabel('Fatigue life [km]'); title('Fatigue life (capped at 1e7 km)');
grid on; xtickangle(45);

subplot(2,3,6);
bar(categorical(V.catNames), V.costByCat);
ylabel('Cost [USD]'); title('Material cost by category'); grid on;

%% Plots - vehicle comparison
figure('Name', 'Phase 7 - Vehicle comparison');
subplot(1,2,1);
bar(categorical(types), M); ylabel('Equivalent mass [kg]');
title('Mass'); legend(modes, 'Location', 'best'); grid on;
subplot(1,2,2);
bar(categorical(types), K); ylabel('Material cost [USD]');
title('Cost'); legend(modes, 'Location', 'best'); grid on;

%% Save
save('phase7_results.mat', 'V', 'vehType', 'mode', 'M', 'K');
disp('Saved phase7_results.mat');