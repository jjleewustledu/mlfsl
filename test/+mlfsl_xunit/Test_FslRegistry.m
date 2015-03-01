classdef Test_FslRegistry  < TestCase
	%% TEST_FSLREGISTRY 
	%  Usage:  >> runtests tests_dir 
	%          >> runtests mlfsl.Test_FslRegistry % in . or the matlab path
	%          >> runtests mlfsl.Test_FslRegistry:test_nameoffunc
	%          >> runtests(mlfsl.Test_FslRegistry, Test_Class2, Test_Class3, ...)
	%  See also:  package xunit

	%  Version $Revision: 1653 $ was created $Date: 2012-08-23 23:57:10 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2012-08-23 23:57:10 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfsl/test/+mlfsl_xunit/Test_FslRegistry.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: Test_FslRegistry.m 1653 2012-08-24 04:57:10Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, Constant, Dependent, Hidden, Transient)
 	end

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_(this) 
 			import mlfsl.*; 
 		end 
 		function this = Test_FslRegistry(varargin) 
 			this = this@ < TestCase(varargin{:}); 
 		end% ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

