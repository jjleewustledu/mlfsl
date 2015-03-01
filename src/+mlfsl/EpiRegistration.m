classdef EpiRegistration < mlfsl.FlirtBuilder
	%% EPIREGISTRATION  
	%  Usage:  obj = EpiRegistration(varargin) 
	%                                ^ cf. ContrastRegistration
	%% Version $Revision$ was created $Date$ by $Author$  
	%% and checked into svn repository $URL$ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id$ 

	methods 

        function this = EpiRegistration(bldr, varargin)
            this      = this@mlfsl.FlirtBuilder(bldr, varargin{:});
        end
	end 
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
