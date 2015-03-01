classdef Test_FslFacade < mlfsl_xunit.Test_mlfsl
	%% TEST_FSLFACADE  
    %  Usage:  runtests mlfsl_xunit.Test_FslFacade
    %          runtests mlfsl_xunit.Test_FslFacade:test_function
    %
	%% Version $Revision$ was created $Date$ by $Author$  
	%% and checked into svn repository $URL$ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id$ 

	properties
        fslf
    end

	methods 

        function test_ensureOnReference(this)
            import mlfsl.*;
            assertEqual('t2_004_on_t1_002.nii.gz', ...
                FslFacade.ensureOnReference('t2_004.nii.gz', 't1_002.nii.gz'));
        end
        function test_fslstats(this)
            mlfsl_xunit.Test_FslFacade.assertEntropies(0.304083672612801, this.fslFullfilename('t1_002'));
        end
        function test_timeIndependent(this)
            dt = mlsystem.DirTool(this.fslFullfilename('ep2d*'));
            assertEqual( ...
                { this.fslFullfilename('ep2d_010.nii.gz') ...
                  this.fslFullfilename('ep2d_011.nii.gz') }, ...
                  mlfsl.FlirtFacade.notFlirted(this.fslf.timeIndependent(dt.fqfns)));
        end
        function test_brightest(this)
            dt = mlsystem.DirTool( ...
                        this.fslFullfilename('ep2d*'));
            assertEqual(this.fslFullfilename('ep2d_010.nii.gz'), mlchoosers.ImagingChoosers.brightest(dt.fqfns));
        end
        
        function test_t1(this)
            assertEqual('t1_002',        this.fslf.t1);
            assertEqual('t1_002.nii.gz', this.fslf.t1('fn'));
            assertEqual( ...
                this.fslFullfilename('t1_002'), ...
                this.fslf.t1('fqfp')); 
            assertEqual( ...
                this.fslFullfilename('t1_002.nii.gz'), ...
                this.fslf.t1('fqfn')); 
        end
        function test_h15o(this)
            assertEqual({'cho' 'pho'}, this.fslf.h15o);
        end
        function test_ep2d(this)
            assertEqual('ep2d_009', this.fslf.ep2d);    
        end
        function test_reference(this)
            assertEqual(this.t1_fqfn, this.fslf.reference.fqfilename);
        end
        function test_log(this)
        end
        function test_fslPath(this)
            assertEqual(this.fslPath, this.fslf.fslPath);
        end 
        
        function test_ctor(this)
        end
        function this = Test_FslFacade(varargin)
            this = this@mlfsl_xunit.Test_mlfsl(varargin{:});
        end 
        function setUp(this)
            import mlfsl.* mlfourd.*;
            this.fslf = FslFacade( ...
                        MRIConverter.creation(this.modalityPath));
            cd(this.sessionPath);
        end        
        function tearDown(this)
        end         
	end 
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
