% Create a structure storing the composition and model parameter for each
% element
% composition here is in weight percent
comp.C = 0.0023;
comp.Si = 0.011;
comp.Mn = 0.2;
comp.Cu = 0.5;
comp.S = 0.034;
comp.Ni = 0.5;

% model parameter m
mv.C = 78;
mv.Si = 7.6;
mv.Mn = 4.9;
mv.S = 38;
mv.Cu = -3.6;
mv.Ni = -3.86;

% model parameter n
nv.C = -1122;
nv.Si = 60;
nv.Mn = -12;
nv.S = 160;
nv.Cu = 12.5;
nv.Ni = 26.5;

% model parameter kdelta
kdelta.C = 0.19;
kdelta.Si = 0.77;
kdelta.Mn = 0.76;
kdelta.S = 0.05;
kdelta.Cu = 0.7;
kdelta.Ni = 0.81;

% model parameter kgamma
kgamma.C = 0.34;
kgamma.Si = 0.52;
kgamma.Mn = 0.78;
kgamma.S = 0.035;
kgamma.Cu = 0.72;
kgamma.Ni = 0.87;

% model parameter Dsdelta_A1
A1delta.C = 0.0127;
A1delta.Si = 8.0;
A1delta.Mn = 0.76;
A1delta.S = 4.56;
A1delta.Cu = 0.00474;
A1delta.Ni = 0.001472;

% model parameter Dsdelta_A2
A2delta.C = -19450;
A2delta.Si = -59500;
A2delta.Mn = -53640;
A2delta.S = -51300;
A2delta.Cu = -37772;
A2delta.Ni = -31849;

% Model parameter Dsgamma_A1
A1gamma.C = 0.0761;
A1gamma.Si = 0.3;
A1gamma.Mn = 0.055;
A1gamma.S = 2.4;
A1gamma.Cu = 0.0002085;
A1gamma.Ni = 0.0001035;

% Model parameter Dsgamma_A2
A2gamma.C = 32160;
A2gamma.Si = -60100;
A2gamma.Mn = -59600;
A2gamma.S = -53400;
A2gamma.Cu = -39259;
A2gamma.Ni = -39382;

% Create a Microsegregation object specifying the elements
msteel = Microsegregation(fieldnames(comp));
msteel.composition = comp;
msteel.m = mv;
msteel.n = nv;
msteel.kdelta = kdelta;
msteel.kgamma = kgamma;
msteel.Dsdelta_A1 = A1delta;
msteel.Dsdelta_A2 = A2delta;
msteel.Dsgamma_A1 = A1gamma;
msteel.Dsgamma_A2 = A2gamma;

% specify the data points of solid fraction where microsegregation will be
% calculated
fs = linspace(0,1,500);
coolrate = 1.2; % cooling rate degC/s

% Run the model and store the results to appropriate property of the
% Microsegregation object, msteel
msteel = msteel.calculate(fs,coolrate);

% Plot the composition of all elements in liquid as a function of the solid
% fraction fs. 
h = msteel.plot;
