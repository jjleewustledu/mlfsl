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
        function set.registrationBuilder(this, s)
            assert(isa(s, 'mlfsl.AbstractRegistrationBuilder'));
            this.registrationBuilder_ = s;
        end
    end
    
	methods
        function g = brain(this)
            if (isempty(this.brain_) && ismethod(this.sessionData_, 'brain'))
                this.brain_ = this.sessionData_.brain;
            end
            g = this.brain_;
        end
        function g = checkpointFqfilename(this, label)
            g = fullfile(this.sessionData.sessionPath, ...
                sprintf('%s.checkpoint_%s_%s.mat', class(this), label, datestr(now, 30)));
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
        function g = ho(this, snum)
            assert(isnumeric(snum));
            this.sessionData_.snumber = snum;
            this.ho_ = this.sessionData_.ho;
            g = this.ho_;
        end
        function g = oo(this, snum)
            assert(isnumeric(snum));
            this.sessionData_.snumber = snum;
            this.oo_ = this.sessionData_.oo;
            g = this.oo_;
        end
        function g = oc(this, snum)
            assert(isnumeric(snum));
            this.sessionData_.snumber = snum;
            this.oc_ = this.sessionData_.oc;
            g = this.oc_;
        end
        function g = talairach(this)
            if (isempty(this.talairach_) && ismethod(this.sessionData_, 'T1'))
                this.talairach_ = this.sessionData_.T1;
            end
            g = this.talairach_;
        end
        function g = tr(this, snum)
            assert(isnumeric(snum));
            this.sessionData_.snumber = snum;
            this.tr_ = this.sessionData_.tr;
            g = this.tr_;
        end
        
        function xfm  = concatTransformations(this, varargin)
            rb  = this.registrationBuilder;
            rb  = rb.concatTransforms(varargin{:});
            xfm = rb.xfm;
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
        function prod = transform(this, src, xfms, refs, varargin)
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
            
            ip = inputParser;
            addRequired(ip, 'src',  @(x) isa(x, 'mlfourd.ImagingContext'));
            addRequired(ip, 'xfms', @iscell);
            addRequired(ip, 'refs', @iscell);
            addOptional(ip, 'interp', 'trilinear', @ischar);
            parse(ip, src, xfms, refs, varargin{:});
            
            assert(isa(src, 'mlfourd.ImagingContext'));
            assert(length(xfms) == length(refs));
            cellfun(@(x) assert(strcmp(x(end-3:end), mlfsl.FlirtVisitor.XFM_SUFFIX)), xfms);
            cellfun(@(x) assert(lexist(x, 'file')), xfms);
            cellfun(@(x) assert(isa(x, 'mlfourd.ImagingContext')), refs);
            
            msrb = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            prod = src;
            for idx = 1:length(xfms)
                msrb.xfm = xfms{idx};
                msrb.sourceImage = prod;
                msrb.referenceImage = refs{idx};
                msrb.interp = ip.Results.interp;
                msrb = msrb.transform;
                prod = msrb.product;
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
        function product = registerTalairachOnPet(this)
            %% REGISTERTALAIRACHWITHPET
            %  @return prod is a struct with products as fields.
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
        prexfm_
        sessionData_
        registrationBuilder_
        
        brain_
        fdg_
        gluc_
        ho_
        oo_
        oc_
        pet_
        talairach_
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
        function ic         = assembleImagingWeight(~, ic1, rng1, ic2, rng2)
            nn1 = ic1.numericalNiftid;
            nn2 = ic2.numericalNiftid;
            nn  = nn1*rng1 + nn2*rng2;
            ic  = mlfourd.ImagingContext2(nn);
        end
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

