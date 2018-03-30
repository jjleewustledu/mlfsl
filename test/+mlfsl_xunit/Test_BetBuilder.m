classdef Test_BetBuilder < mlfsl_xunit.Test_mlfsl
	%% TEST_BETBUILDER also tests BetContext, BetStrategy and its concrete subclasses (BetT1, BetT2, ...), and also BetOptions
	%  Usage:  >> runtests tests_dir  
 	%          >> runtests mlfslTest_BetFacade % in . or the matlab path 
 	%          >> runtests mlfslTest_BetFacade:test_nameoffunc 
 	%          >> runtests(mlfslTest_BetFacade, Test_Class2, Test_Class3, ...) 

    %  See also:  package xunit	%  Version $Revision: 2572 $ was created $Date: 2013-08-23 07:16:21 -0500 (Fri, 23 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-23 07:16:21 -0500 (Fri, 23 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_BetBuilder.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: Test_BetBuilder.m 2572 2013-08-23 12:16:21Z jjlee $ 
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
            opts = mlfsl.BetOptions
        end
        function test_betT2(this)
            error('NotImplemented');
        end
        function test_betT1(this)
            error('NotImplemented');
        end
        function test_BetContext(this)
            import mlfsl.*;
            bs = BetContext( ...
                 BetBuilder.create(), ...
                 't1');
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
        
 		function this = Test_BetBuilder(varargin) 
 			this = this@mlfsl_xunit.Test_mlfsl(varargin{:}); 
 		end % Test_BetBuilder (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

