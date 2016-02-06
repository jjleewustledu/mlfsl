classdef MultispectralAlignmentBuilder < mlfsl.AlignmentBuilderPrototype
	%% MULTISPECTRALALIGNMENTBUILDER  

	%  $Revision$
 	%  was created 08-Dec-2015 16:43:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		
 	end

	methods 
        function this = align(this, nii, niiRef)
            if (isa(nii, 'mlpet.PETImagingContext'))
                assert(isa(niiRef, 'mlmr.MRImagingContext'))
                this = this.alignPET2MR(nii, niiRef);
                return
            end
            if (isa(nii, 'mlmr.MRImagingContext'))    
                assert(isa(niiRef, 'mlpet.PETImagingContext'))            
                this = this.alignMR2PET(nii, niiRef);
                return
            end
            error('mlfsl:unsupportedParamType', ...
                  'MultispectralAlignmentBuilder.align.nii has unsupported type %s', class(nii));
        end
        function this = alignPET2MR(this, pet, mr)
            assert(isa(pet, 'mlpet.PETImagingContext')); 
            assert(isa(mr,  'mlmr.MRImagingContext')); 
            pet0                  = pet.clone;
            pet.timeSummed; 
            pet.blurred;
            this.sourceImage      = pet;
            this.referenceImage   = mr;
            
            this = this.buildVisitor.alignMultispectral(this);             
            this.sourceImage = pet0;            
            this = this.buildVisitor.transformTrilinear(this);
            this.viewTogether(this.product, this.referenceImage);
        end
        function this = alignMR2PET(this, mr, pet)
            assert(isa(mr,  'mlmr.MRImagingContext'));
            assert(isa(pet, 'mlpet.PETImagingContext'));
            this.sourceImage      = mr;
            pet.timeSummed; 
            pet.blurred;
            this.referenceImage   = pet;
            
            this = this.buildVisitor.alignMultispectral(this);
            this.viewTogether(this.product, this.referenceImage);
        end
        function this = alignByInverseTransform(this, nii, niiRef)
            if (isa(nii, 'mlpet.PETImagingContext'))
                assert(isa(niiRef, 'mlmr.MRImagingContext'))
                nii0                = nii.clone;
                niiRef0             = niiRef.clone;
                this.sourceImage    = niiRef;
                nii.timeSummed;
                nii.blurred;
                this.referenceImage = nii;
                
                this = this.buildVisitor.alignMultispectral(this);
                this = this.buildVisitor.inverseTransformBuilder(this);            
                this.sourceImage    = nii0;
                this.referenceImage = niiRef; %0;
                this = this.buildVisitor.transformTrilinear(this);
                this.viewTogether(this.product, niiRef0);
                return
            end
            if (isa(nii, 'mlmr.MRImagingContext'))    
                assert(isa(niiRef, 'mlpet.PETImagingContext'))
                nii0                = nii.clone;
                niiRef0             = niiRef.clone;
                niiRef.timeSummed;
                niiRef.blurred;
                this.sourceImage    = niiRef;
                this.referenceImage = nii;
                
                this = this.buildVisitor.alignMultispectral(this);
                this = this.buildVisitor.inverseTransformBuilder(this);
                this.sourceImage    = nii0;
                this.referenceImage = niiRef; %0;
                this = this.buildVisitor.transformTrilinear(this);
                this.viewTogether(this.product, niiRef0);
                return
            end
            error('mlfsl:unsupportedParamType', ...
                  'MultispectralAlignmentBuilder.align.nii has unsupported type %s', class(nii));
        end
		  
 		function this = MultispectralAlignmentBuilder(varargin)
 			%% MULTISPECTRALALIGNMENTBUILDER
 			%  Usage:  this = MultispectralAlignmentBuilder()
 			
 			this = this@mlfsl.AlignmentBuilderPrototype(varargin{:});             
 		end
        function viewTogether(~, varargin)
            if (~mlpipeline.PipelineRegistry.instance.verbose)
                return;
            end
            assert(~isempty(varargin));
            assert(isa(varargin{1}, 'mlfourd.ImagingContext'));
            niid = varargin{1}.niftid;
            if (length(varargin) > 1)
                niid.freeview( ...
                    cell2str( ...
                        cellfun(@(x) x.fqfilename, varargin(2:end), 'UniformOutput', false), ...
                        'AsRow', true));
            else
                varargin{1}.freeview;
            end
        end
 	end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

