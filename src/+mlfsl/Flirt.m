classdef Flirt < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
	%% FLIRT provides an object-oriented implementation of FSL's flirt.

	%  $Revision$
 	%  was created 22-Nov-2021 22:45:20 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John Joowon Lee.

    methods (Static)
        function AtoC = compositionOfMaps(AtoB, BtoC)
            %% COMPOSITIONOFMAPS generates a semantic filename for composition of maps, applicable for .nii.gz or .mat,
            %  by retaining file extensions.  The path of AtoB is retained.
            %  Params:
            %      AtoB (filename): describing map A->B
            %      BtoC (filename): describing map B->C
            %  Returns:
            %      AtoC (filename): describing map A->C

            [pth,AtoB_fp,ext] = myfileparts(AtoB);
            [~,BtoC_fp,ext1] = myfileparts(BtoC);
            assert(strcmp(ext, ext1))
            A_fp = extractBefore(AtoB_fp, "_on_");
            s = split(string(BtoC_fp), "_on_");
            C_fp = s(end);

            AtoC = fullfile(pth, strcat(A_fp, "_on_", C_fp, ext));
        end
        function BtoA = inverseOfMap(AtoB)
            %% INVERSEOFMAP generates a semantic filename for an inverse map, applicable for .nii.gz or .mat,
            %  by preservation of file extensions.  The path is also preserved.
            %  Params:
            %      AtoB (filename): describing map A->B
            %  Returns:
            %      BtoA (filename): describing map B->A

            [pth,AtoB_fp,ext] = myfileparts(AtoB);
            A_fp = extractBefore(AtoB_fp, "_on_");
            B_fp = extractAfter(AtoB_fp, "_on_");

            BtoA = fullfile(pth, strcat(B_fp, "_on_", A_fp, ext));
        end
        function mskfn = msktgen(varargin)
            %  Args:
            %      niifn (file): upon which to generate mask.
            %      targfn (file): atlas used to generate mask, which has corresponding *_brain_mask_dil.nii.gz.
            %      workpath (folder): within which to store results.
            %  Returns:
            %      mskfn (file)

            ip = inputParser;
            addRequired(ip, 'niifn', @isfile);
            addParameter(ip, 'targfn', fullfile(getenv('FSLDIR'), 'data', 'standard', 'MNI152_T1_1mm.nii.gz'), @isfile);
            addParameter(ip, 'workpath', pwd, @isfolder)
            parse(ip, varargin{:});
            ipr = ip.Results;

            pwd0 = pushd(ipr.workpath);

            niifn_ = strcat(mybasename(ipr.niifn), '_on_MNI', '.nii.gz');
            dilfn = strcat(myfileprefix(ipr.targfn), '_brain_mask_dil', '.nii.gz');
            mskfn = fullfile(pwd, strcat(mybasename(ipr.niifn), '_mskt', '.nii.gz'));
            if isfile(mskfn)
                return
            end
            assert(isfile(dilfn))

            f = mlfsl.Flirt('in', ipr.niifn, 'ref', ipr.targfn, 'out', niifn_, 'dof', 12);
            f.flirt(); % ipr.niifn -> niifn_
            f.invertXfm();
            %deleteExisting(matfn_);
            f.in = dilfn;
            f.ref = ipr.niifn;
            f.out = mskfn;
            f.interp = 'nearestneighbour';
            f.applyXfm(); % dilfn -> ipr.niifn
            deleteExisting(f.init);
            deleteExisting(f.omat);
            deleteExisting(niifn_);

            %ic = mlfourd.ImagingContext2(ipr.niifn);
            %ic.view(mskfn);

            popd(pwd0);
        end
    end
 	
    properties (Dependent)
        exec

        in  % mlfourd.ImagingContext2
        ref % mlfourd.ImagingContext2
        out % mlfourd.ImagingContext2
        init
        omat
        bins
        cost
        searchrx
        searchry
        searchrz
        dof
        paddingsize
        refweight
        inweight
        interp
        schedule
    end

	methods 

        %% GET/SET

        function g = get.exec(~)
            %% Usage: flirt [options] -in <inputvol> -ref <refvol> -out <outputvol>
            %         flirt [options] -in <inputvol> -ref <refvol> -omat <outputmatrix>
            %         flirt [options] -in <inputvol> -ref <refvol> -applyxfm -init <matrix> -out <outputvol>

            g = fullfile(getenv('FSLDIR'), 'bin', 'flirt');
        end
        function g = get.in(this)
            g = copy(this.in_);
        end
        function     set.in(this, s)
            this.in_ = mlfourd.ImagingContext2(s);
            this.in_.selectNiftiTool();
        end
        function g = get.ref(this)
            g = copy(this.ref_);
        end
        function     set.ref(this, s)
            this.ref_ = mlfourd.ImagingContext2(s);
            this.ref_.selectNiftiTool();
        end
        function g = get.out(this)
            g = copy(this.out_);
        end
        function     set.out(this, s)
            this.out_ = mlfourd.ImagingContext2(s);
            this.out_.selectNiftiTool();
        end
        function g = get.init(this)
            if ~isempty(this.init_)
                g = this.init_;
                return
            end
            if ~isempty(this.omat_)
                g = this.omat_;
                return
            end
            error('mlfsl:ValueError', 'Flirt.get.init')
        end
        function     set.init(this, s)
            assert(istext(s))
            this.omat = s;
        end
        function g = get.omat(this)
            g = this.omat_;
        end
        function     set.omat(this, s)
            assert(istext(s))
            this.omat_ = s;
        end
        function g = get.bins(this)
            g = this.bins_;
        end
        function     set.bins(this, s)
            assert(isscalar(s))
            this.bins_ = s;
        end
        function g = get.cost(this)
            g = this.cost_;
        end
        function     set.cost(this, s)
            assert(istext(s))
            this.cost_ = s;
        end
        function g = get.searchrx(this)
            g = this.searchrx_;
        end
        function     set.searchrx(this, s)
            assert(isnumeric(s))
            if isscalar(s)
                s = [-s s];
            end
            this.searchrx_ = s;
        end
        function g = get.searchry(this)
            g = this.searchry_;
        end
        function     set.searchry(this, s)
            assert(isnumeric(s))
            if isscalar(s)
                s = [-s s];
            end
            this.searchry_ = s;
        end
        function g = get.searchrz(this)
            g = this.searchrz_;
        end
        function     set.searchrz(this, s)
            assert(isnumeric(s))
            if isscalar(s)
                s = [-s s];
            end
            this.searchrz_ = s;
        end
        function g = get.dof(this)
            g = this.dof_;
        end
        function     set.dof(this, s)
            assert(isscalar(s))
            this.dof_ = s;
        end
        function g = get.paddingsize(this)
            g = this.paddingsize_;
        end
        function     set.paddingsize(this, s)
            assert(isscalar(s))
            this.paddingsize_ = s;
        end
        function g = get.refweight(this)
            if isa(this.refweight_, 'mlfourd.ImagingContext2')
                g = copy(this.refweight_);
                return
            end
            g = [];
        end
        function     set.refweight(this, s)
            this.refweight_ = mlfourd.ImagingContext2(s);
            this.refweight_.selectNiftiTool();
        end
        function g = get.inweight(this)
            if isa(this.inweight_, 'mlfourd.ImagingContext2')
                g = copy(this.inweight_);
                return
            end
            g = [];
        end
        function     set.inweight(this, s)
            this.inweight_ = mlfourd.ImagingContext2(s);
            this.inweight_.selectNiftiTool();
        end
        function g = get.interp(this)
            g = this.interp_;
        end
        function     set.interp(this, s)
            assert(istext(s))
            this.interp_ = s;
        end
        function g = get.schedule(this)
            g = this.schedule_;
        end
        function     set.schedule(this, s)
            assert(istext(s))
            this.schedule_ = s;
        end

        %%
		  
 		function this = Flirt(varargin)
 			%% FLIRT
            %  @param in  <inputvol>                    (no default)
            %  @param ref <refvol>                      (no default)
            %  @param init <matrix-filname>             (input 4x4 affine matrix)
            %  @param omat <matrix-filename>            (output in 4x4 ascii format)
            %  @param out, -o <outputvol>               (default is none)
            %  @param datatype {char,short,int,float,double}                    (force output data type)
            %  @param cost {mutualinfo,corratio,normcorr,normmi,leastsq,labeldiff,bbr}        (default is corratio)
            %  @param searchcost {mutualinfo,corratio,normcorr,normmi,leastsq,labeldiff,bbr}  (default is corratio)
            %  @param usesqform                         (initialise using appropriate sform or qform)
            %  @param displayinit                       (display initial matrix)
            %  @param anglerep {quaternion,euler}       (default is euler)
            %  @param interp {trilinear,nearestneighbour,sinc,spline}  (final interpolation: def - trilinear)
            %  @param sincwidth <full-width in voxels>  (default is 7)
            %  @param sincwindow {rectangular,hanning,blackman}
            %  @param bins <number of histogram bins>   (default is 256)
            %  @param dof  <number of transform dofs>   (default is 12)
            %  @param noresample                        (do not change input sampling)
            %  @param forcescaling                      (force rescaling even for low-res images)
            %  @param minsampling <vox_dim>             (set minimum voxel dimension for sampling (in mm))
            %  @param applyxfm                          (applies transform (no optimisation) - requires -init)
            %  @param applyisoxfm <scale>               (as applyxfm but forces isotropic resampling)
            %  @param paddingsize <number of voxels>    (for applyxfm: interpolates outside image by size)
            %  @param searchrx <min_angle> <max_angle>  (angles in degrees: default is -90 90)
            %  @param searchry <min_angle> <max_angle>  (angles in degrees: default is -90 90)
            %  @param searchrz <min_angle> <max_angle>  (angles in degrees: default is -90 90)
            %  @param nosearch                          (sets all angular search ranges to 0 0)
            %  @param coarsesearch <delta_angle>        (angle in degrees: default is 60)
            %  @param finesearch <delta_angle>          (angle in degrees: default is 18)
            %  @param schedule <schedule-file>          (replaces default schedule)
            %  @param refweight <volume>                (use weights for reference volume)
            %  @param inweight <volume>                 (use weights for input volume)
            %  @param wmseg <volume>                    (white matter segmentation volume needed by BBR cost function)
            %  @param wmcoords <text matrix>            (white matter boundary coordinates for BBR cost function)
            %  @param wmnorms <text matrix>             (white matter boundary normals for BBR cost function)
            %  @param fieldmap <volume>                 (fieldmap image in rads/s - must be already registered to the reference image)
            %  @param fieldmapmask <volume>             (mask for fieldmap image)
            %  @param pedir <index>                     (phase encode direction of EPI - 1/2/3=x/y/z & -1/-2/-3=-x/-y/-z)
            %  @param echospacing <value>               (value of EPI echo spacing - units of seconds)
            %  @param bbrtype <value>                   (type of bbr cost function: signed [default], global_abs, local_abs)
            %  @param bbrslope <value>                  (value of bbr slope)
            %  @param setbackground <value>             (use specified background value for points outside FOV)
            %  @param noclamp                           (do not use intensity clamping)
            %  @param noresampblur                      (do not use blurring on downsampling)
            %  @param 2D                                (use 2D rigid body mode - ignores dof)
            %  @param verbose <num>                     (0 is least and default)
            %  @param v                                 (same as -verbose 1)

            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'in', [])
            addParameter(ip, 'ref', [])
            addParameter(ip, 'out', [])
            addParameter(ip, 'omat', '', @istext)
            addParameter(ip, 'bins', 256, @isscalar)
            addParameter(ip, 'cost', 'corratio', @istext)
            addParameter(ip, 'searchrx', [], @isnumeric)
            addParameter(ip, 'searchry', [], @isnumeric)
            addParameter(ip, 'searchrz', [], @isnumeric)
            addParameter(ip, 'dof', 6, @isscalar)
            addParameter(ip, 'paddingsize', 0.0, @isscalar)
            addParameter(ip, 'refweight', [])
            addParameter(ip, 'inweight', [])
            addParameter(ip, 'interp', 'trilinear', @istext)
            addParameter(ip, 'schedule', '', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            this.in_ = mlfourd.ImagingContext2(ipr.in);
            this.in_.selectNiftiTool();
            assert(~isempty(this.in_))
            this.ref_ = mlfourd.ImagingContext2(ipr.ref);
            this.ref_.selectNiftiTool();
            assert(~isempty(this.ref_))
            if isempty(ipr.out)
                ipr.out = sprintf('%s_on_%s.nii.gz', this.in_.fqfp, this.ref_.fileprefix);
            end
            this.out_ = mlfourd.ImagingContext2(ipr.out);
            if ~isfolder(fileparts(this.out_.filepath))
                mkdir(this.out_.filepath);
            end
            if isempty(ipr.omat)
                ipr.omat = strcat(this.out_.fqfp, '.mat');
            end
            this.omat_ = ipr.omat;
            if ~isfolder(fileparts(this.omat_))
                mkdir(this.omat_);
            end
            this.bins_ = ipr.bins;
            this.cost_ = ipr.cost;
            if isempty(ipr.searchrx)
                ipr.searchrx = 90;
            end
            if isscalar(ipr.searchrx)
                ipr.searchrx = [-ipr.searchrx ipr.searchrx];
            end
            this.searchrx_ = ipr.searchrx;
            if isempty(ipr.searchry)
                ipr.searchry = ipr.searchrx;
            end
            if isscalar(ipr.searchry)
                ipr.searchry = [-ipr.searchry ipr.searchry];
            end
            this.searchry_ = ipr.searchry;
            if isempty(ipr.searchrz)
                ipr.searchrz = ipr.searchrx;
            end
            if isscalar(ipr.searchrz)
                ipr.searchrz = [-ipr.searchrz ipr.searchrz];
            end
            this.searchrz_ = ipr.searchrz;
            this.dof_ = ipr.dof;
            this.paddingsize_ = ipr.paddingsize;
            if ~isempty(ipr.refweight)
                this.refweight_ = mlfourd.ImagingContext2(ipr.refweight);
                this.refweight_.selectNiftiTool();
            end
            if ~isempty(ipr.inweight)
                this.inweight_ = mlfourd.ImagingContext2(ipr.inweight);
                this.inweight_.selectNiftiTool();
            end
            this.interp_ = ipr.interp;
            this.schedule_ = ipr.schedule;
        end
        
        function [s,r] = applyXfm(this)
            %% uses this.init, which defaults to this.omat

            if ~isfile(this.in.fqfn)
                this.in.save();
            end
            if ~isfile(this.ref.fqfn)
                this.ref.save();
            end
            opts = sprintf('-paddingsize %.1f', this.paddingsize);
            cmd = sprintf('%s -in %s -applyxfm -init %s -out %s -ref %s %s -interp %s', ...
                this.exec, this.in.fqfn, this.init, this.out.fqfn, this.ref.fqfn, ...
                opts, ...
                this.interp);
            fprintf('mlfsl.Flirt.applyXfm:\n%s\n', cmd)
            [s,r] = mlbash(cmd);
        end
        function [s,r] = concatXfm(this, varargin)
            %  Params:
            %      AtoB (text)
            %      BtoC (text)
            %      AtoC (text): option, default given by compositionOfMaps(AtoB, BtoC).
            %  Returns:
            %      this.init: updated.

            ip = inputParser;
            addParameter(ip, 'AtoB', this.omat, @(x) istext(x) && contains(x, '.mat'))
            addParameter(ip, 'BtoC', '', @(x) istext(x) && contains(x, '.mat'))
            addParameter(ip, 'AtoC', '', @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            if isempty(ipr.AtoC)
                ipr.AtoC = this.compositionOfMaps(ipr.AtoB, ipr.BtoC);
            end

            exec_ = fullfile(getenv('FSLDIR'), 'bin', 'convert_xfm');
            cmd = sprintf('%s -omat %s -concat %s %s', exec_, ipr.AtoC, ipr.BtoC, ipr.AtoB);
            fprintf('mlfsl.Flirt.concatXfm:\n%s\n', cmd)
            [s,r] = mlbash(cmd);

            this.init_ = ipr.AtoC;
        end
        function [c,s,j] = cost_final(this)
            %  Returns:
            %      c (scalar): numerical value of cost
            %      s: struct for json
            %      j: json text
            cmd = sprintf('%s -in %s -ref %s -schedule %s/etc/flirtsch/measurecost1.sch -init %s -cost %s', ...
                this.exec, this.in.fqfn, this.ref.fqfn, getenv('FSLDIR'), this.init, this.cost);
            fprintf('mlfsl.Flirt.cost_final:\n%s\n', cmd)
            [s_,r_] = mlbash(cmd);
            assert(0 == s_)
            lines = splitlines(r_);
            line = sscanf(lines{1}, '%f')';
            c = line(1);
            [~,i] = max(contains(lines, 'Final'));
            mat = [];
            for i1 = i+1:length(lines)
                if ~isempty(lines{i1})
                    mat = [mat; sscanf(lines{i1}, '%f')']; %#ok<AGROW> 
                end
            end
            s = struct('mlfsl_Flirt', ...
                  struct('cost_final', ...
                    struct( ...
                      'cost', c, ...
                      'first_line', line, ...
                      'final_result', mat)));
            j = jsonencode(s, 'PrettyPrint', true);
        end
        function [s,r] = flirt(this)
            opts = sprintf('-bins %i -cost %s -searchrx %s -searchry %s -searchrz %s -dof %i', ...
                this.bins, this.cost, num2str(this.searchrx), num2str(this.searchry), num2str(this.searchrz), this.dof);
            if ~isempty(this.schedule)
                opts = sprintf('%s -schedule %s', opts, this.schedule);
            end
            if isa(this.refweight, 'mlfourd.ImagingContext2')
                if ~isfile(this.refweight.fqfn)
                    this.refweight.save();
                end
                opts = sprintf('%s -refweight %s', opts, this.refweight.fqfn);
            end
            if isa(this.inweight, 'mlfourd.ImagingContext2')
                if ~isfile(this.inweight.fqfn)
                    this.inweight.save();
                end
                opts = sprintf('%s -inweight %s', opts, this.inweight.fqfn);
            end
            if ~isfile(this.in.fqfn)
                this.in.save();
            end
            if ~isfile(this.ref.fqfn)
                this.ref.save();
            end
            if ~isempty(this.out)
                cmd = sprintf('%s -in %s -ref %s -out %s -omat %s %s -interp %s', ...
                    this.exec, this.in.fqfn, this.ref.fqfn, this.out.fqfn, this.omat, opts, this.interp);
            else
                cmd = sprintf('%s -in %s -ref %s -omat %s %s -interp %s', ...
                    this.exec, this.in.fqfn, this.ref.fqfn, this.omat, opts, this.interp);
            end
            fprintf('mlfsl.Flirt.flirt:\n%s\n', cmd)
            [s,r] = mlbash(cmd);
        end
        function [s,r] = fsleyes(this, varargin)
            exec_ = fullfile(getenv('FSLDIR'), 'bin', 'fsleyes');
            cmd = sprintf('%s %s %s', exec_, this.out.fqfn, cell2str(varargin));
            [s,r] = mlbash(cmd);
        end
        function [s,r] = invertXfm(this, varargin)
            %  Params:
            %      AtoB (text): option, default is this.omat.
            %  Returns:
            %      this.init: updated.

            ip = inputParser;
            addParameter(ip, 'AtoB', this.omat, @(x) istext(x) && contains(x, '.mat'))
            parse(ip, varargin{:})
            ipr = ip.Results;
            BtoA = this.inverseOfMap(ipr.AtoB);

            exec_ = fullfile(getenv('FSLDIR'), 'bin', 'convert_xfm');
            cmd = sprintf('%s -omat %s -inverse %s', exec_, BtoA, ipr.AtoB);
            fprintf('mlfsl.Flirt.invertXfm:\n%s\n', cmd)
            [s,r] = mlbash(cmd);

            this.init_ = BtoA;
        end
    end 

    %% PROTECTED    
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
            that.in_ = copy(this.in_);
            that.ref_ = copy(this.ref_);
            that.out_ = copy(this.out_);
            if ishandle(this.refweight_)
                that.refweight_ = copy(this.refweight_);
            end
            if ishandle(this.inweight_)
                that.inweight_ = copy(this.inweight_);
            end
        end
    end

    %% PRIVATE

    properties (Access = private)
        bins_
        cost_
        dof_
        in_
        init_
        interp_
        inweight_
        out_
        omat_
        paddingsize_
        ref_
        refweight_
        schedule_
        searchrx_
        searchry_
        searchrz_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

