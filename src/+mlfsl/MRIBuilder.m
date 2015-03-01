classdef MRIBuilder < mlfsl.FlirtBuilder
	%% MRIBUILDER is a concrete builder for MRImagingComponent
    %  Version $Revision: 2481 $ was created $Date: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/MRIBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRIBuilder.m 2481 2013-08-18 06:44:27Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Constant)
        MR0 = 1;
        MR1 = 2;
    end 
        
    properties (Access = 'protected')
        
        aseFileprefixes   = {'ase'    'ase2nd'};
        mcverterFolder = 'MRIConvert';
        ignore         = {'*local*.nii.gz' '*MIP*.nii.gz' '*TTP*' '*GBP*' '*PBP*'}
        
        cbfnii
        cbvnii
        mttnii
    end
           
    properties (Dependent)   
        dcmPaths
        dcmPath
        mrPath
        mcverterPath
    end 
    
    
    
    methods (Static)
        function bldr       = createFromDicomPath(stdPth, dcmPth)
            %% CREATESTUDYBUILDER
            %  Usage:   bldr = MRIBuilder.createStudyBuilder(dicom_path)
            %                                                      ^ complete path as string

            cvtr = mlsurfer.SurferDicomconverter(stdPth, dcmPth);
            bldr = mlfsl.MRIBuilder(cvtr);
        end
        function this = createFromModalityPath(mpth)
            assert(lexist(mpth, 'dir'));
            this = mlfsl.MRIBuilder( ...
                   mlsurfer.SurferDicomConverter.createFromModalityPath(mpth));
        end
        function [nii this] = MRfactory(pnum, metric, msknii, blur)
            %% MRFACTORY produces a NIfTI object & an MRIBuilder object
            %  Usage: [nii this] = PETfactory(pnum [, metric, msknii, blur])
            %          pnum:       string (e.g., 'vc4437') or NIfTI object
            %          metric:    'oo', 'oc', 'ho', 'cbf', 'cbv', 'mtt', 'cmro2', 'oef'
            %          msknii:    NIfTI or [] 
            %          blur:      e.g., [16 16 16], in mm fwhh
            %                     always applied before blocking
            %          nii:       requested NIfTI
            %          this:      MRIBuilder
            
            import mlfourd.* mlfsl.*;
            this = MRIBuilder;
            switch (nargin)
                case 1
                    this        = MRIBuilder(pnum, [],     this.baseBlur);
                    this.metric = 'cbf';
                case 2
                    this        = MRIBuilder(pnum, [],     this.baseBlur);
                    this.metric = metric;
                case 3
                    this        = MRIBuilder(pnum, msknii, this.baseBlur);
                    this.metric = metric;
                case 4
                    this        = MRIBuilder(pnum, msknii, blur);
                    this.metric = metric;
                case 5
                    this        = MRIBuilder(pnum, msknii, blur);
                    this.metric = metric;
            end
            assert(ischar(metric));
            switch (lower(metric))
                case {'mrcbf','mr1cbf','qcbf','cbf'}
                    nii = this.make_metric_nii(this.MR1);
                case {'mrcbv','mr1cbv','qcbv','cbv'}
                    nii = this.make_metric_nii(this.MR1);
                case {'mrmtt','mr1mtt','qmtt','mtt'}
                    nii = this.make_metric_nii(this.MR1);
                case {'mr0cbf','scbf'}
                    nii = this.make_metric_nii(this.MR0);
                case {'mr0cbv','scbv'}
                    nii = this.make_metric_nii(this.MR0);
                case {'mr0mtt','smtt'}
                    nii = this.make_metric_nii(this.MR0);
                otherwise
                    error('mlfourd:InputParamsErr', ...
                         ['MRfactory could not recognize requested metric ' metric]);
            end
        end % static MRfactory       
    end % static methods
    
	methods %% set/get
        function pth  = get.mcverterPath(this)
            pth = fullfile(this.mrPath, this.mcverterFolder, '');
            if (~exist(pth, 'dir')); mkdir(pth); end
        end
        function pths = get.dcmPaths(this)
            flds = mlsurfer.SurferDicomconverter.dicomFolders;
            pths = cell(size(flds));
            for p = 1:length(flds)  %#ok<*FORFLG>
                pths{p} = fullfile(this.pnumPath, flds{p}, ''); 
            end
        end
        function pth  = get.dcmPath( this)
            pth = fullfile(this.pnumPath, mlsurfer.SurferDicomconverter.dicomFolders{1}, '');
        end
    end
    
    methods 
        function structInfo = queryNativeImagingTypes(this)
            %% QUERYNATIVEIMAGINGTYPES returns a *converter.dicomQuery          
            
            structInfo = this.converter.dicomQuery;
        end % queryNativeImagingTypes
        function              clean(this)
            error('mlfsl:NotImplemented'); %#ok<*ERTXT>
        end        
        function              nativeToNIfTI(this)
            assert(isa(this.converter, 'mlsurfer.SurferDicomconverter'));
            this.converter.dicoms2cell;
        end % nativeToNIfTI
        function              rename(this, newname)
            error('mlfsl:NotImplemented');
        end
        function exp        = mcverter_rgx(this, idx)
            import mlsurfer.*;
            if (~exist('idx','var')); idx = 1; end
            exp = [ '\w*(?=\' SurferDicomconverter.dicomFolders{idx} ')' ]; 
        end % mcverter_rgx            
        function              flirtAsePairs(this, fp, fp2nd)
            
            %% FLIRTASEPAIRS
            %  Usage:  obj.flirtAsePairs(file, file2nd)
            %                              ^     ^ fprefixes or fnames
            %  Uses:   FlirtBuilder.*; flirt, matrix_fqfn, image_fp, applyxfm
            import mlfsl.* mlfourd.*;
            try
                if (strcmp(fp, fp2nd)); return; end
                fp2nd    = fileprefix(ensureOnBetPath(fp2nd));
                fp       = fileprefix(ensureOnBetPath(fp));
                
                fstem2nd = fileprefix(NamingRegistry.meanvol(   fp2nd));
                fstem    = fileprefix(NamingRegistry.notMeanvol(fp));
                fn2nd    = filename(  fp2nd);
                fn       = filename(  fp);
                
                if (NIfTI.isNIfTI(fn2nd) && NIfTI.isNIfTI(fn))
                    flirtb    = FlirtBuilder(this);
                    opts      = FlirtOptions;
                    opts.ref  = fp2nd;
                    opts.in   = fp;
                    opts.omat = flirtb.xfmName(fstem2nd, fstem);
                    opts.out  = flirtb.imageObject(  fp2nd,    fp);
                    flirtb    = flirtb.coregister(opts);
                    fp2nd_mcf = NamingRegistry.mcf(fstem2nd);                    

                    opts.ref  = fp;
                    opts.in   = fp2nd_mcf;
                    opts.out  = flirtb.imageObject(fp2nd_mcf, fp);
                    opts.init = flirtb.xfmName(fstem2nd, fstem);
                    flirtb.applyTransform(opts);
                end
            catch ME
                handwarning(ME, 'MRIBuilder.makeFlirtedAse');
            end
        end % flirtAsePairs
        function pth        = ensureOnBetPath(this, pth)
            if (isempty(strfind(pth, this.bettedPath)))
                pth = fullfile(this.bettedPath, pth);
            end
        end
        function nii        = make_metric_nii(this, idx)
            
            %% MAKE_METRIC_NII
            %  Usage:  idx -> 0 for comparator, >0 for new methods
            %               
            metric_nii  = mlfourd.NIfTI.load(this.reg.mr_filename(this.metric,1,0,0), ['MR' num2str(idx-1)]);
            metric_niib = mlfourd.NiiBrowser(metric_nii, this.baseBlur);                
            if (this.blur2bool)
                metric_niib = metric_niib.blurredBrowser(this.baseBlur, this.foreground);
            end
            if (this.block2bool)
                metric_niib = metric_niib.blockedBrowser(this.blockSize, this.foreground);
            end
            metric_niib.fileprefix = this.reg.mr_filename(this.metric, -1);
            nii = metric_niib;
            if (this.pipeline_.debugging)
                disp('make_metric_nii:  created:'); disp(metric_niib);
            end
            
            if     (findstr('cbf', this.metric)) 
                this.cbfnii{idx} = metric_niib;
            elseif (findstr('cbv', this.metric)) 
                this.cbvnii{idx} = metric_niib;
            elseif (findstr('mtt', this.metric)) 
                this.mttnii{idx} = metric_niib;
            else
                error('mlfourd:UnknownParam', ['MRIBuilder.metric->' this.metric]);
            end
        end % make_metric_nii
    end % methods
    
    %% PROTECTED 
    
    methods %(Access = 'protected')
 		function this = MRIBuilder(varargin) 
 			%% MRIBUILDER 
 			%  Usage:  prefer using creation methods 
            %          obj = MRIBuilder()
            
            this = this@mlfsl.FlirtBuilder(varargin{:});
            this.cbfnii      = cell(1,2);
            this.cbvnii      = cell(1,2);
            this.mttnii      = cell(1,2);
 		end % MRIBuilder (ctor)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

