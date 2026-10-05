function tc = defineThermalCase(Tref, Top, Tamb, restraint, P, h, Acool, tEnd)
% Build a thermal case struct.
%
% Tref      : stress-free (assembly) temperature [degC]
% Top       : design operating temperature [degC]
% Tamb      : ambient / coolant temperature [degC]
% restraint : constraint factor, 0 = free expansion, 1 = fully constrained
% P         : heat input power [W] (0 to skip the warm-up model)
% h         : convection coefficient [W/(m^2*K)]
% Acool     : cooling surface area [m^2]
% tEnd      : simulation time for the warm-up curve [s]

tc.Tref      = Tref;
tc.Top       = Top;
tc.Tamb      = Tamb;
tc.restraint = restraint;
tc.P         = P;
tc.h         = h;
tc.Acool     = Acool;
tc.tEnd      = tEnd;
end