classdef Test_FlirtContext < mlfsl_xunit.Test_mlfsl
	%% TEST_FLIRTSTRATEGY 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_FlirtContext % in . or the matlab path
	%          >> runtests mlfsl.Test_FlirtContext:test_nameoffunc
	%          >> runtests(mlfsl.Test_FlirtContext, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision: 2572 $
 	%  was created $Date: 2013-08-23 07:16:21 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:16:21 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FlirtContext.m $, 
 	%  developed on Matlab 8.1.0.47 (R2013a)
 	%  $Id: Test_FlirtContext.m 2572 2013-08-23 12:16:21Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        flirtStrat
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_setStrategy(this) 
 			import mlfsl.*; 
 		end 
 		function test_preprocess(this) 
 			import mlfsl.*; 
 		end 
 		function test_coregister(this) 
 			import mlfsl.*; 
 		end 
 		function test_ctor(this) 
 			import mlfsl.*; 
        end
 		function this = Test_FlirtContext(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:}); 
 		end% ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

