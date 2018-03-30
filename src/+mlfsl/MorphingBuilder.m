classdef MorphingBuilder < mlmr.MRAlignmentBuilder 
	%% MORPHINGBUILDER   
    %  See also:  mlpatterns.BuilderImpl

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties (Dependent)
        bt1default
        standardImage
        bettedStandard
        warp
        premat
        postmat
 	end 

	methods %% Get/Set
        function img  = get.bt1default(this)
            img = mlfourd.ImagingContext.load( ...
                  fullfile(this.product.filepath, 'bt1_default_restore.nii.gz'));
        end
        function this = set.standardImage(this, si)
            assert(~isempty(si));
            this.standardImage_ = mlfourd.ImagingContext.load(si);
        end
        function si   = get.standardImage(this)
            if (isempty(this.standardImage_))
                this.standardImage_ = ImagingContext.load( ...
                    fullfile(this.standardPath, [NamingRegistry.mniNames{1} '.nii.gz']));
            end
            si = this.standardImage_;
        end
        function this = set.bettedStandard(this, bs)
            assert(~isempty(bs));
            this.bettedStandard_ = mlfourd.ImagingContext.load(bs);
        end
        function bs   = get.bettedStandard(this)
            import mlfourd.*;
            if (isempty(this.bettedStandard_))
                this.bettedStandard_ = ImagingContext.load( ...
                    fullfile(this.standardPath, [NamingRegistry.mniNames{1} '_brain.nii.gz']));
            end
            bs = this.bettedStandard_;
        end
        function w    = get.warp(this)
            import mlfsl.*;
            if (isempty(this.warp_))
                this.warp_ = imcast(this.product, 'fqfileprefix');  end
            if (~lstrfind(this.warp_, FnirtVisitor.WARPCOEF_SUFFIX))
                this.warp_ = [this.warp_ FnirtVisitor.WARPCOEF_SUFFIX]; end
            w = this.warp_;
        end
        function this = set.warp(this, w)
            this.warp_ = imcast(w, 'fqfileprefix');
        end
        function x    = get.premat(this)
            x = this.premat_;
        end
        function this = set.premat(this, x)
            this.xfm_ = [imcast(x, 'fqfileprefix') mlfsl.FlirtVisitor.XFM_SUFFIX];
        end
        function x    = get.postmat(this)
            x = this.postmat_;
        end
        function this = set.postmat(this, x)
            this.postmat_ = [imcast(x, 'fqfileprefix') mlfsl.FlirtVisitor.XFM_SUFFIX];
        end
    end
    
    methods
        function this = buildBetted2Betted(this)
            this = this.buildVisitor.alignMultispectral(this);
            
            nvisit       = mlfsl.FnirtVisitor;
            this.xfm     = this.xfm;
            this.warp    = this.warp;
            this.product = this.product;
            this         = nvisit.visitAlignmentBuilder(this);
            this         = nvisit.visitAlignmentBuilder2applywarp(this);
        end
        function this = buildFnirted(this)
            nvisit = mlfsl.FnirtVisitor;
            this   = nvisit.visitAlignmentBuilder(this);
            this   = nvisit.visitAlignmentBuilder2applywarp(this);
        end
        function this = buildFnirted2standard(this)
            bproduct            = this.product;
            this.referenceImage = this.standardImage;
            this                = this.buildVisitor.alignMultispectral(this);
            
            nvisit       = mlfsl.FnirtVisitor;
            this.xfm     = this.xfm;
            this.warp    = this.warp;
            this.product = bproduct;
            this         = nvisit.visitAlignmentBuilder(this);
            this         = nvisit.visitAlignmentBuilder2applywarp(this);
        end
        function this = buildFnirted2bettedStandard(this)
            import mlfsl.*;
            
            %vtor = BrainExtractionVisitor;
            %this = vtor.visitMRAlignmentBuilder(this);
            this.product = mlfourd.ImagingContext.load(fullfile(this.product.filepath, ['b' this.product.filename]));
            
            avisit = FastVisitor;
            this   = avisit.visitMRAlignmentBuilder_t1channel(this);
            
            bproduct            = this.product;
            this.referenceImage = this.bettedStandard; 
            this                = this.buildVisitor.alignMultispectral(this);
            
            nvisit       = FnirtVisitor;
            this.xfm     = this.xfm;  %% KLUDGE to set private variables
            this.warp    = this.warp; %
            this.product = bproduct;  %
            this         = nvisit.visitAlignmentBuilder(this);
            this         = nvisit.visitAlignmentBuilder2applywarp(this);
        end
        function this = buildFnirted4T2star(this)
            
        end
        function this = buildApplywarp(this)
            assert(~isempty(this.product));
            assert(~isempty(this.warp));
            assert(~isempty(this.xfm));
            nvisit = mlfsl.FnirtVisitor;
            this   = nvisit.visitAlignmentBuilder2applywarp(this);
        end
        function this = buildInvwarp(this)
            nvisit = mlfsl.FnirtVisitor;
            this   = nvisit.visitAlignmentBuilder2invwarp(this);
        end
        function obj  = clone(this)
            obj = mlfsl.MorphingBuilder(this);
        end
        
 		function this = MorphingBuilder(varargin) 
 			%% MORPHINGBUILDER 
 			%  Usage:  this = MorphingBuilder() 

 			this = this@mlmr.MRAlignmentBuilder(varargin{:}); 
            p = inputParser;
            p.KeepUnmatched = true;
            addParamValue(p, 'standardImage',  [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'bettedStandard', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'warp',           [], @(x) lexist(x, 'file') || lexist([x FnirtVisitor.WARPCOEF_SUFFIX], 'file') ...
                                                                          || lexist([x FnirtVisitor.INVWARPCOEF_SUFFIX], 'file'));
            addParamValue(p, 'premat',         [], @(x) lexist(x, 'file') || lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            addParamValue(p, 'postmat',        [], @(x) lexist(x, 'file') || lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            parse(p, varargin{:});
            
            this.standardImage_  = p.Results.standardImage;
            this.bettedStandard_ = p.Results.bettedStandard;
 		end 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        standardImage_
        bettedStandard_
        warp_
        premat_
        postmat_
    end
    
    methods (Access = 'private')
        function pth = standardPath(this)
            pth = fullfile(this.fslHome, 'data','standard', '');
        end
        function fh  = fslHome(~)
            fh = '/usr/local/fsl';
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

