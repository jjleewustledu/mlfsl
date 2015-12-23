classdef FlirtVisitor < mlfsl.FslVisitor 
	%% FLIRTVISITOR   

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FlirtVisitor.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
    properties (Constant)
             MCF_SUFFIX = '_mcf';
         MEANVOL_SUFFIX = '_meanvol';
              KL_METRIC =  'kldivergence';
        PREPROCESS_LIST = { 'none' 'gauss' 'susan' 'blindd' };
             XFM_SUFFIX = '.mat';
            ALWAYS_SAVE = false;
    end
    
	methods 
        
        function [bldr,xfm] = alignMultispectral(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.dof         = 6;
            opts.cost        = 'normmi';
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            opts.init        = xfm;
            bldr.xfm         = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end        
        function [bldr,xfm] = alignSmallAnglesGluT(this, bldr)
            this.ensureSaved(bldr.product);
            this.ensureSaved(bldr.referenceImage);
            
            opts          = mlfsl.FlirtOptions;
            opts.in       = this.assignIn(bldr);
            opts.ref      = this.assignRef(bldr);
            opts.dof      = 6;  
            opts.cost     = 'normmi';
            opts.searchrx = ' -20 20 ';
            opts.searchry = ' -20 20 ';
            opts.searchrz = ' -20 20 ';
            opts          = this.assignWeights(bldr, opts);            
            [~,xfm]       = this.flirt(opts);
        end
        function [bldr,xfm] = alignMultispectralGluT(this, bldr)
            this.ensureSaved(bldr.product);
            this.ensureSaved(bldr.referenceImage);
            
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.dof         = 6;  
            opts.cost        = 'normmi';
            opts             = this.assignWeights(bldr, opts);            
            [~,xfm]          = this.flirt(opts);
        end        
        function [bldr,xfm] = align6DOF(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.dof         = 6;
            opts.cost        = 'normmi';
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            opts.init        = xfm;
            bldr.xfm         = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = alignSmallAngles(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.dof         = 12;
            opts.cost        = 'normmi';
            opts.searchrx    = ' -10 10 ';
            opts.searchry    = ' -10 10 ';
            opts.searchrz    = ' -10 10 ';
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = alignPETUsingTransmission(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignRef(bldr);
            opts.ref         = this.assignIn(bldr);
            opts.dof         = 6;
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            bldr.xfm         = xfm;
            [bldr,xfm]       = this.inverseTransformOfBuilder(bldr);            
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.dof         = 6;
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts); 
        end
        function [bldr,xfm] = alignPET(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.cost        = 'corratio';
            opts.dof         = 6;
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function [bldr,xfm] = alignSmallAnglesForPET(this, bldr)
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = this.assignRef(bldr);
            opts.cost        = 'corratio';
            opts.dof         = 6;
            opts.searchrx    = ' -10 10 ';
            opts.searchry    = ' -10 10 ';
            opts.searchrz    = ' -10 10 ';
            opts             = this.assignWeights(bldr, opts);
            [~,xfm]          = this.flirt(opts);
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function  bldr      = alignToFsaverage1mm(this, bldr)
            workpth = fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/fsaverage_2013nov18/fsl', '');
            xfm     = fullfile(workpth, 'brainmask_2mm_on_brainmask_1mm.mat');
            assert(lexist(xfm, 'file'))
            
            opts             = mlfsl.FlirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.ref         = fullfile(workpth, 'brainmask_1mm');
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        
        function bldr        = applyTransformOfBuilder(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = this.assignIn(bldr);
            opts.ref        = this.assignRef(bldr);
            opts.init       = bldr.xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function bldr        = applyTransformNearestNeighbor(this, bldr)
            this.ensureSaved(bldr.product);
            this.ensureSaved(bldr.referenceImage);
            
            opts         = mlfsl.FlirtOptions;
            opts.interp  = 'nearestneighbour';
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            [~,fqfn]     = this.applyTransform(opts);
            bldr.product = mlfourd.ImagingContext(mlfourd.NIfTId(fqfn));
        end
        function bldr        = applyTransformForGluT(this, bldr)
            this.ensureSaved(bldr.product);
            this.ensureSaved(bldr.referenceImage);
            
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            [~,fqfn]     = this.applyTransform(opts);
            
            import mlfourd.*;
            switch (class(bldr.product))
                case 'mlfourd.NIfTId'                    
                    bldr.product = ImagingContext(NIfTId(fqfn));
                case 'mlfourd.NIfTI'                    
                    bldr.product = ImagingContext(NIfTI(fqfn));
                otherwise
                    error('mlfs:unexpectedSwitchCase', ...
                          'FlirtVisitor.applyTransformForGluT.bldr.product has class %s', class(bldr.product));
            end
        end
        function [bldr,xfm]  = inverseTransformOfBuilder(this, bldr)
            opts         = mlfsl.ConvertXfmOptions;
            opts.inverse = bldr.xfm;
            opts.omat    = this.xfmInverseName(bldr.xfm);
            [~,bldr.xfm] = this.inverseTransform(opts);
            xfm          = bldr.xfm;
        end        
        function [bldr,xfm]  = concatTransformsOfBuilder(this, bldr, xfms)
            assert(iscell(xfms));
            opts = mlfsl.ConvertXfmOptions;
            for x = 1:length(xfms)-1                
                opts.concat   = sprintf('%s %s', xfms{x+1}, xfms{x});
                opts.omat     = this.xfmConcatName(xfms{x}, xfms{x+1});
                [~,xfms{x+1}] = this.concatTransforms(opts);
            end            
            xfm      = xfms{end};
            bldr.xfm = xfm;
        end
        function bldr        = motionCorrect(this, bldr)
            opts             = mlfsl.McflirtOptions;
            opts.in          = this.assignIn(bldr);
            opts.dof         = 6;
            [~,bldr.product] = this.mcflirt(opts);
        end
        function bldr        = motionCorrectPET(this, bldr)
            opts             = mlfsl.McflirtOptions;
            if (~isempty(bldr.referenceImage))
                this.ensureSaved(bldr.referenceImage);
                opts.reffile = ref.fqfilename;
            end
            this.ensureSaved(bldr.product);
            opts.in          = this.assignIn(bldr);
            opts.dof         = 6;
            opts.cost        = 'mutualinfo';
            [~,bldr.product] = this.mcflirt(opts);            
        end
        
        function this = FlirtVisitor(varargin)
            this = this@mlfsl.FslVisitor(varargin{:});
        end
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')  
        function in          = assignIn(~, bldr)
            if (~isempty(bldr.sourceImage))
                in = bldr.sourceImage.fqfileprefix;
                return
            end
            in = bldr.product.fqfileprefix; % legacy work-flow
        end
        function ref         = assignRef(~, bldr)
            assert(~isempty(bldr.referenceImage));
            ref = bldr.referenceImage.fqfileprefix;
        end
        function opts        = assignWeights(~, bldr, opts)
            if (~isempty(bldr.inweight))
                assert(isa(bldr.inweight, 'mlfourd.ImagingContext'));
                if (~lexist(bldr.inweight.fqfilename, 'file'))
                    bldr.inweight.save; end
                opts.inweight = bldr.inweight.fqfileprefix;
            end
            if (~isempty(bldr.refweight))
                assert(isa(bldr.refweight, 'mlfourd.ImagingContext'));
                if (~lexist(bldr.refweight.fqfilename, 'file'))
                    bldr.refweight.save; end
                opts.refweight = bldr.refweight.fqfileprefix;
            end
        end      
        function               ensureSaved(this, ic)
            assert(isa(ic, 'mlfourd.ImagingContext'));
            if (~lexist(ic.fqfilename, 'file') || this.ALWAYS_SAVE)
                ic.niftid.save;
            end
        end
        function [this,omat] = flirt(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            mlfsl.FslVisitor.fslcmd('flirt', opts);
            omat = opts.omat;
        end
        function [this,obj]  = mcflirt(this, opts)
            assert(isa(opts, 'mlfsl.McflirtOptions'));
            mlfsl.FslVisitor.fslcmd('mcflirt', opts);
            obj = mlfourd.ImagingContext.load(filename([opts.in this.MCF_SUFFIX]));
        end
        function [this,obj]  = applyTransform(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            opts.applyxfm = true;
            opts.omat = [];
            mlfsl.FslVisitor.fslcmd('flirt', opts); 
            obj = mlfourd.ImagingContext.load( ...
                  this.thisOnThatImageFilename(opts.in, opts.init));
        end
        function [this,xfm]  = concatTransforms(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.concat));
            assert(~isempty(opts.omat));
            mlfsl.FslVisitor.fslcmd('convert_xfm', opts); 
            xfm = opts.omat;
        end
        function [this,xfm]  = inverseTransform(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.inverse));
            assert(~isempty(opts.omat));
            mlfsl.FslVisitor.fslcmd('convert_xfm', opts);
            xfm = opts.omat;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

