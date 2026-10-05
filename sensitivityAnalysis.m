function out = sensitivityAnalysis(S, w, feasible, nTrial, spread)
% Monte Carlo sensitivity of the ranking to the criteria weights.
%
% S        : n x 6 matrix of criterion scores (from scoreMaterials)
% w        : 1 x 6 nominal weights (sum = 1)
% feasible : n x 1 logical, materials eligible to be recommended
% nTrial   : number of random weight sets (e.g. 2000)
% spread   : relative perturbation, e.g. 0.5 -> each weight varies +/-50%
%
% Output: winPct = percentage of trials in which each material ranks first
%         (among the eligible ones). A high value for one material means the
%         recommendation is robust to the choice of weights.

n = size(S, 1);
w = w(:)';

cand = find(feasible);
if isempty(cand), cand = (1:n)'; end

rng(1);                                  % reproducible results
wins = zeros(n, 1);
for k = 1:nTrial
    wk = w .* (1 + spread*(2*rand(size(w)) - 1));
    wk = wk / sum(wk);
    [~, iBest] = max(S(cand,:) * wk');
    wins(cand(iBest)) = wins(cand(iBest)) + 1;
end

out.winPct = 100 * wins / nTrial;
out.nTrial = nTrial;
out.spread = spread;
end