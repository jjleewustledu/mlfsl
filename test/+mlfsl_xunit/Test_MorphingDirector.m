classdef Test_MorphingDirector < mlfsl_xunit.Test_MyAlignmentDirector 
	%% TEST_MORPHINGDIRECTOR 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_MorphingDirector % in . or the matlab path
	%          >> runtests mlfsl.Test_MorphingDirector:test_nameoffunc
	%          >> runtests(mlfsl.Test_MorphingDirector, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision: 2340 $
 	%  was created $Date: 2013-02-01 16:18:26 -0600 (Fri, 01 Feb 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-02-01 16:18:26 -0600 (Fri, 01 Feb 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_MorphingDirector.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Test_MorphingDirector.m 2340 2013-02-01 22:18:26Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        director_on_betstnd
        director_on_stnd
        director_on_t1
        director_on_fsaver
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

        function test_morphSequentially(this)
            %% morphSequentially varargin{1} should be functional; varargin{N} should be structural anatomy
%             
%             argin = {}:
%             N = length(argin); assert(N > 1);
%             [this.morphDirector,xfms] = this.morphDirector.coregisterSequence(argin{:}); 
% 
%             [this.betDirector, bettedVararginN] = this.betDirector.bet(argin{N});
%             [this.morphDirector, xfm1onN]       = this.morphDirector.coregister(argin{1},             bettedVararginN);
%             [this.morphDirector, xfmNonStd]     = this.morphDirector.coregister(bettedVararginN, this.bettedStandard);
%             [this.builder,nlxfm]                = this.builder.morph2standardImage(argin{N}, xfmNonStd);
%             [~, morphedobj]                     = this.applyMorph(                          argin{1}, this.standardImage, nlxfm, xfm1onN);
        end
 		function test_morphSingle2bettedStandard(this) 
 			[~,director] = this.director_on_betstnd.morphSingle2bettedStandard(this.t1Cntxt);
            assertEqual(fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_MNI152_T1_2mm_brain.mat'), director.xfm);
            assertEqual(fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_MNI152_T1_2mm_brain_warpcoef'), director.warp);
            this.assertKLdiv(0.0070938, ...
                        fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_MNI152_T1_2mm_brain_warped.nii.gz'), ...
                        this.bettedStandard_fqfn);
        end 
 		function test_morphSingle2fsaverage2mm(this) 
 			[~,director] = this.director_on_fsaver.morphSingle2bettedStandard(this.t1Cntxt);
            assertEqual(fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_brainmask_2mm.mat'), director.xfm);
            assertEqual(fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_brainmask_2mm_warpcoef'), director.warp);
            this.assertKLdiv(-0.0012577, ...
                        fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_brainmask_2mm_warped.nii.gz'), ...
                        this.fsaverage_fqfn);
        end 
        function test_align2fsaverage1mm(this)
            this.director_on_fsaver.align2fsaverage1mm( ...
                        fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/mm01-020_p7377_2009feb5/fsl/bt1_default_restore_on_brainmask_2mm_warped.nii.gz'));
        end
        function test_morph2fsaverage1mm(this)
            [~,director] = this.director_on_fsaver.morph2fsaverage1mm(this.t1Cntxt, this.t1maskCntxt);
        end
        function test_inverseMorph(this)
%             if (~lexist())
%                 this.test_morph; end
%             [this.director,invxfm,invwarp] = this.director.inverseMorph(this.t1_fqfn);
%             assertEqual('', xfm);
%             assertEqual('', warp);
%             this.assertKLdiv(, '', '');
%             this.assertKLdiv(, '', '');
        end
 		function this = Test_MorphingDirector(varargin) 
 			this = this@mlfsl_xunit.Test_MyAlignmentDirector(varargin{:}); 
            import mlfsl.*;
            this.director_on_betstnd = MorphingDirector( ...
                                       AlignmentDirector( ...
                                       MorphingBuilder('reference', this.bettedStandardCntxt)));
            this.director_on_stnd    = MorphingDirector( ...
                                       AlignmentDirector( ...
                                       MorphingBuilder('reference', this.standardCntxt))); 
            this.director_on_t1      = MorphingDirector( ...
                                       AlignmentDirector( ...
                                       MorphingBuilder('reference', this.standardCntxt)));
            this.director_on_fsaver  = MorphingDirector( ...
                                       AlignmentDirector( ...
                                       MorphingBuilder('reference',      this.fsaverageCntxt, ...
                                                       'bettedStandard', this.fsaverageCntxt)));                                 
        end % ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

