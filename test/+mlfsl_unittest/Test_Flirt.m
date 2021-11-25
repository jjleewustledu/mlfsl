classdef Test_Flirt < matlab.unittest.TestCase
	%% TEST_FLIRT 

	%  Usage:  >> results = run(mlfsl_unittest.Test_Flirt)
 	%          >> result  = run(mlfsl_unittest.Test_Flirt, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 22-Nov-2021 22:45:20 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John Joowon Lee.
 	
	properties
 		registry
 		testObj
 	end

	methods (Test)
		function test_afun(this)
 			import mlfsl.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
	end

 	methods (TestClassSetup)
		function setupFlirt(this)
 			import mlfsl.*;
 			this.testObj_ = Flirt;
 		end
	end

 	methods (TestMethodSetup)
		function setupFlirtTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanTestMethod);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanTestMethod(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
end

