classdef FastOptions < mlfsl.FslOptions
	%% FASTOPTIONS 
    %  Usage:  fast [options] file(s)
    
	%  $Revision: 2550 $
 	%  was created $Date: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FastOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FastOptions.m 2550 2013-08-22 09:37:03Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties
        %% Optional arguments (You may optionally specify one or more of):
        n = 4;    % -n,--class	number of tissue-type classes; default=3
        I         % -I,--iter	number of main-loop iterations during bias-field removal; default=4
        l         % -l,--lowpass	bias field smoothing extent (FWHM) in mm; default=20
        t = 1;    % -t,--type	type of image 1=T1, 2=T2, 3=PD; default=T1
        f         % -f,--fHard	initial segmentation spatial smoothness (during bias field estimation); default=0.02
        g = true  % -g,--segments	outputs a separate binary image for each tissue type
        a               % -a <standard2input.mat> initialise using priors; you must supply a FLIRT transform
        A               % -A <prior1> <prior2> <prior3>    alternative prior images
        nopve           % --nopve	turn off PVE (partial volume estimation)
        b = true;       % -b		output estimated bias field
        B = true;       % -B		output bias-corrected image
        N               % -N,--nobias	do not remove bias field
        S               % -S,--channels	number of input images (channels); default 1
        o               % -o,--out	output basename
        P               % -P,--Prior	use priors throughout; you must also set the -a option
        W               % -W,--init	number of segmentation-initialisation iterations; default=15
        R               % -R,--mixel	spatial smoothness for mixeltype; default=0.3
        O               % -O,--fixed	number of main-loop iterations after bias-field removal; default=4
        H               % -H,--Hyper	segmentation spatial smoothness; default=0.1
        v               % -v,--verbose	switch on diagnostic messages
        h               % -h,--help	display this message
        s               % -s,--manualseg <filename> Filename containing intensities
        p = true        % -p		outputs individual probability maps
    end

    methods
 		% N.B. (Static, Abstract, Access='', Hidden, Sealed) 
 		
 		function s = updateOptionsString(~, s, fldname, val)
            if (islogical(val))
                val = ' '; end
            if (isnumeric(val))
                val = num2str(val); end
            if (1 == length(strtrim(fldname)))
                s = sprintf('%s -%s %s', s, fldname, val); end
            if (length(strtrim(fldname)) > 1)
                s = sprintf('%s --%s %s', s, fldname, val); end
        end
		function this = set.a(this, val)
			this.a = this.transformFilename(val);
		end
		function this = set.A(this, vals)
			vals = ensureCell(vals);
			vals = cellfun(@(x) imcast(x,'fileprefix'), vals);
			this.A = cell2str(vals);
		end
		function this = set.s(this, val)
			this.manualseg = imcast(val, 'fileprefix');
		end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

