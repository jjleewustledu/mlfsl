classdef AlignmentBuilderPrototype < mlfsl.AlignmentBuilder
	%% ALIGNMENTBUILDERPROTOTYPE is a concrete prototpye;
    %  it uses the prototype design pattern to create a variety of AlignmentBuilders for 
    %  PET, MRIConverter, Freesurfer, etc., without duplicating the hierarchy of product classes.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AlignmentBuilderPrototype.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AlignmentBuilderPrototype.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
	properties (Dependent)
         product
 		 referenceImage
         xfm
         inweight
         refweight
    end 

    methods %% SET/GET
        function this = set.product(this, img)
            this.product_ = imcast(img, 'mlfourd.ImagingContext');
        end
        function img  = get.product(this)
            assert(~isempty(this.product_));
            img = imcast(this.product_, 'mlfourd.ImagingContext');
        end
        function this = set.referenceImage(this, img)
            this.referenceImage_ = imcast(img, 'mlfourd.ImagingContext');
        end
        function img  = get.referenceImage(this)
            assert(~isempty(this.referenceImage_));
            img = imcast(this.referenceImage_, 'mlfourd.ImagingContext');
        end
        function x    = get.xfm(this)
            %% GET.XFM returns one of:
            %    - a f.q. filename obtained from this.product but ending in AlignmentBuilderPrototype.XFM_SUFFIX
            %    - a f.q. filename with FnirtVisitor.WARPCOEF_SUFFIX replaced by XFM_SUFFIX

            if (isempty(this.xfm_))
                this.xfm_ = imcast(this.product, 'fqfileprefix'); 
            end
            if (lstrfind(this.xfm_, mlfsl.FnirtVisitor.WARPCOEF_SUFFIX))
                pos = strfind(this.xfm_, mlfsl.FnirtVisitor.WARPCOEF_SUFFIX);
                this.xfm_ = this.xfm_(1:pos-1);
            end
            if (~lstrfind(this.xfm_, mlfsl.FlirtVisitor.XFM_SUFFIX));
                this.xfm_ = [this.xfm_ mlfsl.FlirtVisitor.XFM_SUFFIX]; end
            x = this.xfm_;
        end
        function this = set.xfm(this, x)
            %% SET.XFM casts its argument to a f.q. filename ending in AlignmentBuilderPrototype.XFM_SUFFIX
            
            x         = imcast(x, 'mlfourd.ImagingContext');
            this.xfm_ = [x.fqfileprefix mlfsl.FlirtVisitor.XFM_SUFFIX];
        end
        function w    = get.inweight(this)
            %%%assert(isempty(this.inweight_) || lexist(this.inweight_, 'file'));
            w = this.inweight_;
        end
        function this = set.inweight(this, w)
            this.inweight_ = [imcast(w, 'fqfileprefix') mlfourd.NIfTIInterface.FILETYPE_EXT];
        end
        function w    = get.refweight(this)
            %%%assert(isempty(this.refweight_) || lexist(this.refweight_, 'file'));
            w = this.refweight_;
        end
        function this = set.refweight(this, w)
            this.refweight_ = [imcast(w, 'fqfileprefix') mlfourd.NIfTIInterface.FILETYPE_EXT];
        end
    end
    
	methods 
        function this = buildMeanVolume(this)
            nii = imcast(this.product, 'mlfourd.NIfTI');            
            T   = nii.size(4); 
            acc = nii.img(:,:,:,1);
            for t = 2:T
                acc = acc + nii.img(:,:,:,t);
            end
            nii.img      = acc/T;
            this.product = nii.append_fileprefix(mlfsl.FlirtVisitor.MEANVOL_SUFFIX);
        end
        function this = buildMeanVolumeByComponent(this)
            imcmp = imcast(this.product, 'mlfourd.ImagingComponent');
            acc   = imcmp{1}.img;
            for c = 2:imcmp.length
                acc = acc + imcmp{c}.img;
            end
            imcmp{1}.img = acc/imcmp.length;
            this.product = mlfourd.ImagingSeries.load(imcmp{1});  
        end
        function this = buildMotionCorrected(this)
            vtor = mlfsl.FlirtVisitor;
            this = vtor.visitAlignmentBuilder2buildMotionCorrected(this);
        end    
        function this = applyXfm(this)
            vtor = mlfsl.FlirtVisitor;
            this = vtor.visitAlignmentBuilder2applyXfm(this);
        end
        function this = applywarp(this)
            vtor = mlfsl.FnirtVisitor;
            this = vtor.visitAlignmentBuilder2applywarp(this);
        end
            
        function obj  = clone(this)
            obj = mlfsl.AlignmentBuilderPrototype(this);
        end
        
 		function this = AlignmentBuilderPrototype(varargin) 
 			%% ALIGNMENTBUILDERPROTOTYPE 
 			%  Usage:  this = AlignmentBuilderPrototype([anAlignmentBuilderPrototype]|['parameter', 'value']) 
            %                                            ^ for copy-ctor
            %          Parameters    Values                                             ^            ^
            %          'product'     ImagingContext object       
            %          'reference'          "
            %          'xfm'         f.q. filename
            %          'inweight'    ImagingContext object
            %          'refweight'          "
            %          Alternatively assign this.product, this.referenceImage after construction.

            %  Copy ctor
 			this  = this@mlfsl.AlignmentBuilder(); 
            if (1 == nargin && isa(varargin{1}, 'mlfsl.AlignmentBuilderPrototype'))
                this.product_   = varargin{:}.product_;
                this.referenceImage_ = varargin{:}.referenceImage_;
                this.xfm_            = varargin{:}.xfm_;
                this.inweight_       = varargin{:}.inweight_;
                this.refweight_      = varargin{:}.refweight_;
                return
            end
            
            import mlfsl.*;
            p = inputParser;
            p.KeepUnmatched = true;
            addParamValue(p, 'image',          [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'product',        [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'reference',      [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'referenceImage', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'xfm',            [], @(x) lexist(x, 'file') || lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            addParamValue(p, 'inweight',       [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParamValue(p, 'refweight',      [], @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(p, varargin{:});
            this.product_        = p.Results.image;
            if (~isempty(p.Results.product))
            this.product_        = p.Results.product; end
            this.referenceImage_ = p.Results.reference;
            if (~isempty(p.Results.referenceImage))
            this.referenceImage_ = p.Results.referenceImage; end
            this.xfm_            = p.Results.xfm;
            this.inweight_       = p.Results.inweight;
            this.refweight_      = p.Results.refweight;
 		end 
    end 

    properties (Access = 'private')
        product_
        referenceImage_
        xfm_
        inweight_
        refweight_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

