function k = thermalDerating(mat, Tc)
% Strength knockdown factor (0..1) of yield strength at temperature Tc [degC].
% ILLUSTRATIVE curves only: replace with datasheet / handbook data when available.

switch mat.Class
    case 'Polymer'
        Tpts = [23  60  80 120];  kpts = [1.00 0.55 0.30 0.05];
    case 'Composite'   % epoxy matrix dominated
        Tpts = [23  80 120 180];  kpts = [1.00 0.95 0.60 0.20];
    otherwise          % metals
        if contains(mat.Name, 'Aluminium')
            Tpts = [23 100 200 300];  kpts = [1.00 0.95 0.60 0.20];
        else           % steels and cast irons
            Tpts = [23 300 400 500];  kpts = [1.00 0.90 0.75 0.50];
        end
end

k = interp1(Tpts, kpts, Tc, 'linear', 'extrap');
k = min(max(k, 0.05), 1.0);   % clamp to a physically sensible range
end