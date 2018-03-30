classdef BetFlair < mlfsl.BetStrategy
	%% BETFLAIR ...
	%  $Revision: 2571 $
 	%  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetFlair.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: BetFlair.m 2571 2013-08-23 12:16:08Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
	
    properties (Constant)
        ABS_SUFFIX = '_abs';
    end
    
	methods 
 		function [this, imobj] = bet(this, imobj)
            try
                imobj = this.makeAbs(imobj);
                this.in_tag = imcast(imobj, 'fileprefix');
                this.out_tag = fileprefix(BetBuilder.bettedFilename(this.in_tag));
                this.betOptions.A2 = this.inOnT2;
                this.betOptions.f = 0.2;
                import mlfsl.*;
                this.betOptions.r = BetT1.radius(imobj);
                this.betOptions.c = BetT1.center(imobj);
                [this.builder_,imobj] = this.builder_.betUsingReference(this.betOptions);
            catch ME
                handwarning(ME);
                [this,imobj] = this.betAlt(imobj);
            end
        end
        function [this, imobj] = betAlt(this, imobj) 
            imobj = this.makeAbs(imobj);
            this.in = imcast(imobj, 'fileprefix');
            this.betOptions.R = true;
            this.betOptions.f = 0.01;
            import mlfsl.*;
            this.betOptions.r = BetFlair.radius(imobj);
            this.betOptions.c = BetFlair.center(imobj);
            [this.builder_,imobj] = this.builder_.betUsingReference(this.betOptions);
        end
        function imobj = makeAbs(this, imobj)
            typclass = class(imobj);
            imobj = imcast(imobj, 'fileprefix');
            if (lstrfind(imobj, this.ABS_SUFFIX)); return; end
            nii = mlfourd.NIfTI.load(imobj);
            if (nii.dipmin < 0)
                nii = nii .* (nii < eps) .* -1; end
            nii = nii.saveas( ...
                filenameSuffixed(nii.fqfileprefix));
            imobj = imcast(nii, typclass);
        end
 		function this = BetFlair(bldr) 
 			%% BETFLAIR
 			%  Usage:  obj = BetFlair(bet_builder) 
            
            this = this@mlfsl.BetStrategy(bldr);
 		end %  ctor 
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

