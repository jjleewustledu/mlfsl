classdef ImageDirector
	%% IMAGEDIRECTOR is the client interface that contains construction information.  Representation information should
    %  be reserved for FslBuilder and its concrete subclasses
    %
    %  Version $Revision: 2481 $ was created $Date: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/ImageDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: ImageDirector.m 2481 2013-08-18 06:44:27Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
   
	properties (Dependent)
        adc
        asl
        builder
        diff
        epi
        epiMeanvol
        gre
        ho
        hoMeanvol
        ir
        lastProduct
        logger
        oc
        oo
        ooMeanvol
        products
        t1
        t2
    end
    
    methods %% set/get 
        function im = get.adc(this)
            im = ;
        end
        function im = get.asl
            function b =  get.builder
        function im = get.diff(this)
            im = ;
        end
        function im = get.epi(this)
            im = ;
        end
        function im = get.epiMeanvol(this)
            im = ;
        end
        function im = get.gre(this)
            im = ;
        end
        function im = get.ho(this)
            im = ;
        end
        function im = get.hoMeanvol(this)
            im = ;
        end
        function im = get.ir(this)
            im = ;
        end
        function prd  = get.lastProduct(this)
            prd = this.builder_.lastProduct;
        end
        function im = get.logger(this)
            im = ;
        end
        function im = get.oc(this)
            im = ;
        end
        function im = get.oo(this)
            im = ;
        end
        function im = get.ooMeanvol(this)
            im = ;
        end
        function prd  = get.products(this)
            prd = this.builder_.products;
        end
        function im = get.t1(this)
            im = ;
        end
        function im = get.t2(this)
            im = ;
        end
    end
    
    methods
        function       visualCheck(this)
            assert(isa(this.builder_, 'mlfsl.FslBuilder'));
            this.builder_.visualCheck(this.products);
        end
        function fn  = xfmName(this, varargin)
            fn = mlfsl.FslBuilder.xfmName(varargin{:});
        end
        function obj = imageObject(this, varargin)
            assert(isa(this.builder_, 'mlfsl.FslBuilder'));
            obj = this.builder_.imageObject(varargin{:});
        end
    end

    %% PROTECTED
        
    properties (Access = 'protected')
        builder_
    end 
    
    methods (Access = 'protected')
 		function this = ImageDirector(bldr) 
            assert(isa(bldr, 'mlfsl.FslBuilder'));
            this.builder_ = bldr;
        end 
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

