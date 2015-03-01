classdef FslVisitorInterface  
	%% FSLVISITORINTERFACE   

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslVisitorInterface.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FslVisitorInterface.m 2644 2013-09-21 22:58:45Z jjlee $ 

	methods (Abstract)
        visitMRAlignmentBuilder(this)
        visitPETAlignmentBuilder(this)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

