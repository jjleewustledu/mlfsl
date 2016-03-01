classdef AbstractRegistrationBuilder 
	%% ABSTRACTREGISTRATIONBUILDER is a concrete builder and a concrete prototpye.
    %  It uses the prototype design pattern to create a variety of builders,
    %  avoiding duplicating the hierarchy of product classes.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AbstractRegistrationBuilder.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: AbstractRegistrationBuilder.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
    
    properties (Abstract)
        sourceWeight
        referenceWeight
        sourceImage
        referenceImage
        product
    end
    
    methods (Abstract)
        clone(this)
    end
    
	properties (Dependent)
        blurringFactor
        interp
        sessionData        
        buildVisitor
        xfm
    end 

    methods %% SET/GET
        function g    = get.blurringFactor(this)
            g = this.blurringFactor_;
        end
        function this = set.blurringFactor(this, s)
            assert(isnumeric(s));
            this.blurringFactor_ = s;
        end
        function g    = get.interp(this)
            g = this.interp_;
        end
        function this = set.interp(this, s)
            assert(ismember(s, { 'trilinear' 'nearestneighbour' 'sinc' 'spline' }));
            this.interp_ = s;
        end
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
        function this = set.xfm(this, x)
            %% SET.XFM casts its argument to a f. q. filename ending in FlirtVisitor.XFM_SUFFIX
            
            this.xfm_ = [myfileprefix(x) mlfsl.FlirtVisitor.XFM_SUFFIX];
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
        
        %% REGISTRATION
        
        function this = concatTransforms(this, varargin)
            this = this.buildVisitor.concatTransforms(this, varargin{:});
        end
        function this = invertTransform(this, varargin)
            this = this.buildVisitor.invertTransform(this, varargin{:});
        end
        function this = motionCorrect(this)
            this  = this.buildVisitor.motionCorrect(this);
        end
        function this = register(this)
            if (this.sourceImage.sizeEq(this.referenceImage))
                this = this.registerBijective;
                return
            end
            if (this.sourceImage.sizeLt(this.referenceImage))
                this = this.registerInjective;
                return
            end
            if (this.sourceImage.sizeGt(this.referenceImage))
                this = this.registerSurjective;
                return
            end
            error('mlfsl:unsupportedArraySize', ...
                  'AbstractRegistrationBuilder.register:  size(src)->%s but size(ref)->%s', mat2str(src.size), mat2str(ref.size));
        end
        function this = registerBijective(this)
            this = this.registerInjective;
        end
        function this = registerInjective(this)
            this = this.buildVisitor.registerInjective(this, this.proxyBuilder);
            this.cleanUpProxy(this.proxyBuilder);
        end
        function this = registerSurjective(this)
            this = this.buildVisitor.registerSurjective(this, this.proxyBuilder);
            this.cleanUpProxy(this.proxyBuilder);
        end
        function this = transform(this)
            if (isdir(this.xfm))
                this = this.transform4D;
            end
            this = this.buildVisitor.transform(this);
        end
        function this = transform4D(this)
            this.sourceImage = this.ensureTimeDependent(this.sourceImage, this.referenceImage.niftid.size(4));
            this.referenceImage = this.ensureTimeIndep(this.referenceImage);
            this.sourceImage.ensureSaved;
            this.referenceImage.ensureSaved;
            visitor = mlfsl.FlirtVisitor;
            this = visitor.transform4D(this);
            
            deleteExisting(this.sourceImage.fqfn);
        end   
        
        %% SUPPORT METHODS
        
        function this = cleanUpProxy(this, pb)
            ims = {'sourceWeight' 'referenceWeight'};
            for idx = 1:length(ims)
                deleteExisting(pb.(ims{idx}));
            end
        end
        function ic = ensurePetBlurred(this, ic)
            if (~isa(ic, 'mlpet.PETImagingContext'))
                return
            end
            ic = ic.blurred(this.blurringFactor * this.petPointSpread);
        end
        function ic = ensurePetMaskedByZ(this, ic)
            if (~isa(ic, 'mlpet.PETImagingContext'))
                return
            end
            if (isa(this.sessionData, 'mlraichle.SessionData'))
                return
            end
            ic = ic.maskedByZ;
        end
        function ic = ensureTimeDependent(this, ic, lent)
            n = ic.niftid;
            z = zeros([n.size lent]);
            for t = 1:lent
                z(:,:,:,t) = n.img;
            end
            n.img = z;
            n.fileprefix = sprintf('%s%s%i', ic.fileprefix, '_x', lent);
            ic = this.sessionData.repackageImagingContext(n, class(ic));
        end
        function ic = ensureTimeIndep(~, ic)
            if (ic.rank < 4)
                return
            end
            ic = ic.timeSummed;
        end
        function wt = ensureWeight(~, wt, varargin)
            %% ENSUREWEIGHT ensures a non-empty ImagingContext for weighting registration operations.
            %  @param wt is a proposed weighting image, which may be empty.
            %  @param [src] is a source image, used to specify the size of a default weight of ones when wt is empty.
            %  @returns, wt is the ensured weight, sized to match src.
            %  @throws mlfsl:inconsistentImageSizes
            
            ip = inputParser;
            addRequired(ip, 'wt',      @(x) isImagingContext(x) || isempty(x));
            addOptional(ip, 'src', [], @(x) isImagingContext(x) || isempty(x));
            parse(ip, wt, varargin{:});
            
            if (isempty(ip.Results.wt))
                assert(~isempty(ip.Results.src), ...
                    'mlfsl:inconsistentImageSizes', ...
                    'AbstractRegistrationBuilder.ensureWeight received both images empty'); 
                wt = ip.Results.src.ones;
                return
            end
            wt = ip.Results.wt;
        end      
        function fp = motionCorrectedFileprefix(this, ic)
            %% MOTIONCORRECTEDFILEPREFIX is a KLUDGE!
            
            import mlfourd.*;
            n = NIfTId;            
            n.fqfileprefix = ic.fqfileprefix(1:strfind(ic.fqfileprefix, '_mcf')-1);
            b = BlurringNIfTId(n);
            b.blur = this.blurringFactor * this.petPointSpread;
            fp = [b.blurredFileprefix '_mcf'];
        end 
        function p  = petPointSpread(this)
            p = this.sessionData.petPointSpread;
        end
        function p  = pointSpread(this)
            p = this.sessionData.petPointSpread;
            if (~isempty(this.sourceImage))
                p = max(p, this.sourceImage.niftid.pixdim(1:3));
            end
            if (~isempty(this.referenceImage))
                p = max(p, this.referenceImage.niftid.pixdim(1:3));
            end
        end        
        function pb = proxyBuilder(this)  
            pb = this.clone;
            pb.sourceImage     = this.ensurePetBlurred( ...
                                 this.ensureTimeIndep(pb.sourceImage));
            pb.referenceImage  = this.ensurePetBlurred( ...
                                 this.ensureTimeIndep(pb.referenceImage));
            pb.sourceWeight    = this.ensurePetMaskedByZ( ...
                                 this.ensureTimeIndep( ...
                                 this.ensureWeight(pb.sourceWeight, pb.sourceImage)));
            pb.referenceWeight = this.ensurePetMaskedByZ( ...
                                 this.ensureTimeIndep( ...
                                 this.ensureWeight(pb.referenceWeight, pb.referenceImage)));
            
            pb.sourceImage.ensureSaved;
            pb.referenceImage.ensureSaved;
            pb.sourceWeight.ensureSaved;
            pb.referenceWeight.ensureSaved;
        end
        
        %% LEGACY
        
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
            this = this.buildVisitor.invertTransform(this);            
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
            
            this = this.buildVisitor.invertTransform(this);            
            this.sourceImage = im.clone;
            this.referenceImage = ref;
            this = this.buildVisitor.transformTrilinear(this);
        end        
        function prod = buildWarped(this, varargin)
            ip = inputParser;
            addParameter(ip, 'sourceImage',    [], @(x) isa(x, 'mlfourd.ImagingContext'));
            addParameter(ip, 'referenceImage', [], @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(ip, varargin{:});
            
            if (~isempty(ip.Results.sourceImage))
                this.sourceImage    = ip.Results.sourceImage; end
            if (~isempty(ip.Results.referenceImage))
                this.referenceImage = ip.Results.referenceImage; end
            visitor = mlfsl.FnirtVisitor;
            this = visitor.visitAlignmentBuilder2applywarp(this);
            prod = this.product;
        end            
        
        %% CTOR
        
 		function this = AbstractRegistrationBuilder(varargin) 
 			%% ABSTRACTREGISTRATIONBUILDER 
            %  @param [sessionData] is an instance of mlpipeline.SessionData.
            %  @param [buildVisitor]
            %  @param [sourceWeight]
            %  @param [referenceWeight]
            %  @param [sourceImage]
            %  @param [referenceImage]
            %  @param [] with any AbstractRegistrationBuilder is for copy-construction.

            if (0 == nargin); return; end
            
            %% invoke copy-ctor
            
            if (1 == nargin && isa(varargin{1}, 'mlfsl.AbstractRegistrationBuilder'))
                arg = varargin{1};                
                this.sessionData_  = arg.sessionData_;                
                this.buildVisitor_ = arg.buildVisitor_;
                this.xfm_          = arg.xfm_;
                
                fields = {'sourceWeight_' 'referenceWeight_' 'sourceImage_' 'referenceImage_' 'product_'};
                for f = 1:length(fields)
                    if (~isempty(arg.(fields{f})))
                        this.(fields{f}) = arg.(fields{f}).clone;
                    end
                end
                return
            end
            
            %% manage parameters 
            
            import mlfsl.*;
            ip = inputParser;
            ip.KeepUnmatched = true;
            addParameter(ip, 'sessionData',     [], @(x) isa(x, 'mlpipeline.ISessionData'));
            addParameter(ip, 'buildVisitor',    FlirtVisitor, @(x) isa(x, 'mlfsl.FslVisitor'));
            addParameter(ip, 'sourceWeight',    [], @(x) isa(x, 'mlfourd.ImagingContext') || isempty(x));
            addParameter(ip, 'referenceWeight', [], @(x) isa(x, 'mlfourd.ImagingContext') || isempty(x));
            addParameter(ip, 'sourceImage',     [], @(x) isa(x, 'mlfourd.ImagingContext') || isempty(x));
            addParameter(ip, 'referenceImage',  [], @(x) isa(x, 'mlfourd.ImagingContext') || isempty(x));
            addParameter(ip, 'xfm',             [], @(x) lexist(x, 'file') || ...
                                                         lexist([x FlirtVisitor.XFM_SUFFIX], 'file') || ...
                                                         isempty(x));
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
    

    %% PROTECTED
    
    properties (Access = protected)
        blurringFactor_ = 1
        buildVisitor_
        interp_ = 'trilinear'
        product_
        referenceImage_
        referenceWeight_
        sessionData_
        sourceImage_
        sourceWeight_
        xfm_
    end
    
    methods (Access = protected)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

