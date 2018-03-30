classdef Test_AbstractFslDirector < TestCase 
	%% TEST_ABSTRACTFSLDIRECTOR 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_AbstractFslDirector % in . or the matlab path 
 	%          >> runtests Test_AbstractFslDirector:test_nameoffunc 
 	%          >> runtests(Test_AbstractFslDirector, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2377 $ was created $Date: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_AbstractFslDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_AbstractFslDirector.m 2377 2013-03-05 13:46:34Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        mprInfo
        dicomPath
        unpackPath
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 

 		function test_createFromBuilder(this) 
 			%% TEST_CREATEFROMBUILDER 
 			%  Usage:   
 			import mlfourd.* mlfsl.*; 
            mr = MRImagingComponent.createSeries(this.dicomPath); % simplest
            b  = FslBuilder.createFromImaging(mr);
            d  = AbstractFslDirector.createFromBuilder(b);
            assert(false);
 		end % test_createFromBuilder 
 		function this = Test_AbstractFslDirector(varargin) 
 			this = this@TestCase(varargin{:}); 
            this.mprInfo = struct( ...
                'dicom_path', this.dicomPath, ...
                'target_path', this.unpackPath, ...
                'index', 2, ...
                'name', 'mpr', ...
                'type', 'mgz', ...
                'new_name', '001.mgz');
 		end % Test_AbstractFslDirector (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

