classdef Test_MRIBuilder < MyTestCase 
	%% TEST_MRIBUILDER 
    %  Usage:  >> runtests tests_dir  
 	%          >> runtests Test_MRIBuilder % in . or the matlab path 
 	%          >> runtests Test_MRIBuilder:test_nameoffunc 
 	%          >> runtests(Test_MRIBuilder, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit%  Version $Revision: 2645 $ was created $Date: 2013-09-21 17:58:51 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:51 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_MRIBuilder.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: Test_MRIBuilder.m 2645 2013-09-21 22:58:51Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        
        dicomPath
        anMRImagingSession
        anMRImagingSeries
        unpacked
 	end 

	methods 
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed)
        
        function test_buildUnpacked(this) 
            
 			import mlfourd.* mlfsl.*; 
            mrBlder  = MRIBuilder;
            director =   AbstractFslDirector(mrBlder);
            director.unpack;
            assert(isa(director, 'mlfourd.AbstractFslDirector'));   
 		end % test_buildUnpacked 
        function test_createFromDicomPath(this)
        end % test_createFromDicomPath
        function test_queryNativeImagingTypes(this)
            
            import mlfsl.* mlpipeline.*;
            bldr   = MRIBuilder.createFromDicomPath(this.dicomPath);
            report = bldr.queryNativeImagingTypes;
            report.asTextfile(           'test_queryNativeImagingTypes.txt');
            refrep = Reporter.readReport('test_queryNativeImagingTypes_reference.txt');
            assert(eqtool(report.asCell, refrep.asCell));
        end
        
 		function this = Test_MRIBuilder(varargin)             
 			this = this@MyTestCase(varargin{:});            
            this.preferredSession = 2;
 		end 
        function setUp(this)
            if (isempty(this.dicomPath))                
                this.dicomPath = fullfile(getenv('HOME'), 'Local/src/mlcvl/mlfourd/test/data/CDR_OFFLINE', '');
            end
            %this.anMRImagingSession =  mlfsl.MRImagingSession.sessionFromPath(this.dicomPath);
            %this.anMRImagingSeries  = this.anMRImagingSession.structInfo(2);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

