classdef Test_FlirtVisitor < matlab.unittest.TestCase
	%% TEST_FLIRTVISITOR 

	%  Usage:  >> results = run(mlfsl_unittest.Test_FlirtVisitor)
 	%          >> result  = run(mlfsl_unittest.Test_FlirtVisitor, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 07-Dec-2015 20:49:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

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
 		function setupFlirtVisitor(this)
 			import mlfsl.*;
 			this.testObj = FlirtVisitor;
 		end
 	end

 	methods (TestMethodSetup)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

