classdef BEOptionsT2 < mlfsl.BrainExtractionOptions
	%% BETT2 ...
	%  $Revision: 2571 $
 	%  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetT2.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: BetT2.m 2571 2013-08-23 12:16:08Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
	
    methods 
 		function this = BEOptionsT2(bev)
 			this = this@mlfsl.BrainExtractionOptions(bev);
            this.R = true;
 		end % ctor 
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

