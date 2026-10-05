function phase7_dashboard()
% PHASE 7 - Automotive Material Analysis System (programmatic GUI).
% Requires MATLAB R2018b or later (uifigure + uigridlayout).
% Run with:  phase7_dashboard

S = load('materialLibrary.mat');
T = S.T;  C = S.C;
[spec, par] = defineVehicleDB();

crit = defineSelectionCriteria(25, 25, 15, 10, 15, 10);
if isfile('phase6_results.mat')
    P6 = load('phase6_results.mat');
    if isfield(P6, 'sel') && isfield(P6.sel, 'crit'), crit = P6.sel.crit; end
end

custom  = containers.Map('KeyType','char','ValueType','char');
V       = [];
selComp = '';

%% ---- Layout --------------------------------------------------------------
fig  = uifigure('Name', 'Automotive Material Analysis System', ...
                'Position', [40 40 1280 780]);
main = uigridlayout(fig, [1 2]);
main.ColumnWidth = {340, '1x'};

% Left column: controls + readout
left = uigridlayout(main, [10 1]);
left.Layout.Row = 1;  left.Layout.Column = 1;
left.RowHeight = {22, 28, 22, 28, 22, 28, 22, 28, 40, '1x'};

place(uilabel(left, 'Text', 'Vehicle',   'FontWeight', 'bold'), 1);
vehDD  = place(uidropdown(left, 'Items', {'ICE','Hybrid','BEV'}, 'Value', 'BEV'), 2);
place(uilabel(left, 'Text', 'Mode',      'FontWeight', 'bold'), 3);
modeDD = place(uidropdown(left, 'Items', {'Baseline','Optimised'}, 'Value', 'Optimised'), 4);
place(uilabel(left, 'Text', 'Component', 'FontWeight', 'bold'), 5);
compDD = place(uidropdown(left, 'Items', {'-'}), 6);
place(uilabel(left, 'Text', 'Material',  'FontWeight', 'bold'), 7);
matDD  = place(uidropdown(left, 'Items', {'-'}), 8);
statusLbl = place(uilabel(left, 'Text', '', 'FontSize', 15, 'FontWeight', 'bold', ...
    'HorizontalAlignment', 'center', 'BackgroundColor', [0.9 0.9 0.9]), 9);
readout = place(uitextarea(left, 'Editable', 'off', ...
    'FontName', 'Courier New', 'FontSize', 12), 10);

% Right column: summary + table + charts
right = uigridlayout(main, [3 1]);
right.Layout.Row = 1;  right.Layout.Column = 2;
right.RowHeight = {48, '1x', 260};

summaryLbl = place(uilabel(right, 'Text', '', 'FontSize', 14, 'FontWeight', 'bold', ...
    'WordWrap', 'on'), 1);
tbl = place(uitable(right), 2);
axg = place(uigridlayout(right, [1 3]), 3);
ax1 = place(uiaxes(axg), 1, 1);
ax2 = place(uiaxes(axg), 1, 2);
ax3 = place(uiaxes(axg), 1, 3);

%% ---- Callbacks -----------------------------------------------------------
vehDD.ValueChangedFcn  = @(~,~) refresh();
modeDD.ValueChangedFcn = @(~,~) onModeChange();
compDD.ValueChangedFcn = @(~,~) onCompChange();
matDD.ValueChangedFcn  = @(~,~) onMaterialChange();
tbl.CellSelectionCallback = @(~,evt) onTableSelect(evt);

refresh();

%% ---- Nested functions ----------------------------------------------------
    function refresh()
        V = analyzeVehicle(T, C, spec, par, crit, vehDD.Value, modeDD.Value, custom);
        comps = V.Tbl.Component;
        if ~any(strcmp(comps, selComp)), selComp = comps{1}; end
        compDD.Items = comps(:)';
        compDD.Value = selComp;
        updateReadout();
        updateTable();
        updateCharts();
    end

    function onModeChange()
        custom = containers.Map('KeyType','char','ValueType','char');  % reset overrides
        refresh();
    end

    function onCompChange()
        selComp = compDD.Value;
        updateReadout();
    end

    function onMaterialChange()
        custom(selComp) = matDD.Value;      % manual override for this component
        refresh();
    end

    function onTableSelect(evt)
        if isempty(evt.Indices), return; end
        selComp = V.Tbl.Component{evt.Indices(1)};
        compDD.Value = selComp;
        updateReadout();
    end

    function updateReadout()
        tb = V.Tbl;
        i  = find(strcmp(tb.Component, selComp), 1);
        rk = V.rank{i};

        matDD.Items = rk.cands(:)';
        matDD.Value = tb.Material{i};

        if isnan(tb.Defl_mm(i)), defStr = 'n/a';
        else, defStr = sprintf('%.2f mm', tb.Defl_mm(i)); end
        if isinf(tb.Cycles(i)), lifeStr = 'infinite (below endurance limit)';
        else, lifeStr = sprintf('%.2e cycles (%.2e km)', tb.Cycles(i), tb.LifeKm(i)); end

        L = {
            sprintf('Vehicle    : %s (%s)', vehDD.Value, modeDD.Value)
            sprintf('Component  : %s  x%.1f', tb.Component{i}, tb.Qty(i))
            sprintf('Material   : %s', tb.Material{i})
            ''
            '--- Mechanical ---'
            sprintf('Stress     : %.1f MPa', tb.Stress(i))
            sprintf('Strain     : %.5f', tb.Strain(i))
            sprintf('Deflection : %s', defStr)
            sprintf('FoS        : %.2f', tb.FoS(i))
            ''
            '--- Thermal ---'
            sprintf('Tmax       : %.0f C', tb.Top(i))
            sprintf('Expansion  : %.3f mm', tb.dL_mm(i))
            sprintf('Thermal str: %.1f MPa', tb.SigmaTh(i))
            sprintf('FoS (T)    : %.2f', tb.FoSThermal(i))
            ''
            '--- Fatigue ---'
            sprintf('Life       : %s', lifeStr)
            sprintf('Fatigue FoS: %.2f', tb.FoSf(i))
            ''
            '--- Selection ---'
            sprintf('Score      : %.1f / 100', tb.Score(i))
            sprintf('Best option: %s', tb.Recommended{i})
            sprintf('Mass       : %.2f kg each, %.2f kg total', tb.MassEach(i), tb.MassTotal(i))
            sprintf('Cost       : %.1f USD total', tb.CostTotal(i))
            };
        readout.Value = L;

        if strcmp(tb.Status{i}, 'FAIL')
            statusLbl.Text = ['NOT SUITABLE: ' tb.FailReason{i}];
            statusLbl.BackgroundColor = [0.96 0.70 0.70];
        elseif strcmp(tb.Material{i}, tb.Recommended{i})
            statusLbl.Text = 'RECOMMENDED';
            statusLbl.BackgroundColor = [0.70 0.90 0.70];
        else
            statusLbl.Text = ['ACCEPTABLE (best: ' tb.Recommended{i} ')'];
            statusLbl.BackgroundColor = [1.00 0.90 0.60];
        end
    end

    function updateTable()
        d = V.Tbl(:, {'Component','Qty','Material','MassTotal','CostTotal', ...
                      'Stress','FoSGov','LifeKm','Status'});
        d.MassTotal = round(d.MassTotal, 2);
        d.CostTotal = round(d.CostTotal, 1);
        d.Stress    = round(d.Stress, 1);
        d.FoSGov    = round(d.FoSGov, 2);
        tbl.Data       = d;
        tbl.ColumnName = {'Component','Qty','Material','Mass [kg]','Cost [USD]', ...
                          'Stress [MPa]','Gov. FoS','Life [km]','Status'};
        try   % row highlighting needs R2019b or later
            removeStyle(tbl);
            addStyle(tbl, uistyle('BackgroundColor', [1 0.8 0.8]), 'row', ...
                find(strcmp(d.Status, 'FAIL')));
        catch
        end

        summaryLbl.Text = sprintf(['%s | %s    Mass: %.1f kg    Cost: %.0f USD    ' ...
            'Failing: %d/%d    Min FoS: %.2f    Avg score: %.1f'], ...
            vehDD.Value, modeDD.Value, V.totalMass, V.totalCost, ...
            V.nFail, height(V.Tbl), V.minFoS, V.avgScore);
    end

    function updateCharts()
        % 1) Mass by material class
        cla(ax1);
        labels = cellfun(@(c,m) sprintf('%s %.0f%%', c, 100*m/V.totalMass), ...
            V.classNames(:), num2cell(V.massByClass(:)), 'UniformOutput', false);
        pie(ax1, V.massByClass, labels);
        title(ax1, 'Mass by material class');

        % 2) Mass by category
        cla(ax2);
        nc = numel(V.catNames);
        bar(ax2, 1:nc, V.massByCat);
        ax2.XTick = 1:nc;  ax2.XTickLabel = V.catNames;
        ax2.XTickLabelRotation = 45;
        ylabel(ax2, 'Mass [kg]');  title(ax2, 'Mass by category');
        grid(ax2, 'on');

        % 3) Governing factor of safety per component
        cla(ax3);
        n = height(V.Tbl);
        bar(ax3, 1:n, V.Tbl.FoSGov);
        hold(ax3, 'on');
        plot(ax3, [0.5 n+0.5], [1 1], 'r--');
        hold(ax3, 'off');
        ax3.XTick = 1:n;  ax3.XTickLabel = V.Tbl.Component;
        ax3.XTickLabelRotation = 60;
        ylabel(ax3, 'Governing FoS');  title(ax3, 'Safety factor distribution');
        grid(ax3, 'on');
    end
end

function h = place(h, row, col)
% Helper: set the grid position of a UI component
h.Layout.Row = row;
if nargin > 2, h.Layout.Column = col; end
end