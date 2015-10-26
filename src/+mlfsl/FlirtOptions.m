classdef FlirtOptions < mlfsl.FslOptions
	%% FLIRTOPTIONS 
    %  Usage: flirt [options] -in <inputvol> -ref <refvol> -out <outputvol>
    %         flirt [options] -in <inputvol> -ref <refvol> -omat <outputmatrix>
    %         flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>
    
	%  $Revision: 2629 $
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FlirtOptions.m 2629 2013-09-16 06:19:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        in  % <inputvol>                    (no default)
        ref % <refvol>                      (no default)
        applyxfm %                          (applies transform (no optimisation) - requires -init)
        applyisoxfm % <scale>               (as applyxfm but forces isotropic resampling)
        init % <matrix-filname>             (input 4x4 affine matrix)
        omat % <matrix-filename>            (output in 4x4 ascii format)
        out % <outputvol>                   (default is none)
        datatype % {char,short,int,float,double}                                  (force output data type)
        cost = 'normmi'; % {mutualinfo,corratio,normcorr,normmi,leastsq,labeldiff,bbr}        (default is corratio)
        searchcost % {mutualinfo,corratio,normcorr,normmi,leastsq,labeldiff,bbr}  (default is corratio)
        usesqform %                         (initialise using appropriate sform or qform)
        displayinit %                       (display initial matrix)
        anglerep % {quaternion,euler}       (default is euler)
        interp % {trilinear,nearestneighbour,sinc,spline}                         (final interpolation: def - trilinear)
        sincwidth % <full-width in voxels>  (default is 7)
        sincwindow % {rectangular,hanning,blackman}
        bins % <number of histogram bins>   (default is 256)
        dof % <number of transform dofs>    (default is 12)
        noresample %                        (do not change input sampling)
        forcescaling %                      (force rescaling even for low-res images)
        minsampling % <vox_dim>             (set minimum voxel dimension for sampling (in mm))
        paddingsize % <number of voxels>    (for applyxfm: interpolates outside image by size)
        searchrx % = ' -180 180 ' % <min_angle> <max_angle>  (angles in degrees: default is -90 90)
        searchry % = ' -180 180 ' % <min_angle> <max_angle>  (angles in degrees: default is -90 90)
        searchrz % = ' -180 180 ' % <min_angle> <max_angle>  (angles in degrees: default is -90 90)
        nosearch %                          (sets all angular search ranges to 0 0)
        coarsesearch % <delta_angle>        (angle in degrees: default is 60)
        finesearch % <delta_angle>          (angle in degrees: default is 18)
        schedule % <schedule-file>          (replaces default schedule)
        refweight % <volume>                (use weights for reference volume)
        inweight % <volume>                 (use weights for input volume)
        wmseg % <volume>                    (white matter segmentation volume needed by BBR cost function)
        wmcoords % <text matrix>            (white matter boundary coordinates for BBR cost function)
        wmnorms % <text matrix>             (white matter boundary normals for BBR cost function)
        fieldmap % <volume>                 (fieldmap image in rads/s - must be already registered to the reference image)
        fieldmapmask % <volume>             (mask for fieldmap image)
        pedir % <index>                     (phase encode direction of EPI - 1/2/3=x/y/z & -1/-2/-3=-x/-y/-z)
        echospacing % <value>               (value of EPI echo spacing - units of seconds)
        bbrtype % <value>                   (type of bbr cost function: signed [default], global_abs, local_abs)
        bbrslope % <value>                  (value of bbr slope)
        setbackground % <value>             (use specified background value for points outside FOV)
        noclamp %                           (do not use intensity clamping)
        noresampblur %                      (do not use blurring on downsampling)
        twoD %                              (use 2D rigid body mode - ignores dof)
        verbose % <num>                     (0 is least and default)
        v %                                 (same as -verbose 1)
        i %                                 (pauses at each stage: default is off)
        version %                           (prints version number)
        help
    end

	methods
        function s    = updateOptionsString(~, s, fldname, val) 
            if (islogical(val))
                val = ' '; end
            if (isnumeric(val))
                val = num2str(val); end
            s = sprintf('%s -%s %s', s, fldname, val);
        end
        function this = checkOther(this)
            assert(lexist(filename(this.in),  'file'), 'mlsfl.FlirtOptions.checkOther could not find %s\n', filename(this.in));
            assert(lexist(filename(this.ref), 'file'), 'mlsfl.FlirtOptions.checkOther could not find %s\n', filename(this.ref));
            if (~isempty(this.applyxfm) || ~isempty(this.applyisoxfm))
                assert(lexist(filename(this.init, mlfsl.FlirtVisitor.XFM_SUFFIX), 'file'));
            end
        end
        function tf   = applyTrans(this)
            tf = ~isempty(this.applyxfm) || ~isempty(this.applyisoxfm);
        end
        
		function this = set.in(this, obj)
			this.in = imcast(obj, 'fqfileprefix');
		end
		function this = set.ref(this, obj)
			this.ref = imcast(obj, 'fqfileprefix');
		end
		function this = set.init(this, obj)
			this.init = this.xfmName(obj);
        end
		function this = set.omat(this, obj)
            if (isempty(obj))
                this.omat = []; return; end
			this.omat = this.xfmName(obj);
		end
        function val  = get.omat(this)
            val = [];
            if (~this.applyTrans && isempty(this.omat) && ~isempty(this.ref))
                val = this.xfmName(this.in, this.ref);
            end
        end
		function this = set.out(this, obj)
			this.out = imcast(obj, 'fqfileprefix');
        end
        function val  = get.out(this)
            val = this.out;
            if (isempty(val))
                if (this.applyTrans)
                    val = fileprefix(this.imageObject(this.in, this.init));
                    return
                end
                val = fileprefix(this.imageObject(this.in, this.ref));
            end
        end
        function this = set.refweight(this, obj)
			this.refweight = imcast(obj, 'fqfileprefix');
		end
		function this = set.inweight(this, obj)
			this.inweight = imcast(obj, 'fqfileprefix');        	
		end
		function this = set.wmseg(this, obj)
			this.wmseg = imcast(obj, 'fqfileprefix');
		end
		function this = set.wmcoords(this, obj)
			this.wmcoords = imcast(obj, 'fqfileprefix'); 
		end
		function this = set.wmnorms(this, obj)
			this.wmnorms = imcast(obj, 'fqfileprefix'); 
		end
		function this = set.fieldmap(this, obj)
			this.fieldmap = imcast(obj, 'fqfileprefix'); 
		end
		function this = set.fieldmapmask(this, obj)
			this.fieldmapmask = imcast(obj, 'fqfileprefix');
		end
    end
		
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

