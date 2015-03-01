classdef FslDataFactory < mlunpacking.NIfTIFactory
	%% FSLDATAFACTORY   

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslDataFactory.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FslDataFactory.m 2629 2013-09-16 06:19:00Z jjlee $ 
 	 

	properties (Abstract) 		 
    end 

    methods (Abstract)
        renameData(this)
		standardizeOrientation(this)
        archiveFslLocation(this)
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

