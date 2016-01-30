classdef Test_FlirtVisitor < matlab.unittest.TestCase
	%% TEST_FLIRTVISITOR 

	%  Usage:  >> results = run(mlfsl_unittest.Test_FlirtVisitor)
 	%          >> result  = run(mlfsl_unittest.Test_FlirtVisitor, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 07-Dec-2015 20:49:18
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/test/+mlfsl_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		registry
 		testObj
    end
    
    properties (Constant)
        kldiv_t1_t2      = 0.088875119095288;
        kldiv_t1_t2ont1  = 0.898098883035243;
          klH_t1_t2ont1  = 0.304083672612801;
          klH_primitives = { 0.272639207578218 ...
                             0.00298888408257953 ...
                             1.02126351281633 ...
                             0.00148046777301085 ...
                             0 ...
                             2.67380480758806e-05 };
        primitives       = { 'gre_006' 'ir_003' 'ptr' 't1_018' 't2_004' 'tof_013' };
        invertxfm_matrix = [ 1.0063   -0.0246   -0.0015   17.2640; ...
                             0.0251    0.9810    0.0320  -21.0375; ...
                             0.0039   -0.0370    1.0001  -68.8645; ...
                             0         0         0         1.0000];
        concatxfm_matrix = [ -0.0132    0.0336    1.0330   89.6728; ...
                             -0.9852   -0.3085    0.0073  285.8070; ...
                              0.3002   -1.0400    0.0584  137.7130; ...
                              0         0         0         1.0000 ];
        applyxfm_matrix  = [ 0.9913927758   0.0256578013  0.0007383069831 -16.50196736  ...
                            -0.02624065483  1.018564634  -0.0346606522     19.67107345  ...
                            -0.005403264193 0.03965201842 1.000845366      69.27308156  ...
                             0  0  0  1  ];
        tol_type         =  'absolute';
        tol              =   0.0001
    end
    
    properties (Dependent)
        fqPrimitives
    end
    
	properties
        srcroot = '/Users/jjlee/Local/src';
        flirtb
    end

	methods (Test)
 		function test_afun(this)
 			import mlfsl.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
 		function test_constructRegistered(this)
 			%% TEST_CONSTRUCTREGISTERED acts as the client to FslBuilder,
            %  which is both a director and a builder
            %  Tests:  flirt via FslBuilder.constructRegistered
            
 			import mlmr.* mlpet.*; 
             
            mrDirector  = MRIDirector.createFromBuilder(MRIBuilder);
            irOnT1   = mrDirector.constructRegistered(this.ir, this.t1);
            assert(eqtool(this.irRef, irOnT1));
             
            petDirector = PetDirector.createFromBuilder(PetBuilder);
            petoefOnT1  = petDirector.constructRegistered(this.petoef, this.t1);
            assert(eqtool(this.petoefOnT1, petoefOnT1));
 		end % test_constructRegistered
        
        function test_concatTransformsByOptions(this)
            opts        = mlfsl.ConvertXfmOptions;
            opts.AtoB   = this.flirtb.xfmName('t2_004', 't1_002');
            opts.BtoC   = this.flirtb.xfmName('t1_002',  this.flirtb.standardReference);
            this.flirtb = this.flirtb.concatTransforms(opts);
            assertElementsAlmostEqual(this.concatxfm_matrix, ...
                                      this.loadMatrix('t2_004', this.flirtb.standardReference), ...
                                      this.tol_type, this.tol);
        end        
        function test_invertxfm(this)
            opts         = mlfsl.ConvertXfmOptions;
            opts.inverse = this.flirtb.xfmName('t2_004', 't1_002');   
            this.flirtb  = this.flirtb.invertTransform(opts);
            assertElementsAlmostEqual(this.invertxfm_matrix, ...
                                      this.loadMatrix('t1_002', 't2_004'), ...
                                      this.tol_type, this.tol);
        end
        function test_applyTransformByOptions(this)
            import mlfsl_xunit.*;
            opts     = mlfsl.FlirtOptions;
            opts.ref = fullfilename(this.fslPath, 't1_002');
            opts.in  = fullfilename(this.fslPath, 't2_004');
            opts.out = fullfilename(this.fslPath, 'test_applyxfm');
            this.flirt = this.flirtb.applyTransform(opts);            
            assertElementsAlmostEqual(this.applyxfm_matrix, ...
                                      this.loadMatrix('t1_002', 't2_004'), ...
                                      this.tol_type, this.tol);
        end
        function test_coregisterByOptions(this)
            import mlfsl_xunit.* mlfsl.*; 
            flirto = FlirtOptions;
            flirto.in = 't2_004';
            flirto.ref = 't1_002';
            flirto.out = fullfilename(this.fslPath, 'test_flirt');
            this.flirtb = this.flirtb.coregister(flirto);
            assertElementsAlmostEqual( ...
                0.304083672612801, Test_FlirtBuilder.filenames2KL('t1_002.nii.gz', 'test_flirt.nii.gz'));
        end
        function test_coregister(this)
            import mlfsl_xunit.* mlfsl.*; 
            this.flirtb = this.flirtb.coregister('t2_004', 't1_002');
            assertElementsAlmostEqual( ...
                0.304083672612801, Test_FlirtBuilder.filenames2KL('t1_002.nii.gz', 't2_004_on_t1_002.nii.gz'));
        end
        function test_ctor(this)
            assertTrue(isa(this.flirtb, 'mlfsl.FlirtBuilder'));
        end
 	end

 	methods (TestClassSetup)
 		function setupFlirtVisitor(this)
 			import mlfsl.*;
 			this.testObj = FlirtVisitor;
 		end
 	end

 	methods (TestMethodSetup)
 	end

    %% PROTECTED
    
    methods (Access = 'protected')
        function assertFlirted(this, s, r, opts)
            assertEqual(0, s, r);
            this.assertKLH_t1_t2ont1(opts);
        end
        
        
        
        function mat  = loadMatrix(this, fp, fp2)
            mat = load(this.flirtb.xfmName(fp, fp2), '-ascii');
        end
        function assertKLdiv_t1_t2(this, opts)
            assert(isfield(opts, 'ref'));
            assert(isfield(opts, 'in'));            
            mlfsl_xunit.Test_FlirtBuilder.assertKLdiv( this.kldiv_t1_t2ont1, opts.ref, opts.in );
        end
        function assertKLdiv_t1_t2ont1(this, opts)
            assert(isfield(opts, 'ref'));
            assert(isfield(opts, 'out'));            
            mlfsl_xunit.Test_FlirtBuilder.assertKLdiv( this.kldiv_t1_t2ont1, opts.ref, opts.out );
        end
        function assertKLH_t1_t2ont1(this, opts)
            assert(isfield(opts, 'ref'));
            assert(isfield(opts, 'out'));            
            mlfsl_xunit.Test_FlirtBuilder.assertKLdiv( this.klH_t1_t2ont1, opts.ref, opts.out );
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

