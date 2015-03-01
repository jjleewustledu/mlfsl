classdef FlirtNoPreprocess < mlfsl.FlirtStrategy
	%% FlirtNoPreprocess is a place-holder for FlirtStrategy for the case of no preprocessing
    
	%  Version $Revision: 2580 $ was created $Date: 2013-08-29 02:57:58 -0500 (Thu, 29 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-29 02:57:58 -0500 (Thu, 29 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtNoPreprocess.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: FlirtNoPreprocess.m 2580 2013-08-29 07:57:58Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
	methods    
        function imgcmp = preprocess(~, imgcmp) 
            % must remain empty
        end
        function cst = costfun(~)
            cst = 1;
        end
 		function this = FlirtNoPreprocess(varargin)
            this = this@mlfsl.FlirtStrategy(varargin{:});
 		end %  ctor    
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

