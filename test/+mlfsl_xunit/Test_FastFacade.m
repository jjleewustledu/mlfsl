classdef Test_FastFacade < mlfsl_xunit.Test_mlfsl
	%% TEST_FASTFACADE  
    %  Usage:  runtests mlfsl_xunit.Test_FastFacade
    %          runtests mlfsl_xunit.Test_FastFacade:test_function
    %
	%% Version $Revision: 2377 $ was created $Date: 2013-03-05 07:46:34 -0600 (Tue, 05 Mar 2013) $ by $Author: jjlee $  
	%% and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/test/+mlfsl_xunit/trunk/Test_FastFacade.m $ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id: Test_FastFacade.m 2377 2013-03-05 13:46:34Z jjlee $ 

	properties
        fastf
    end

	methods
        
        function test_fastWithFilenames(this)
            this.fastf.fastWithFilenames('t1_002', 't2_004', 'ir_003', 'dwi_008', 'gre_006', 'tof_013');
            for c = 1:this.fastf.Nclasses
                assertTrue(lexist());
            end
        end
        %% ctor, test setup, test teardown
        
        function this = Test_FastFacade(varargin)
            this = this@mlfsl_xunit.Test_mlfsl(varargin{:});
        end 
        function setUp(this)
            import mlfsl.* mlfourd.*;
            this.fastf = FastFacade( ...
                         MRIConverter.createFromModalityPath(this.modalityPath));
            cd(this.sessionPath);
        end        
        function tearDown(this)
        end 
        
	end 
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
