classdef Test_BrainExtractionVisitor < MyTestCase 
	%% TEST_BRAINEXTRACTIONVISITOR  

	%  Usage:  >> runtests tests_dir  
	%          >> runtests mlfsl.Test_BrainExtractionVisitor % in . or the matlab path 
	%          >> runtests mlfsl.Test_BrainExtractionVisitor:test_nameoffunc 
	%          >> runtests(mlfsl.Test_BrainExtractionVisitor, Test_Class2, Test_Class3, ...) 
	%  See also:  package xunit 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	
    properties (Dependent)
        allAs
        allBs
        afp
        afqfp
        afn
        afqfn
        bfp
        bfqfp
        bfn
        bfqfn
    end

    methods %% GET
        function a = get.allAs(this)
            a = {this.afp this.afqfp this.afn this.afqfn};
        end
        function b = get.allBs(this)
            b = {this.bfp this.bfqfp this.bfn this.bfqfn};
        end
        function a = get.afp(this)
            a = this.t1_fp;
        end
        function a = get.afqfp(this)
            a = fullfile(this.fslPath, this.t1_fp);
        end
        function a = get.afn(this)
            a = filename(this.afp);
        end
        function a = get.afqfn(this)
            a = filename(this.afqfp);
        end
        function b = get.bfp(this)
            import mlfsl.*;
            b = [BrainExtractionVisitor.BET_PREFIXES{1} this.t1_fp BrainExtractionVisitor.BET_SUFFIXES{1}];
        end
        function b = get.bfqfp(this)
            b = fullfile(this.fslPath, this.bfp);
        end
        function b = get.bfn(this)
            b = filename(this.bfp);
        end
        function b = get.bfqfn(this)
            b = filename(this.bfqfp);
        end
    end
    
	methods 
 		function test_visitMRAlignmentBuilder(this) 
 			import mlfsl.*; 
            vtor = BrainExtractionVisitor;
            this.t1Bldr = vtor.visitMRAlignmentBuilder(this.t1Bldr);
            this.t1Bldr.product.save;
            this.assertEntropies(this.E_bt1, this.t1Bldr.product.fqfilename);
        end 
        
        function test_unbettedFiles(this)
            this.assertNoneBetted(this.allAs);
        end
        function test_bettedFiles(this)
            this.assertAllBetted(this.allBs);
        end
        function test_isbetted(this) 
            assertTrue(mlfsl.BrainExtractionVisitor.isbetted( ...
                       this.bfqfn));
            assertFalse(mlfsl.BrainExtractionVisitor.isbetted( ...
                       this.afqfn));
        end
        
        
        
        
 		function this = Test_BrainExtractionVisitor(varargin) 
 			this = this@MyTestCase(varargin{:}); 
            this.t1Bldr = mlfsl.AlignmentBuilderPrototype('product', mlfourd.ImagingContext.load(this.t1_fqfn));
            this.bev    = mlfsl.BrainExtractionVisitor;
 		end 
    end 
 
    %% PROTECTED
    
	properties (Access = 'protected')
        bev
        E_bt1 = 1.827426346110560;
        t1Bldr
    end 
    
    methods (Access = 'protected')
        function assertAllBetted(~, cll)
            cellfun(@(b) assertTrue(mlfsl.BrainExtractionVisitor.isbetted(b)), ...
                      cll);
        end
        function assertNoneBetted(~, cll)
            cellfun(@(u) assertFalse(mlfsl.BrainExtractionVisitor.isbetted(u)), ...
                      cll);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

