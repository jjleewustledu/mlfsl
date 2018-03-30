classdef FnirtOptions < mlfsl.FslOptions
	%% FNIRTOPTIONS 
    %  Usage:
    %  fnirt --ref=<some template> --in=<some image>
    %  fnirt --ref=<some template> --in=<some image> --infwhm=8,4,2 --subsamp=4,2,1 --warpres=8,8,8

	%  $Revision: 2550 $
 	%  was created $Date: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FnirtOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FnirtOptions.m 2550 2013-08-22 09:37:03Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties

        %% Compulsory arguments (You MUST set one or more of):
        ref		% name of reference image
        in		% name of input image

        %% Optional arguments (You may optionally specify one or more of):
        aff			% name of file containing affine transform
        inwarp		% name of file containing initial non-linear warps
        intin		% name of file/files containing initial intensity maping
        cout		% name of output file with field coefficients
        iout		% name of output image
        fout		% name of output file with field
        jout		% name of file for writing out the Jacobian of the field (for diagnostic or VBM purposes)
        refout		% name of file for writing out intensity modulated --ref (for diagnostic purposes)
        intout		% name of files for writing information pertaining to intensity mapping
        logout		% Name of log-file
        config		% Name of config file specifying command line arguments
        refmask		% name of file with mask in reference space
        inmask		% name of file with mask in input image space
        applyrefmask	% Use specified refmask if set, deafult 1 (true)
        applyinmask		% Use specified inmask if set, deafult 1 (true)
        imprefm		% If =1, use implicit masking based on value in --ref image. Default =1
        impinm		% If =1, use implicit masking based on value in --in image, Default =1
        imprefval	% Value to mask out in --ref image. Default =0.0
        impinval	% Value to mask out in --in image. Default =0.0
        minmet		% non-linear minimisation method [lm | scg] (Leveberg-Marquardt or Scaled Conjugate Gradient)
        miter		% Max # of non-linear iterations, default 5,5,5,5
        subsamp		% sub-sampling scheme, default 4,2,1,1
        warpres		% (approximate) resolution (in mm) of warp basis in x-, y- and z-direction, default 10,10,10
        splineorder	% Order of spline, 2->Qadratic spline, 3->Cubic spline. Default=3
        infwhm		% FWHM (in mm) of gaussian smoothing kernel for input volume, default 6,4,2,2
        reffwhm		% FWHM (in mm) of gaussian smoothing kernel for ref volume, default 4,2,0,0
        regmod		% Model for regularisation of warp-field [membrane_energy bending_energy], default bending_energy
        lambda		% Weight of regularisation, default depending on --ssqlambda and --regmod switches. See user documetation.
        ssqlambda	% If set (=1), lambda is weighted by current ssq, default 1
        jacrange	% Allowed range of Jacobian determinants, default 0.01,100.0
        refderiv	% If =1, ref image is used to calculate derivatives. Default =0
        intmod		% Model for intensity-mapping [none global_linear global_non_linear local_linear global_non_linear_with_bias local_non_linear]
        intorder	% Order of poynomial for mapping intensities, default 5
        biasres		% Resolution (in mm) of bias-field modelling local intensities, default 50,50,50
        biaslambda	% Weight of regularisation for bias-field, default 10000
        estint		% Estimate intensity-mapping if set, deafult 1 (true)
        numprec		% Precision for representing Hessian, double or float. Default double
        interp		% Image interpolation model, linear or spline. Default linear
        verbose		% Print diagonostic information while running
        help		% display help info
 	end

	methods 
        function s = updateOptionsString(~, s, fldname, val) 
            if (isnumeric(val))
                val = num2str(val); end
            s = sprintf('%s --%s=%s', s, fldname, char(val));
        end
        
		function this = set.ref(this, obj)
			this.ref = imcast(obj, 'fqfileprefix');
		end
		function this = set.in(this, obj)
			this.in = imcast(obj, 'fqfileprefix');
        end
		function this = set.aff(this, obj)
			this.aff = this.transformFilename(obj);
		end
        function this = set.inwarp(this, obj)
			this.inwarp = imcast(obj, 'fqfileprefix');
		end
        function this = set.intin(this, obj)
            this.intin = imcast(obj, 'fqfileprefix');
		end
        function this = set.cout(this, obj)
			this.cout = imcast(obj, 'fqfileprefix');
		end
        function this = set.iout(this, obj)
			this.iout = imcast(obj, 'fqfileprefix');
		end
        function this = set.fout(this, obj)
			this.fout = imcast(obj, 'fqfileprefix');
		end
        function this = set.jout(this, obj)
			this.jout = imcast(obj, 'fqfileprefix');
		end
        function this = set.refout(this, obj)
			this.refout = imcast(obj, 'fqfileprefix');
		end
        function this = set.intout(this, obj)
			this.intout = imcast(obj, 'fqfileprefix');
		end
        function this = set.refmask(this, obj)
			this.refmask = imcast(obj, 'fqfileprefix');
		end
        function this = set.inmask(this, obj)
			this.inmask = imcast(obj, 'fqfileprefix');
        end
        
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

