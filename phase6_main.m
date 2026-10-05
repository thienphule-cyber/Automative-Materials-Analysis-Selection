%% PHASE 6 - Material Selection & Multi-Criteria Optimisation
clear; clc; close all;

load('materialLibrary.mat');    % T (materials), C (components)
load('phase2_results.mat');     % res  (Phase 2), lc, component
load('phase3_results.mat');     % res3 (Phase 3), tc
load('phase4_results.mat');     % res4 (Phase 4), fc
load('phase5_results.mat');     % res5 (Phase 5), ic

%% ---- USER INPUT ---------------------------------------------------------
% defineSelectionCriteria(Strength, Weight, Fatigue, Thermal, Cost, Manufacturing)
crit = defineSelectionCriteria(25, 25, 15, 10, 15, 10);   % weights in %

requireAllPass = true;   % true = a material that FAILS any phase cannot be recommended
nTrial         = 2000;   % Monte Carlo trials for the sensitivity analysis
spread         = 0.5;    % each weight is varied by +/-50% in the sensitivity analysis
% -------------------------------------------------------------------------

%% Collect raw metrics and score the materials
D   = collectPhaseResults(res, res3, res4, res5, T);
out = scoreMaterials(D, crit, requireAllPass);
sens = sensitivityAnalysis(out.S, crit.w, out.feasible, nTrial, spread);

%% Print report
fprintf('\n=== MATERIAL SELECTION ===\n');
fprintf('Weights: ');
for k = 1:numel(crit.names)
    fprintf('%s %.0f%% | ', crit.names{k}, 100*crit.w(k));
end
fprintf('\n\n');

fprintf('%-4s %-18s %8s %7s %8s %8s %6s %7s %8s %9s %9s\n', ...
    'Rank','Material','Strength','Weight','Fatigue','Thermal','Cost','Manuf', ...
    'Overall','Eligible','Win%');
for k = 1:height(D)
    i = out.order(k);
    fprintf('%-4d %-18s %8.1f %7.1f %8.1f %8.1f %6.1f %7.1f %8.1f %9s %8.1f%%\n', ...
        k, D.Material{i}, out.S(i,1), out.S(i,2), out.S(i,3), out.S(i,4), ...
        out.S(i,5), out.S(i,6), out.total(i), ...
        char(ternary(out.feasible(i),'yes','no')), sens.winPct(i));
end

fprintf('\n');
best = out.best;
if out.noFeasible
    fprintf('WARNING: no material passes all phases.\n');
    fprintf('Highest score (NOT eligible): %s (%.1f / 100)\n', D.Material{best}, out.total(best));
    fprintf('Consider a larger section, a different load case or other candidates.\n');
else
    fprintf('Recommended Material: %s (score %.1f / 100)\n', D.Material{best}, out.total(best));
    fprintf('Robustness: ranks first in %.1f%% of %d random weight sets (+/-%.0f%% on each weight).\n', ...
        sens.winPct(best), sens.nTrial, 100*sens.spread);
end

fprintf('\nRaw metrics:\n');
disp(D);

%% Plots
names = categorical(D.Material(out.order));
names = reordercats(names, D.Material(out.order));

figure('Name','Phase 6 - Material selection');

subplot(1,3,1);
bar(names, out.contrib(out.order,:), 'stacked');
ylabel('Weighted score'); title('Overall score by criterion');
legend(crit.names, 'Location','best'); grid on;

subplot(1,3,2);
bar(names, out.S(out.order,:));
ylabel('Criterion score [0-100]'); title('Normalised criterion scores');
legend(crit.names, 'Location','best'); grid on;

subplot(1,3,3);
bar(names, sens.winPct(out.order));
ylabel('Rank-1 frequency [%]');
title(sprintf('Sensitivity to weights (+/-%.0f%%)', 100*sens.spread)); grid on;

%% Save results for Phase 7
sel.component   = component;
sel.crit        = crit;
sel.D           = D;
sel.S           = out.S;
sel.total       = out.total;
sel.order       = out.order;
sel.feasible    = out.feasible;
sel.recommended = D.Material{best};
sel.recScore    = out.total(best);
sel.winPct      = sens.winPct;
save('phase6_results.mat', 'sel');
disp('Saved phase6_results.mat');

%% Local helper
function out = ternary(cond, a, b)
if cond, out = a; else, out = b; end
end