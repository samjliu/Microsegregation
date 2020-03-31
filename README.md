# Microsegregation
This class is an implementation of a model reported in Young-Mok Won and Brian G.Thomas, Simple Model of Microsegregation during Solidification of Steels. Metallurgurgical and Materials Transactions A, 2001, 32A, pp 1757-1767. https://doi.org/10.1007/s11661-001-0152-4. 

[![View Microsegregation on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://uk.mathworks.com/matlabcentral/fileexchange/74792-microsegregation)

## How to use this class:

    1. Initialise an instance of an object i.e. ms = Microsegration([input arguments])
    2. Check all the required parameters are availalbe including composition, m, n, kdelta, kgamma, Dsdelta_A1, Dsdelta_A2, Dsgamma_A1, Dsgamma_A2
    3. Run the calculate method as follows:
     	[Tint, cl] =  ms.calculate(fs,cr). 
       * It accepts two input arguments including 
         * fs --- solid fraction, 
         * cr --- cooling rate, cr
       * Output arguments
         * Tint --- local solid-liquid interface temperature
         * cl --- composition in liquid
    4) To plot the results: run plot method as: ms.plot(fs,cl,elements) 

## Examples: matlab code for modelling microsegregation of an laboratory steel 
```matlab
comp.C = 0.0023;
comp.Si = 0.011;
comp.Mn = 0.2;
comp.Cu = 0.5;
comp.S = 0.034;
comp.Ni = 0.5;

mv.C = 78;
mv.Si = 7.6;
mv.Mn = 4.9;
mv.S = 38;
mv.Cu = -3.6;
mv.Ni = -3.86;

nv.C = -1122;
nv.Si = 60;
nv.Mn = -12;
nv.S = 160;
nv.Cu = 12.5;
nv.Ni = 26.5;

kdelta.C = 0.19;
kdelta.Si = 0.77;
kdelta.Mn = 0.76;
kdelta.S = 0.05;
kdelta.Cu = 0.7;
kdelta.Ni = 0.81;

kgamma.C = 0.34;
kgamma.Si = 0.52;
kgamma.Mn = 0.78;
kgamma.S = 0.035;
kgamma.Cu = 0.72;
kgamma.Ni = 0.87;

A1delta.C = 0.0127;
A1delta.Si = 8.0;
A1delta.Mn = 0.76;
A1delta.S = 4.56;
A1delta.Cu = 0.00474;
A1delta.Ni = 0.001472;

A2delta.C = -19450;
A2delta.Si = -59500;
A2delta.Mn = -53640;
A2delta.S = -51300;
A2delta.Cu = -37772;
A2delta.Ni = -31849;

A1gamma.C = 0.0761;
A1gamma.Si = 0.3;
A1gamma.Mn = 0.055;
A1gamma.S = 2.4;
A1gamma.Cu = 0.0002085;
A1gamma.Ni = 0.0001035;

A2gamma.C = 32160;
A2gamma.Si = -60100;
A2gamma.Mn = -59600;
A2gamma.S = -53400;
A2gamma.Cu = -39259;
A2gamma.Ni = -39382;

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

fs = linspace(0,1,500);
coolrate = 1.2;

msteel = msteel.calculate(fs,coolrate);
h = msteel.plot;comp.C = 0.0023;

### Result
    
