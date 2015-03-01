classdef Test_ImageDirector < mlfourd_xunit.Test_mlfourd
	%% TEST_IMAGEDIRECTOR 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfourd.Test_ImageDirector % in . or the matlab path
	%          >> runtests mlfourd.Test_ImageDirector:test_nameoffunc
	%          >> runtests(mlfourd.Test_ImageDirector, Test_Class2, Test_Class3, ...)
    
	%  See also:  package xunit
	%  $Revision: 2333 $
 	%  was created $Date: 2013-01-23 12:39:57 -0600 (Wed, 23 Jan 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-23 12:39:57 -0600 (Wed, 23 Jan 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_ImageDirector.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Test_ImageDirector.m 2333 2013-01-23 18:39:57Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    

	properties
        director
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 
        function test_ctor(this)
            disp(this)
        end
        
 		function this = Test_ImageDirector(varargin) 
 			this = this@mlfourd_xunit.Test_mlfourd(varargin{:}); 
            this.director = mlfsl.ImageDirector.createFromModalityPath(this.petPath);
 		end% ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

