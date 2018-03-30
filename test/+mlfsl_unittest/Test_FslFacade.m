classdef Test_FslFacade < matlab.unittest.TestCase
	%% TEST_FSLFACADE 

	%  Usage:  >> results = run(mlfsl_unittest.Test_FslFacade)
 	%          >> result  = run(mlfsl_unittest.Test_FslFacade, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 30-Dec-2015 17:40:52
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

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
        function test_(this)
        end
        function test_alignImages(this)
            mpr = ;
            ho = ;
        end
	end

 	methods (TestClassSetup)
		function setupFslFacade(this)
 			import mlfsl.*;
 			this.testObj = FslFacade;
 		end
	end

 	methods (TestMethodSetup)
		function setupFslFacadeTest(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

