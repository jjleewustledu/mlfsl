classdef ApplywarpOptions < mlfsl.FslOptions
	%% APPLYWARPOPTIONS ...
    %  Usage:
    %  applywarp -i invol -o outvol -r refvol -w warpvol
    %  applywarp -i invol -o outvol -r refvol -w coefvol
    
	%  $Revision: 2550 $
 	%  was created $Date: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/ApplywarpOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ApplywarpOptions.m 2550 2013-08-22 09:37:03Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        % Compulsory arguments (You MUST set one or more of):
        in	% filename of input image (to be warped)
        ref	% filename for reference image
        out	% filename for output (warped) image
        
        % Optional arguments (You may optionally specify one or more of):
        warp	    % filename for warp/coefficient (volume)
        abs		    % treat warp field as absolute: x' = w(x)
        rel		    % treat warp field as relative: x' = x + w(x)
        datatype	% Force output data type [char short int float double].
        super	    % intermediary supersampling of output, default is off
        superlevel	% level of intermediary supersampling, a for 'automatic' or integer level. Default = 2
        premat	    % filename for pre-transform (affine matrix)
        postmat	    % filename for post-transform (affine matrix)
        mask	    % filename for mask image (in reference space)
        interp	    % interpolation method {nn,trilinear,sinc,spline}
        paddingsize	% Extrapolates outside original volume by n voxels
        verbose	    % switch on diagnostic messages
        help        % display this message
    end

	methods 
        function s = updateOptionsString(~, s, fldname, val)
            if (isnumeric(val))
                val = num2str(val); end
            s = sprintf('%s --%s=%s', s, fldname, val);
        end
		function this = set.in(this, obj)
			this.in = imcast(obj, 'fqfileprefix');
		end
		function this = set.ref(this, obj)
			this.ref = imcast(obj, 'fqfileprefix');
		end
		function this = set.out(this, obj)
			this.out = imcast(obj, 'fqfileprefix');
		end
		function this = set.warp(this, obj)
			this.warp = imcast(obj, 'fqfileprefix');
		end
		function this = set.mask(this, obj)
			this.mask = imcast(obj, 'fqfileprefix');
		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

