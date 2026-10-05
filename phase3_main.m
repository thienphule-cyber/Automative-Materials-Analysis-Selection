%% PHASE 3 - Thermal & Thermo-Mechanical Analysis
clear; clc; close all;

load('materialLibrary.mat');    % T (materials), C (components)
load('phase2_results.mat');     % res (Phase 2 results), lc, component

%% ---- USER INPUT ---------------------------------------------------------
% defineThermalCase(Tref, Top, Tamb, restraint, P, h, Acool, tEnd)
tc = defineThermalCase(20, 120, 25, 0.3, 500, 25, 0.05, 1800);
% Tref=20 degC, Top=120 degC, Tamb=25 degC, 30% restrained,
% 500 W heat input, h=25 W/m^2K, 0.05 m^2 cooling area, 30 min simulation
% -------------------------------------------------------------------------

%% Analyse every material that was evaluated in Phase 2
res3 = [];
for i = 1:numel(res)
    m = getMaterial(T, res(i).Material);
    r = thermalAnalysis(m, lc, res(i), tc);
    if isempty(res3), res3 = r; else, res3(end+1) = r; end %#ok<SAGROW>
end

%% Print report
fprintf('\n=== THERMO-MECHANICAL ANALYSIS: %s ===\n', component);
fprintf('Tref = %g C | Top = %g C | restraint = %.2f | required FoS = %.2f\n\n', ...
    tc.Tref, tc.Top, tc.restraint, lc.FoSReq);
fprintf('%-18s %8s %9s %9s %9s %7s %7s %6s\n', ...
    'Material','dL[mm]','SigTh','SigComb','Sy(T)','Derate','FoS','Status');
for i = 1:numel(res3)
    r = res3(i);
    fprintf('%-18s %8.3f %9.1f %9.1f %9.1f %7.2f %7.2f %6s\n', ...
        r.Material, r.dL_free_mm, r.SigmaTh_MPa, r.SigmaComb, ...
        r.YieldT_MPa, r.Derating, r.FoS_comb, r.Status);
end

fprintf('\nWarm-up model (lumped):\n');
for i = 1:numel(res3)
    r = res3(i);
    fprintf('  %-18s Q = %7.1f kJ | Tss = %6.1f C | tau = %7.1f s', ...
        r.Material, r.Q_kJ, r.Tss_C, r.Tau_s);
    if r.TempWarn, fprintf('  <-- Tss exceeds design temperature'); end
    fprintf('\n');
end

%% Plots
names = categorical({res3.Material});
names = reordercats(names, {res3.Material});

figure('Name','Phase 3 - Thermo-mechanical results');
subplot(2,2,1);
bar(names, [[res3.SigmaMech]' [res3.SigmaTh_MPa]'], 'stacked');
ylabel('Stress [MPa]'); title('Mechanical + thermal stress');
legend('Mechanical','Thermal','Location','best'); grid on;

subplot(2,2,2);
bar(names, [res3.FoS_comb]); hold on;
yline(lc.FoSReq, 'r--', 'Required FoS', 'LineWidth', 1.5);
ylabel('Combined FoS'); title('Safety at operating temperature'); grid on;

subplot(2,2,3);
bar(names, [res3.dL_free_mm]);
ylabel('Free expansion [mm]'); title('Thermal expansion'); grid on;

subplot(2,2,4); hold on;
for i = 1:numel(res3)
    plot(res3(i).t/60, res3(i).Tt, 'LineWidth', 1.5);
end
yline(tc.Top, 'r--', 'Design T');
xlabel('Time [min]'); ylabel('Temperature [\circC]');
title('Warm-up curve'); legend({res3.Material}, 'Location','best'); grid on;

%% Save results for later phases
save('phase3_results.mat', 'res3', 'tc');
disp('Saved phase3_results.mat');