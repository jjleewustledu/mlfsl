classdef MultispectralAlignmentDirector < mlfsl.AlignmentDirectorDecorator
	%% MULTISPECTRALALIGNMENTDIRECTOR  

	%  $Revision$
 	%  was created 27-Dec-2015 00:07:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties (Dependent)
        sessionAtlas
        sessionAnatomy 		
 	end

	methods %% GET		  
        function g = get.sessionAnatomy(this)
            g = this.sessionAnatomy_;
        end
        function g = get.sessionAtlas(this)
            g = this.sessionAtlas_;
        end  
    end
    
    methods
 		function this = MultispectralAlignmentDirector(varargin)
 			%% MULTISPECTRALALIGNMENTDIRECTOR
 			%  Usage:  this = MultispectralAlignmentDirector()

 			this = this@mlfsl.AlignmentDirectorDecorator(varargin{:});
 		end
    end 

    %% PRIVATE
    
    properties (Access = 'private')        
        sessionAnatomy_
        sessionAtlas_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

