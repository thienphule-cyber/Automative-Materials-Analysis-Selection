function lc = defineLoadCase(type, F, L, sec, FoSReq, deflRatio)
% Build a load case struct.
%
% type      : 'axial'        - axial tension/compression, F in N
%             'cantilever'   - cantilever with end load, F in N
%             'simply'       - simply supported beam, central load, F in N
%             'torsion'      - circular shaft under torque, F is torque T in N*m
% F         : load magnitude (N, or N*m for torsion)
% L         : length [mm]
% sec       : section struct (see sectionProperties)
% FoSReq    : required minimum factor of safety (e.g. 1.5)
% deflRatio : allowable deflection = L/deflRatio (e.g. 100); use Inf to skip

lc.type      = lower(type);
lc.F         = F;
lc.L         = L;
lc.section   = sec;
lc.FoSReq    = FoSReq;
lc.deflRatio = deflRatio;
end