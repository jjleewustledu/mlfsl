classdef BrainExtractionOptionsInterface  
	%% BRAINEXTRACTIONOPTIONSINTERFACE   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id$ 
 	 
	properties (Abstract)

        %% Main bet2 options:

        o           % generate brain surface outline overlaid onto original image
        m           % generate binary brain mask
        s           % generate approximate skull image
        n           % don't generate segmented brain image output
        f % <f>       fractional intensity threshold (0->1); default=0.5; smaller values give larger brain outline estimates
        g % <g>       vertical gradient in fractional intensity threshold (-1->1); default=0; positive values give larger brain outline at bottom, smaller at top
        r % <r>       head radius (mm not voxels); initial surface sphere is set to half of this
        c % <x y z> % centre-of-gravity (voxels not mm) of initial mesh surface.
        t           % apply thresholding to segmented brain image and mask
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

