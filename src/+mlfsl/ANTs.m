classdef ANTs < handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable
    %% ANTs provides an object-oriented implementation of ANTsX/ANTs.
    % --------------------------------------------------------------------------------------
    % Get the latest ANTs version at:
    % --------------------------------------------------------------------------------------
    % https://github.com/stnava/ANTs/
    % 
    % --------------------------------------------------------------------------------------
    % Read the ANTS documentation at:
    % --------------------------------------------------------------------------------------
    % http://stnava.github.io/ANTs/
    % https://github.com/ANTsX/ANTs/wiki
    % https://github.com/ANTsX/ANTs/wiki/Forward-and-inverse-warps-for-warping-images,-pointsets-and-Jacobians
    % 
    % --------------------------------------------------------------------------------------
    % ANTS was created by:
    % --------------------------------------------------------------------------------------
    % Brian B. Avants, Nick Tustison and Gang Song
    % Penn Image Computing And Science Laboratory
    % University of Pennsylvania
    % 
    % Relevent references for this script include:
    %    * http://www.ncbi.nlm.nih.gov/pubmed/20851191
    %    * http://www.frontiersin.org/Journal/10.3389/fninf.2013.00039/abstract
    % --------------------------------------------------------------------------------------
    % script by Nick Tustison
    % --------------------------------------------------------------------------------------    
    %  
    %  Created 13-Mar-2022 23:56:20 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlfsl/src/+mlfsl.
    %  Developed on Matlab 9.11.0.1873467 (R2021b) Update 3 for MACI64.  Copyright 2022 John J. Lee.
    
    properties (Dependent)
        Nthreads
        transform_type
        workpath
    end

    methods

        %% GET

        function g = get.Nthreads(~)
            g = 8;
        end
        function g = get.transform_type(~)
            g = 's'; % rigid + affine + deformable syn (3 stages)
        end
        function g = get.workpath(this)
            g = this.workpath_;
        end

        %%

        function this = ANTs(varargin)
            
            ip = inputParser;
            addParameter(ip, "workpath", pwd, @isfolder)
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            this.workpath_ = ipr.workpath;
        end

        function out = antsApplyTransforms(~, in, ref, transbase)
            %%     antsApplyTransforms
            %           antsApplyTransforms, applied to an input image, transforms it according to a 
            %           reference image and a transform (or a set of transforms). 
            % 
            % OPTIONS: 
            %      -d, --dimensionality 2/3/4
            %           This option forces the image to be treated as a specified-dimensional image. If 
            %           not specified, antsWarp tries to infer the dimensionality from the input image. 
            % 
            %      -e, --input-image-type 0/1/2/3/4 
            %                             scalar/vector/tensor/time-series/multichannel 
            %           Option specifying the input image type of scalar (default), vector, tensor, time 
            %           series, or multi-channel. A time series image is a scalar image defined by an 
            %           additional dimension for the time component whereas a multi-channel image is a 
            %           vector image with only spatial dimensions. 
            %           <VALUES>: 0
            % 
            %      -i, --input inputFileName
            %           Currently, the only input objects supported are image objects. However, the 
            %           current framework allows for warping of other objects such as meshes and point 
            %           sets. 
            % 
            %      -r, --reference-image imageFileName
            %           For warping input images, the reference image defines the spacing, origin, size, 
            %           and direction of the output warped image. 
            % 
            %      -o, --output warpedOutputFileName
            %                   [warpedOutputFileName or compositeDisplacementField,<printOutCompositeWarpFile=0>]
            %                   Linear[genericAffineTransformFile,<calculateInverse=0>]
            %           One can either output the warped image or, if the boolean is set, one can print 
            %           out the displacement field based on the composite transform and the reference 
            %           image. A third option is to compose all affine transforms and (if boolean is 
            %           set) calculate its inverse which is then written to an ITK file. 
            % 
            %      -n, --interpolation Linear
            %                          NearestNeighbor
            %                          MultiLabel[<sigma=imageSpacing>,<alpha=4.0>]
            %                          Gaussian[<sigma=imageSpacing>,<alpha=1.0>]
            %                          BSpline[<order=3>]
            %                          CosineWindowedSinc
            %                          WelchWindowedSinc
            %                          HammingWindowedSinc
            %                          LanczosWindowedSinc
            %                          GenericLabel[<interpolator=Linear>]
            %           Several interpolation options are available in ITK. These have all been made 
            %           available. 
            % 
            %      -u, --output-data-type char
            %                             uchar
            %                             short
            %                             int
            %                             float
            %                             double
            %                             default
            %           Output image data type. This is a direct typecast; output values are not 
            %           rescaled. Default is to use the internal data type (float or double). uchar is 
            %           unsigned char; others are signed. WARNING: Outputs will be incorrect 
            %           (overflowed/reinterpreted) if values exceed the range allowed by your choice. 
            %           Note that some pixel types are not supported by some image formats. e.g. int is 
            %           not supported by jpg. 
            % 
            %      -t, --transform transformFileName
            %                      [transformFileName,useInverse]
            %           Several transform options are supported including all those defined in the ITK 
            %           library in addition to a deformation field transform. The ordering of the 
            %           transformations follows the ordering specified on the command line. An identity 
            %           transform is pushed onto the transformation stack. Each new transform 
            %           encountered on the command line is also pushed onto the transformation stack. 
            %           Then, to warp the input object, each point comprising the input object is warped 
            %           first according to the last transform pushed onto the stack followed by the 
            %           second to last transform, etc. until the last transform encountered which is the 
            %           identity transform. Also, it should be noted that the inverse transform can be 
            %           accommodated with the usual caveat that such an inverse must be defined by the 
            %           specified transform class 
            % 
            %      -f, --default-value value
            %           Default voxel value to be used with input images only. Specifies the voxel value 
            %           when the input point maps outside the output domain. With tensor input images, 
            %           specifies the default voxel eigenvalues. 
            % 
            %      -z, --static-cast-for-R value
            %           forces static cast in ReadTransform (for R) 
            % 
            %      --float 
            %           Use 'float' instead of 'double' for computations. 
            %           <VALUES>: 0
            % 
            %      -v, --verbose (0)/1
            %           Verbose output. 
            % 
            %      -h 
            %           Print the help menu (short version). 
            % 
            %      --help 
            %           Print the help menu. 
            %%

            exec = fullfile(getenv('ANTSPATH'), 'antsApplyTransforms');
            out = mlfourd.ImagingContext2(strcat(in.fqfp, '_Warped.nii.gz')); 
            cmd = sprintf('%s -d 3 -i %s -r %s -t %s_1Warp.nii.gz %s_0GenericAffine.mat -o %s -v 1', ...
                exec, in.fqfn, ref.fqfn, transbase.fqfp, transbase.fqfp, out.fqfn);
            mlbash(cmd);            
            copyfile(strcat(in.fqfp, '.json'), strcat(out.fqfp, '.json'));
        end
        function out = antsRegistrationSyNQuick(this, fixed, moving)
            %% antsRegistrationSyNQuick.sh -d ImageDimension -f FixedImage -m MovingImage -o OutputPrefix
            % 
            % Example Case:
            % 
            % antsRegistrationSyNQuick.sh -d 3 -f fixedImage.nii.gz -m movingImage.nii.gz -o output
            % 
            % Compulsory arguments:
            % 
            %      -d:  ImageDimension: 2 or 3 (for 2 or 3 dimensional registration of single volume)
            % 
            %      -f:  Fixed image(s) or source image(s) or reference image(s)
            % 
            %      -m:  Moving image(s) or target image(s)
            % 
            %      -o:  OutputPrefix: A prefix that is prepended to all output files.
            % 
            % Optional arguments:
            % 
            %      -n:  Number of threads (default = ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS if defined, otherwise 1)
            % 
            %      -i:  initial transform(s) --- order specified on the command line matters
            % 
            %      -t:  transform type (default = 's')
            %         t: translation (1 stage)
            %         r: rigid (1 stage)
            %         a: rigid + affine (2 stages)
            %         s: rigid + affine + deformable syn (3 stages)
            %         sr: rigid + deformable syn (2 stages)
            %         so: deformable syn only (1 stage)
            %         b: rigid + affine + deformable b-spline syn (3 stages)
            %         br: rigid + deformable b-spline syn (2 stages)
            %         bo: deformable b-spline syn only (1 stage)
            % 
            %      -r:  histogram bins for mutual information in SyN stage (default = 32)
            % 
            %      -s:  spline distance for deformable B-spline SyN transform (default = 26)
            % 
            %      -x:  mask(s) for the fixed image space.  Should specify either a single image to be used for
            %           all stages or one should specify a mask image for each "stage" (cf -t option).  If
            %           no mask is to be used for a particular stage, the keyword 'NULL' should be used
            %           in place of a file name.
            % 
            %      -p:  precision type (default = 'd')
            %         f: float
            %         d: double
            % 
            %      -j:  use histogram matching (default = 0)
            %         0: false
            %         1: true
            % 
            %      -z:  collapse output transforms (default = 1)
            % 
            %      -e:  Fix random seed to an int value (default = system time)
            % 
            %      NB:  Multiple image pairs can be specified for registration during the SyN stage.
            %           Specify additional images using the '-m' and '-f' options.  Note that image
            %           pair correspondence is given by the order specified on the command line.
            %           Only the first fixed and moving image pair is used for the linear resgitration
            %           stages.
            %%

            exec = fullfile(getenv('ANTSPATH'), 'antsRegistrationSyNQuick.sh');
            cmd = sprintf('%s -d 3 -f %s -m %s -o %s_ -n %i -t %s -j 0', ...
                exec, fixed.fqfn, moving.fqfn, moving.fqfp, this.Nthreads, this.transform_type);
            mlbash(cmd);
            out = mlfourd.ImagingContext2(strcat(moving.fqfp, '_Warped.nii.gz')); 
            % see also: _0GenericAffine.mat, _1Warp.nii.gz
            copyfile(strcat(moving.fqfp, '.json'), strcat(out.fqfp, '.json'));
        end
        function CreateJacobianDeterminantImage(~, warp, out)
            %% Usage: CreateJacobianDeterminantImage imageDimension deformationField outputImage [doLogJacobian=0] [useGeometric=0]

            exec = fullfile(getenv('ANTSPATH'), 'CreateJacobianDeterminantImage');
            cmd = sprintf('%s 3 %s %s', exec, warp.fqfn, out.fqfn);
            mlbash(cmd);
        end
        function N4BiasFieldCorrection(~, in, out)
            in = mlfourd.ImagingContext2(in);
            out = mlfourd.ImagingContext2(out);
            exec = fullfile(getenv('ANTSPATH'), 'N4BiasFieldCorrection');
            cmd = sprintf('%s -d 3 -i %s -o %s', exec, in.fqfn, out.fqfn);
            mlbash(cmd);
            try
                copyfile(strcat(in.fqfp, '.json'), strcat(out.fqfp, '.json'));
            catch ME
                handwarning(ME);
            end
        end
    end

    %% PROTECTED    
    
    methods (Access = protected)
        function that = copyElement(this)
            %%  See also web(fullfile(docroot, 'matlab/ref/matlab.mixin.copyable-class.html'))
            
            that = copyElement@matlab.mixin.Copyable(this);
        end
    end

    %% PRIVATE

    properties (Access = private)
        workpath_
    end
    
    
    %  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn.
end
