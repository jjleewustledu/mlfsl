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
        logger
        sessionPath
        buildVisitor
        sourceWeight
        referenceWeight
        sourceImage    % needed by FlirtVisitor
        referenceImage % "
        product        % "
        xfm            % "
    end 

    methods %% SET/GET
        function this = set.logger(this, lg)
            assert(isa(lg, 'mlpipeline.Logger'));
            this.logger_ = lg;
        end
        function lg   = get.logger(this)
            assert(~isempty(this.logger_));
            lg = this.logger_;
        end
        function g    = get.sessionPath(this)
            assert(~isempty(this.sessionPath_));
            g = this.sessionPath_;
        end
        function this = set.buildVisitor(this, v)
            assert(isa(v, 'mlfsl.FslVisitor'));
            this.buildVisitor_ = v;
        end
        function v    = get.buildVisitor(this)
            v = this.buildVisitor_;
        end
        function this = set.sourceWeight(this, w)
            this.sourceWeight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.sourceWeight(this)
            % may be empty
            w = this.sourceWeight_;
        end
        function this = set.referenceWeight(this, w)
            this.referenceWeight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.referenceWeight(this)
            % may be empty
            w = this.referenceWeight_;
        end
        function this = set.product(this, prod)
            this.product_ = mlfourd.ImagingContext(prod);
        end
        function prod = get.product(this)
            prod = this.product_;
        end
        function this = set.referenceImage(this, ref)
            this.referenceImage_ = mlfourd.ImagingContext(ref);
        end
        function ref  = get.referenceImage(this)
            ref = this.referenceImage_;
        end
        function this = set.sourceImage(this, src)
            this.sourceImage_ = mlfourd.ImagingContext(src);
        end
        function src  = get.sourceImage(this)
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
    end
    
	methods
        function this = buildAligned(this, varargin)
            ip = inputParser;
            addOptional(ip, 'src', this.sourceImage,    @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(ip, 'ref', this.referenceImage, @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(ip, 'xfm', this.xfm,            @(x) lexist(x, 'file'));
            parse(ip, varargin{:});
            
            this.sourceImage    = ip.Results.src.clone;
            this.referenceImage = ip.Results.ref;  
            
            this = this.buildVisitor.alignMultispectral(this);             
            this.sourceImage = ip.Results.src.clone;   
            this = this.buildVisitor.transformTrilinear(this);
        end
        function this = buildInverseAligned(this, im, ref)
            this.sourceImage = ref.clone;
            this.referenceImage = im;

            this = this.buildVisitor.alignMultispectral(this);
            this = this.buildVisitor.inverseTransformBuilder(this);            
            this.sourceImage = im.clone;
            this.referenceImage = ref;
            this = this.buildVisitor.transformTrilinear(this);
        end
        function this = buildTransformed(this, varargin)
            ip = inputParser;
            addOptional(ip, 'src', this.sourceImage,    @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(ip, 'ref', this.referenceImage, @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(ip, 'xfm', this.xfm,            @(x) lexist(x, 'file'));
            parse(ip, varargin{:});
            
            this.sourceImage    = ip.Results.src.clone;
            this.referenceImage = ip.Results.ref;
            this.xfm            = ip.Results.xfm;
            
            this = this.buildVisitor.transformTrilinear(this);
        end
        function this = buildInverseTransformed(this, im, ref, xfm)
            this.sourceImage = ref.clone;
            this.referenceImage = im.clone;
            this.xfm = xfm;
            
            this = this.buildVisitor.inverseTransformBuilder(this);            
            this.sourceImage = im.clone;
            this.referenceImage = ref;
            this = this.buildVisitor.transformTrilinear(this);
        end
        
        function this = buildFlirted(this) %% DEPRECATED
            this = this.buildVisitor.alignMultispectral(this);
        end 
        function this = buildMeanVolume(this)
            niid = imcast(this.sourceImage, 'mlfourd.NIfTId');            
            T    = niid.size(4); 
            vol  = niid.img(:,:,:,1);
            for t = 2:T
                vol = vol + niid.img(:,:,:,t);
            end
            niid.img     = vol/T;
            this.product = niid.append_fileprefix(mlfsl.FlirtVisitor.MEANVOL_SUFFIX);
        end
        function this = buildMeanVolumeByComponent(this)
            imcmp = imcast(this.sourceImage, 'mlfourd.ImagingComponent');
            vol   = imcmp{1}.img;
            for c = 2:imcmp.length
                vol = vol + imcmp{c}.img;
            end
            imcmp{1}.img = vol/imcmp.length;
            this.product = mlfourd.ImagingSeries.load(imcmp{1});  
        end
        function this = buildMotionCorrected(this)
            this  = this.buildVisitor.motionCorrect(this);
        end   
        function this = buildWarped(this)
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
            %          Parameters       Values                                          ^            ^    
            %          'sessionPath'    filesystem path
            %          'buildVisitor'   FslVisitor object
            %          'sourceWeight'       ImagingContext object
            %          'referenceWeight'               "
            %          'sourceImage'             "
            %          'referenceImage'          "
            %          'xfm'            f.q. filename
            %          Alternatively assign this.product, this.referenceImage after construction.

            if (0 == nargin); return; end
            
            %% invoke copy-ctor
            
            if (1 == nargin && isa(varargin{1}, 'mlfsl.AlignmentBuilderPrototype'))
                this.sessionPath_    = varargin{1}.sessionPath_;
                this.buildVisitor_   = varargin{1}.buildVisitor_;
                this.sourceWeight_       = varargin{1}.sourceWeight_;
                this.referenceWeight_      = varargin{1}.referenceWeight_;
                this.sourceImage_    = varargin{1}.sourceImage_;
                this.referenceImage_ = varargin{1}.referenceImage_;
                this.xfm_            = varargin{1}.xfm_;
                this.product_        = varargin{1}.product_;
                return
            end
            
            %% manage parameters 
            
            import mlfsl.*;
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'sessionPath',    '', @isdir);
            addParameter(p, 'buildVisitor',  mlfsl.FlirtVisitor, @(x) isa(x, 'mlfsl.FslVisitor'));
            addParameter(p, 'sourceWeight',       [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'referenceWeight',      [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'sourceImage',    [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'referenceImage', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(p, 'xfm',            [], @(x) lexist(x, 'file') || lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            addParameter(p, 'image',          [], @(x) isa(x, 'mlfourd.ImagingContext')); % DEPRECATED
            addParameter(p, 'reference',      [], @(x) isa(x, 'mlfourd.ImagingContext')); % DEPRECATED
            addParameter(p, 'product',        [], @(x) isa(x, 'mlfourd.ImagingContext')); % DEPRECATED
            parse(p, varargin{:});
            
            this.sessionPath_    = p.Results.sessionPath;
            this.buildVisitor_   = p.Results.buildVisitor;
            this.sourceWeight_       = p.Results.sourceWeight;
            this.referenceWeight_      = p.Results.referenceWeight; 
            this.sourceImage_    = p.Results.sourceImage;
            this.referenceImage_ = p.Results.referenceImage;
            this.xfm_            = p.Results.xfm;           
            
            %% legacy synonyms
            
            if (~isempty(p.Results.image))
                this.sourceImage_ = p.Results.image; % KLUDGE for image as synonym for sourceImage
            end
            if (~isempty(p.Results.reference))
                this.referenceImage_ = p.Results.reference; % KLUDGE for reference as synonym for referenceImage
            end
            if (~isempty(p.Results.product))
                this.sourceImage_ = p.Results.product; % KLUDGE for product as synonym for sourceImage
            end
 		end 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        logger_
        sessionPath_
        buildVisitor_
        sourceWeight_
        referenceWeight_
        sourceImage_
        referenceImage_
        xfm_
        product_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

