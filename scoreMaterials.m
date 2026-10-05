function out = scoreMaterials(D, crit, requireAllPass)
% Multi-criteria scoring: Score = sum_i w_i * S_i  (S_i in 0..100)
%
% Normalisation (relative to the best candidate, so the best = 100):
%   higher-is-better : S = 100 * x / max(x)
%   lower-is-better  : S = 100 * min(x) / x
%
% Criteria definitions:
%   Strength      = 50% static FoS (Phase 2) + 50% impact energy ratio (Phase 5)
%   Weight        = equivalent mass (Phase 5), lower is better
%   Fatigue       = log10(life in cycles) (Phase 4)
%   Thermal       = combined FoS at operating temperature (Phase 3)
%   Cost          = cost of the equivalent mass (Phase 5), lower is better
%   Manufacturing = manufacturability rating (0..100, illustrative)
%
% requireAllPass : true = materials that FAIL in any phase are not eligible
%                  to be recommended (they are still scored and shown).

n = height(D);

S = zeros(n, 6);
S(:,1) = 100 * (0.5*hi(D.FoS) + 0.5*hi(D.EnergyRatio));
S(:,2) = 100 * lo(D.EqMass);
S(:,3) = 100 * hi(D.LogN);
S(:,4) = 100 * hi(D.FoSThermal);
S(:,5) = 100 * lo(D.EqCost);
S(:,6) = D.Manuf;

w       = crit.w(:)';                   % 1 x 6
contrib = S .* w;                       % weighted contribution per criterion
total   = sum(contrib, 2);

if requireAllPass
    feasible = D.AllPass;
else
    feasible = true(n,1);
end

% Order: eligible materials first, then by descending total score
[~, order] = sortrows([~feasible, -total]);
rank = zeros(n,1);
rank(order) = (1:n)';

out.Material = D.Material;
out.S        = S;
out.contrib  = contrib;
out.total    = total;
out.feasible = feasible;
out.order    = order;
out.rank     = rank;
out.best     = order(1);
out.noFeasible = ~feasible(order(1));   % true if no material is eligible
end

function y = hi(x)
% higher is better, normalised to the maximum
x = max(x, 0);
y = x / max(max(x), eps);
end

function y = lo(x)
% lower is better, normalised to the minimum
x = max(x, eps);
y = min(x) ./ x;
end