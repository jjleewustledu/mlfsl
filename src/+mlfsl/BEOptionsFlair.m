classdef BEOptionsFlair < mlfsl.BrainExtractionOptions
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
    
    properties
        variant = 0;
    end
    
    methods        
 		function this = BEOptionsFlair(bev)
 			this = this@mlfsl.BrainExtractionOptions(bev);            
            this.in_tag = imcast( ...
                          this.makeAbs(this.in_tag), 'fqfileprefix');
            switch (this.variant)
                case 0
                    this.A2 = this.t2OnIn;
                    this.f = 0.2;
                otherwise
                    this.R = true;
                    this.f = 0.01;
            end
 		end % ctor 
    end
    
    methods (Access = 'protected')
        function imobj = makeAbs(this, imobj)
            typclass = class(imobj);
            imobj = imcast(imobj, 'fqfileprefix');
            if (lstrfind(imobj, this.ABS_SUFFIX)); return; end
            nii = mlfourd.NIfTI.load(imobj);
            if (nii.dipmin < 0)
                nii = nii .* (nii < eps) .* -1; end
            nii = nii.saveas( ...
                filenameSuffixed(nii.fqfileprefix));
            imobj = imcast(nii, typclass);
        end
 	end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

