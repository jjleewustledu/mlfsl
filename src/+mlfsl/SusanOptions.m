classdef SusanOptions < mlfsl.FslOptions
	%% SUSANOPTIONS  
    % Usage: susan <input> <bt> <dt> <dim> <use_median> <n_usans> [<usan1> <bt1> [<usan2> <bt2>]] <output>
    
	%  $Revision$
 	%  was created 13-Jan-2016 09:52:36
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		input
        bt            % is brightness threshold and should be greater than noise level and less than contrast of edges to be preserved.
        dt            % is spatial size (sigma, i.e., half-width) of smoothing, in mm.
        dim           % is dimensionality (2 or 3), depending on whether smoothing is to be within-plane (2) or fully 3D (3).
        use_median    % determines whether to use a local median filter in the cases where single-point noise is detected (0 or 1).
        n_usans = '0' % [<usan1> <bt1> [<usan2> <bt2>]]
                      % determines whether the smoothing area (USAN) is to be found from secondary images (0, 1 or 2).
        output
        
        %% A negative value for any brightness threshold will auto-set the threshold at 10% of the robust range
 	end

	methods 
 		function s = char(this) 
            assert(ischar(this.input));
            assert(ischar(this.n_usans));
            assert(ischar(this.output));
            assert(isnumeric(this.bt));
            assert(isnumeric(this.dt));
            assert(isnumeric(this.dim));
            assert(isnumeric(this.use_median));
            s = sprintf('%s %g %g %i %i %s %s', ...
                this.input, this.bt, this.dt, this.dim, this.use_median, this.n_usans, this.output);
        end  
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

