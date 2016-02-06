classdef RegistrationFacade < handle
	%% RegistrationFacade simplifies use of linear registration frameworks.

	%  $Revision$
 	%  was created 30-Dec-2015 17:49:30
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    properties (Dependent)
        sessionData
        registrationBuilder
        
        talairach
        pet
        fdg
        gluc
        ho
        oo
        oc
        tr
    end
    
    methods %% GET
        function g = get.sessionData(this)
            g = this.sessionData_;
        end
        function g = get.registrationBuilder(this)
            g = this.registrationBuilder_;
        end
        function g = get.talairach(this)
            if (isempty(this.talairach_))
                this.talairach_ = mlmr.MRImagingContext(this.sessionData_.T1_fqfn);
            end
            g = this.talairach_;
        end
        function g = get.pet(this)
            g = mlpet.PETImagingContext({ this.fdg this.gluc this.ho this.oo this.oc this.tr });
        end
        function g = get.fdg(this)
            if (isempty(this.fdg_))
                this.fdg_ = mlpet.PETImagingContext(this.sessionData_.fdg_fqfn);
            end
            g = this.fdg_;
        end
        function g = get.gluc(this)
            if (isempty(this.gluc_))
                this.gluc_ = mlpet.PETImagingContext(this.sessionData_.gluc_fqfn);
            end
            g = this.gluc_;
        end
        function g = get.ho(this)
            if (isempty(this.ho_))
                this.ho_ = mlpet.PETImagingContext(this.sessionData_.ho_fqfn);
            end
            g = this.ho_;
        end
        function g = get.oo(this)
            if (isempty(this.oo_))
                this.oo_ = mlpet.PETImagingContext(this.sessionData_.oo_fqfn);
            end
            g = this.oo_;
        end
        function g = get.oc(this)
            if (isempty(this.oc_))
                this.oc_ = mlpet.PETImagingContext(this.sessionData_.oc_fqfn);
            end
            g = this.oc_;
        end
        function g = get.tr(this)
            if (isempty(this.tr_))
                this.tr_ = mlpet.PETImagingContext(this.sessionData_.tr_fqfn);
            end
            g = this.tr_;
        end
    end
    
	methods
 		function this = RegistrationFacade(varargin)
 			%% RegistrationFacade
            %  @param sessionData is an mlpipeline.SessionData specifying identifiers for the study session, including
            %  Freesurfer's recon-all results (T1.mgz is in Talairach space) and all PET data.
            %  @param registrationBuilder is an mlfsl.RegistrationBuilder, a builder pattern.
            %  @return this is a facade pattern for imaging alignment.

            ip = inputParser;
            addParameter(ip, 'sessionData',         [], @(x) isa(x, 'mlpipeline.SessionData'));
            addParameter(ip, 'registrationBuilder', [], @(x) isa(x, 'mlfsl.AbstractRegistrationBuilder') || isempty(x));
            parse(ip, varargin{:});
            
            this.sessionData_         = ip.Results.sessionData;
            this.registrationBuilder_ = ip.Results.registrationBuilder;
        end
        
        
        
        
        function prod = register(this, varargin)
            assert(length(varargin) > 1);
            
            images = varargin;
            for idx = 1:length(images)
                if (~isa(images{idx}, 'mlfourd.ImagingContext'))
                    images{idx} = mlfourd.ImagingContext(images{idx});
                end
            end
            
            mrb = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            for idx = 1:length(images)-1
                mrb.sourceImage = images{idx};
                mrb.referenceImage = images{idx+1};
                mrb = mrb.register;
                images{idx+1} = mrb.product;
                images{idx+1}.ensureSaved;
            end
            prod = images{end};
        end
        function prod = transform(this, src, xfms, refs)
            assert(isa(src, 'mlfourd.ImagingContext'));
            assert(length(xfms) == length(refs));
            cellfun(@(x) assert(strcmp(x(end-3:end), mlfsl.FlirtVisitor.XFM_SUFFIX)), xfms);
            cellfun(@(x) assert(lexist(x, 'file')), xfms);
            cellfun(@(x) assert(isa(x, 'mlfourd.ImagingContext')), refs);
            
            mrb  = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            prod = src;
            for idx = 1:length(xfms)
                mrb.xfm = xfms{idx};
                mrb.sourceImage = prod;
                mrb.referenceImage = refs{idx};
                mrb  = mrb.transformTrilinear;
                prod = mrb.product;
            end
        end
        function xfm  = transformation(this, varargin)
            %% TRANSFORMATION 
            %  @param arg[, arg2[, ...]] are each imaging or filesystem objects.
            %  @returns xfm which is the filename of a transformation corresponding to the
            %  transformation sequence implied by arg, arg2, ....  Transformations are created when needed
            %  if at all possible.  However, a single arg is returned as a transformation filename without 
            %  other interventions.
            
            import mlfsl.*;   
            assert(~isempty(varargin)); 
            %xfms    = varargin;
            xfms{1} = FslVisitor.transformFilename(varargin{1});
            for a = 2:length(varargin)                
                xfms{a} = FslVisitor.transformFilename(xfms{a-1}, varargin{a});
                if (~lexist(xfms{a}, 'file'))
                    rb = this.registrationBuilder;
                    rb.sourceImage    = this.ensureImagingContext(varargin{a-1});
                    rb.referenceImage = this.ensureImagingContext(varargin{a});
                    rb = rb.register;
                    rb.product.ensureSaved;
                    xfms{a} = rb.xfm;
                end
            end
            xfms(1) = [];
            xfm = this.concatTransformations(xfms{:});
        end
        
        
        
        function prod = registerTalairachWithPet(this)
            %% REGISTERTALAIRACHWITHPET
            %  @return prod is a struct with products as fields.
            
            import mlfsl.*;
            msrb = MultispectralRegistrationBuilder(this.sessionData);
            prb  = PETRegistrationBuilder(this.sessionData);
            
            prod.talairach = this.talairach;
            prod.petAtlas  = this.pet.atlas;
            prod.fdg       = prb.motionCorrect(this.fdg);
            prod.gluc      = prb.motionCorrect(this.gluc);
            prod.ho        = prb.motionCorrect(this.ho);
            prod.oo        = prb.motionCorrect(this.oo);
            prod.oc        = this.oc;
            prod.tr        = this.tr;
            
            tail_on_atl = msrb.registerSurjective(prod.talairach, prod.petAtlas);
            
             fdg_on_atl = prb.registerBijective(prod.fdg,  prod.petAtlas);
            gluc_on_atl = prb.registerBijective(prod.gluc, prod.petAtlas);
              ho_on_atl = prb.registerBijective(prod.ho,   prod.petAtlas);
              oo_on_atl = prb.registerBijective(prod.oo,   prod.petAtlas);
              oc_on_atl = prb.registerBijective(prod.oc,   prod.petAtlas);
              tr_on_atl = prb.registerBijective(prod.tr,   prod.petAtlas);
            
            prod.talairach_on_fdg  = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed( fdg_on_atl));
            prod.talairach_on_gluc = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed(gluc_on_atl));
            prod.talairach_on_ho   = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed(  ho_on_atl));
            prod.talairach_on_oo   = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed(  oo_on_atl));
            prod.talairach_on_oc   = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed(  oc_on_atl));
            prod.talairach_on_tr   = msrb.registerComposed(tail_on_atl, msrb.inverseTransformed(  tr_on_atl));
        end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        sessionData_
        registrationBuilder_
        
        talairach_
        fdg_
        gluc_
        ho_
        oo_
        oc_
        tr_
    end
    
    methods (Access = private)
        function ic  = ensureImagingContext(~, ic)
            if (isa(ic, 'mlfourd.ImagingContext'))
                return
            end
            if (ischar(ic))
                ic = mlfourd.ImagingContext(myfileprefix(ic));
                return
            end
            ic = mlfourd.ImagingContext(ic);
        end
        function xfm = concatTransformations(this, varargin)
            rb  = this.registrationBuilder;
            rb  = rb.concatTransforms(varargin{:});
            xfm = rb.xfm;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

