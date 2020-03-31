# Microsegregation
This class is an implementation of a model reported in Young-Mok Won and Brian G.Thomas, Simple Model of Microsegregation during Solidification of Steels. Metallurgurgical and Materials Transactions A, 2001, 32A, pp 1757-1767. https://doi.org/10.1007/s11661-001-0152-4. 

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
