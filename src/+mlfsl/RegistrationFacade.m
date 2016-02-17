classdef RegistrationFacade < handle
	%% RegistrationFacade simplifies use of linear registration frameworks.

	%  $Revision$
 	%  was created 30-Dec-2015 17:49:30
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	
    properties 
        recursion = true;
        singleMoco = false;
    end
    
    properties (Dependent)
        sessionData
        registrationBuilder
    end
    
    methods %% GET
        function g = get.sessionData(this)
            g = this.sessionData_;
        end
        function g = get.registrationBuilder(this)
            g = this.registrationBuilder_;
        end
    end
    
	methods
        function g = talairach(this)
            if (isempty(this.talairach_) && ismethod(this.sessionData_, 'T1'))
                this.talairach_ = this.sessionData_.T1;
            end
            g = this.talairach_;
        end
        function g = pet(this)
            if (isempty(this.pet_))
                this.pet_ = mlpet.PETImagingContext( ...
                    this.annihilateEmptyCells({ this.oc this.ho this.oo this.gluc this.fdg this.tr }));
            end
            g = this.pet_;
        end
        function g = fdg(this)
            if (isempty(this.fdg_) && ismethod(this.sessionData_, 'fdg'))
                this.fdg_ = this.sessionData_.fdg;
            end
            g = this.fdg_;
        end
        function g = gluc(this)
            if (isempty(this.gluc_) && ismethod(this.sessionData_, 'gluc'))
                this.gluc_ = this.sessionData_.gluc;
            end
            g = this.gluc_;
        end
        function g = ho(this)
            if (isempty(this.ho_) && ismethod(this.sessionData_, 'ho'))
                this.ho_ = this.sessionData_.ho;
            end
            g = this.ho_;
        end
        function g = oo(this)
            if (isempty(this.oo_) && ismethod(this.sessionData_, 'oo'))
                this.oo_ = this.sessionData_.oo;
            end
            g = this.oo_;
        end
        function g = oc(this)
            if (isempty(this.oc_) && ismethod(this.sessionData_, 'oc'))
                this.oc_ = this.sessionData_.oc;
            end
            g = this.oc_;
        end
        function g = tr(this)
            if (isempty(this.tr_) && ismethod(this.sessionData_, 'tr'))
                this.tr_ = this.sessionData_.tr;
            end
            g = this.tr_;
        end
        
        function xfm  = concatTransformations(this, varargin)
            rb  = this.registrationBuilder;
            rb  = rb.concatTransforms(varargin{:});
            xfm = rb.xfm;
        end
        function prod = petMotionCorrect(this, src)
            if (isempty(src))
                prod = [];
                return
            end
            assert(isa(src, 'mlfourd.ImagingContext'));   
            if (lstrfind(src.fileprefix, '_mcf') && this.singleMoco)
                prod = src;
                return
            end
                     
            prb  = mlpet.PETRegistrationBuilder('sessionData', this.sessionData);
            prb.sourceImage = src;
            prb  = prb.motionCorrect;
            prod = prb.product;
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
            if (isempty(src))
                prod = [];
                return
            end
            if (isempty(xfms))
                prod = src;
                return
            end
            
            if (~iscell(xfms)); xfms = {xfms}; end
            if (~iscell(refs)); refs = {refs}; end
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
            
            prod.talairach = this.talairach;
            this.pet_      = this.petMotionCorrectAndRegister(this.pet);
            prod.petAtlas  = this.pet.atlas;
            prod.fdg       = this.petMotionCorrect(this.fdg);
            prod.gluc      = this.petMotionCorrect(this.gluc);
            prod.ho        = this.petMotionCorrect(this.ho);
            prod.oo        = this.petMotionCorrect(this.oo);
            prod.oc        = this.oc;
            prod.tr        = this.tr;
            
            msrb       = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            msrb.sourceImage = prod.talairach;
            msrb.referenceImage = prod.petAtlas;
            msrb = msrb.registerSurjective;
            tal_on_atl = msrb.product;
            
            [ fdg_on_atl,xfm_atl_on_fdg]  = this.petRegisterAndInvertTransform(prod.fdg,  prod.petAtlas);
            [gluc_on_atl,xfm_atl_on_gluc] = this.petRegisterAndInvertTransform(prod.gluc, prod.petAtlas);
            [  ho_on_atl,xfm_atl_on_ho]   = this.petRegisterAndInvertTransform(prod.ho,   prod.petAtlas);
            [  oo_on_atl,xfm_atl_on_oo]   = this.petRegisterAndInvertTransform(prod.oo,   prod.petAtlas);
            [  oc_on_atl,xfm_atl_on_oc]   = this.petRegisterAndInvertTransform(prod.oc,   prod.petAtlas);
            [  tr_on_atl,xfm_atl_on_tr]   = this.petRegisterAndInvertTransform(prod.tr,   prod.petAtlas);
            
            if (this.recursion)
                this.pet_ = mlpet.PETImagingContext( ...
                    this.annihilateEmptyCells({fdg_on_atl gluc_on_atl ho_on_atl oo_on_atl oc_on_atl tr_on_atl})); % for recursion
            end
            
            prod.talairach_on_fdg  = this.transform(tal_on_atl, xfm_atl_on_fdg,  this.fdg);
            prod.talairach_on_gluc = this.transform(tal_on_atl, xfm_atl_on_gluc, this.gluc);
            prod.talairach_on_ho   = this.transform(tal_on_atl, xfm_atl_on_ho,   this.ho);
            prod.talairach_on_oo   = this.transform(tal_on_atl, xfm_atl_on_oo,   this.oo);
            prod.talairach_on_oc   = this.transform(tal_on_atl, xfm_atl_on_oc,   this.oc);
            prod.talairach_on_tr   = this.transform(tal_on_atl, xfm_atl_on_tr,   this.tr);
        end 
        
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
    end
    
    
    %% PROTECTED
    
    properties (Access = protected)
        sessionData_
        registrationBuilder_
        
        talairach_
        fdg_
        gluc_
        ho_
        oo_
        oc_
        pet_
        tr_
    end
    
    methods (Static, Access = protected)        
        function c   = annihilateEmptyCells(c)
            for cidx = length(c):-1:1
                if (isempty(c{cidx}))
                    c(cidx) = [];
                end
            end
        end
        function ic  = ensureImagingContext(ic)
            if (isa(ic, 'mlfourd.ImagingContext'))
                return
            end
            if (ischar(ic))
                ic = mlfourd.ImagingContext(myfileprefix(ic));
                return
            end
            ic = mlfourd.ImagingContext(ic);
        end
    end
    
    methods (Access = protected)        
        function [prod,xfm] = petRegisterAndInvertTransform(this, src, ref)
            if (isempty(src) || isempty(ref))
                prod = [];
                xfm = '';
                return
            end
            
            assert(isa(src, 'mlfourd.ImagingContext'));
            assert(isa(ref, 'mlfourd.ImagingContext'));            
            prb  = mlpet.PETRegistrationBuilder('sessionData', this.sessionData);
            prb.sourceImage = src;
            prb.referenceImage = ref;
            prb  = prb.register;
            prod = prb.product;
            prb  = prb.invertTransform;
            xfm  = prb.xfm;
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

