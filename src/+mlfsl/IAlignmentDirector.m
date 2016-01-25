classdef (Abstract) IAlignmentDirector  
	%% IALIGNMENTDIRECTOR defines the interface for dynamically adding responsibilities in a decorator design pattern.
    %  See also:  mlfsl.AlignmentDirectorDecorator.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/IAlignmentDirector.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: IAlignmentDirector.m 2644 2013-09-21 22:58:45Z jjlee $  	  
    
    properties (Abstract)
        builder
        logger
        sourceWeight
        referenceWeight
        sourceImage
        referenceImage
        product
        xfm
    end

	methods
        function prds = alignSequentially(~)
            prds = [];
        end
        function prds = alignSequentiallySmallAngles(~)
            prds = [];
        end
        function prds = alignIndependently(~)
            prds = [];
        end
        function prd  = alignSingle(~)
            prd = [];
        end
        function prd  = alignPair(~)
            prd = [];
        end
        function prds = alignThenApplyXfm(~)
            prds = [];
        end
        
        function prd  = motionCorrect(~)
            prd = [];
        end
        function prd  = meanvol(~)
            prd = [];
        end
        function prd  = meanvolByComponent(~)
            prd = [];
        end
            
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

