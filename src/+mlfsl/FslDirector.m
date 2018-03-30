classdef FslDirector
	%% FSLDIRECTOR is the client's director that specifies algorithms for builder patterns for FSL-genereated products.
    %  It redirects all its methods and properties to the encapsulated builder.
    %  This class may be removed in a future release.
	
	%  Version $Revision: 2481 $ was created $Date: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslDirector.m $
 	%  Developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslDirector.m 2481 2013-08-18 06:44:27Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
	properties (Dependent)
        products
        lastProduct
        fslPath
    end
    
    methods %% set/get 
        function prd  = get.products(this)
            prd = this.builder_.products;
        end
        function prd  = get.lastProduct(this)
            prd = this.builder_.lastProduct;
        end
        function pth  = get.fslPath(this)
            pth = this.builder_.fslPath;
        end
    end
    
    methods
        function       visualCheck(this)
            this.builder_.visualCheck(this.products);
        end
        function fn  = xfmName(~, varargin)
            fn = mlfsl.FslBuilder.xfmName(varargin{:});
        end
        function obj = imageObject(this, varargin)
            obj = this.builder_.imageObject(varargin{:});
        end
    end

    %% PROTECTED
        
    properties (Access = 'protected')
        builder_
    end
        
    methods (Access = 'protected')
 		function this = FslDirector(bldr) 
            assert(isa(bldr, 'mlfsl.FslBuilder'));
            this.builder_ = bldr;
        end 
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

