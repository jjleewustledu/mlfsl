classdef GreyRois < mlfsl.FastRois  
	%% GREYROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties 		 
        maskFileprefix  = 'grayMask'
 	end 

	methods 
        function test_grey(this)
        end
        
 		function this = GreyRois(varargin) 
 			%% GREYROIS 
 			%  Usage:  this = GreyRois() 

            this = this@mlfsl.FastRois(varargin{:});
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

