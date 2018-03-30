classdef Test_BetFacade < mlfsl_xunit.Test_FlirtFacade 
	%% TEST_BETFACADE 
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests mlfslTest_BetFacade % in . or the matlab path 
 	%          >> runtests mlfslTest_BetFacade:test_nameoffunc 
 	%          >> runtests(mlfslTest_BetFacade, Test_Class2, Test_Class3, ...) 
 	%  See also:  package xunit	%  Version $Revision: 2377 $ was created $Date: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_BetFacade.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: Test_BetFacade.m 2377 2013-03-05 13:46:34Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Dependent)
        bettedT1
        unbettedT1
    end
    
	methods 
        
        function fn = get.bettedT1(this)
            import mlfsl.*;
            [p,f,e] = fileparts(this.t1_fqfn);
            fn      = fullfile(p, BetFacade.bettedFilename([f e]));
        end
        function fn = get.unbettedT1(this)
            fn = this.t1_fqfn;
        end
        
        function test_bet(this)            
            error('NotImplemented');
        end
        function test_betFlair(this)
            error('NotImplemented');
        end
        function test_betT2(this)
            error('NotImplemented');
        end
        function test_betT1(this)
            error('NotImplemented');
        end
        function test_unbetted3Names(this)
            names     = { this.bettedT1 this.bettedT1 this.bettedT1 };
            expected  = { this.unbettedT1 this.unbettedT1 this.unbettedT1 };
            processed = mlfsl.BetFacade.unbettedFilename(names);
            assertEqual(expected, processed);
        end
        function test_betted3Names(this)
            expected  = { this.bettedT1 this.bettedT1 this.bettedT1 };
            names     = { this.unbettedT1 this.unbettedT1 this.unbettedT1 };
            processed = mlfsl.BetFacade.bettedFilename(names);
            assertEqual(expected, processed);
        end        
        function test_bettedFilename(this)
            expected  = fullfile(this.fslPath, 'bt1_002.nii.gz');
            processed = char(mlfsl.BetFacade.bettedFilename(this.reference));
            assertEqual(expected, processed);
        end
        
 		function this = Test_BetFacade(varargin) 
 			this = this@mlfsl_xunit.Test_FlirtFacade(varargin{:}); 
 		end % Test_BetFacade (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

