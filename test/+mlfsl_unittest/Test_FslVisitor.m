classdef Test_FslVisitor < matlab.unittest.TestCase
	%% TEST_FSLVISITOR 

	%  Usage:  >> results = run(mlfsl_unittest.Test_FslVisitor)
 	%          >> result  = run(mlfsl_unittest.Test_FslVisitor, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 07-Dec-2015 20:48:49
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
        function test_cmd(this)
        end
        function test_help(this)
        end
        function test_view(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
        function test_(this)
        end
 	end

 	methods (TestClassSetup)
 		function setupFslVisitor(this)
 			import mlfsl.*;
 			this.testObj = FslVisitor;
 		end
 	end

 	methods (TestMethodSetup)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

