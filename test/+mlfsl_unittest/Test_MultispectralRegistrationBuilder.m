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
 		registry
        studyData
        sessionData
 		mrb
        
        orig
        ho
        ho_sumt
        t1_small
        t1_small_fqfn
        
        view = false
    end
    
	methods (Test)
 		function test_mr(this)
            this.assertTrue(isa(this.orig, 'mlmr.MRImagingContext'));
        end
 		function test_ho(this)
            this.assertTrue(isa(this.ho, 'mlpet.PETImagingContext'));
        end
 		function test_ho_sumt(this)
            this.assertTrue(isa(this.ho_sumt, 'mlpet.PETImagingContext'));
        end
        function test_registerBijective3D_mr2pet(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    =  MRImagingContext(this.t1_small_fqfn);
            this.mrb.referenceImage = PETImagingContext(this.sessionData.tr_fqfn);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;            
            this.verifyIC(prod, 0.941518966054972, 96.7990898329575, 't1_default_on_p7686tr1_01_919110fwhh')
            if (this.view)
                prod.view(this.mrb.sourceImage, ...
                          this.mrb.referenceImage, ...
                          this.mrb.sourceWeight, ...
                          this.mrb.referenceWeight);
            end
        end
        function test_registerBijective3D_pet2mr(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    = PETImagingContext(this.sessionData.oc_fqfn);
            this.mrb.referenceImage =  MRImagingContext(this.t1_small_fqfn);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;
            this.verifyIC(prod, 0.999314623985113, 335.617793544018, 'p7686oc1_03_on_ho_meanvol_default')
            if (this.view)
                prod.view(this.mrb.sourceImage, ...
                          this.mrb.referenceImage, ...
                          this.mrb.sourceWeight, ...
                          this.mrb.referenceWeight);
            end
        end
        function test_registerBijective4D(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    = PETImagingContext(this.sessionData.ho_fqfn);
            this.mrb.referenceImage =  MRImagingContext(this.t1_small_fqfn);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;
            this.verifyIC(prod, 0.985157164151474, 131.29401255791, 'p7686ho1_on_ho_meanvol_default')
            if (this.view)
                prod.view(this.mrb.sourceImage, ...
                          this.mrb.referenceImage, ...
                          this.mrb.sourceWeight, ...
                          this.mrb.referenceWeight);
            end
        end
        function test_registerInjective3D(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    = PETImagingContext(this.ho_sumt);
            this.mrb.referenceImage =  MRImagingContext(this.orig);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;
            this.verifyIC(prod, 0.942524162757309, 2745.76260010973, 'p7686ho1_sumt_on_orig')
            if (this.view)
                prod.view(this.mrb.referenceImage, ...
                          this.mrb.referenceWeight);
            end
        end
        function test_registerSurjective3D(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    =  MRImagingContext(this.orig);
            this.mrb.referenceImage = PETImagingContext(this.ho_sumt);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;
            this.verifyIC(prod, 0.967830143951345, 43.6223512676426, 'orig_on_p7686ho1_sumt_919110fwhh')
            if (this.view)
                prod.view(this.mrb.referenceImage, ...
                          this.mrb.referenceWeight);
            end
        end
        function test_registerSurjective4D(this)
            import mlpet.* mlmr.*;
            this.mrb.sourceImage    =  MRImagingContext(this.orig);
            this.mrb.referenceImage = PETImagingContext(this.ho);
            this.mrb                = this.mrb.register;
            prod                    = this.mrb.product;
            this.verifyIC(prod, 0.967830143951345, 43.6223512676426, 'orig_on_p7686ho1_sumt_919110fwhh')
            if (this.view)
                prod.view(this.mrb.referenceImage, ...
                          this.mrb.referenceWeight);
            end
        end
 	end

 	methods (TestClassSetup)
 		function setupMultispectralAlignmentBuilder(this)
            this.registry = mlsiemens.ECATRegistry.instance('initialize');
            this.studyData = this.registry.testStudyData('test_derdeyn');
            iter = this.studyData.createIteratorForSessionData;
            this.sessionData = iter.next;
            disp(this.sessionData);
 			this.mrb_ = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
            
 			import mlfourd.*;
            this.t1_small_fqfn = fullfile(this.sessionData.fslPath, 't1_default_on_ho_meanvol_default.nii.gz');
            this.t1_small = mlmr.MRImagingContext(NumericalNIfTId.load(this.t1_small_fqfn));
            this.ho      = mlpet.PETImagingContext(NumericalNIfTId.load(this.sessionData.ho_fqfn));
            this.ho_sumt = this.ho.timeSummed;
            this.orig     = mlmr.MRImagingContext(NumericalNIfTId.load(this.sessionData.orig_fqfn));
 		end
 	end

 	methods (TestMethodSetup)
        function setupMultispectralAlignmentBuilderTest(this)            
 			this.mrb = this.mrb_;
            this.addTeardown(@this.cleanupFiles);
        end
    end
        
    %% PRIVATE

	properties (Access = private)
 		mrb_
    end
    
    methods (Access = private)
        function cleanupFiles(this)
            deleteExisting(this.mrb.sourceWeight);
            deleteExisting(this.mrb.referenceWeight);
        end
        function verifyIC(this, ic, e, m, fp)
            this.assumeInstanceOf(ic, 'mlfourd.ImagingContext');
            this.verifyEqual(ic.niftid.entropy, e, 'RelTol', 1e-6);
            this.verifyEqual(dipmad(ic.niftid.img), m, 'RelTol', 1e-4);
            this.verifyEqual(ic.fileprefix, fp); 
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

