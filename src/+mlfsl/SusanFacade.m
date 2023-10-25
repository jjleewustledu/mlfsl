classdef SusanFacade 
	%% SUSANFACADE is a wrapper for the FSL Susan filtering schemes
	%  
	%  
	 
	%% Version $Revision$ was created $Date$ by $Author$  
 	%% and checked into svn repository $URL$ 
 	%% Developed on Matlab 7.10.0.499 (R2010a) 
 	%% $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access='private', GetAccess='protected', SetAccess='protected', ... 
 		%       Constant, Dependent, Hidden, Transient) 
        nii;
        brightThresh;
        sigmaHalfWidth;
        dimensionality = 3;
        useMedian = 0;
        susanSuffix = '_susan';
        nUsans = 0;
 	end 

	methods 

 		function this = SusanFacade(nii, nSigma) 
 			%% SUSANFACADE (ctor) 
 			%  Usage:  obj = SusanFacade()
            if (nargin < 2); nSigma = 2; end
            this.nii            = nii;
            this.brightThresh   = this.findBrightThresh;
            this.sigmaHalfWidth = min(this.nii.mmppix)*nSigma;
 		end % SusanFacade (ctor) 
        
        function this = set.nii(this, nii)
            if (ischar(nii))
                try
                    nii = mlfourd.NIfTI.load(nii);
                catch ME
                    handexcept(ME, ['SusanFacade.doSusan failed to load ' nii]);
                end
            end
            assert(isa(nii, 'mlfourd.INIfTI'));
            this.nii = nii;
        end      
 	end 

	methods (Static)
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
        
        function sf = doSusan(nii, nSigma)
            sf     = 0;
            if (nargin < 2)
                sf = mlfsl.SusanFacade(nii);
            else
                sf = mlfsl.SusanFacade(nii, nSigma);
            end
            cmd = sprintf('susan %s %g %g %g %g %g %s %s', ...
                sf.nii.fileprefix, sf.brightThresh, sf.sigmaHalfWidth, sf.dimensionality, sf.useMedian, sf.nUsans, ...
                sf.nii.fileprefix, sf.susanSuffix);
            mlbash(cmd);            
        end
    end 
    
    methods (Access='protected')
        
        function bth = findBrightThresh(this)
            SAMPLING_FRAC = 0.2;
            sampSize      = floor(this.nii.size*SAMPLING_FRAC);
            sampImg       = this.nii.img(1:sampSize(1), 1:sampSize(2), 1:sampSize(3));
            medianNoise   = dipmedian(sampImg);
            stdNoise      = dipstd(   sampImg);
            medianImg     = dipmedian(this.nii.img);
            stdImg        = dipstd(   this.nii.img);
            if (medianNoise < medianImg)
                bth       = medianNoise + (medianImg - medianNoise)*SAMPLING_FRAC;
            else
                bth       = medianNoise;
            end
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
