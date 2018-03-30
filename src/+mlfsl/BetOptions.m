classdef BetOptions < mlfsl.FslOptions
	%% BETOPTIONS 
    %  Usage:    bet <input> <output> [options]
    
	%  $Revision: 2376 $
 	%  was created $Date: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetOptions.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: BetOptions.m 2376 2013-03-05 13:46:20Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties
        %% Main bet2 options:
        o           % generate brain surface outline overlaid onto original image
        m = true;   % generate binary brain mask
        s           % generate approximate skull image
        n           % don't generate segmented brain image output
        f % <f>       fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates
        g % <g>       vertical gradient in fractional intensity threshold (-1->1); default=0; positive values give larger brain outline at bottom, smaller at top
        r % <r>       head radius (mm not voxels); initial surface sphere is set to half of this
        c % <x y z> % centre-of-gravity (voxels not mm) of initial mesh surface.
        t = true;   % apply thresholding to segmented brain image and mask
        e           % generates brain surface as mesh in .vtk format
        %% Variations on default bet2 functionality (mutually exclusive options):
        %  (default)  % just run bet2
        R          % robust brain centre estimation (iterates BET several times)
        S          % eye & optic nerve cleanup (can be useful in SIENA)
        B          % bias field & neck cleanup (can be useful in SIENA)
        Z          % improve BET if FOV is very small in Z (by temporarily padding end slices)
        F          % apply to 4D FMRI data (uses -f 0.3 and dilates brain mask slightly)
        A          % run bet2 and then betsurf to get additional skull and scalp surfaces (includes registrations)
        A2 % <T2>  % as with -A, when also feeding in non-brain-extracted T2 (includes registrations)
        %% Miscellaneous options:
        v          % verbose (switch on diagnostic messages)
        h          % display this help, then exits
        d          % debug (don't delete temporary intermediate images)
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

