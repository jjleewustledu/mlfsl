classdef Test_AffineDirector < mlfsl_xunit.Test_mlfsl
	%% TEST_AFFINEDIRECTOR 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_AffineDirector % in . or the matlab path
	%          >> runtests mlfsl.Test_AffineDirector:test_nameoffunc
	%          >> runtests(mlfsl.Test_AffineDirector, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  $Revision: 2333 $
 	%  was created $Date: 2013-01-23 12:39:57 -0600 (Wed, 23 Jan 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-23 12:39:57 -0600 (Wed, 23 Jan 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_AffineDirector.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Test_AffineDirector.m 2333 2013-01-23 18:39:57Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        director
 	end

	methods
 		function test_coregister(this) 
            [this.director,xfm] = this.director.coregister(this.tr_fqfn, this.t1_fqfn);
            assertEqual('ptr_on_t1_002.mat', xfm)
            this.assertKLdiv(0.679503042945520, 't1_002', 'ptr_on_t1_002');
 		end 
        function test_coregisterSequence(this)
            [this.director,xfms] = this.director.coregisterSequence(this.ir_fqfn, this.t2_fqfn, this.t1_fqfn);
            assertEqual(2, length(xfms));
            assertEqual(xfms.get(1), 'ir_003_on_t2_004.mat');
            assertEqual(xfms.get(2), 't2_004_on_t1_002.mat');
            this.assertKLdiv(0.080430161070461, 't2_004_on_t1_002', 't1_002');
            this.assertKLdiv(0.006495673374264, 'ir_003_on_t2_004', 't2_004');
        end
 		function this = Test_AffineDirector(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:});
            this.director = mlfsl.AffineDirector.createFromModalityPath(this.petPath);
 		end% ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

