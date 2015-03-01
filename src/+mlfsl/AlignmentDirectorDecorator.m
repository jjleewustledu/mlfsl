classdef AlignmentDirectorDecorator < mlfsl.AlignmentDirectorComponent
	%% DECORATEDALIGNMENTDIRECTOR maintains a reference to a component object,
    %  forwarding requests to the component object.   
    %  Maintains an interface consistent with the component's interface.
    %  Subclasses may optionally perform additional operations before/after forwarding requests.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AlignmentDirectorDecorator.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AlignmentDirectorDecorator.m 2644 2013-09-21 22:58:45Z jjlee $ 
    
    properties (Dependent)
        alignmentBuilder
        product
        referenceImage
        xfm
        inweight
        refweight
    end
  
    methods %% Set/Get
        function this = set.alignmentBuilder(this, bldr)
            this.component_.alignmentBuilder = bldr;
        end
        function bldr = get.alignmentBuilder(this)
            bldr = this.component_.alignmentBuilder;
        end
        function this = set.product(this, img)
            this.component_.product = img;
        end
        function img  = get.product(this)
            img = this.component_.product;
        end
        function this = set.referenceImage(this, img)
            this.component_.referenceImage = img;
        end
        function img  = get.referenceImage(this)
            img = this.component_.referenceImage;
        end
        function this = set.xfm(this, x)
            this.component_.xfm = x;
        end
        function x    = get.xfm(this)
            x = this.component_.xfm;
        end
        function this = set.inweight(this, w)
            this.component_.inweight = w;
        end
        function w    = get.inweight(this)
            w = this.component_.inweight;
        end
        function this = set.refweight(this, w)
            this.component_.refweight = w;
        end
        function w    = get.refweight(this)
            w = this.component_.refweight;
        end
    end

	methods 
        function prds = alignSequentially(this, imgs)
            prds = this.component_.alignSequentially(imgs);
        end
        function prds = alignSequentiallySmallAngles(this, imgs)
            prds = this.component_.alignSequentiallySmallAngles(imgs);
        end
        function prds = alignIndependently(this, imgs, ref)
            prds = this.component_.alignIndependently(imgs, ref);
        end
        function prd  = alignSingle(this, img)
            prd = this.component_.alignSingle(img);
        end
        function prd  = alignPair(this, img, ref)
            prd = this.component_.alignPair(img, ref);
        end
        function prds = alignThenApplyXfm(this, varargin)
            prds = this.component_.alignThenApplyXfm(varargin{:});
        end
        
        function prd  = motionCorrect(this, varargin)
            prd = this.component_.motionCorrect(varargin{:});
        end
        function prd  = meanvol(this, nii)
            prd = this.component_.meanvol(nii);
        end
        function prd  = meanvolByComponent(~, imcmp)
            prd = this.component_.meanvolByComponent(imcmp);
        end
        
        function this = AlignmentDirectorDecorator(varargin)
            %% ALIGNMENTDIRECTORDECORATOR
            %  Usage:  obj = AlignmentDirectorDecorator([anAlignmentDirector])
            %                                            ^ default is an AlignmentDirector
            
            p = inputParser;
            addOptional(p, 'cmp', mlfsl.AlignmentDirector, @(x) isa(x, 'mlfsl.AlignmentDirectorComponent'));
            parse(p, varargin{:});
            
            this.component_ = p.Results.cmp;
        end
    end 

    properties (Access = 'protected')
        component_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

