classdef Test_Np755Registry < TestCase 
	%% TEST_NP755REGISTRY 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_Np755Registry % in . or the matlab path 
 	%          >> runtests Test_Np755Registry:test_nameoffunc 
 	%          >> runtests(Test_Np755Registry, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	
    %  Version $Revision: 1653 $ was created $Date: 2012-08-23 23:57:10 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 23:57:10 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/Shared/Library/SVNRepository/mpackages/mlfsl/test/+mlfsl_xunit/Test_Np755Registry.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_Np755Registry.m 1653 2012-08-24 04:57:10Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

 		function this = Test_Np755Registry(varargin) 
 			this = this@TestCase(varargin{:}); 
 		end % Test_Np755Registry (ctor) 
 		function test_(this) 
 			%% TEST_  
 			%  Usage:   
 			import mlfsl.*; 
 		end % test_ 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

