classdef Test_FnirtBuilder  < mlfsl_xunit.Test_mlfsl
	%% TEST_FNIRTBUILDER 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_FnirtBuilder % in . or the matlab path
	%          >> runtests mlfsl.Test_FnirtBuilder:test_nameoffunc
	%          >> runtests(mlfsl.Test_FnirtBuilder, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2377 $ was created $Date: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FnirtBuilder.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_FnirtBuilder.m 2377 2013-03-05 13:46:34Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
	methods 
        function test_warp(this)
            mniroi = this.roidir.warp(this.rois{1});
            assert(isequal(this.mniAtlas{1}, mniroi));
        end
        function test_invwarp(this)
            roi = this.roidir.warp(this.mniAtlas{1});
            assert(isequal(this.rois{1}, roi));
        end
 		function this = Test_FnirtBuilder(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:}); 
        end % ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

