classdef FslContext < handle
	%% FSLSTRATEGY provides the baseclass context of a strategy design pattern with fsl-related strategies,
    %  dispatching properties & methods to concrete classes that subclass abstract strategies.
    %  FslContext must be handle so as to allow run-time changes of concrete strategies.
    
	%  $Revision: 2580 $
 	%  was created $Date: 2013-08-29 02:57:58 -0500 (Thu, 29 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-29 02:57:58 -0500 (Thu, 29 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslContext.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslContext.m 2580 2013-08-29 07:57:58Z jjlee $


    properties (Dependent)
       theStrategy
       products
       lastProduct
    end

    methods %% set/get
       function st = get.theStrategy(this)
           assert(~isempty(this.stategyType_));
           st = this.theStrategy_;
       end
       function ps = get.products(this)
           ps = this.theStrategy.products;
       end
       function lp = get.lastProduct(this)
           lp = this.theStrategy.lastProduct;
       end
    end
    
    methods (Abstract)
        this = setStrategy(this, choice)
    end
    
	methods 
 		function thish = FslContext(bldr, varargin)
           %% FSLSTRATEGY is a strategy pattern for selcting processing variationsw
           %  Usage:   obj = FslContext(strategy_label, image_builder) 
           
           p = inputParser;
           addRequired(p, 'bldr', @(x) isa(x, 'mlfourd.ImageBuilder'));
           addOptional(p, 'strat', 'default', @ischar);
           parse(p, bldr, varargin{:});
           
           thish.builder_ = p.Results.bldr;
           thish.setStrategy(p.Results.strat);
 		end %  ctor  
 	end 

    properties (Access = 'protected')
        builder_
        theStrategy_ = {};
    end
   
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

