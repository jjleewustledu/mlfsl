classdef InversewarpOptions < mlfsl.FslOptions
	%% INVERSEWARPOPTIONS
    %  Usage:
    %  invwarp -w warpvol -o invwarpvol -r refvol

	%  $Revision: 2550 $
 	%  was created $Date: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/InversewarpOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: InversewarpOptions.m 2550 2013-08-22 09:37:03Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        % Compulsory arguments (You MUST set one or more of):
        warp	% filename for warp/shiftmap transform (volume)
        out	    % filename for output (inverse warped) image
        ref	    % filename for new reference image, i.e., what was originally the input image (determines inverse warpvol's FOV and pixdims)

        % Optional arguments (You may optionally specify one or more of):
        rel	    % use relative warp convention: x' = x + w(x)
        abs	    % use absolute warp convention (default): x' = w(x)
        niter   %=# Determines how many iterations of the gradient-descent search that should be run
        regularize      % Regularisation strength (deafult=1.0)
        noconstraint	% do not apply the Jacobian constraint
        jmin	% minimum acceptable Jacobian value for constraint (default 0.01)
        jmax	% maximum acceptable Jacobian value for constraint (default 100.0)
        debug	% turn on debugging output
        verbose	% switch on diagnostic messages
        help	% display this message
 	end

	methods 
        function s = updateOptionsString(~, s, fldname, val) 
            if (isnumeric(val))
                val = num2str(val); end
            s = sprintf('%s --%s=%s', s, fldname, val);
        end
		function this = set.ref(this, obj)
			this.ref = imcast(obj, 'fileprefix');
		end
		function this = set.out(this, obj)
			this.out = imcast(obj, 'fileprefix');
		end
		function this = set.warp(this, obj)
			this.warp = imcast(obj, 'fileprefix');
		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

