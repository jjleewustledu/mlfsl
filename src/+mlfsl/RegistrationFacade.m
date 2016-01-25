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
        petAtlas
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
        function g = get.petAtlas(this)
            if (isempty(this.petAtlas_))
                ic = mlfourd.ImagingContext(this.sessionData.pet_fqfns);
                this.petAtlas_ = ic.atlas;
            end
            g = this.petAtlas_;
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
            addParameter(ip, 'sessionData',         [], @(x) isa(x, mlpipeline.SessionData));
            addParameter(ip, 'registrationBuilder', [], @(x) isa(x, mlfsl.RegistrationBuilder));
            parse(ip, varargin{:});
            
            this.sessionData_         = ip.Results.sessionData;
            this.registrationBuilder_ = ip.Results.registrationBuilder;
        end
        
        function this = applyTransform(this, varargin)
            ip = inputParser;
            addParameter(ip, 'interpolation', 'trilinear', @isinterpolation);
            parse(ip, varargin{:});
        end
        function this = motionCorrectPet(this, varargin)
            ip = inputParser;
            addParameter(ip, 'sourceImage');
            addParameter(ip, 'indirectBlurring', [], @isnumeric);
            parse(ip, varargin{:});
        end
        function prod = registerTalairachOnPetAtlas(this, varargin)
            %% ALIGNTALAIRACHONPET
            %  @param angles
            %  @param cost
            %  @return prod is a struct with fields:  talairach, petAtlas, talairachOnPetAtlas, xfm, inverseXfm.
            %  xfm transforms tailairch to petAtlas.  The first three are mlfourd.ImagingContext and 
            %  the latter are fully-qualified filenames.
            
            ip = inputParser;
            addParameter(ip, 'angles', [-90 90], @isnumeric); % isotropic
            addParameter(ip, 'cost', 'normmi', @iscost);
            parse(ip, varargin{:});            
            
            bldr = mlfsl.MultispectralRegistrationBuilder(this.sessionData);
            bldr = bldr.registerLinear(this.talairach, this.petAtlas);            
            bldr = bldr.applyTransform(this.talairach, this.petAtlas);
            
            prod.talairach           = this.talairach;
            prod.petAtlas            = this.petAtlas;
            prod.talairachOnPetAtlas = bldr.product;
            prod.xfm                 = bldr.xfm;
            prod.inverseXfm          = bldr.inverseXfm;
        end
    end 
    
    %% PRIVATE
    
    properties (Access = private)
        sessionData_
        registrationBuilder_
        talairach_
        petAtlas_
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

