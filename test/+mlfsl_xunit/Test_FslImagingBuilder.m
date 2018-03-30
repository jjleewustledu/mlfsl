classdef Test_FslImagingBuilder < mlfourd_xunit.Test_ImagingBuilder 
	%% TEST_FSLIMAGINGBUILDER 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_FslImagingBuilder % in . or the matlab path 
 	%          >> runtests Test_FslImagingBuilder:test_nameoffunc 
 	%          >> runtests(Test_FslImagingBuilder, Test_Class2, Test_Class3, ...) 
    %  Use cases: 
    %  -  
 	%  See also:  package xunit%  Version $Revision: 2478 $ was created $Date: 2013-08-18 01:42:23 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 01:42:23 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FslImagingBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_FslImagingBuilder.m 2478 2013-08-18 06:42:23Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_constructRegistered(this) 
 			
 			%% TEST_CONSTRUCTREGISTERED acts as the client to FslImagingBuilder,
            %  which is both a director and a builder
            %  Tests:  flirt via FslImagingBuilder.constructRegistered
            
 			import mlfsl.*; 
             
            mrBuilder  = MrImagingBuilder;
            mrDirector =   AbstractImageDirector(mrBuilder);
            irOnT1   = mrDirector.constructRegistered(this.ir, this.t1);
            assert(eqtool(this.irRef, irOnT1));
             
            petBuilder  = PetImagingBuilder;
            petDirector =    AbstractImageDirector(petBuilder);
            petoefOnT1  = petDirector.constructRegistered(this.petoef, this.t1);
            assert(eqtool(this.petoefOnT1, petoefOnT1));
 		end % test_constructRegistered
        
        
 		function this = Test_FslImagingBuilder(varargin) 
 			this = this@mlfourd_xunit.Test_ImagingBuilder(varargin{:}); 
 		end % Test_FslImagingBuilder (ctor)         
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

