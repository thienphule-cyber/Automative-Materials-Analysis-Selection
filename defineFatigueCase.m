function fc = defineFatigueCase(R, Kf, ks, kz, kr, cyclesPerKm, designKm, includeThermal)
% Build a fatigue case struct.
%
% R              : load ratio Fmin/Fmax (-1 = fully reversed, 0 = pulsating)
% Kf             : fatigue stress concentration factor (>= 1)
% ks             : surface finish factor (0..1), e.g. 0.8 machined, 0.6 forged
% kz             : size factor (0..1), e.g. 0.85 for medium sections
% kr             : reliability factor (0..1), e.g. 0.897 for 90%, 0.814 for 99%
% cyclesPerKm    : significant load cycles per km driven
% designKm       : required design life [km]
% includeThermal : true = add Phase 3 thermal stress as mean stress and
%                  derate strength at the operating temperature
%
% The peak load of the cycle is the Phase 2 load (sigma_max = Phase 2 stress).

fc.R              = R;
fc.Kf             = Kf;
fc.ks             = ks;
fc.kz             = kz;
fc.kr             = kr;
fc.cyclesPerKm    = cyclesPerKm;
fc.designKm       = designKm;
fc.Nreq           = cyclesPerKm * designKm;   % required number of cycles
fc.includeThermal = includeThermal;
end