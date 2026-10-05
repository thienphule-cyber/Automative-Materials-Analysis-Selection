function ic = defineImpactCase(mVeh, vKmh, absorbFrac, stroke, sec, L, baseline)
% Build an impact case struct (three-point bending of a beam, centre impact).
%
% mVeh       : impacting vehicle mass [kg]
% vKmh       : impact speed [km/h]
% absorbFrac : fraction of kinetic energy the member must absorb (0..1)
% stroke     : available crush stroke / allowable deformation [mm]
% sec        : section struct (see sectionProperties)
% L          : beam span [mm]
% baseline   : name of the baseline material for lightweighting comparison

v = vKmh / 3.6;                          % km/h -> m/s

ic.mVeh       = mVeh;
ic.vKmh       = vKmh;
ic.v          = v;
ic.Ek         = 0.5 * mVeh * v^2;        % Ek = 1/2*m*v^2 [J]
ic.absorbFrac = absorbFrac;
ic.Ereq       = absorbFrac * ic.Ek;      % energy the member must absorb [J]
ic.stroke     = stroke;
ic.section    = sec;
ic.L          = L;
ic.baseline   = baseline;
end