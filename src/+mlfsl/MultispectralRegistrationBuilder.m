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
            visitor = mlfsl.MultispectralFlirtVisitor;           
            this = visitor.registerSurjective(this, this.proxyBuilder);
            this.cleanUpProxy(this.proxyBuilder);
        end
        
        %% CTOR
		  
 		function this = MultispectralRegistrationBuilder(varargin)
 			this = this@mlfsl.AbstractRegistrationBuilder(varargin{:});             
 		end
        function obj  = clone(this)
            obj = mlfsl.MultispectralRegistrationBuilder(this);
        end
 	end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

