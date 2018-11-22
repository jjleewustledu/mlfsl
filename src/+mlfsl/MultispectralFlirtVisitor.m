classdef MultispectralFlirtVisitor < mlfsl.FlirtVisitor 
	%% MULTISPECTRALFLIRTVISITOR  

	%  $Revision$
 	%  was created 31-Jan-2016 23:50:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
 		
 	end

	methods         
        function bldr = motionCorrect(this, bldr)
            if (isa(bldr, 'mlpet.PETRegistrationBuilder'))
                pfv = mlpetPETFlirtVisitor;
                bldr = pfv.motionCorrect(bldr);
                return
            end
            if (isa(bldr, 'mlmr.MRRegistrationBuilder'))
                mfv = mlmr.MRFlirtVisitor;
                bldr = mfv.motionCorrect(bldr);
            end
            bldr = motionCorrect@mlfsl.FlirtVisitor(this, bldr);
        end  
        function [bldr,xfm] = registerInjective(this, bldr, proxyBldr)
            this.ensureBuilderSaved(bldr);
            this.ensureBuilderSaved(proxyBldr);
            
            opts              = mlfsl.FlirtOptions;
            opts.in           = proxyBldr.sourceImage;
            opts.ref          = proxyBldr.referenceImage;
            opts.cost         = 'normmi';
            opts.dof          = 6;  
            opts.inweight     = proxyBldr.sourceWeight;
            opts.refweight    = proxyBldr.referenceWeight;           
            opts.init         = this.flirt__(opts);
            
            opts.in           = bldr.sourceImage;
            opts.ref          = bldr.referenceImage;
            opts.inweight     = bldr.sourceWeight;
            opts.refweight    = bldr.referenceWeight; 
            bldr.product      = this.transform__(opts);
            bldr.product.addLog( ...
                ['FlirtVisitor.registerInjective.bldr.sourceImage\n' bldr.sourceImage.logger.contents]);
            bldr.xfm          = opts.init;
            xfm               = opts.init;
        end
        function [bldr,xfm] = registerSurjective(this, bldr, proxyBldr)
            this.ensureBuilderSaved(bldr);
            this.ensureBuilderSaved(proxyBldr);
            
            opts              = mlfsl.FlirtOptions;
            opts.in           = proxyBldr.referenceImage;
            opts.ref          = proxyBldr.sourceImage;
            opts.cost         = 'normmi';
            opts.dof          = 6;  
            opts.inweight     = proxyBldr.referenceWeight;
            opts.refweight    = proxyBldr.sourceWeight;           
            opts.init         = this.flirt__(opts);
            
            opts              = this.inverseTransformOptions__(opts);
            
            opts.in           = bldr.sourceImage;
            opts.ref          = bldr.referenceImage;
            opts.inweight     = bldr.sourceWeight;
            opts.refweight    = bldr.referenceWeight; 
            bldr.product      = this.transform__(opts);
            bldr.product.addLog( ...
                ['FlirtVisitor.registerSurjective.bldr.sourceImage\n' bldr.sourceImage.logger.contents]);
            bldr.xfm          = opts.init;
            xfm               = opts.init;
        end  
        
 		function this = MultispectralFlirtVisitor(varargin)
 			this = this@mlfsl.FlirtVisitor(varargin{:});
 		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

