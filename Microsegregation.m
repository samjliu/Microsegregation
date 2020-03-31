classdef Microsegregation
    % This class is an implementatioin of a model of microsegregation
    % reported in the paper: Young-Mok Won and Brian G.Thomas, Simple Model
    % of Microsegregation during Solidification of Steels. Metallurgurgical
    % and Materials Transactions A, 2001, 32A, pp 1757-1767
    % 
    %% How to use this class:
    % 1) initilise an instance of an object using the Microsegregation
    %       method e.g. ms
    % 2) check all the required parameter is availalbe including
    % composition, m, n, kdelta, kgamma, Dsdelta_A1, Dsdelta_A2,
    % Dsgamma_A1, Dsgamma_A2
    % 3) run the calculate method as follows:
    % [Tint, cl] =  ms.calculate(fs,coolingrate). It accepts solid fraction
    % fs and cooling rate as input and output the local solid-liquid interface
    % temperature, Tint, and composition in liquid, cl. 
    % 4) Plot results: run plot method as: ms.plot(fs,cl,elements)
    %%
    properties
        composition         % composition of alloy elements - a structure with field name of elements and field value of the composition
        sdas                % secondary-dendrite arm spacing [m]
        alphadelta          % Fourier number for delta ferrite
        betadelta           % back diffusion parameter for delta ferrite
        alphagamma          % Fourier number for austenite phase
        betagamma           % back diffusion parameter for delta ferrite
        m                   % slope of liquidus line (degC/pct)
        n                   % slope of Tar4 line (degC/pct), that is, the delta ferrite - austenite transformation line
        kdelta              % partition coefficient for delta-ferrite phase
        kgamma              % partition coefficient for gamma phase
        Dsdelta_A1          % Diffusion coefficient for elements in delta-ferrite phase
        Dsdelta_A2          % activatio enery for elements in delta-ferrite phase
        Dsgamma_A1          % Diffusion coefficient for elements in gamma phase
        Dsgamma_A2          % activation energy for elements in austenite
        tpure = 1536;       % MELTING temperature for pure iron
        Tsol                % Solidus temperature
        c_enriched = struct();          % enriched composition
    end
    methods
        function f = Microsegregation(elements,composition,m,n,kdelta,kgamma)
            % Construction method
            % The default element is only Carbon
            % To initialise an instance, elements must be 
            if nargin < 1
                elements = {'C'};
                composition = ones(length(elements),1)*0.1;
                m = zeros(length(elements),1);
                n = zeros(length(elements),1);
                kdelta = zeros(length(elements),1);
                kgamma = zeros(length(elements),1);
            end
            if nargin < 2
                composition = ones(length(elements),1)*0.1;
                m = zeros(length(elements),1);
                n = zeros(length(elements),1);
                kdelta = zeros(length(elements),1);
                kgamma = zeros(length(elements),1);
            end
            for i=1:length(elements)   
                f.composition.(elements{i}) = composition(i);
                f.m.(elements{i}) = m(i);
                f.n.(elements{i}) = n(i);
                f.kdelta.(elements{i}) = kdelta(i);
                f.kgamma.(elements{i}) = kgamma(i);
            end
        end
        
        function f = getsdas(ms,coolrate)
            % Calculate secondary dendrite arm spacing for given coolrate
            if ms.composition.C <=0.15
                f = (169.1-720.9.*ms.composition.C) .* (coolrate .^(-0.4935));
            else
                f = 143.9 .* coolrate .^(-0.3616) .* ms.composition.C .^(0.5501-1.996.*ms.composition.C);
            end
            % convert it to m rather than micron
            f = 1e-6 *f;
        end
        
        function f = Ds(ms,phase,tc)
            % Calculate diffusion coefficient [m^2/s] for given temperature tc (in
            % Celsius) 
            elements = fieldnames(ms.composition);
            f = ms.composition;
            for i = 1:length(elements)
                f.(elements{i}) = calDs(ms.(['Ds',phase,'_A1']).(elements{i}),ms.(['Ds',phase,'_A2']).(elements{i}));
            end
                
            function v = calDs(A1,A2)
                R = 1.987; % gas constant cal/mol.K
                scale4unit = 1e-4;
                v = scale4unit .* A1 .* exp(A2 ./ (R .* (tc+273)));
            end
        end
        
        function f = composliquid(ms,fs,interface)
            % Calculate the composition of each element in the liquid for
            % given solid fraction
            if nargin<3
                interface = 'delta';
            end
            elements = fieldnames(ms.composition);
            for i = 1:length(elements)
                betavalue = ms.(['beta',interface]).(elements{i});
                kvalue = ms.(['k' interface]).(elements{i});
                f.(elements{i}) = ms.composition.(elements{i}) .* ...
                    (1 + fs .* (betavalue .* kvalue - 1))...
                    .^((1 - kvalue)/(betavalue .* kvalue -1));
            end
        end
        
        function f = cliquidlever(ms,fs)
            % calculate liquid composition using lever rule
            elements = fieldnames(ms.composition);
            for i = 1:length(elements)
                ki = ms.kdelta.(elements{i});
                f.(elements{i}) = ms.composition.(elements{i}) ./ (1-...
                    (1-ki).*fs);
            end
        end
        
        function ms = getalpha(ms,tf,temp)
            % Calculate Fourier number alpha for both delta-ferrite and
            % austenite phase
            elements = fieldnames(ms.composition);
            for i = 1:length(elements)
                elem = elements{i};
                ms.alphadelta.(elem) = 1e-4*ms.Ds('delta',temp).(elem) .* tf ./ (ms.sdas .^2 /4);
                ms.alphagamma.(elem) = 1e-4*ms.Ds('gamma',temp).(elem) .* tf ./ (ms.sdas .^2 /4);
            end
        end
        
        function ms = getbeta(ms)
            % calculate the back diffusion parameter for both delta and
            % gamma phase
            elements = fieldnames(ms.composition);
            for i = 1:length(elements)
                elem = elements{i};
                alphac = 0.1;
                alphaplusdelta = 2*(ms.alphadelta.(elem) + alphac);
                alphaplusgamma = 2*(ms.alphagamma.(elem) + alphac);
                ms.betadelta.(elem) = 2 * alphaplusdelta .* (1 - exp(-1/alphaplusdelta))...
                    -exp(-1/(2*alphaplusdelta));
                ms.betagamma.(elem) = 2 * alphaplusgamma .* (1 - exp(-1/alphaplusgamma))...
                    -exp(-1/(2*alphaplusgamma));
            end
        end
        
        function tint = getTint(ms,cl)
            % Calculate the liquidus temperature for given composition at
            % interface CL

            elements = fieldnames(ms.composition);
            mvalue = zeros(length(elements),1);
            clall = zeros(length(elements),1);
            for i = 1:length(elements)
                mvalue(i) = ms.m.(elements{i});  
                clall(i) = cl.(elements{i});
            end
            tint = ms.tpure - sum(mvalue .* clall);
        end
        
        function tliq = getTliq(ms)
            elements = fieldnames(ms.composition);
            mall = zeros(length(elements),1);
            c0 = zeros(length(elements),1);
            for i = 1:length(elements)
                mall(i) = ms.m.(elements{i});
                c0(i) = ms.composition.(elements{i});
            end
            tliq = ms.tpure - sum(mall .* c0);
        end
        
        function [tar4c0,tar4cl] = getTar4(ms,fs,phase)
            % Calculate the local delta/gamma transformation temperature tarc4cl
            % and the equilibrium delta/gamma transformation temperature tar4c0 
            t_pure = 1392; % temperature of the delta/gamma transformation of pure iron
            elements = fieldnames(ms.composition);
            nvalue = zeros(length(elements),1);
            kvalue = zeros(length(elements),1);
            cl = zeros(length(elements),1);
            c0 = zeros(length(elements),1);
            liquidcomposition = ms.composliquid(fs,phase); 
            for i = 1:length(elements)
                nvalue(i) = ms.n.(elements{i});
                kvalue(i) = ms.(['k',phase]).(elements{i});
                cl(i) = liquidcomposition.(elements{i});
                c0(i) = ms.composition.(elements{i});
            end
            tar4c0 = t_pure - sum(nvalue(i) .* kvalue(i) .* c0(i));
            tar4cl = t_pure - sum(nvalue(i) .* kvalue(i) .* cl(i));
        end
        
        
        function [tint, cl] = peritectic(ms,fs)
            % Calculate interface temperature considering peritectic
            % transformation
            cldelta = ms.composliquid(fs,'delta');
            clgamma = ms.composliquid(fs,'gamma');
            elements = fieldnames(ms.composition);
            tint= ms.getTint(cldelta);
            [tar4c0,tar4cl] = ms.getTar4(fs,'delta');
            tliq = ms.getTliq;
            tstart = tar4cl;
            if tliq < tar4cl || clgamma.C > 0.53
                tint = ms.getTint(clgamma);
                cl = clgamma;
            elseif tint <= tar4cl
                fsdelta = fsdeltafromt(tint,tar4c0,tstart);
                fsgamma = fs - fsdelta;
                
                for i = 1:length(elements)
                    
                    cl.(elements{i}) = getclave(fsdelta,cldelta.(elements{i}),fsgamma,clgamma.(elements{i}));
                end
                tint = ms.getTint(cl);
            else
                cl = cldelta;  
            end

            function f2 = fsdeltafromt(tint,tar4c0,tstart)
                f2 = ((tint-tar4c0)./(tstart-tar4c0)).^2 .* fs;
            end
            
            function clave = getclave(fsdelta,cldelta,fsgamma,clgamma)
                clave = (fsdelta./fs).*cldelta + clgamma.* (fsgamma./fs);
            end
        end
        
        function ms = calculate(ms,fs,coolrate)
            tsol = ms.findTsol(coolrate);
            ms.Tsol = tsol;
            
            for i = 1:length(fs)
                tliq = ms.getTliq;
                tf = (tliq-tsol)./coolrate;
                ms.sdas = ms.getsdas(coolrate);
                ms = ms.getalpha(tf,tsol);
                ms = ms.getbeta;
                ms.c_enriched(i).fs = fs(i);
                [ms.c_enriched(i).Tint, ms.c_enriched(i).cl] = ms.peritectic(fs(i));
            end
            if length(fs)< length(ms.c_enriched)
                ms.c_enriched(length(fs)+1:end) = [];
            end
        end
        
        
        function tsol = findTsol(ms,coolrate)
            tol = 0.01; % Tolerance of iteration for the temperature
            tliq = ms.getTliq;
            tsol0 = ms.getTint(ms.cliquidlever(1));  % Guess the Tsol by lever rule
            dt = 100;                    % Initialise dt
            tsol = tsol0;
            tf = (tliq - tsol)./ coolrate;
            while dt > tol
%                 tf = (tliq - tsol)./ coolrate;
                ms.sdas = ms.getsdas(coolrate);
                ms = ms.getalpha(tf,tsol);
                ms = ms.getbeta;
                [tint,~] = ms.peritectic(1);
                dt = abs(tint-tsol);
                % next guess is the median value between the last guess and
                % evaluated Tint
                tsol = (tint+tsol)/2;
                disp(['Delta T is ', num2str(dt), ' deg C...'])
            end
            display(['Tsol was found: ', num2str(tsol)])
        end
        
        function f = plot(ms,elements)
            if nargin<2 || (ischar(elements) && (strcmp(elements,'*') || strcmp(elements,'all')))
                
                elements = fieldnames(ms.composition);
            end
            cldata = zeros(length(vertcat(ms.c_enriched.fs)),length(elements));
            for j= 1:length(elements)
                cl = vertcat(ms.c_enriched.cl);
                cldata(:,j) = vertcat(cl.(elements{j}));
            end

            f = plot(vertcat(ms.c_enriched.fs),cldata);
            legend(elements,'Location','NorthWest');
            set(f,'LineWidth',2);
            xlabel('Solid fraction');
            ylabel('Composition in liquid wt%');
        end
    end
   
end
