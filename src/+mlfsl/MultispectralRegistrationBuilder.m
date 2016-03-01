classdef MultispectralRegistrationBuilder < mlfsl.AbstractRegistrationBuilder
	%% MULTISPECTRALREGISTRATIONBUILDER  

	%  $Revision$
 	%  was created 08-Dec-2015 16:43:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	
	
	properties (Dependent) 		
        sourceWeight
        referenceWeight
        sourceImage
        referenceImage
        product
        
        prexfm
    end

    methods %% GET/SET
        function this = set.sourceWeight(this, w)
            if (isa(w, 'mlfourd.ImagingContext')) % preserves MR/PETImagingContexts
                this.sourceWeight_ = w;
                return
            end
            this.sourceWeight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.sourceWeight(this)
            % may be empty
            w = this.sourceWeight_;
        end
        function this = set.referenceWeight(this, w)
            if (isa(w, 'mlfourd.ImagingContext')) % preserves MR/PETImagingContexts
                this.referenceWeight_ = w;
                return
            end
            this.referenceWeight_ = mlfourd.ImagingContext(w);
        end
        function w    = get.referenceWeight(this)
            % may be empty
            w = this.referenceWeight_;
        end
        function this = set.referenceImage(this, ref)
            if (isa(ref, 'mlfourd.ImagingContext')) % preserves MR/PETImagingContexts
                this.referenceImage_ = ref;
                return
            end
            this.referenceImage_ = mlfourd.ImagingContext(ref);
        end
        function ref  = get.referenceImage(this)
            ref = this.referenceImage_;
        end
        function this = set.sourceImage(this, src)
            if (isa(src, 'mlfourd.ImagingContext')) % preserves MR/PETImagingContexts
                this.sourceImage_ = src;
                return
            end
            this.sourceImage_ = mlfourd.ImagingContext(src);
        end
        function src  = get.sourceImage(this)
            src = this.sourceImage_;
        end
        function this = set.product(this, p)
            if (isa(p, 'mlfourd.ImagingContext')) % preserves MR/PETImagingContexts
                this.product_ = p;
                return
            end
            this.product_ = mlfourd.ImagingContext(p);
        end
        function prod = get.product(this)
            prod = this.product_;
            %prod.setNoclobber(false);
        end
        function this = set.prexfm(this, x)
            %% SET.XFM casts its argument to a f. q. filename ending in FlirtVisitor.XFM_SUFFIX
            
            this.prexfm_ = [myfileprefix(x) mlfsl.FlirtVisitor.XFM_SUFFIX];
        end
        function x    = get.prexfm(this)
            %% GET.XFM 
            %  @return:
            %  - f.q. filename obtained from this.product, ending in FlirtVisitor.XFM_SUFFIX
            %  - f.q. filename with FnirtVisitor.WARPCOEF_SUFFIX replaced by XFM_SUFFIX

            import mlfsl.*;
            if (isempty(this.xfm_))
                this.prexfm_ = this.product.fqfileprefix; 
            end
            lw = length(FnirtVisitor.WARPCOEF_SUFFIX);
            if ( strcmp(this.prexfm_(end-lw+1:end), FnirtVisitor.WARPCOEF_SUFFIX))
                pos = strfind(this.prexfm_,         FnirtVisitor.WARPCOEF_SUFFIX);
                this.prexfm_ = this.prexfm_(1:pos-1);
            end
            lx = length(FlirtVisitor.XFM_SUFFIX);
            if (~strfind(this.prexfm_(end-lx+1:end), FlirtVisitor.XFM_SUFFIX));
                this.prexfm_ = [this.prexfm_            FlirtVisitor.XFM_SUFFIX]; 
            end
            x = this.prexfm_;
        end
    end
    
	methods 
        function this = registerBijective(this)
            this = this.registerInjective;
        end
        function this = registerInjective(this)
            visitor = mlfsl.MultispectralFlirtVisitor;           
            this = visitor.registerInjective(this, this.proxyBuilder);
            this.cleanUpProxy(this.proxyBuilder);
        end
        function this = registerSurjective(this)
            if (this.referenceImage.niftid.rank > 3)
                this = this.registerSurjectiveOnDynamic;
                return
            end
            visitor = mlfsl.MultispectralFlirtVisitor;           
            this = visitor.registerSurjective(this, this.proxyBuilder);
            this.cleanUpProxy(this.proxyBuilder);
        end
        function this = registerSurjectiveOnDynamic(this)
            if (isa(this.referenceImage, 'mlpet.PETImagingContext'))
                this = this.registerSurjectiveOnDynamicPET;
                return               
            end
            if (isa(this.referenceImage, 'mlmr.MRImagingContext'))
                this = this.registerSurjectiveOnDynamicMR;
                return
            end
            this = this.registerSurjectiveOnDynamicOther;
        end        
        function this = registerSurjectiveOnDynamicPET(this)
            
            % motion correct PET
            prb = mlpet.PETRegistrationBuilder('sessionData', this.sessionData);
            prb.sourceImage = this.referenceImage;
            if (lexist([prb.motionCorrectedFileprefix(prb.sourceImage) '.nii.gz']))
                prb.product = mlpet.PETImagingContext( ...
                              [prb.motionCorrectedFileprefix(prb.sourceImage) '.nii.gz']);
                prb.xfm     = [prb.motionCorrectedFileprefix(prb.sourceImage) '.mat'];
            else
                prb = prb.motionCorrect;
            end
            this.prexfm = prb.xfm;

            % register anatomy to motion-corrected PET
            this.referenceImage = prb.product; 
            this = this.registerSurjective;                           

            % apply motion-correcting transformations to anatomy
            prb.sourceImage = this.product;
            prb.referenceImage = prb.product;
            prb = prb.transform4D;
            this.product = prb.product;
            this.xfm = prb.xfm;
        end        
        function this = registerSurjectiveOnDynamicMR(this)
            
            % motion correct MR
            mrrb = mlmr.MRRegistrationBuilder('sessionData', this.sessionData);
            mrrb.sourceImage = this.referenceImage;
            if (lexist([mrrb.motionCorrectedFileprefix(mrrb.sourceImage) '.nii.gz']))
                mrrb.product = mlmr.MRImagingContext( ...
                               [mrrb.motionCorrectedFileprefix(mrrb.sourceImage) '.nii.gz']);
                mrrb.xfm     = [mrrb.motionCorrectedFileprefix(mrrb.sourceImage) '.mat'];
            else
                mrrb = mrrb.motionCorrect;
            end
            this.prexfm = mrrb.xfm;

            % register anatomy to motion-corrected MR
            this.referenceImage = mrrb.product; 
            this = this.registerSurjective;                           

            % apply motion-correcting transformations to anatomy
            mrrb.sourceImage = this.product;
            mrrb.referenceImage = mrrb.product;
            mrrb = mrrb.transform4D;
            this.product = mrrb.product;
            this.xfm = mrrb.xfm;
        end
        function this = registerSurjectiveOnDynamicOther(this)
            
            % motion correct MR
            msrb = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            msrb.sourceImage = this.referenceImage;
            if (lexist([msrb.motionCorrectedFileprefix(msrb.sourceImage) '.nii.gz']))
                msrb.product = mlfsl.ImagingContext( ...
                               [msrb.motionCorrectedFileprefix(msrb.sourceImage) '.nii.gz']);
                msrb.xfm     = [msrb.motionCorrectedFileprefix(msrb.sourceImage) '.mat'];
            else
                msrb = msrb.motionCorrect;
            end
            this.prexfm = msrb.xfm;

            % register anatomy to motion-corrected MR
            this.referenceImage = msrb.product; 
            this = this.registerSurjective;                           

            % apply motion-correcting transformations to anatomy
            msrb.sourceImage = this.product;
            msrb.referenceImage = msrb.product;
            msrb = msrb.transform4D;
            this.product = msrb.product;
            this.xfm = msrb.xfm;
        end
        
        %% CTOR
		  
 		function this = MultispectralRegistrationBuilder(varargin)
 			this = this@mlfsl.AbstractRegistrationBuilder(varargin{:});             
 		end
        function obj  = clone(this)
            obj = mlfsl.MultispectralRegistrationBuilder(this);
        end
    end 
    
    %% PROTECTED
    
    properties (Access = protected)
        prexfm_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

