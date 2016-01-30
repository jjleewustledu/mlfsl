classdef Test_RegistrationFacade < matlab.unittest.TestCase
	%% TEST_REGISTRATIONFACADE 

	%  Usage:  >> results = run(mlfsl_unittest.Test_RegistrationFacade)
 	%          >> result  = run(mlfsl_unittest.Test_RegistrationFacade, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 30-Dec-2015 17:49:32
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
        registry
 		testFacade
        view = true
    end
    
    properties (Dependent)
        sessionData
        registrationBuilder
        
        sessionPath
        ecatPath
        
        ho_fqfn
        oo_fqfn
        oc_fqfn
        tr_fqfn  
        mask_fqfn      
        
        aparcAseg_fqfn
        aparcAsegOnHoManual_fqfn        
        T1_fqfn
        T1OnHoManual_fqfn
        talairach_on_ho
        talairach_on_oo
        talairach_on_oc
        talairach_on_tr
        talairach_on_pet
        
        expectedReport
        expectedReport2
        expectedReport3
        expectedReport4
    end
    
    methods % GET
        function g = get.sessionData(~)
            sds = mlderdeyn.StudyDataSingleton.instance('initialize');
            iter = sds.createIteratorForSessionData;
            iter.reset;
            assert(iter.hasNext);
            g = iter.next;
        end
        function g = get.registrationBuilder(this)
            g = mlfsl.MultispectralRegistrationBuilder(this.sessionData);
        end
        
        function g = get.sessionPath(~)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
        end
        function g = get.ecatPath(this)
            g = fullfile(this.sessionPath, 'ECAT_EXACT', '');
        end
        function g = get.ho_fqfn(this)
            g = fullfile(this.ecatPath, 'pet', 'p7377ho1_frames', 'p7377ho1.nii.gz');
        end
        function g = get.mask_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'aparc.a2009s+aseg.mgz');
        end
        function g = get.oc_fqfn(this)
            g = fullfile(this.ecatPath, 'pet', 'p7377oc1_frames', 'p7377oc1_03.nii.gz');
        end
        function g = get.oo_fqfn(this)
            g = fullfile(this.ecatPath, 'pet', 'p7377oo1_frames', 'p7377oo1.nii.gz');
        end
        function g = get.tr_fqfn(this)
            g = fullfile(this.ecatPath, 'pet', 'p7377tr1_frames', 'p7377tr1_01.nii.gz');
        end
        function g = get.aparcAseg_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'aparc.a2009s+aseg.mgz');
        end
        function g = get.aparcAsegOnHoManual_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'aparc_a2009s+aseg_on_p7377ho1_manual.nii.gz');
        end
        function g = get.T1_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'T1.mgz');
        end
        function g = get.T1OnHoManual_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'T1_on_p7377ho1_manual.nii.gz');
        end
    end

	methods (Test)
        function test_registerTalairachWithPet(this)
            prod = this.testFacade.registerTalairachWithPet;
            
            statsReport = this.testFacade.stats(prod);
            this.verifyEqual(statsReport, this.expectedReport);
            this.verifyEqual(prod.talairach_on_ho, this.talairach_on_ho);
            this.verifyEqual(prod.talairach_on_oo, this.talairach_on_oo);
            this.verifyEqual(prod.talairach_on_oc, this.talairach_on_oc);
            this.verifyEqual(prod.talairach_on_tr, this.talairach_on_tr);
            if (this.view)
                prod.view(top); 
            end
        end
        function test_registerTalairachOnPet_inverse(this)
            prod = this.testFacade.registerTalairachOnPet('inverse', true);            
            top  = this.talairach_on_pet;
            this.verifyEqual(prod, top);
            if (this.view)
                prod.view(top); 
            end
        end
        function test_applyTransform(this)
            error('mlfourd_unittest:notImplemented', '');
        end
        function test_motionCorrect(this)
            error('mlfourd_unittest:notImplemented', '');
        end
	end

 	methods (TestClassSetup)
		function setupRegistrationFacade(this)
            this.cachedSessionData_   = this.sessionData;
            this.registrationBuilder_ = this.registrationBuilder;
 		end
	end

 	methods (TestMethodSetup)
		function setupRegistrationFacadeTest(this)
 			this.testFacade = mlfsl.RegistrationFacade( ...
                this.cachedSessionData_, this.registrationBuilder_); % handle
            this.addTeardown(@this.cleanUp);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        cachedSessionData_
        registrationBuilder_
    end
    
    methods (Access = private)
        function cleanUp(this)
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

