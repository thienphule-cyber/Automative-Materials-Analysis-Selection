%% PHASE 4 - Fatigue & Service Life Analysis
clear; clc; close all;

load('materialLibrary.mat');    % T (materials), C (components)
load('phase2_results.mat');     % res (Phase 2), lc, component
load('phase3_results.mat');     % res3 (Phase 3), tc

%% ---- USER INPUT ---------------------------------------------------------
% defineFatigueCase(R, Kf, ks, kz, kr, cyclesPerKm, designKm, includeThermal)
fc = defineFatigueCase(0.1, 1.5, 0.8, 0.85, 0.897, 50, 200000, true);
% R = 0.1 (pulsating load), Kf = 1.5, machined surface, medium size,
% 90% reliability, 50 significant cycles per km, 200,000 km design life
% -------------------------------------------------------------------------

%% Analyse every material evaluated in Phase 2 / 3
res4 = [];
for i = 1:numel(res)
    m  = getMaterial(T, res(i).Material);
    r3 = [];
    if fc.includeThermal
        r3 = res3(strcmp({res3.Material}, res(i).Material));
    end
    r = fatigueAnalysis(m, res(i), r3, fc, tc.Top);
    if isempty(res4), res4 = r; else, res4(end+1) = r; end %#ok<SAGROW>
end

%% Print report
fprintf('\n=== FATIGUE ANALYSIS: %s ===\n', component);
fprintf('R = %.2f | Kf = %.2f | required life = %.2e cycles (%g km)\n', ...
    fc.R, fc.Kf, fc.Nreq, fc.designKm);
fprintf('Thermal effects included: %d\n\n', fc.includeThermal);
fprintf('%-18s %7s %7s %8s %7s %11s %11s %6s %6s\n', ...
    'Material','Sa','Sm','Sar','Se','N[cycles]','Life[km]','FoSf','Status');
for i = 1:numel(res4)
    r = res4(i);
    fprintf('%-18s %7.1f %7.1f %8.1f %7.1f %11.2e %11.2e %6.2f %6s', ...
        r.Material, r.Sa_MPa, r.Sm_MPa, r.Sar_MPa, r.Se_MPa, ...
        r.N, r.LifeKm, r.FoS_f, r.Status);
    if r.LowCycle,   fprintf('  <-- low-cycle, S-N model unreliable'); end
    if ~r.YieldOK,   fprintf('  <-- yields on first cycle'); end
    fprintf('\n');
end
fprintf('\n(Stresses in MPa. N = Inf means below the endurance limit.)\n');

%% Plots
Ncap  = 1e9;                                   % cap for plotting infinite life
names = categorical({res4.Material});
names = reordercats(names, {res4.Material});
cols  = lines(numel(res4));

figure('Name','Phase 4 - Fatigue results');

subplot(1,3,1); hold on;
for i = 1:numel(res4)
    loglog(res4(i).Nvec, res4(i).Svec, 'Color', cols(i,:), 'LineWidth', 1.5);
end
for i = 1:numel(res4)                          % operating points
    Np = min(res4(i).N, 1e8);
    Np = max(Np, 1e3);
    loglog(Np, res4(i).Sar_MPa, 'o', 'MarkerFaceColor', cols(i,:), ...
        'MarkerEdgeColor', 'k', 'HandleVisibility', 'off');
end
xline(fc.Nreq, 'r--', 'Required N');
set(gca, 'XScale', 'log', 'YScale', 'log');
xlabel('Cycles N'); ylabel('Stress amplitude [MPa]');
title('S-N curves and operating points');
legend({res4.Material}, 'Location', 'southwest'); grid on;

subplot(1,3,2);
bar(names, min([res4.N], Ncap)); hold on;
set(gca, 'YScale', 'log');
yline(fc.Nreq, 'r--', 'Required N', 'LineWidth', 1.5);
ylabel('Fatigue life [cycles]');
title('Life (capped at 1e9 if infinite)'); grid on;

subplot(1,3,3);
bar(names, [res4.FoS_f]); hold on;
yline(1, 'r--', 'FoS = 1', 'LineWidth', 1.5);
ylabel('Goodman fatigue FoS'); title('Fatigue safety factor'); grid on;

%% Save results for later phases
save('phase4_results.mat', 'res4', 'fc');
disp('Saved phase4_results.mat');