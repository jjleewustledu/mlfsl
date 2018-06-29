classdef FastRois < mlsurfer.AbstractRois 
	%% FASTROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$  
	
	properties (Dependent) 		 
         greySessionPrior
         whiteSessionPrior
         csfSessionPrior         
    end
    
    properties
    end 

    methods %% SET/GET
        function ic  = get.greySessionPrior(this)
            channel = 'gray';
            fqfp = fullfile(this.fslPath, this.sessionPriorFileprefix(channel));
            if (~lexist(filename(fqfp), 'file'))
                try
                    this.builder_.atlas2mask(this.fslPriorFqfn(channel), [fqfp '_fslprior']);                    
                catch ME
                    handexcept(ME);
                end
            end
            ic = mlfourd.ImagingContext.load(fqfn);
        end
        function ic  = get.whiteSessionPrior(this)
        end
        function ic  = get.csfSessionPrior(this)
        end
    end

	methods 
 		 

 		function afun(this) 
 		end 
 		function this = FastRois(varargin) 
 			%% FASTROIS 
 			%  Usage:  this = FastRois() 

 			this = this@mlsurfer.AbstractRois(varargin{:}); 
 		end 
    end 
    
    %% PRIVATE
    
    
    methods (Access = 'private')
        function fn = sessionPriorFileprefix(channel)
            assert(ischar(channel));
            fn = [channel mlfourd.NIfTId.FILETYPE_EXT];
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

