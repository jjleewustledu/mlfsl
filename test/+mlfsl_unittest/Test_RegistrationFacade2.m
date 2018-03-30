classdef Test_RegistrationFacade2 < matlab.unittest.TestCase
	%% TEST_REGISTRATIONFACADE 

	%  Usage:  >> results = run(mlfsl_unittest.Test_RegistrationFacade2)
 	%          >> result  = run(mlfsl_unittest.Test_RegistrationFacade2, 'test_dt')
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
        petPath
        
        ho_fqfn
        oo_fqfn
        oc_fqfn
        tr_fqfn  
        mask_fqfn        
        aparcAseg_fqfn
        aparcAsegOnHoManual_fqfn        
        T1_fqfn
        T1OnHo_fqfn
        t2_fqfn
        
        ho
        oo
        oc
        tr
        mask
        aparcAseg
        aparcAsegOnHoManual
        T1
        T1OnHo
        t2
        
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
            sds = mlderdeyn.TestDataSingleton.instance('initialize');
            iter = sds.createIteratorForSessionData;
            iter.reset;
            assert(iter.hasNext);
            g = iter.next;
        end
        function g = get.registrationBuilder(this)
            g = mlfsl.MultispectralRegistrationBuilder('sessionData', this.sessionData);
        end
        
        function g = get.sessionPath(~)
            g = fullfile(getenv('MLUNIT_TEST_PATH'), 'cvl', 'np755', 'mm01-020_p7377_2009feb5', '');
        end
        function g = get.ecatPath(this)
            g = fullfile(this.sessionPath, 'ECAT_EXACT', '');
        end
        function g = get.petPath(this)
            g = fullfile(this.ecatPath, 'pet', '');
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
        function g = get.T1OnHo_fqfn(this)
            g = fullfile(this.sessionPath, 'mri', 'T1_on_p7377ho1.nii.gz');
        end
        function g = get.t2_fqfn(this)
            g = fullfile(this.sessionPath, 'fsl', 't2_default.nii.gz');
        end
        
        function g = get.ho(this)
            g = mlpet.PETImagingContext(this.ho_fqfn);
        end
        function g = get.oo(this)
            g = mlpet.PETImagingContext(this.oo_fqfn);
        end
        function g = get.oc(this)
            g = mlpet.PETImagingContext(this.oc_fqfn);
        end
        function g = get.tr(this)
            g = mlpet.PETImagingContext(this.tr_fqfn);
        end
        function g = get.mask(this)
            g = mlfsl.ImagingContext(this.mask_fqfn);
        end
        function g = get.aparcAseg(this)
            g = mlmr.MRImagingContext(this.aparcAseg_fqfn);
        end
        function g = get.aparcAsegOnHoManual(this)
            g = mlmr.MRImagingContext(this.aparcAsegOnHoManual_fqfn);
        end
        function g = get.T1(this)
            g = mlmr.MRImagingContext(this.T1_fqfn);
        end
        function g = get.T1OnHo(this)
            g = mlmr.MRImagingContext(this.T1OnHo_fqn);
        end 
        function g = get.t2(this)
            g = mlmr.MRImagingContext(this.t2_fqfn);
        end     
    end

	methods (Test)
        function test_registerTalairachOnPet(this)
            studyd = mlpipeline.StudyDataSingletons.instance('test_raichle');
            sessd = mlraichle.SessionData( ...
                'studyData', studyd, 'sessionPath', fullfile(studyd.subjectsDir, 'NP995_09', ''), 'vnumber', 1, 'suffix', '_v1');            
            rb = mlfsl.MultispectralRegistrationBuilder('sessionData', sessd);
            rf = mlraichle.RegistrationFacade(          'sessionData', sessd, 'registrationBuilder', rb);            
            product = rf.registerTalairachOnPet2;
            this.verifyTrue(~isempty(product));
            
            if (this.view)
                product.talairach_on_fdg.view(product.fdg.fqfn);
                product.talairach_on_ho1.view(product.ho1.fqfn);
                product.talairach_on_oo1.view(product.oo1.fqfn);
                product.talairach_on_oc1.view(product.oc1.fqfn);
            end
        end
        function test_masksTalairachOnProduct(this)
            studyd = mlpipeline.StudyDataSingletons.instance('test_raichle');
            sessd = mlraichle.SessionData( ...
                'studyData', studyd, 'sessionPath', fullfile(studyd.subjectsDir, 'NP995_09', ''), 'vnumber', 1, 'suffix', '_v1');            
            rb = mlfsl.MultispectralRegistrationBuilder('sessionData', sessd);
            rf = mlraichle.RegistrationFacade(          'sessionData', sessd, 'registrationBuilder', rb);
            msk = mlfourd.ImagingContext(fullfile(rf.sessionData.sessionPath, 'V1', 'wmparc.mgz'));  
            msk = rf.;
            product.fdg = mlfourd.PETImagingContext(fullfile(this.sessionPath, 'NP995_09fdg_v1_flip2_crop_mcf.nii.gz'));
            product.xfm_tal_on_fdg = fullfile(this.sessionPath, 'T1_on_NP995_09fdg_v1_flip2_crop_434343fwhh_mcf.mat');
            
            masks = rf.masksTalairachOnProduct2(msk, product); 
            if (this.view)
                masks.talairach_on_fdg.view(product.fdg.fqfilename);
            end
            masks.fileprefix = '';
            masks.save;
        end
        function test_repairTalairachOnPetFrame(this)
            studyd = mlpipeline.StudyDataSingletons.instance('test_raichle');
            sessd = mlraichle.SessionData( ...
                'studyData', studyd, 'sessionPath', fullfile(studyd.subjectsDir, 'NP995_09', ''), 'vnumber', 1, 'suffix', '_v1');            
            rb = mlfsl.MultispectralRegistrationBuilder('sessionData', sessd);
            rf = mlraichle.RegistrationFacade(          'sessionData', sessd, 'registrationBuilder', rb); 
            product.fdg = mlfourd.PETImagingContext(fullfile(this.sessionPath, 'NP995_09fdg_v1_flip2_crop_mcf.nii.gz'));
            
            tal1 = rf.repairTalairachOnPetFrame(product.fdg, 23);
            if (this.vew)
                tal1.view(product.fdg.fqfilename);
            end
        end
        function test_repairMaskInSitu(this)            
            studyd = mlpipeline.StudyDataSingletons.instance('test_raichle');
            sessd = mlraichle.SessionData( ...
                'studyData', studyd, 'sessionPath', fullfile(studyd.subjectsDir, 'NP995_09', ''), 'vnumber', 1, 'suffix', '_v1');            
            rb = mlfsl.MultispectralRegistrationBuilder('sessionData', sessd);
            rf = mlraichle.RegistrationFacade(          'sessionData', sessd, 'registrationBuilder', rb);            
            product.fdg = mlpet.PETImagingContext(fullfile(this.sessionPath, 'NP995_09fdg_v1_flip2_crop_mcf.nii.gz'));
            mask = mlfourd.ImagingContext(fullfile(this.sessionPath, ''));
            
            [mask, tal1] = rf.repairMaskInSitu(product.fdg, , , 23);
            if (this.view)
                tal1.view(mask.fqfilename, produt.fdg);
            end
        end
        
        
        
        
        function test_register2(this)
            t1OnHo = this.testFacade.register(this.T1, this.ho);
            this.verifyIC(t1OnHo, 0.933614551530444, 25.2526521461733, 'T1_on_p7377ho1_sumt_919110fwhh');
            if (this.view)
                t1OnHo.view;
                t1OnHo.save;
            end
        end
        function test_register3(this)
            hoOnTr = this.testFacade.register(this.ho, this.oc, this.tr); 
            this.verifyIC(hoOnTr, 0.999597504482372, 56.4147385189332, 'p7377ho1_on_p7377tr1_01_919110fwhh');
            if (this.view)
                hoOnTr.view;
                hoOnTr.save;
            end
        end
        function test_register4(this)
            t2 = mlmr.MRImagingContext(fullfile(this.sessionPath, 'fsl', 't2_default.nii.gz')); %#ok<PROP>
            t1OnT2 = this.testFacade.register(this.T1, this.ho, this.oc, t2); %#ok<PROP>
            this.verifyIC(t1OnT2, 0.999999436208328, 35.1398357741361, 'T1_on_t2_default');
            if (this.view)
                t1OnT2.view;
                t1OnT2.save;
            end
        end
        function test_transformation1(this)   
            xfm = this.testFacade.transformation(this.oc);
            this.verifyEqual(xfm, [myfileprefix(this.oc_fqfn) '.mat']);
        end
        function test_transformation2_existing(this)  
            fn = [myfileprefix(this.oc_fqfn) '_on_p7377tr1_01.mat'];
            mlbash(sprintf('touch %s', fn));
            xfm = this.testFacade.transformation(this.oc, this.tr);            
            this.verifyEqual(xfm, fn);
            deleteExisting(fn);
        end
        function test_transformation2_notexisting(this)  
            fn = [myfileprefix(this.oc_fqfn) '_919110fwhh_on_p7377tr1_01_919110fwhh.mat'];
            deleteExisting(fn);
            xfm = this.testFacade.transformation(this.oc, this.tr);            
            this.verifyEqual(xfm, fn);
            this.verifyTrue(lexist(xfm));
        end
        function test_transformation3(this)     
            smallT1 = mlmr.MRImagingContext( ...
                fullfile(this.sessionPath, 'fsl', 't1_default_on_ho_meanvol_default.nii.gz'));
            xfm = this.testFacade.transformation(this.oc, this.tr, smallT1); 
            this.verifyEqual(xfm, [myfileprefix(this.oc_fqfn) '_919110fwhh_on_ho_meanvol_default.mat']);   
            this.verifyTrue(lexist(xfm, 'file')); 
        end
        function test_transformation4(this)
            smallT1 = mlmr.MRImagingContext( ...
                fullfile(this.sessionPath, 'fsl', 't1_default_on_ho_meanvol_default.nii.gz'));
            xfm = this.testFacade.transformation(this.oc, this.tr, smallT1, this.t2); 
            this.verifyEqual(xfm, [myfileprefix(this.oc_fqfn) '_919110fwhh_on_t2_default.mat']);   
            this.verifyTrue(lexist(xfm, 'file'));         
        end
        function test_transform4(this)
            this.verifyEqual(magic(3), magic(3) + 0.009*dipmin(magic(3)), 'RelTol', 1e-2);
            xfms = { ...
                fullfile(this.petPath, 'p7377oc1_frames', 'testing_oc_on_tr.mat'), ...
                fullfile(this.petPath, 'p7377tr1_frames', 'testing_tr_on_ho.mat'), ...
                fullfile(this.sessionPath, 'fsl', 'testing_ho_on_t2.mat')};
            refs = {this.tr this.ho this.t2};
            t = this.testFacade.transform(this.oc, xfms, refs);
            control_niftid = mlfourd.NIfTId.load( ...
                fullfile(this.petPath, 'p7377oc1_frames', 'Test_RegistrationFacade2.test_transform4.nii.gz'));
            if (this.view)
                t.view(control_niftid.fqfn);
            end
        end
        function test_setup(this)
            this.fatalAssertTrue(isvalid(this.testFacade));
            this.fatalAssertInstanceOf(this.testFacade.sessionData,         'mlpipeline.SessionData');
            this.fatalAssertInstanceOf(this.testFacade.registrationBuilder, 'mlfsl.MultispectralRegistrationBuilder');
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
                'sessionData', this.cachedSessionData_, 'registrationBuilder', this.registrationBuilder_); % handle
            this.addTeardown(@this.cleanFiles);
 		end
    end
    
    %% PRIVATE
    
    properties (Access = private)
        cachedSessionData_
        registrationBuilder_
    end
    
    methods (Access = private)
        function cleanFiles(this)
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

