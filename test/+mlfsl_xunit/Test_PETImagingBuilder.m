classdef Test_PETImagingBuilder < TestCase 
	%% TEST_PETIMAGINGBUILDER \n	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_PETImagingBuilder % in . or the matlab path 
 	%          >> runtests Test_PETImagingBuilder:test_nameoffunc 
 	%          >> runtests(Test_PETImagingBuilder, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2645 $ was created $Date: 2013-09-21 17:58:51 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:51 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_PETImagingBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_PETImagingBuilder.m 2645 2013-09-21 22:58:51Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties
        srcroot        = '/Users/jjlee/Local/src';
        aPETImagingBuilder  = 0;
        butCorr        = true;
        cbfnii         = 0;
        cbvnii         = 0;
        mttnii         = 0;
        oefnii         = 0;
        cmro2nii       = 0;
        pnum           = 'p7377';
        imaging          = 0;
        doswap         = 0;
        totest         = {0 0 0 1 0 0};
    end % properties 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 
 		
 		function test_(this) 
 			%% TEST_  
 			%  Usage:   
 			import mlfourd.*; 
 		end % test_ 
        
        function setUp(this)
            this.imaging = mlfsl.ImagingComponent.createStudyFromPnum(this.pnum);
            cd(fullfile(this.srcroot, 'mlcvl/mlfourd/test/data'));            
        end
        
        %% TEST_NULL assures that xunit assert functions are working correctly
        function test_null(this)
            assertEqual(1,1);
        end        
        function test_factory(this)
            this.cbfnii = mlfourd.PETImagingBuilder.PETfactory('p7395', 'cbf');
            disp(['Test_PETImagingBuilder.test_factory:   displaying CBF from ' this.cbfnii.fileprefix]);
            this.cbfnii.showDipimg;
        end 
        
        %% TEST_LIGHTBOX
%         function this = test_lightbox(this)
%
%             import mlfourd.*;
%             if (~this.totest{6}) return; end
%             cd(this.imaging.pet_path);
%             CLIM = 0.45;
%             
%             petoef = mlfourd.NIfTI.load(['petoef_on_oef'  NIfTIInterface.FILETYPE_EXT]);
%             figure
%             montage(reshape(flip4d(petoef.img, 'xt'), [64 48 1 24]))
%             colormap('jet')
%             colorbar
%             set(gca, 'CLim', [0 CLIM]);
%             set(gca, 'FontSize', 14);
%             title([this.imaging.pnum ' PET OEF 16 mm blur'], 'FontSize', 14);
%             
%             oefm   = mlfourd.NIfTI.load(['oefm'           NIfTIInterface.FILETYPE_EXT]);
%             figure
%             montage(reshape(flip4d(oefm.img, 'xt'), [64 48 1 24]))
%             colormap('jet')
%             colorbar
%             set(gca, 'CLim', [0 CLIM]);
%             set(gca, 'FontSize', 14);
%             title([this.imaging.pnum ' MR OEF'], 'FontSize', 14);
%             
%             oefmgm = mlfourd.NIfTI.load(['oefm_g16petmsk' NIfTIInterface.FILETYPE_EXT]);
%             figure
%             montage(reshape(flip4d(oefmgm.img, 'xt'), [64 48 1 24]))
%             colormap('jet')
%             colorbar
%             set(gca, 'CLim', [0 CLIM]);
%             set(gca, 'FontSize', 14);
%             title([this.imaging.pnum ' MR OEF 16 mm blur'], 'FontSize', 14);
%         end % function test_lightbox
%         
%         function this = test_cmro2(this)
%             if (~this.totest{5}) return; end
%             [nii converter] = mlfourd.PETImagingBuilder.PETfactory(this.imaging.pnum);
%             if (isNIfTI(this.cbfnii)); converter.cbfnii = this.cbfnii; end
%             if (isNIfTI(this.cbvnii)); converter.cbvnii = this.cbvnii; end
%             if (isNIfTI(this.oefnii)); converter.oefnii = this.oefnii; end
%             this.cmro2nii = converter.make_cmro2nii;
%             disp(['test_cmro2:   displaying CMRO2 from ' this.cmro2nii.fileprefix]);
%             cmro2img     = dip_image(this.cmro2nii.img);
%             dipshow(cmro2img, 'percentile', 'grey')
%             disp(['saving '         this.imaging.pet_path 'petcmro2' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%             save_nii(this.cmro2nii, [this.imaging.pet_path 'petcmro2' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%         end % function test_cmro2
%         
%         function this = test_oef(this)
%             if (~this.totest{4}) return; end
%             [nii converter] = mlfourd.PETImagingBuilder.PETfactory(this.imaging.pnum);
%             if (isNIfTI(this.cbfnii)); converter.cbfnii = this.cbfnii; end
%             if (isNIfTI(this.cbvnii)); converter.cbvnii = this.cbvnii; end
%             this.oefnii = converter.make_oefnii;
%             disp(['test_oef:   displaying OEF from ' this.oefnii.fileprefix]);
%             oefimg     = dip_image(this.oefnii.img);
%             dipshow(oefimg, 'percentile', 'grey')
%             disp(['saving '       this.imaging.pet_path 'petoef' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%             save_nii(this.oefnii, [this.imaging.pet_path 'petoef' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%             msknii            = this.oefnii;
%             msknii.img        = double(dip_image(msknii.img) > 0);
%             msknii.untouch    = 0;
%             msknii.fileprefix = 'petmsk';
%             save_nii(msknii, [this.imaging.pet_path msknii.fileprefix NIfTIInterface.FILETYPE_EXT]);
%         end % function test_oef
%         
%         
%         function this = test_cbv(this)
%             if (~this.totest{2}) return; end
%             [this.cbvnii converter] = mlfourd.PETImagingBuilder.PETfactory(this.imaging.pnum, 'cbv');
%             disp(['test_cbv:   displaying CBV from ' this.cbvnii.fileprefix]);
%             dipshow(dip_image(this.cbvnii.img), 'percentile', 'grey')
%             disp(['saving '       this.imaging.pet_path 'petcbv' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%             save_nii(this.cbvnii, [this.imaging.pet_path 'petcbv' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%         end % function test_cbv
%         
%         function this = test_mtt(this)
%             if (~this.totest{3}) return; end
%             [nii converter] = mlfourd.PETImagingBuilder.PETfactory(this.imaging.pnum);
%             if (isNIfTI(this.cbfnii)); converter.cbfnii = this.cbfnii; end
%             if (isNIfTI(this.cbvnii)); converter.cbvnii = this.cbvnii; end
%             this.mttnii = converter.make_mttnii;
%             disp(['test_mtt:   displaying MTT from ' this.mttnii.fileprefix]);
%             mttimg     = dip_image(this.mttnii.img);
%             dipshow(mttimg, 'percentile', 'grey')
%             disp(['saving '       this.imaging.pet_path 'petmtt' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%             save_nii(this.mttnii, [this.imaging.pet_path 'petmtt' this.imaging.pet_ref_series NIfTIInterface.FILETYPE_EXT]);
%         end % function test_mtt  

        function this = Test_PETImagingBuilder(varargin)
 			this = this@TestCase(varargin{:}); 
 		end % Test_PETImagingBuilder (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

