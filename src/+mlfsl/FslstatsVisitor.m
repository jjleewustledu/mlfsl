classdef FslstatsVisitor < mlfsl.FslVisitor
	%% FSLSTATSVISITOR  

	%  $Revision$
 	%  was created 13-Jan-2016 09:54:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties 		
 	end

	methods 
		  
 		function this = FslstatsVisitor(varargin)
 			this = this@mlfsl.FslVisitor(varargin{:});
 		end
 	end 
    
    %% PROTECTED
    
    methods (Access = 'protected')  
        function this = fslstats__(this, opts)
            assert(isa(opts, 'mlfsl.FslstatsOptions'));
            this.cmd('fslstats', opts);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

