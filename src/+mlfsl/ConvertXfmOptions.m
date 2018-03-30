classdef ConvertXfmOptions < mlfsl.FslOptions
	%% CONVERTXFMOPTIONS
    %  Usage: convert_xfm [options] <input-matrix-filename>
    %  e.g. convert_xfm -omat <outmat> -inverse <inmat>
    %       convert_xfm -omat <outmat_AtoC> -concat <mat_BtoC> <mat_AtoB>
    
	%  $Revision: 2481 $
 	%  was created $Date: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/ConvertXfmOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ConvertXfmOptions.m 2481 2013-08-18 06:44:27Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Dependent)
        omat % <matrix-filename>            (4x4 ascii format)
    end
    
    properties
        concat % <second-matrix-filename>
        fixscaleskew % <second-matrix-filename>
        inverse %                           (Reference image must be the one originally used)
        help
 	end
	
	methods
		function this = set.omat(this, obj)
			this.omat_ = this.transformFilename(obj);
        end	
        function val  = get.omat(this)
            if (isempty(this.omat_))
                if (~isempty(this.inverse))
                    parts = mlchoosers.ImagingChoosers.splitFilename(this.inverse);
                    this.omat_ = this.transformFilename(parts{length(parts)}, parts{1});
                end
                if (~isempty(this.concat))
                    [BtoC,AtoB] = strtok(this.concat);
                    this.omat_ = this.transformFilename(AtoB, BtoC);
                end
            end
            val = this.omat_;
        end
        function this = checkOther(this)
            assert(~isempty(this.omat));
            if (~isempty(this.inverse))
                assert(lexist(this.inverse, 'file')); end
            if (~isempty(this.concat))
                [sec,first] = strtok(this.concat);
                first = first(2:end);
                assert(lexist(strtrim(sec),   'file'));
                assert(lexist(strtrim(first), 'file'));
            end
        end
    end	
    
    properties (Access = 'private')
        omat_
    end
	
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

