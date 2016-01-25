classdef Test_MultispectralRegistrationBuilder < matlab.unittest.TestCase
	%% TEST_MULTISPECTRALREGISTRATIONBUILDER 

	%  Usage:  >> results = run(mlfsl_unittest.Test_MultispectralRegistrationBuilder)
 	%          >> result  = run(mlfsl_unittest.Test_MultispectralRegistrationBuilder, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 08-Dec-2015 16:43:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
        mr
        mrOnPet
        pet
        petSumt
        sessionPath
 		testObj
 	end

	methods (Test)
 		function test_mr(this)
            this.assertTrue(isa(this.mr, 'mlmr.MRImagingContext'));
        end
 		function test_pet(this)
            this.assertTrue(isa(this.pet, 'mlpet.PETImagingContext'));
        end
        function test_alignPET2MR(this)
            this.testObj = this.testObj.align(this.petSumt, this.mr);
            p = this.testObj.product;
            this.verifyEqual(p.niftid.entropy,             0.940927831691311, 'RelTol', 1e-12);
            this.verifyEqual(sum(sum(sum(p.niftid.img))), -2723491237.44,     'RelTol', 1e-12);
        end
        function test_alignMR2PET(this)
            this.testObj = this.testObj.align(this.mr, this.petSumt);
            p = this.testObj.product;
            this.verifyEqual(p.niftid.entropy,            0.890441152357043, 'RelTol', 1e-12);
            this.verifyEqual(sum(sum(sum(p.niftid.img))), 27280699,          'RelTol', 1e-7);
        end
        function test_alignByInverseTransform(this)
            this.testObj = this.testObj.alignByInverseTransform(this.petSumt, this.mr);
            p = this.testObj.product;
            this.verifyEqual(p.niftid.entropy,            0.941728769775346, 'RelTol', 1e-12);
            this.verifyEqual(sum(sum(sum(p.niftid.img))), -2700759711.38535, 'RelTol', 1e-12);
        end
        function test_alignByInverseTransform2(this)
            this.testObj = this.testObj.alignByInverseTransform(this.mr, this.petSumt);
            p = this.testObj.product;
            this.verifyEqual(p.niftid.entropy,            0.8901370869198, 'RelTol', 1e-12);
            this.verifyEqual(sum(sum(sum(p.niftid.img))), 27290361,        'RelTol', 1e-7);
        end
 	end

 	methods (TestClassSetup)
 		function setupMultispectralAlignmentBuilder(this)
 			import mlfsl.* mlfourd.*;
            this.sessionPath = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
 		end
 	end

 	methods (TestMethodSetup)
        function setupMultispectralAlignmentBuilderTest(this)
 			import mlfsl.* mlfourd.*;
            this.pet = mlpet.PETImagingContext( ...
                NumericalNIfTId.load( ...
                fullfile(this.sessionPath, 'ECAT_EXACT', 'pet', 'p7377ho1_frames', 'p7377ho1.nii.gz')));
            this.petSumt = mlpet.PETImagingContext( ...
                NumericalNIfTId.load( ...
                fullfile(this.sessionPath, 'ECAT_EXACT', 'pet', 'p7377ho1_frames', 'p7377ho1_sumt.nii.gz')));
            this.mr = mlmr.MRImagingContext( ...
                NumericalNIfTId.load( ...
                fullfile(this.sessionPath, 'mri', 'orig.mgz')));
            this.mrOnPet = mlmr.MRImagingContext( ...
                NumericalNIfTId.load( ...
                fullfile(this.sessionPath, 'mri', 'orig_on_p7377ho1.nii.gz')));
 			this.testObj  = MultispectralAlignmentBuilder('sessionPath', this.sessionPath);
            if (~lexist(fullfile(this.sessionPath, 'mri', 'orig.nii.gz')))
                mlbash(sprintf('mri_convert %s %s', ...
                    fullfile(this.sessionPath, 'mri', 'orig.mgz'), ...
                    fullfile(this.sessionPath, 'mri', 'orig.nii.gz')));
            end
        end
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

