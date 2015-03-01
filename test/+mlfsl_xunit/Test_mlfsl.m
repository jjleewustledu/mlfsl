classdef Test_mlfsl < mlfourd_xunit.Test_mlfourd 
	%% TEST_MLFSL 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_mlfsl % in . or the matlab path 
 	%          >> runtests Test_mlfsl:test_nameoffunc 
 	%          >> runtests(Test_mlfsl, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2471 $ was created $Date: 2013-08-10 21:36:24 -0500 (Sat, 10 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-10 21:36:24 -0500 (Sat, 10 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_mlfsl.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_mlfsl.m 2471 2013-08-11 02:36:24Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	methods    
 		function this = Test_mlfsl(varargin)
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:}); 
        end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

