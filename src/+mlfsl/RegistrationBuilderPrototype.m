classdef RegistrationBuilderPrototype 
	%% REGISTRATIONBUILDERPROTOTYPE is a concrete builder and a concrete prototpye.
    %  It uses the prototype design pattern to create a variety of builders,
    %  avoiding duplicating the hierarchy of product classes.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/RegistrationBuilderPrototype.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: RegistrationBuilderPrototype.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
	properties (Dependent)
        sessionData        
        buildVisitor
        sourceWeight
        referenceWeight
        sourceImage
        referenceImage
        product
        xfm
        inverseXfm
    end 

    methods %% SET/GET
        function g    = get.sessionData(this)
            g = this.sessionData_;
        end
        function this = set.buildVisitor(this, v)
            assert(isa(v, 'mlfsl.FlirtVisitor'));
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
            %% SET.XFM casts its argument to a f. q.filename ending in FlirtVisitor.XFM_SUFFIX
            
            import mlfsl.*;
            lx = length(FlirtVisitor.XFM_SUFFIX);
            if (~strcmp(x(end-lx+1:end), x))
                x = [x FlirtVisitor.XFM_SUFFIX]; 
            end
            this.xfm_ = x;
        end
        function x    = get.xfm(this)
            %% GET.XFM 
            %  @return:
            %  - f.q. filename obtained from this.product, ending in FlirtVisitor.XFM_SUFFIX
            %  - f.q. filename with FnirtVisitor.WARPCOEF_SUFFIX replaced by XFM_SUFFIX

            import mlfsl.*;
            if (isempty(this.xfm_))
                this.xfm_ = this.product.fqfileprefix; 
            end
            lw = length(FnirtVisitor.WARPCOEF_SUFFIX);
            if ( strcmp(this.xfm_(end-lw+1:end), FnirtVisitor.WARPCOEF_SUFFIX))
                pos = strfind(this.xfm_,         FnirtVisitor.WARPCOEF_SUFFIX);
                this.xfm_ = this.xfm_(1:pos-1);
            end
            lx = length(FlirtVisitor.XFM_SUFFIX);
            if (~strfind(this.xfm_(end-lx+1:end), FlirtVisitor.XFM_SUFFIX));
                this.xfm_ = [this.xfm_            FlirtVisitor.XFM_SUFFIX]; 
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
            this = this.buildVisitor.transformBuilder(this);
        end
        function this = buildInverseAligned(this, im, ref)
            this.sourceImage = ref.clone;
            this.referenceImage = im;

            this = this.buildVisitor.alignMultispectral(this);
            this = this.buildVisitor.inverseTransformBuilder(this);            
            this.sourceImage = im.clone;
            this.referenceImage = ref;
            this = this.buildVisitor.transformBuilder(this);
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
            
            this = this.buildVisitor.transformBuilder(this);
        end
        function this = buildInverseTransformed(this, im, ref, xfm)
            this.sourceImage = ref.clone;
            this.referenceImage = im.clone;
            this.xfm = xfm;
            
            this = this.buildVisitor.inverseTransformBuilder(this);            
            this.sourceImage = im.clone;
            this.referenceImage = ref;
            this = this.buildVisitor.transformBuilder(this);
        end
        
        function this = buildFlirted(this) %% DEPRECATED
            this = this.buildVisitor.align6DOF(this);
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
            obj = mlfsl.RegistrationBuilderPrototype(this);
        end
        
 		function this = RegistrationBuilderPrototype(varargin) 
 			%% REGISTRATIONBUILDERPROTOTYPE 

            if (0 == nargin); return; end
            
            %% invoke copy-ctor
            
            if (1 == nargin && isa(varargin{1}, 'mlfsl.RegistrationBuilderPrototype'))
                this.sessionData_    = varargin{1}.sessionData_;                
                this.buildVisitor_    = varargin{1}.buildVisitor_;
                this.sourceWeight_    = varargin{1}.sourceWeight_;
                this.referenceWeight_ = varargin{1}.referenceWeight_;
                this.sourceImage_     = varargin{1}.sourceImage_;
                this.referenceImage_  = varargin{1}.referenceImage_;
                this.xfm_             = varargin{1}.xfm_;
                this.product_         = varargin{1}.product_;
                return
            end
            
            %% manage parameters 
            
            import mlfsl.*;
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'sessionData',     [], @(x) isa(x, 'mlpipeline.ISessionData'));
            addParameter(ip, 'buildVisitor',    FlirtVisitor, @(x) isa(x, 'mlfsl.FslVisitor'));
            addParameter(ip, 'sourceWeight',    [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'referenceWeight', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'sourceImage',     [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'referenceImage',  [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'xfm',             [], @(x) lexist(x, 'file') || ...
                                                         lexist([x FlirtVisitor.XFM_SUFFIX], 'file'));
            parse(ip, varargin{:});
            
            this.sessionData_     = ip.Results.sessionData;
            this.buildVisitor_    = ip.Results.buildVisitor;
            this.sourceWeight_    = ip.Results.sourceWeight;
            this.referenceWeight_ = ip.Results.referenceWeight; 
            this.sourceImage_     = ip.Results.sourceImage;
            this.referenceImage_  = ip.Results.referenceImage;
            this.xfm_             = ip.Results.xfm;           
 		end 
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        sessionData_
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

