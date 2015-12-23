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
            this.sourceImage      = this.blurred(this.timeSummed(pet));
            this.referenceImage   = mr;
            
            visit = mlfsl.FlirtVisitor;
            this  = visit.alignMultispectral(this);             
            this.sourceImage = pet0;            
            this  = visit.applyTransformOfBuilder(this);
            this.viewTogether(this.product, this.referenceImage);
        end
        function this = alignMR2PET(this, mr, pet)
            assert(isa(mr,  'mlmr.MRImagingContext'));
            assert(isa(pet, 'mlpet.PETImagingContext'));
            this.sourceImage      = mr;
            this.referenceImage   = this.blurred(this.timeSummed(pet));
            
            visit = mlfsl.FlirtVisitor;
            this  = visit.alignMultispectral(this);
            this.viewTogether(this.product, this.referenceImage);
        end
        function this = alignByInverseTransform(this, nii, niiRef)
            if (isa(nii, 'mlpet.PETImagingContext'))
                assert(isa(niiRef, 'mlmr.MRImagingContext'))
                nii0                = nii.clone;
                niiRef0             = niiRef.clone;
                this.sourceImage    = niiRef;
                this.referenceImage = this.blurred(this.timeSummed(nii));
                
                visit = mlfsl.FlirtVisitor;
                this  = visit.alignMultispectral(this);
                this  = visit.inverseTransformOfBuilder(this);            
                this.sourceImage    = nii0;
                this.referenceImage = niiRef0;
                this  = visit.applyTransformOfBuilder(this);
                this.viewTogether(this.product, niiRef0);
                return
            end
            if (isa(nii, 'mlmr.MRImagingContext'))    
                assert(isa(niiRef, 'mlpet.PETImagingContext'))
                nii0                = nii.clone;
                niiRef0             = niiRef.clone;
                this.sourceImage    = this.blurred(this.timeSummed(niiRef));
                this.referenceImage = nii;
                
                visit = mlfsl.FlirtVisitor;
                this  = visit.alignMultispectral(this);
                this  = visit.inverseTransformOfBuilder(this);
                this.sourceImage    = nii0;
                this.referenceImage = niiRef0;
                this  = visit.applyTransformOfBuilder(this);
                this.viewTogether(this.product, niiRef0);
                return
            end
            error('mlfsl:unsupportedParamType', ...
                  'MultispectralAlignmentDirector.align.nii has unsupported type %s', class(nii));
        end
		  
 		function this = MultispectralAlignmentBuilder(varargin)
 			%% MULTISPECTRALALIGNMENTBUILDER
 			%  Usage:  this = MultispectralAlignmentBuilder()
 			
 			this = this@mlfsl.AlignmentBuilderPrototype(varargin{:});             
 		end
        function viewTogether(~, varargin)
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

    %% PROTECTED
    
    methods (Access = 'protected')
        function ic = blurred(~, ic)
            assert(isa(ic, 'mlfourd.ImagingContext'));
            if (~lstrfind(ic.niftid.fileprefix, 'fwhh'))
                ic = ic.blurred;
            end
        end
        function ic = timeSummed(~, ic)
            assert(isa(ic, 'mlfourd.ImagingContext'));
            if (~lstrfind(ic.niftid.fileprefix, '_sumt'))
                ic = ic.timeSummed;
            end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

