classdef ProductInterface
	%% PRODUCTINTERFACE provides data objects for processed images
	%  $Revision: 2326 $
 	%  was created $Date: 2013-01-21 00:36:42 -0600 (Mon, 21 Jan 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-01-21 00:36:42 -0600 (Mon, 21 Jan 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/ProductInterface.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ProductInterface.m 2326 2013-01-21 06:36:42Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Abstract)
        opts
        logger
    end

    methods 
        function this = addlog(this, lg)
            this.logger_.add(lg);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

