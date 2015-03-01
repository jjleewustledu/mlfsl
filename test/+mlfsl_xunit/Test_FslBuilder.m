classdef Test_FslBuilder < mlfsl_xunit.Test_mlfsl
	%% TEST_FSLBUILDER 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_FslBuilder % in . or the matlab path 
 	%          >> runtests Test_FslBuilder:test_nameoffunc 
 	%          >> runtests(Test_FslBuilder, Test_Class2, Test_Class3, ...) 
    %  Use cases: 
    %  -  
 	%  See also:  package xunit%  Version $Revision: 2471 $ was created $Date: 2013-08-10 21:36:24 -0500 (Sat, 10 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-10 21:36:24 -0500 (Sat, 10 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FslBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_FslBuilder.m 2471 2013-08-11 02:36:24Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
        fslBuilder
        fslcmdTextfile
 	end 

	methods 
        function fn = get.fslcmdTextfile(this)
            fn = fullfile(this.fslPath, 'Test_fslBuilder_test_fslcmd.txt');
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
        function test_ctor(this)
            assert(isa(this.fslBuilder, 'mlfsl.FslBuilder'));
        end
        
 		function this = Test_FslBuilder(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:}); 
            this.preferredSession = 2;
            this.fslBuilder = mlfsl.FslBuilder.createFromConverter( ...
                              mlsurfer.SurferDicomConverter.createFromModalityPath(this.mrPath));
 		end % Test_FslBuilder (ctor)
        function setUp(this) %#ok<MANU>
            pr = mlpipeline.PipelineRegistry.instance;
            pr.logging = false;
        end
        function tearDown(this) %#ok<MANU>
            pr = mlpipeline.PipelineRegistry.instance;
            pr.logging = false;
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

