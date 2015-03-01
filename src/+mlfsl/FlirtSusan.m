classdef FlirtSusan < mlfsl.FlirtGauss
	%% FLIRTSUSAN 
	%  Version $Revision: 2571 $ was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtSusan.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: FlirtSusan.m 2571 2013-08-23 12:16:08Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods 
 		function this = FlirtSusan(varargin) 
 			this = this@mlfsl.FlirtGauss(varargin{:}); 
            this.averagingStrategy_ = mlaveraging.AveragingContext(this, 'susan', this.blur);
 		end % ctor         
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

