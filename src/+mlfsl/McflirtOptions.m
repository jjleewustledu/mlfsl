classdef McflirtOptions < mlfsl.FslOptions
	%% MCFLIRTOPTIONS 
    %  Usage: mcflirt -in <infile> [options]
    %         mcfopts = McflirtOptions;
    %         mcfopts.in_tag = input_fileprefix

	%  $Revision: 2550 $
 	%  was created $Date: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-22 04:37:03 -0500 (Thu, 22 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/McflirtOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: McflirtOptions.m 2550 2013-08-22 09:37:03Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
	    in % <infile>
        % out % <outfile>                     (default is infile_mcf)
        cost = 'normmi'; % {mutualinfo,woods,corratio,normcorr,normmi,leastsquares}        (default is normcorr)
        bins % <number of histogram bins>   (default is 256)
        dof = 12; % <number of transform dofs>    (default is 6)
        refvol % <number of reference volume> (default is no_vols/2)- registers to (n+1)th volume in series
        reffile % <filename>            use a separate 3d image file as the target for registration (overrides refvol option)
        scaling % <num>                     (6.0 is default)
        smooth % <num>                      (1.0 is default - controls smoothing in cost function)
        rotation % <num>                    specify scaling factor for rotation optimization tolerances
        verbose % <num>                     (0 is least and default)
        stages = 3; % <number of search levels>  (default is 3 - specify 4 for final sinc interpolation)
        fov % <num>                         (default is 20mm - specify size of field of view when padding 2d volume)
        % 2d                                % Force padding of volume
        sinc_final                        % (applies final transformations using sinc interpolation)
        spline_final                      % (applies final transformations using spline interpolation)
        nn_final                          % (applies final transformations using Nearest Neighbour interpolation)
        init % <filename>                   (initial transform matrix to apply to all vols)
        gdt                               % (run search on gradient images)
        edge                              % (run search on contour images)
        meanvol = true;                   % register timeseries to mean volume (overrides refvol and reffile options)
        stats   = true;                   % produce variance and std. dev. images
        mats    = true;                   % save transformation matricies in subdirectory outfilename.mat
        plots   = true;                   % save transformation parameters in file outputfilename.par
        report                            % report progress to screen
        help
    end

    methods %% Set
		function this = set.in(this, obj)
			this.in = imcast(obj, 'fileprefix');
        end
		function this = set.reffile(this, obj)
			this.ref = imcast(obj, 'fileprefix');
		end
    end 

	methods
        function [this,s] = checkInOut(this)
            s = '';
            if (~isempty(this.in_tag))
                s = [' -in ' fileprefix(this.in_tag) ' '];
            end
            this.in_tag = '';
            this.out_tag = '';
        end 
        function  this = checkOther(this)
            assert(lexist(filename(this.in), 'file'));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

