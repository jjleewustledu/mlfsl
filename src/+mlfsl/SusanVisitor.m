classdef SusanVisitor < mlfsl.FslVisitor
	%% SUSANVISITOR  

	%  $Revision$
 	%  was created 13-Jan-2016 09:52:17
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties 		
 	end

	methods 
		  
 		function this = SusanVisitor(varargin)
 			this = this@mlfsl.FslVisitor(varargin{:});
 		end
 	end 
    
    %% PROTECTED
    
    methods (Access = 'protected')        
        function this = susan__(this, opts)
            assert(isa(opts, 'mlfsl.SusanOptions'));
            this.cmd('susan', opts);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

