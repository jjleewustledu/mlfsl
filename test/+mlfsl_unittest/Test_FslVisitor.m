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
 		testObj
 	end

	methods (Test)
        function test_cmd_exit1(this)
            this.verifyError(@()error('err:id', 'known error'), 'err:id');
            %this.verifyError(@()error('err:id', 'known error'), 'other:id');
            this.verifyError(@()mlfsl.FslVisitor.cmd('flirt'), 'mlfsl:shellFailure');
        end
        function test_cmd(this)
            [s,r,c] = mlfsl.FslVisitor.cmd('fslhd', 't1_default');
            this.verifyEqual(s, 0);
            this.verifyEqual(r(1:8), 'filename');
            this.verifyEqual(c, 'fslhd  t1_default');
        end
        function test_fslmaths(this)
            %('gre_004 -Xmean -Ymean -Zmean test_fslmaths');
            [s,r,c] = mlfsl.FslVisitor.fslmaths('gre_004', '-Xmean', '-Ymean', '-Zmean', 'test_fslmaths');
            this.verifyEqual(s, 0);
            this.verifyEqual(r, '');
            this.verifyEqual(c, 'fslmaths  gre_004 -Xmean -Ymean -Zmean test_fslmaths');
            delete(fullfile(this.testObj.workPath, 'test_fslmaths.nii.gz'));
        end
        function test_help(this)
            msg = mlfsl.FslVisitor.help('mcflirt');
            this.verifyEqual(msg(1:37), 'Usage: mcflirt -in <infile> [options]');
        end
        function test_outputRedirection(this)
            lg = getenv('LOGGING');
            setenv('LOGGING', '1');
            str = mlfsl.FslVisitor.outputRedirection;
            this.verifyEqual(str(1:14), '>> FslVisitor_');
            this.verifyEqual(str(end-3:end), '2>&1');
            setenv('LOGGING', lg);
        end
        
        
        
        function test_fslstats(this)
            [s,r] = this.fslBuilder.fslstats('t1_002', struct('E',''));
            assertEqual(0, s, r);
            assertElementsAlmostEqual(0.695402, str2double(r), r);
        end
        function test_fslhdParameter(this)
            assertEqual( ...
                         'Scanner Anat', ...
                         this.fslBuilder.fslhdParameter( ...
                         't1_002', 'sform_code_name'));
        end
        function test_fslcmd(this)
            [s,r] = this.fslBuilder.fslcmd('fslhd', struct('x','t1_002'));
            assertTrue(0 == s);
            assertTrue( ...
                mlio.TextIO.textfileStrcmp( ...
                    this.fslcmdTextfile, strtrim(r)));
        end
 	end

 	methods (TestClassSetup)
 		function setupFslVisitor(this)
 			import mlfsl.*;
 			this.testObj = FslVisitor( ...
                'workPath', ...
                fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', 'fsl', ''));
 		end
 	end

 	methods (TestMethodSetup)
 		function setupFslVisitorTest(this)
            cd(this.testObj.workPath);
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function fn = fslcmdTextfile(this)
            fn = fullfile(this.fslPath, 'Test_fslBuilder_test_fslcmd.txt');
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

