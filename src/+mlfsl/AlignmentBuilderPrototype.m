classdef AlignmentBuilderPrototype < mlfsl.AlignmentBuilder
	%% AlignmentBuilderPrototype is a concrete builder and a concrete prototpye.
    %  It uses the prototype design pattern to create a variety of AlignmentBuilders for 
    %  PET, MRIConverter, Freesurfer, etc., without duplicating the hierarchy of product classes.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AlignmentBuilderPrototype.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AlignmentBuilderPrototype.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
	properties (Dependent)
        sessionPath
        logger
        product        % needed by FlirtVisitor
        referenceImage % "
        sourceImage    % "
        xfm            % "
        inweight
        refweight
    end 

    methods %% SET/GET
        function g    = get.sessionPath(this)
            assert(~isempty(this.sessionPath_));
            g = this.sessionPath_;
        end
        function this = set.logger(this, lg)
            assert(isa(lg, 'mlpipeline.Logger'));
            this.logger_ = lg;
        end
        function lg   = get.logger(this)
            assert(~isempty(this.logger_));
            lg = this.logger_;
        end
        function this = set.product(this, prod)
            this.product_ = mlfourd.ImagingContext(prod);
        end
        function prod = get.product(this)
            assert(isa(this.product_, 'mlfourd.ImagingContext'));
            prod = this.product_;
        end
        function this = set.referenceImage(this, ref)
            this.referenceImage_ = mlfourd.ImagingContext(ref);
        end
        function ref  = get.referenceImage(this)
            assert(isa(this.referenceImage_, 'mlfourd.ImagingContext'));
            ref = this.referenceImage_;
        end
        function this = set.sourceImage(this, src)
            this.sourceImage_ = mlfourd.ImagingContext(src);
        end
        function src  = get.sourceImage(this)
            assert(isa(this.sourceImage_, 'mlfourd.ImagingContext'));
            src = this.sourceImage_;
        end
        function this = set.xfm(this, x)
            %% SET.XFM casts its argument to a f.q. filename ending in FlirtVisitor.XFM_SUFFIX
            
            import mlfsl.*;
            if (~lstrfind(x, FlirtVisitor.XFM_SUFFIX))
                x = [x FlirtVisitor.XFM_SUFFIX]; end
            this.xfm_ = x;
        end
        function x    = get.xfm(this)
            %% GET.XFM returns one of:
            %    - a f.q. filename obtained from this.product but ending in suffix FlirtVisitor.XFM_SUFFIX
            %    - a f.q. filename with FnirtVisitor.WARPCOEF_SUFFIX replaced by XFM_SUFFIX

            import mlfsl.*;
            if (isempty(this.xfm_))
                this.xfm_ = this.product.fqfileprefix; 
            end
            if ( lstrfind(this.xfm_,     FnirtVisitor.WARPCOEF_SUFFIX))
                pos = strfind(this.xfm_, FnirtVisitor.WARPCOEF_SUFFIX);
                this.xfm_ = this.xfm_(1:pos-1);
            end
            if (~lstrfind(this.xfm_, FlirtVisitor.XFM_SUFFIX));
                this.xfm_ = [this.xfm_       FlirtVisitor.XFM_SUFFIX]; 
            end
            x = this.xfm_;
        end
        function this = set.inweight(this, w)
            this.inweight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.inweight(this)
            % may be empty
            w = this.inweight_;
        end
        function this = set.refweight(this, w)
            this.refweight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.refweight(this)
            % may be empty
            w = this.refweight_;
        end
    end
    
	methods
        function this = buildFlirted(this)
            visit = mlfsl.FlirtVisitor;
            this  = visit.align6DOF(this);
        end 
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
            visit = mlfsl.FlirtVisitor;
            this  = visit.motionCorrect(this);
        end    
        function this = applyXfm(this)
            visit = mlfsl.FlirtVisitor;
            this  = visit.applyTransformOfBuilder(this);
        end
        function this = applywarp(this)
            vtor = mlfsl.FnirtVisitor;
            this = vtor.visitAlignmentBuilder2applywarp(this);
        end            
        function obj  = clone(this)
            obj = mlfsl.AlignmentBuilderPrototype(this);
        end
        
 		function this = AlignmentBuilderPrototype(varargin) 
 			%% AlignmentBuilderPrototype 
 			%  Usage:  this = AlignmentBuilderPrototype([anAlignmentBuilderPrototype]|['parameter', 'value']) 
            %                                            ^ for copy-ctor
            %          Parameters    Values                                             ^            ^
            %          'product'     ImagingContext object       
            %          'reference'          "
            %          'xfm'         f.q. filename
            %          'inweight'    ImagingContext object
            %          'refweight'          "
            %          Alternatively assign this.product, this.referenceImage after construction.

            %% invoke copy-ctor
            
            if (1 == nargin && isa(varargin{1}, 'mlfsl.AlignmentBuilderPrototype'))
                this.sessionPath_    = varargin{:}.sessionPath_;
                this.product_        = varargin{:}.product_;
                this.referenceImage_ = varargin{:}.referenceImage_;
                this.xfm_            = varargin{:}.xfm_;
                this.inweight_       = varargin{:}.inweight_;
                this.refweight_      = varargin{:}.refweight_;
                return
            end
            
            %% manage parameters 
            
            import mlfsl.*;
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'sessionPath',    '', @(x) lexist(x, 'dir'));
            addParameter(p, 'product',        [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'referenceImage', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'xfm',            [], @(x) lexist(x, 'file') || lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            addParameter(p, 'inweight',       [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'refweight',      [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'image',          [], @(x) isa(x, 'mlfourd.ImagingContext')); % DEPRECATED
            addParameter(p, 'reference',      [], @(x) isa(x, 'mlfourd.ImagingContext')); % DEPRECATED
            parse(p, varargin{:});
            
            this.sessionPath_    = p.Results.sessionPath;
            this.product_        = p.Results.product;
            this.referenceImage_ = p.Results.referenceImage;
            this.xfm_            = p.Results.xfm;
            this.inweight_       = p.Results.inweight;
            this.refweight_      = p.Results.refweight;            
            
            %% legacy synonyms
            
            if (~isempty(p.Results.image))
                this.product_ = p.Results.image; % KLUDGE for image as synonym for product
            end
            if (~isempty(p.Results.reference))
                this.referenceImage_ = p.Results.reference; % KLUDGE for reference as synonym for referenceImage
            end
 		end 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        sessionPath_
        logger_
        product_
        referenceImage_
        sourceImage_
        xfm_
        inweight_
        refweight_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

