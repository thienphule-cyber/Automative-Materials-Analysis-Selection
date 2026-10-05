%% 
%% PHASE 2 - Mechanical Property & Static Load Analysis
clear; clc; close all;

load('materialLibrary.mat');   % loads T (materials) and C (components)

%% ---- USER INPUT ---------------------------------------------------------
component = 'Bumper';

sec = struct('type','rect', 'dims',[40 25]);   % b x h in mm

% defineLoadCase(type, F, L, section, requiredFoS, deflRatio)
%   type: 'axial' | 'cantilever' | 'simply' | 'torsion'
lc = defineLoadCase('cantilever', 3000, 300, sec, 1.5, 100);
% -------------------------------------------------------------------------

%% Analyse every candidate material of the selected component
cands = getCandidateMaterials(C, component);
res   = [];
for i = 1:numel(cands)
    m = getMaterial(T, cands{i});
    r = staticAnalysis(m, lc);
    if isempty(res), res = r; else, res(end+1) = r; end %#ok<SAGROW>
end

%% Print report
fprintf('\n=== STATIC ANALYSIS: %s ===\n', component);
fprintf('Load type: %s | F = %g | L = %g mm | Required FoS = %.2f\n\n', ...
    lc.type, lc.F, lc.L, lc.FoSReq);
fprintf('%-18s %9s %9s %9s %9s %6s %8s %6s\n', ...
    'Material','Stress','Strain','Defl[mm]','Sy[MPa]','FoS','Mass[kg]','Status');
for i = 1:numel(res)
    r = res(i);
    fprintf('%-18s %9.1f %9.5f %9.2f %9.0f %6.2f %8.2f %6s\n', ...
        r.Material, r.Stress_MPa, r.Strain, r.Defl_mm, ...
        r.Yield_MPa, r.FoS, r.Mass_kg, r.Status);
end

%% Plots
names = categorical({res.Material});
names = reordercats(names, {res.Material});

figure('Name','Phase 2 - Static results');
subplot(1,2,1);
bar(names, [res.FoS]); hold on;
yline(lc.FoSReq, 'r--', 'Required FoS', 'LineWidth', 1.5);
ylabel('Factor of Safety'); title('Strength'); grid on;

subplot(1,2,2);
bar(names, [res.Defl_mm]); hold on;
yline(res(1).DeflLim_mm, 'r--', 'Allowable deflection', 'LineWidth', 1.5);
ylabel('Deflection [mm]'); title('Stiffness'); grid on;

%% Save results for later phases
save('phase2_results.mat', 'res', 'lc', 'component');
disp('Saved phase2_results.mat');