classdef FslstatsOptions < mlfsl.FslOptions
	%% FSLSTATSOPTIONS  
    %  Usage: fslstats [-t] <input> [options]
    %  Note - options are applied in order, e.g. -M -l 10 -M will report the non-zero mean, apply a threshold and then report the new nonzero mean

	%  $Revision$
 	%  was created 13-Jan-2016 09:54:03
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlfsl/src/+mlfsl.
 	%% It was developed on Matlab 9.0.0.307022 (R2016a) Prerelease for MACI64.
 	

	properties
        t %           : will give a separate output line for each 3D volume of a 4D timeseries

        l % <lthresh> : set lower threshold
        u % <uthresh> : set upper threshold
        r %           : output <robust min intensity> <robust max intensity>
        R %           : output <min intensity> <max intensity>
        e %           : output mean entropy ; mean(-i*ln(i))
        E %           : output mean entropy (of nonzero voxels)
        v %           : output <voxels> <volume>
        V %           : output <voxels> <volume> (for nonzero voxels)
        m %           : output mean
        M %           : output mean (for nonzero voxels)
        s %           : output standard deviation
        S %           : output standard deviation (for nonzero voxels)
        w %           : output smallest ROI <xmin> <xsize> <ymin> <ysize> <zmin> <zsize> <tmin> <tsize> containing nonzero voxels
        x %           : output co-ordinates of maximum voxel
        X %           : output co-ordinates of minimum voxel
        c %           : output centre-of-gravity (cog) in mm coordinates
        C %           : output centre-of-gravity (cog) in voxel coordinates
        p % <n>       : output nth percentile (n between 0 and 100)
        P % <n>       : output nth percentile (for nonzero voxels)
        a %           : use absolute values of all image intensities
        n %           : treat NaN or Inf as zero for subsequent stats
        k % <mask>    : use the specified image (filename) for masking - overrides lower and upper thresholds
        d % <image>   : take the difference between the base image and the image specified here
        h % <nbins>   : output a histogram (for the thresholded/masked voxels only) with nbins
        H % <nbins> <min> <max> 
          %           : output a histogram (for the thresholded/masked voxels only) with nbins and histogram limits of min and max

        %% Note - thresholds are not inclusive ie lthresh<allowed<uthresh
 	end

	methods 
        function s    = updateOptionsString(~, s, fldname, val) 
            if (islogical(val))
                val = ' '; end
            if (isnumeric(val))
                val = num2str(val); end
            s = sprintf('%s -%s %s', s, fldname, val);
        end
        
		function this = set.k(this, obj)
			this.k = imcast(obj, 'fqfileprefix');
		end
		function this = set.d(this, obj)
			this.d = imcast(obj, 'fqfileprefix');
		end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

