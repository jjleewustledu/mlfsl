classdef FnirtVisitor < mlfsl.FslVisitor 
	%% FNIRTVISITOR   

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FnirtVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FnirtVisitor.m 2629 2013-09-16 06:19:00Z jjlee $ 
 	 

	properties (Constant)
        WARPCONFIG_EXT      = '.cfg';
        REGION_LABEL        = '_region';
        SEGMENTATION_LABEL  = 'rois_seg';
        WARPED_SUFFIX       = '_warped';
        WARPCOEF_SUFFIX     = '_warpcoef';
    end 
    
	methods 		 

 		function [bldr,nlxfm]    = visitAlignmentBuilder(this, bldr) 
            import mlpipeline.*;
            opts            = mlfsl.FnirtOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            assert(lexist(bldr.xfm, 'file'));
            opts.aff        = bldr.xfm;
            opts.cout       = PipelineVisitor.thisOnThatImageFilename(opts.in, [opts.ref this.WARPCOEF_SUFFIX]);
            if (lexist(bldr.sourceWeight, 'file'))
                opts.inmask = bldr.sourceWeight; end
            if (lexist(bldr.refweight, 'file'))
                opts.refmask = bldr.refweight; end
            [~,nlxfm]        = this.fnirt(opts);
            bldr.warp        = nlxfm;
        end 
        function [bldr,warpFqfn] = visitAlignmentBuilder2applywarp(this, bldr)
            import mlpipeline.*;
            opts            = mlfsl.ApplywarpOptions;
            opts.in         = bldr.product.fqfileprefix;
            opts.ref        = bldr.referenceImage.fqfileprefix;
            opts.warp       = bldr.warp;
            opts.out        = PipelineVisitor.thisOnThatImageFilename(opts.in, [opts.ref this.WARPED_SUFFIX]);
            if (~isempty(bldr.premat))
                opts.premat = bldr.premat; end
            if (~isempty(bldr.postmat))
                opts.postmat = bldr.postmat; end
            warpFqfn        = filename(opts.warp);
            assert(lexist(warpFqfn, 'file'));
            [~,bldr.product] = this.applywarp(opts);
        end
        function bldr            = visitAlignmentBuilder2invwarp(this, bldr)
            import mlpipeline.*;
            opts      = mlfsl.InversewarpOptions;
            opts.ref  = bldr.product.fqfileprefix;
            opts.warp = PipelineVisitor.thisOnThatImageFilename(opts.ref, [bldr.bettedStandard.fqfileprefix this.WARPCOEF_SUFFIX]);
            opts.out  = PipelineVisitor.thisOnThatImageFilename(bldr.bettedStandard.fqfileprefix, [opts.ref this.WARPCOEF_SUFFIX]);
            [~,bldr.product] = this.invwarp(opts);
        end
        function rbldr           = visitRoisBuilder2applywarp(this, rbldr)
            import mlpipeline.*;
            opts            = mlfsl.ApplywarpOptions;
            opts.in         = rbldr.product.fqfileprefix;
            opts.ref        = rbldr.bt1default.fqfileprefix;
            opts.warp       = PipelineVisitor.thisOnThatImageFilename(bldr.bettedStandard, [opts.ref this.WARPCOEF_SUFFIX]);
            opts.out        = [rbldr.mask.fqfileprefix this.WARPED_SUFFIX];
            opts.interp     = 'nn';
            warpFqfn        = filename(opts.warp);
            assert(lexist(warpFqfn, 'file'));
            [~,rbldr.product] = this.applywarp(opts);            
        end
        
 		function this = FnirtVisitor(varargin) 
 			this = this@mlfsl.FslVisitor(varargin{:}); 
 		end 
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function [this,nlxfm] = fnirt(this, opts)
            assert(isa(opts, 'mlfsl.FnirtOptions'));
            [~,~,log] = this.cmd('fnirt', opts);
                        this.logger.add(log);  
             nlxfm    = opts.cout;
        end
        function [this,im ]   = applywarp(this, opts)
            assert(isa(opts, 'mlfsl.ApplywarpOptions'));
            [~,~,log] = this.cmd('applywarp', opts); 
                        this.logger.add(log);
            im        = opts.out;
        end
        function [this,im]    = invwarp(this, opts)            
            assert(isa(opts, 'mlfsl.InversewarpOptions'));
            [~,~,log] = this.cmd('invwarp', opts); 
                        this.logger.add(log);
            im        = opts.out;
        end
        function [this,im]    = convertwarp(this, opts) 
            im = opts.out;
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

