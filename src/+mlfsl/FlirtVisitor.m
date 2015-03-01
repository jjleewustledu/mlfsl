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
            DEFAULT_DOF = 6;
    end

    methods (Static)
        function this  = createFromBuilder(bldr)
            %% CREATEFROMBUILDER
            
            assert(lexist(   bldr.sessionPath, 'dir'));
            assert(~lstrfind(bldr.sessionPath, 'fsl'));
            this = mlfsl.FlirtVisitor('product', bldr.product, 'sessionPath', bldr.sessionPath);
            setenv('SUBJECTS_DIR', this.studyPath);
        end 
    end
    
	methods 
        function bldr       = visitAlignmentBuilder2buildMotionCorrected(this, bldr)
            opts            = mlfsl.McflirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            [~,bldr.product] = this.mcflirt(opts);
        end
        function bldr       = visitAlignmentBuilder2applyXfm(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.init       = bldr.xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function [bldr,xfm] = visitAlignmentBuilder2concatXfms(this, bldr, xfms)
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
        function [bldr,xfm] = visitAlignmentBuilder2invertXfm(this, bldr)
            opts         = mlfsl.ConvertXfmOptions;
            opts.inverse = bldr.xfm;
            opts.omat    = this.xfmInverseName(bldr.xfm);
            [~,bldr.xfm] = this.inverseTransform(opts);
            xfm          = bldr.xfm;
        end
        function [bldr,xfm] = visitAlignmentBuilder4T2Star(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.dof        = 6;
            if (lexist(bldr.inweight, 'file'))
                opts.inweight = bldr.inweight; end
            if (lexist(bldr.refweight, 'file'))
                opts.refweight = bldr.refweight; end
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = visitAlignmentBuilder(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.dof        = this.DEFAULT_DOF;
            if (lexist(bldr.inweight, 'file'))
                opts.inweight = bldr.inweight; end
            if (lexist(bldr.refweight, 'file'))
                opts.refweight = bldr.refweight; end
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = visitAlignmentBuilderSmallAngles(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.dof        = 12;
            opts.searchrx   = ' -10 10 ';
            opts.searchry   = ' -10 10 ';
            opts.searchrz   = ' -10 10 ';
            if (lexist(bldr.inweight, 'file'))
                opts.inweight = bldr.inweight; end
            if (lexist(bldr.refweight, 'file'))
                opts.refweight = bldr.refweight; end
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = visitAlignmentBuilderUsingTransmission(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.referenceImage.fqfileprefix;
            opts.ref        = bldr.product.fqfileprefix;
            opts.dof        = 6;
            [~,xfm]         = this.flirt(opts);
            bldr.xfm        = xfm;
            [bldr,xfm]      = this.visitAlignmentBuilder2invertXfm(bldr);            
            
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.dof        = 6;
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts); 
        end
        function [bldr,xfm] = visitAlignmentBuilderRigidBody(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.dof        = 6;
            if (lexist(bldr.inweight, 'file'))
                opts.inweight = bldr.inweight; end
            if (lexist(bldr.refweight, 'file'))
                opts.refweight = bldr.refweight; end
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);            
        end
        function [bldr,xfm] = visitPETAlignmentBuilder(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.cost       = 'corratio';
            opts.dof        = 6;
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function [bldr,xfm] = visitPETAlignmentBuilderSmallAngles(this, bldr)
            opts            = mlfsl.FlirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.cost       = 'corratio';
            opts.dof        = 6;
            opts.searchrx   = ' -10 10 ';
            opts.searchry   = ' -10 10 ';
            opts.searchrz   = ' -10 10 ';
            [~,xfm]         = this.flirt(opts);
            opts.init       = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function  bldr      = visitAlign2fsaverage1mm(this, bldr)
            
            workpth = fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/fsaverage_2013nov18/fsl', '');
            xfm     = fullfile(workpth, 'brainmask_2mm_on_brainmask_1mm.mat');
            assert(lexist(xfm, 'file'))
            
            opts             = mlfsl.FlirtOptions;
            opts.in          = bldr.product.fqfileprefix;
            opts.ref         = fullfile(workpth, 'brainmask_1mm');
            opts.init        = xfm;
            [~,bldr.product] = this.applyTransform(opts);
        end
        function this       = FlirtVisitor(varargin)
            this = this@mlfsl.FslVisitor(varargin{:});
        end
    end 
    
    methods (Access = 'protected')
        function [this,omat] = flirt(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            [~,log] = mlfsl.FslVisitor.fslcmd('flirt', opts);
                      this.logged.add(log);  
               omat = opts.omat;
        end
        function [this,obj]  = mcflirt(this, opts)
            assert(isa(opts, 'mlfsl.McflirtOptions'));
            [~,log] = mlfsl.FslVisitor.fslcmd('mcflirt', opts);
                      this.logged.add(log);            
                obj = mlfourd.ImagingContext.load(filename([opts.in this.MCF_SUFFIX]));
        end
        function [this,im]   = applyTransform(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            opts.applyxfm = true;
            opts.omat     = [];
            [~,log]       = mlfsl.FslVisitor.fslcmd('flirt', opts); 
                            this.logged.add(log);
            im            = this.thisOnThatImageFilename(opts.in, opts.init);
        end
        function [this,xfm]  = concatTransforms(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.concat));
            assert(~isempty(opts.omat));
            [~,log] = mlfsl.FslVisitor.fslcmd('convert_xfm', opts); 
                            this.logged.add(log);
            xfm     = opts.omat;
        end
        function [this,xfm]  = inverseTransform(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.inverse));
            assert(~isempty(opts.omat));
            [~,log] = mlfsl.FslVisitor.fslcmd('convert_xfm', opts);
                      this.logged.add(log);
            xfm     = opts.omat;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

