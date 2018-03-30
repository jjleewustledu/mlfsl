classdef BetEpi < mlfsl.BetStrategy
	%% BETEPI ...
	%  $Revision: 2571 $
 	%  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetEpi.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: BetEpi.m 2571 2013-08-23 12:16:08Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	methods 
 		function [this, imobj] = bet(this, imobj)
            import mlfsl.*;
            this.in_tag = imcast(imobj, 'fileprefix');
            this.out_tag = fileprefix(BetBuilder.bettedFilename(this.in_tag));
            this.betOptions.A2 = this.inOnT2;
            this.betOptions.f = 0.2;
            this.betOptions.r = BetT1.radius(imobj);
            this.betOptions.c = BetT1.center(imobj);
            [this.builder_,imobj] = this.builder_.bet(this.betOptions);
        end
 		function this = BetEpi(varargin) 
 			%% BETEPI 
 			%  Usage:  obj = BetEpi() 

 			this = this@mlfsl.BetStrategy(varargin{:}); 
 		end %  ctor 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

