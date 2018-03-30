classdef CsfRois < mlfsl.FastRois  
	%% CSFROIS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 

	properties  		 
        maskFileprefix  = 'csfMask'
 	end 

	methods 
 		 

 		function afun(this) 
 		end 
 		function this = CsfRois(varargin) 
 			%% CSFROIS 
 			%  Usage:  this = CsfRois() 

            this = this@mlfsl.FastRois(varargin{:});
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

