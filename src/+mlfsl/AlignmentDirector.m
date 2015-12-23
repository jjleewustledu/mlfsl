classdef AlignmentDirector < mlfsl.IAlignmentDirector
	%% ALIGNMENTDIRECTOR is the concrete component in a decorator design pattern;
    %  additional responsibilities may be attached

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AlignmentDirector.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AlignmentDirector.m 2644 2013-09-21 22:58:45Z jjlee $ 	 

    properties (Dependent)
        alignmentBuilder
        logger
        product
        referenceImage
        sourceImage
        xfm
        inweight
        refweight
    end
    
    methods %% Set/Get
        function this = set.alignmentBuilder(this, bldr)
            assert(isa(bldr, 'mlfsl.AlignmentBuilder'));
            this.alignmentBuilder_ = bldr;
        end
        function bldr = get.alignmentBuilder(this)
            bldr = this.alignmentBuilder_;
        end
        function this = set.logger(this, lg)
            this.alignmentBuilder_.logger = lg;
        end
        function img  = get.logger(this)
            img = this.alignmentBuilder_.logger;
        end
        function this = set.product(this, prod)
            this.alignmentBuilder_.product = prod;
        end
        function prod = get.product(this)
            prod = this.alignmentBuilder_.product;
        end
        function this = set.referenceImage(this, ref)
            this.alignmentBuilder_.referenceImage = ref;
        end
        function ref  = get.referenceImage(this)
            ref = this.alignmentBuilder_.referenceImage;
        end
        function this = set.sourceImage(this, src)
            this.alignmentBuilder_.sourceImage = src;
        end
        function img  = get.sourceImage(this)
            img = this.alignmentBuilder_.sourceImage;
        end
        function this = set.xfm(this, x)
            this.alignmentBuilder_.xfm = x;
        end
        function x    = get.xfm(this)
            x = this.alignmentBuilder_.xfm;
        end
        function this = set.inweight(this, w)
            this.alignmentBuilder_.inweight = w;
        end
        function w    = get.inweight(this)
            w = this.alignmentBuilder_.inweight;
        end
        function this = set.refweight(this, w)
            this.alignmentBuilder_.refweight = w;
        end
        function w    = get.refweight(this)
            w = this.alignmentBuilder_.refweight;
        end

    end
    
	methods 
        function [prds,this] = alignSequentially(this, imgs)
            %% ALIGNSEQUENTIALLY ... imgs{3} <- imgs{2} <- imgs{1}
            %  accepts types accepted by imcast, returns an ImagingComposite

            % clone on entry not at exit
            imgs = imcast(imgs, 'mlfourd.ImagingComposite');
            assert(imgs.length > 1);
            for m = length(imgs)-1:-1:1
                toalign = imgs{m}.clone;
                ref     = imgs{m+1}.clone;
                imgs{m} = this.alignPair(toalign, ref);
            end
            this.product = imgs;
            prds         = this.product;
        end
        function [prds,this] = alignSequentiallySmallAngles(this, imgs)
            %% ALIGNSEQUENTIALLY ... imgs{3} <- imgs{2} <- imgs{1}
            %  accepts types accepted by imcast, returns an ImagingComposite

            % clone on entry not at exit
            imgs = imcast(imgs, 'mlfourd.ImagingComposite');
            assert(imgs.length > 1);
            for m = length(imgs)-1:-1:1
                toalign = imgs{m}.clone;
                ref     = imgs{m+1}.clone;
                imgs{m} = this.alignPairSmallAngles(toalign, ref);
            end
            this.product = imgs;
            prds         = this.product;
        end
        function [prds,this] = alignIndependently(this, imgs, ref)
            imgs = imcast(imgs, 'mlfourd.ImagingComposite');
            if (~exist('ref', 'var'))
                ref = this.referenceImage; end
            for m = 1:length(imgs)
                toalign = imgs{m}.clone;
                imgs{m} = this.alignPair(toalign, ref);
            end
            this.product = imgs;
            prds         = this.product;
        end
        function [prds,this] = alignIndependentlySmallAngles(this, imgs, ref)
            imgs = imcast(imgs, 'mlfourd.ImagingComposite');
            if (~exist('ref', 'var'))
                ref = this.referenceImage; end
            for m = 1:length(imgs)
                toalign = imgs{m}.clone;
                imgs{m} = this.alignPairSmallAngles(toalign, ref);
            end
            this.product = imgs;
            prds         = this.product;
        end
        function [prd,this]  = alignSingle(this, img)
            [prd,this] = this.alignPair(img, this.referenceImage);
        end
 		function [prd,this]  = alignPair(this, img, ref)
            this.product           = img;
            this.referenceImage    = ref;
            this.alignmentBuilder_ = this.alignmentBuilder_.buildFlirted;
            prd                    = this.product;
        end 
 		function [prd,this]  = alignPairSmallAngles(this, img, ref)
            this.product           = img;
            this.referenceImage    = ref;
            this.alignmentBuilder_ = this.alignmentBuilder_.buildFlirtedSmallAngles;
            prd                    = this.product;
        end 
        function [prd,this]  = alignThenApplyXfm(this, varargin)
            %% ALIGNTHENAPPLYXFM aligns the first image of the passed ImagingComposite/ImagingContext
            %  then applies the transformation matrix to all subsequent images of the ImagingComposite/ImagingContext
            %  [new_images,obj] = obj.alignThenApplyXfm(images[, reference_image])
            %                                           ^ any ImagingContext, typically containing an ImagingComposite
            %                                                    ^ default is obj.referenceImage
            
            p = inputParser;
            addRequired(p, 'imgs',                      @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(p, 'ref',  this.referenceImage, @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(p, varargin{:});            
            imgs = p.Results.imgs.imcomponent; 
            assert(imgs.length > 1);
            ref  = p.Results.ref.nifti;
            
            import mlfourd.*;
            aligned = this.alignPair(imgs{1}, ref);
            aligned.nifti.save;
            prd = ImagingComponent.load(aligned);
            for a = 2:length(imgs)
                this.product           = imgs{a};
                this.referenceImage    = ref;
                this.xfm               = prd{1};
                this.alignmentBuilder_ = this.alignmentBuilder_.applyXfm;
                prd                    = prd.add(this.alignmentBuilder_.product);
            end
            prd = ImagingContext.load(prd);
            this.product = prd;
        end
        function [prd,this]  = applyXfm(this, prd, ref, xfm)
            import mlfourd.*;
            prd = ImagingContext(prd);
            ref = ImagingContext(ref);
            assert(ischar(xfm));
            
            this.product          = prd;
            this.referenceImag    = ref;
            this.xfm              = xfm;
            this.alignmentBuilder_ = this.alignmentBuilder_.applyXfm;
            prd                    = this.alignmentBuilder_.product;
        end
        
        function [prd,this]  = motionCorrect(this, timedep)
            this.product           = timedep;
            this.alignmentBuilder_ = this.alignmentBuilder_.buildMotionCorrected;
            prd                    = this.alignmentBuilder_.product;
        end
        function [prd,this]  = meanvol(this, imobj)
            this.product           = imobj;
            this.alignmentBuilder_ = this.alignmentBuilder_.buildMeanVolume;
            prd                    = this.alignmentBuilder_.product;
        end
        function  prd        = meanvolByComponent(this, imcmp)
            this.product           = imcmp;
            this.alignmentBuilder_ = this.alignmentBuilder_.buildMeanVolumeByComponent;
            prd                    = this.alignmentBuilder_.product;
        end
        
 		function this        = AlignmentDirector(varargin)
 			%% ALIGNMENTDIRECTOR 
 			%  Usage:  this = AlignmentDirector([anAlignmentBuilder]) 
            %                                    ^ default is an AlignmentBuilder

            p = inputParser;
            addOptional(p, 'bldr', mlfsl.AlignmentBuilderPrototype, @(x) isa(x, 'mlfsl.AlignmentBuilder'));
            parse(p, varargin{:});
            
            this.alignmentBuilder_ = p.Results.bldr;
 		end 
    end 
    
    properties (Access = 'private')
        alignmentBuilder_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

