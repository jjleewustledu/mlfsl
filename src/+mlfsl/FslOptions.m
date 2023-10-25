classdef FslOptions < mlpipeline.AbstractOptions
	%% FSLOPTIONS is the baseclass for options classes such as FlirtOptions, BetOptions, ...
    %  Usage:  obj = FslOptions; ...
    %          mlbash(strcat('executable', char(obj)));
    
	%  $Revision: 2629 $
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslOptions.m 2629 2013-09-16 06:19:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties
        in_tag
        out_tag
    end
        
    methods %% Set/Get
		function this = set.in_tag(this, it)
            if (isempty(it))
                this.in_tag = []; return; end
            this.in_tag = imcast(it, 'fqfilename');
		end
		function this = set.out_tag(this, ot)
            if (isempty(ot))
                this.out_tag = []; return; end
            this.out_tag = imcast(ot, 'fqfilename');
		end	
    end 
    
	methods 
 		function s        = char(this) 
 			flds = fieldnames(this);
            [this,s] = this.checkInOut;
             this    = this.checkOther;
            for f = 1:length(flds)
                if (~isempty(this.(flds{f})))
                    s = this.updateOptionsString(s, flds{f}, this.(flds{f}));
                end
            end
        end   
        function  this    = checkOther(this)
        end
        function [this,s] = checkInOut(this)
            s = '';
            if (~isempty(this.in_tag))
                s = [s fileprefix(this.in_tag) ' ']; 
                if (~isempty(this.out_tag))
                    s = [s fileprefix(this.out_tag) ' '];
                end
            end
            this.in_tag = '';
            this.out_tag = '';
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

