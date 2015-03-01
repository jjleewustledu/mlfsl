classdef ContrastRegistration 
	%% CONTRASTREGISTRATION is the abstract interface for a strategy design pattern:
    %  CoRegistration -> ContrastRegistration strategy interface
    %                    ^
    %                    EpiRegistration, IrRegistration, T2Registration, T1Registration
    %                    specific strategies
    %  http://en.wikipedia.org/wiki/File:Strategy.JPG
    %
	%  Usage:  obj = ContrastRegistration(workarea) 
	%                                     ^ string
    %
	%% Version $Revision$ was created $Date$ by $Author$  
	%% and checked into svn repository $URL$ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id$ 
    
    properties
        workarea = '';
    end

	methods (Abstract)
        [status, stdout] = register_to_t1();
        [status, stdout] = register_to_std();
        [status, stdout] = register_stdroi_to_t1();
        [status, stdout] = register_to_lowres();
        [status, stdout] = downsample();
    end 
    
    methods
        
        function this = ContrastRegistration(workarea)
            this.workarea = workarea;
        end
    end
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
