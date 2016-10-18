classdef FslmathsVisitor < mlfsl.FslVisitor 
	%% FSLMATHSVISITOR gathers behaviors using FSL's fslmaths.
    %  Data are received as builder objects, acted upon, then returned as builder objects.  

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslMathsVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FslMathsVisitor.m 2629 2013-09-16 06:19:00Z jjlee $  	 

	properties  		 
 	end 

	methods 
 		function this = FslmathsVisitor(varargin) 
 			this = this@mlfsl.FslVisitor(varargin{:}); 
 		end 
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')        
        function this = fslmaths__(this, opts)
            assert(isa(opts, 'mlfsl.FslmathsOptions'));
            this.cmd('fslmaths', opts);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

