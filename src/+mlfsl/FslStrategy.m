classdef FslStrategy	
    % Interface / Abstract Class 
    % This class must be inherited. The child class must deliver the
    % FlirtStrategy method that accepts the concrete Flirt class

	%  $Revision: 2577 $
 	%  was created $Date: 2013-08-23 07:17:28 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:17:28 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslStrategy.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslStrategy.m 2577 2013-08-23 12:17:28Z jjlee $

    methods (Abstract, Static)
        concrete = newStrategy(choice, builder)
    end
    
	properties (Dependent)
        products
        lastProduct
    end
    
	methods
        function pr = get.products(this)
            pr = this.builder_.products;
            assert(~isempty(pr));
        end
        function pr = get.lastProduct(this)
            pr = this.builder_.lastProduct;
            assert(~isempty(pr));
        end
    end
    
    properties (Access = 'private')
        builder_
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

