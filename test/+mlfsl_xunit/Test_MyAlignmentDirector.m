classdef Test_MyAlignmentDirector < MyTestCase 
	%% TEST_MYALIGNMENTDIRECTOR  

	%  Usage:  >> runtests tests_dir  
	%          >> runtests mlfsl.Test_MyAlignmentDirector % in . or the matlab path 
	%          >> runtests mlfsl.Test_MyAlignmentDirector:test_nameoffunc 
	%          >> runtests(mlfsl.Test_MyAlignmentDirector, Test_Class2, Test_Class3, ...) 
	%  See also:  package xunit 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
    properties
        E_diffusion = { 2.212584730546838 1.978445464593273 };
        E_ep2dMcf   =   4.872446363605402;
        E_ep2dMean  =   4.486447584822766;
        E_indep     = { 2.823928199240487 3.117361156097319 };
        E_perfusion =   2.900899603213688;
        E_sequen    = { 2.900899603213688 3.117361156097319 4.318537132583254 };
        E_t2ont1    =   3.117361156097319;
        E_iront1    =   0;
    end
    
    properties (Dependent)
        bettedStandard_fqfn
        bettedStandardCntxt
        standard_fqfn
        standardCntxt
        fsaverage_fqfn
        fsaverageCntxt
    end

    methods %% GET/SET
        function fn = get.bettedStandard_fqfn(this) %#ok<MANU>
            fn = fullfile(getenv('FSLDIR'), 'data/standard', 'MNI152_T1_2mm_brain.nii.gz');
        end
        function ic = get.bettedStandardCntxt(this)
            ic = mlfourd.ImagingContext.load(this.bettedStandard_fqfn);
        end
        function fn = get.standard_fqfn(this) %#ok<MANU>
            fn = fullfile(getenv('FSLDIR'), 'data/standard', 'MNI152_T1_2mm.nii.gz');
        end
        function ic = get.standardCntxt(this)
            ic = mlfourd.ImagingContext.load(this.standard_fqfn);
        end
        function fn = get.fsaverage_fqfn(this) %#ok<MANU>
            fn = fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/fsaverage_2013nov18/fsl/brainmask_2mm.nii.gz');
        end
        function ic = get.fsaverageCntxt(this)
            ic = mlfourd.ImagingContext.load(this.fsaverage_fqfn);
        end
    end

    methods (Access = 'protected')
        function this = Test_MyAlignmentDirector(varargin)
            this = this@MyTestCase(varargin{:});
            cd(this.sessionPath);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

