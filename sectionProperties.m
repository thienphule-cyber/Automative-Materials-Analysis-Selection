function s = sectionProperties(sec)
% Compute cross-section properties in SI units.
% sec.type : 'rect' | 'circ' | 'tube'
% sec.dims : [b h] (rect), [d] (circ), [do di] (tube), all in mm
%            for 'rect', h is the dimension along the bending direction
%
% Output (SI): A [m^2], I [m^4], c [m] (distance to extreme fibre),
%              J [m^4] (polar moment, circular sections only)

d = sec.dims / 1000;   % mm -> m

switch lower(sec.type)
    case 'rect'
        b = d(1); h = d(2);
        s.A = b*h;
        s.I = b*h^3/12;
        s.c = h/2;
        s.J = NaN;     % torsion of rectangular sections not supported
    case 'circ'
        D = d(1);
        s.A = pi*D^2/4;
        s.I = pi*D^4/64;
        s.c = D/2;
        s.J = pi*D^4/32;
    case 'tube'
        Do = d(1); Di = d(2);
        if Di >= Do
            error('Tube inner diameter must be smaller than outer diameter.');
        end
        s.A = pi/4*(Do^2 - Di^2);
        s.I = pi/64*(Do^4 - Di^4);
        s.c = Do/2;
        s.J = 2*s.I;
    otherwise
        error('Unknown section type: %s', sec.type);
end
end