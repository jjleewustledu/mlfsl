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
        function g = get.talairach(this)
            if (isempty(this.talairach_))
                this.talairach_ = mlfourd.ImagingContext(this.sessionData_.T1_fqfn);
            end
            g = this.talairach_;
        end
        function g = get.pet(this)
            g = mlfourd.ImagingContext( ...
                { this.fdg this.gluc this.ho this.oo this.oc this.tr });
        end
        function g = get.fdg(this)
            if (isempty(this.fdg_))
                this.fdg_ = mlfourd.ImagingContext(this.sessionData_.fdg_fqfn);
            end
            g = this.fdg_;
        end
        function g = get.gluc(this)
            if (isempty(this.gluc_))
                this.gluc_ = mlfourd.ImagingContext(this.sessionData_.gluc_fqfn);
            end
            g = this.gluc_;
        end
        function g = get.ho(this)
            if (isempty(this.ho_))
                this.ho_ = mlfourd.ImagingContext(this.sessionData_.ho_fqfn);
            end
            g = this.ho_;
        end
        function g = get.oo(this)
            if (isempty(this.oo_))
                this.oo_ = mlfourd.ImagingContext(this.sessionData_.oo_fqfn);
            end
            g = this.oo_;
        end
        function g = get.oc(this)
            if (isempty(this.oc_))
                this.oc_ = mlfourd.ImagingContext(this.sessionData_.oc_fqfn);
            end
            g = this.oc_;
        end
        function g = get.tr(this)
            if (isempty(this.tr_))
                this.tr_ = mlfourd.ImagingContext(this.sessionData_.tr_fqfn);
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
            addParameter(ip, 'sessionData', [], @(x) isa(x, mlpipeline.SessionData));
            parse(ip, varargin{:});
            
            this.sessionData_ = ip.Results.sessionData;
        end
        
        function this = applyTransform(this, varargin)
            ip = inputParser;
            addParameter(ip, 'interpolation', 'trilinear', @this.isinterpolation);
            parse(ip, varargin{:});
        end
        function this = motionCorrectPet(this, varargin)
            ip = inputParser;
            addParameter(ip, 'sourceImage');
            addParameter(ip, 'indirectBlurring', [], @isnumeric);
            parse(ip, varargin{:});
        end
        function prod = registerTalairachWithPet(this)
            %% REGISTERTALAIRACHWITHPET
            %  @return prod is a struct with products as fields.
            
            import mlfsl.*;
            msrb = MultispectralRegistrationBuilder(this.sessionData);
            prb  = PetRegistrationBuilder(this.sessionData);
            
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
        
        talairach_
        fdg_
        gluc_
        ho_
        oo_
        oc_
        tr_
    end
    
    methods (Static, Access = private) % TO DO:  move to builder classes
        function tf = iscost(c)
            tf = lstrfind(c, {'mutualinfo' 'corratio' 'normcorr' 'normmi' 'leastsq' 'labeldiff' 'bbr'});
        end
        function tf = iscost_mc(c)
            tf = lstrfind(c, {'mutualinfo' 'woods' 'corratio' 'normcorr' 'normmi' 'leastsquares'});
        end
        function tf = isinterpolation(int)
            tf = lstrfind(int, {'trilinear' 'nearestneighbour' 'sinc' 'spline'});
        end
        % 
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

