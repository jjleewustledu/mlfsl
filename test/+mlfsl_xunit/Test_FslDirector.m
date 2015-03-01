classdef Test_FslDirector < mlfsl_xunit.Test_mlfsl
	%% TEST_FSLDIRECTOR 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_FslDirector % in . or the matlab path
	%          >> runtests mlfsl.Test_FslDirector:test_nameoffunc
	%          >> runtests(mlfsl.Test_FslDirector, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 2314 $ was created $Date: 2013-01-12 17:53:38 -0600 (Sat, 12 Jan 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-12 17:53:38 -0600 (Sat, 12 Jan 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FslDirector.m $
 	%  Developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Test_FslDirector.m 2314 2013-01-12 23:53:38Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, Constant, Dependent, Hidden, Transient)
        
        fsldirector
        fslbuilder
    end
    
    properties (Dependent)
        modalityPath
    end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 
        
        function pth = get.modalityPath(this)
            assert(lexist(this.mrPath, 'dir'));
            pth = this.mrPath;
        end

 		function test_createFromBuilder(this)
            assert(isa(this.fsldirector, 'mlfsl.FslDirector'));
            assertEqual(this.fsldirector, mlfsl.FslDirector.createFromBuilder(this.fslbuilder));
 		end 
 		function this = Test_FslDirector(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:}); 
            import mlfsl.*;
            this.fslbuilder  = FslBuilder.createFromModalityPath(this.modalityPath);
            this.fsldirector = FslDirector.createFromModalityPath(this.modalityPath);
 		end% ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

