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
            g = 1;
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

        function out = antsApplyTransforms(~, in, ref, transbase, varargin)
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

            ip = inputParser;
            addOptional(ip, 'more_options', '', @istext);
            parse(ip, varargin{:});
            ipr = ip.Results;

            exec = fullfile(getenv('ANTSPATH'), 'antsApplyTransforms');
            out = mlfourd.ImagingContext2(strcat(in.fqfp, '_Warped.nii.gz')); 
            cmd = sprintf('%s -d 3 -i %s -r %s %s -t %s_1Warp.nii.gz %s_0GenericAffine.mat -o %s -v 1', ...
                exec, in.fqfn, ref.fqfn, ipr.more_options, transbase.fqfp, transbase.fqfp, out.fqfn);
            mlbash(cmd);

            if isfile(strcat(out.fqfp, '.json'))
                deleteExisting(strcat(out.fqfp, '.json'))
            end
            jsonrecode(strcat(in.fqfp, '.json'), ...
                struct(clientname(true, 2), cmd), ...
                'filenameNew', strcat(out.fqfp, '.json'));
        end
        function out = antsApplyTransforms2(~, in, ref, transbase)
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
            out = mlfourd.ImagingContext2(strcat(transbase.fqfp, '_2Warp.nii.gz')); 
            cmd = sprintf('%s -d 3 -i %s -r %s --interpolation LINEAR -t %s_1Warp.nii.gz %s_0GenericAffine.mat -o [%s,1] -v 1', ...
                exec, in.fqfn, ref.fqfn, transbase.fqfp, transbase.fqfp, out.fqfn);
            mlbash(cmd);

            if isfile(strcat(out.fqfp, '.json'))
                deleteExisting(strcat(out.fqfp, '.json'))
            end
            jsonrecode(strcat(in.fqfp, '.json'), ...
                struct(clientname(true, 2), cmd), ...
                'filenameNew', strcat(out.fqfp, '.json'));
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

            out = mlfourd.ImagingContext2(strcat(moving.fqfp, '_Warped.nii.gz')); 
            exec = fullfile(getenv('ANTSPATH'), 'antsRegistrationSyNQuick.sh');
            cmd = sprintf('%s -d 3 -f %s -m %s -o %s_ -n %i -t %s -j 0', ...
                exec, fixed.fqfn, moving.fqfn, moving.fqfp, this.Nthreads, this.transform_type);
            mlbash(cmd);
            % see also: _0GenericAffine.mat, _1Warp.nii.gz      

            jsonrecode(strcat(moving.fqfp, '.json'), ...
                struct(clientname(true, 2), cmd), ...
                'filenameNew', strcat(out.fqfp, '.json'));
        end
        function out = CreateJacobianDeterminantImage(~, warp, out)
            %% Usage: CreateJacobianDeterminantImage imageDimension deformationField outputImage [doLogJacobian=0] [useGeometric=0]

            exec = fullfile(getenv('ANTSPATH'), 'CreateJacobianDeterminantImage');
            cmd = sprintf('%s 3 %s %s', exec, warp.fqfn, out.fqfn);
            mlbash(cmd);

            jsonrecode(strcat(warp.fqfp, '.json'), ...
                struct(clientname(true, 2), cmd), ...
                'filenameNew', strcat(out.fqfp, '.json'));
        end
        function out = deepmrseg_apply(this, mpr)
            mpr = mlfourd.ImagingContext2(mpr);
            out = mlfourd.ImagingContext2(strcat(mpr.fqfp, '_dlicv.nii.gz'));
            
            if this.on_cluster
                sif = fullfile(getenv('SINGULARITY_HOME'), 'deepmrseg_image_20220515.sif');
                cmd = sprintf('singularity exec --bind %s:/data %s "deepmrseg_apply" "--task" "dlicv" "--inImg" "/data/%s" "--outImg" "/data/%s"', ...
                    mpr.filepath, sif, mpr.filename, out.filename);
            else
                mlbash(sprintf('chmod 777 %s', mpr.filepath));
                dock = 'jjleewustledu/deepmrseg_image:20220615';
                cmd = sprintf('nvidia-docker run -it -v %s:/data --rm %s --task dlicv --inImg %s --outImg %s', ...
                    mpr.filepath, dock, mpr.filename, out.filename);
            end
            mlbash(cmd);

            mladni.FDG.jsonrecode( ...
                mpr, ...
                struct('bash', cmd), ...
                out);
        end
        function [out,transbase] = epiToMpr(this, epi, mpr, inference, varargin)
            %% https://sourceforge.net/p/advants/discussion/840261/thread/7d71cb7d64/
            %  Args:
            %      epi (any): is time-averaged to 3D
            %      mpr (any): is skull-stripped
            %      t2 (optional, any): has contrasts like epi, but is rigidly isomorphic to mpr
            %  Returns:
            %      out:  ImagingContext2
            %      transbase:  ImagingContext2
            %
            % COMMAND: 
            %      antsRegistration
            %           This program is a user-level registration application meant to utilize classes 
            %           in ITK v4.0 and later. The user can specify any number of "stages" where a stage 
            %           consists of a transform; an image metric; and iterations, shrink factors, and 
            %           smoothing sigmas for each level. Note that explicitly setting the 
            %           dimensionality, metric, transform, output, convergence, shrink-factors, and 
            %           smoothing-sigmas parameters is mandatory. 
            % 
            % OPTIONS: 
            %      --version 
            %           Get Version Information. 
            % 
            %      -d, --dimensionality 2/3/4
            %           This option forces the image to be treated as a specified-dimensional image. If 
            %           not specified, we try to infer the dimensionality from the input image. 
            % 
            %      -o, --output outputTransformPrefix
            %                   [outputTransformPrefix,<outputWarpedImage>,<outputInverseWarpedImage>]
            %           Specify the output transform prefix (output format is .nii.gz ). Optionally, one 
            %           can choose to warp the moving image to the fixed space and, if the inverse 
            %           transform exists, one can also output the warped fixed image. Note that only the 
            %           images specified in the first metric call are warped. Use antsApplyTransforms to 
            %           warp other images using the resultant transform(s). 
            % 
            %      -j, --save-state saveSateAsTransform
            %           Specify the output file for the current state of the registration. The state 
            %           file is written to an hdf5 composite file. It is specially usefull if we want to 
            %           save the current state of a SyN registration to the disk, so we can load and 
            %           restore that later to continue the next registration process directly started 
            %           from the last saved state. The output file of this flag is the same as the 
            %           write-composite-transform, unless the last transform is a SyN transform. In that 
            %           case, the inverse displacement field of the SyN transform is also added to the 
            %           output composite transform. Again notice that this file cannot be treated as a 
            %           transform, and restore-state option must be used to load the written file by 
            %           this flag. 
            % 
            %      -k, --restore-state restoreStateAsATransform
            %           Specify the initial state of the registration which get immediately used to 
            %           directly initialize the registration process. The flag is mutually exclusive 
            %           with other intialization flags.If this flag is used, none of the 
            %           initial-moving-transform and initial-fixed-transform cannot be used. 
            % 
            %      -a, --write-composite-transform 1/(0)
            %           Boolean specifying whether or not the composite transform (and its inverse, if 
            %           it exists) should be written to an hdf5 composite file. This is false by default 
            %           so that only the transform for each stage is written to file. 
            %           <VALUES>: 0
            % 
            %      -p, --print-similarity-measure-interval <unsignedIntegerValue>
            %           Prints out the CC similarity metric measure between the full-size input fixed 
            %           and the transformed moving images at each iteration a value of 0 (the default) 
            %           indicates that the full scale computation should not take placeany value greater 
            %           than 0 represents the interval of full scale metric computation. 
            %           <VALUES>: 0
            % 
            %      --write-interval-volumes <unsignedIntegerValue>
            %           Writes out the output volume at each iteration. It helps to present the 
            %           registration process as a short movie a value of 0 (the default) indicates that 
            %           this option should not take placeany value greater than 0 represents the 
            %           interval between the iterations which outputs are written to the disk. 
            %           <VALUES>: 0
            % 
            %      -z, --collapse-output-transforms (1)/0
            %           Collapse output transforms. Specifically, enabling this option combines all 
            %           adjacent transforms wherepossible. All adjacent linear transforms are written to 
            %           disk in the forman itk affine transform (called xxxGenericAffine.mat). 
            %           Similarly, all adjacent displacement field transforms are combined when written 
            %           to disk (e.g. xxxWarp.nii.gz and xxxInverseWarp.nii.gz (if available)).Also, an 
            %           output composite transform including the collapsed transforms is written to the 
            %           disk (called outputCollapsed(Inverse)Composite). 
            %           <VALUES>: 1
            % 
            %      -i, --initialize-transforms-per-stage (1)/0
            %           Initialize linear transforms from the previous stage. By enabling this option, 
            %           the current linear stage transform is directly intialized from the previous 
            %           stage's linear transform; this allows multiple linear stages to be run where 
            %           each stage directly updates the estimated linear transform from the previous 
            %           stage. (e.g. Translation -> Rigid -> Affine). 
            %           <VALUES>: 0
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
            %           available. Currently the interpolator choice is only used to warp (and possibly 
            %           inverse warp) the final output image(s). 
            % 
            %      -g, --restrict-deformation PxQxR
            %           This option allows the user to restrict the optimization of the displacement 
            %           field, translation, rigid or affine transform on a per-component basis. For 
            %           example, if one wants to limit the deformation or rotation of 3-D volume to the 
            %           first two dimensions, this is possible by specifying a weight vector of '1x1x0' 
            %           for a deformation field or '1x1x0x1x1x0' for a rigid transformation. 
            %           Low-dimensional restriction only works if there are no preceding 
            %           transformations.All stages up to and including the desired stage must have this 
            %           option specified,even if they should not be restricted (in which case specify 
            %           1x1x1...) 
            % 
            %      -q, --initial-fixed-transform initialTransform
            %                                    [initialTransform,<useInverse>]
            %                                    [fixedImage,movingImage,initializationFeature]
            %           Specify the initial fixed transform(s) which get immediately incorporated into 
            %           the composite transform. The order of the transforms is stack-esque in that the 
            %           last transform specified on the command line is the first to be applied. In 
            %           addition to initialization with ITK transforms, the user can perform an initial 
            %           translation alignment by specifying the fixed and moving images and selecting an 
            %           initialization feature. These features include using the geometric center of the 
            %           images (=0), the image intensities (=1), or the origin of the images (=2). 
            % 
            %      -r, --initial-moving-transform initialTransform
            %                                     [initialTransform,<useInverse>]
            %                                     [fixedImage,movingImage,initializationFeature]
            %           Specify the initial moving transform(s) which get immediately incorporated into 
            %           the composite transform. The order of the transforms is stack-esque in that the 
            %           last transform specified on the command line is the first to be applied. In 
            %           addition to initialization with ITK transforms, the user can perform an initial 
            %           translation alignment by specifying the fixed and moving images and selecting an 
            %           initialization feature. These features include using the geometric center of the 
            %           images (=0), the image intensities (=1), or the origin of the images (=2). 
            % 
            %      -m, --metric CC[fixedImage,movingImage,metricWeight,radius,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   MI[fixedImage,movingImage,metricWeight,numberOfBins,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   Mattes[fixedImage,movingImage,metricWeight,numberOfBins,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   MeanSquares[fixedImage,movingImage,metricWeight,radius=NA,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   Demons[fixedImage,movingImage,metricWeight,radius=NA,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   GC[fixedImage,movingImage,metricWeight,radius=NA,<samplingStrategy={None,Regular,Random}>,<samplingPercentage=[0,1]>]
            %                   ICP[fixedPointSet,movingPointSet,metricWeight,<samplingPercentage=[0,1]>,<boundaryPointsOnly=0>]
            %                   PSE[fixedPointSet,movingPointSet,metricWeight,<samplingPercentage=[0,1]>,<boundaryPointsOnly=0>,<pointSetSigma=1>,<kNeighborhood=50>]
            %                   JHCT[fixedPointSet,movingPointSet,metricWeight,<samplingPercentage=[0,1]>,<boundaryPointsOnly=0>,<pointSetSigma=1>,<kNeighborhood=50>,<alpha=1.1>,<useAnisotropicCovariances=1>]
            %                   IGDM[fixedImage,movingImage,metricWeight,fixedMask,movingMask,<neighborhoodRadius=0x0>,<intensitySigma=0>,<distanceSigma=0>,<kNeighborhood=1>,<gradientSigma=1>]
            %           These image metrics are available--- CC: ANTS neighborhood cross correlation, 
            %           MI: Mutual information, Demons: (Thirion), MeanSquares, and GC: Global 
            %           Correlation. The "metricWeight" variable is used to modulate the per stage 
            %           weighting of the metrics. The metrics can also employ a sampling strategy 
            %           defined by a sampling percentage. The sampling strategy defaults to 'None' (aka 
            %           a dense sampling of one sample per voxel), otherwise it defines a point set over 
            %           which to optimize the metric. The point set can be on a regular lattice or a 
            %           random lattice of points slightly perturbed to minimize aliasing artifacts. 
            %           samplingPercentage defines the fraction of points to select from the domain. In 
            %           addition, three point set metrics are available: Euclidean (ICP), Point-set 
            %           expectation (PSE), and Jensen-Havrda-Charvet-Tsallis (JHCT). 
            % 
            %      -t, --transform Rigid[gradientStep]
            %                      Affine[gradientStep]
            %                      CompositeAffine[gradientStep]
            %                      Similarity[gradientStep]
            %                      Translation[gradientStep]
            %                      BSpline[gradientStep,meshSizeAtBaseLevel]
            %                      GaussianDisplacementField[gradientStep,updateFieldVarianceInVoxelSpace,totalFieldVarianceInVoxelSpace]
            %                      BSplineDisplacementField[gradientStep,updateFieldMeshSizeAtBaseLevel,<totalFieldMeshSizeAtBaseLevel=0>,<splineOrder=3>]
            %                      TimeVaryingVelocityField[gradientStep,numberOfTimeIndices,updateFieldVarianceInVoxelSpace,updateFieldTimeVariance,totalFieldVarianceInVoxelSpace,totalFieldTimeVariance]
            %                      TimeVaryingBSplineVelocityField[gradientStep,velocityFieldMeshSize,<numberOfTimePointSamples=4>,<splineOrder=3>]
            %                      SyN[gradientStep,<updateFieldVarianceInVoxelSpace=3>,<totalFieldVarianceInVoxelSpace=0>]
            %                      BSplineSyN[gradientStep,updateFieldMeshSizeAtBaseLevel,<totalFieldMeshSizeAtBaseLevel=0>,<splineOrder=3>]
            %                      Exponential[gradientStep,updateFieldVarianceInVoxelSpace,velocityFieldVarianceInVoxelSpace,<numberOfIntegrationSteps>]
            %                      BSplineExponential[gradientStep,updateFieldMeshSizeAtBaseLevel,<velocityFieldMeshSizeAtBaseLevel=0>,<numberOfIntegrationSteps>,<splineOrder=3>]
            %           Several transform options are available. The gradientStep or learningRate 
            %           characterizes the gradient descent optimization and is scaled appropriately for 
            %           each transform using the shift scales estimator. Subsequent parameters are 
            %           transform-specific and can be determined from the usage. For the B-spline 
            %           transforms one can also specify the smoothing in terms of spline distance (i.e. 
            %           knot spacing). 
            % 
            %      -c, --convergence MxNxO
            %                        [MxNxO,<convergenceThreshold=1e-6>,<convergenceWindowSize=10>]
            %           Convergence is determined from the number of iterations per level and is 
            %           determined by fitting a line to the normalized energy profile of the last N 
            %           iterations (where N is specified by the window size) and determining the slope 
            %           which is then compared with the convergence threshold. 
            % 
            %      -s, --smoothing-sigmas MxNxO...
            %           Specify the sigma of gaussian smoothing at each level. Units are given in terms 
            %           of voxels ('vox') or physical spacing ('mm'). Example usage is '4x2x1mm' and 
            %           '4x2x1vox' where no units implies voxel spacing. 
            % 
            %      -f, --shrink-factors MxNxO...
            %           Specify the shrink factor for the virtual domain (typically the fixed image) at 
            %           each level. 
            % 
            %      -u, --use-histogram-matching 
            %           Histogram match the images before registration. 
            % 
            %      -l, --use-estimate-learning-rate-once 
            %           turn on the option that lets you estimate the learning rate step size only at 
            %           the beginning of each level. * useful as a second stage of fine-scale 
            %           registration. 
            % 
            %      -w, --winsorize-image-intensities [lowerQuantile,upperQuantile]
            %           Winsorize data based on specified quantiles. 
            % 
            %      -x, --masks [fixedImageMask,movingImageMask]
            %           Image masks to limit voxels considered by the metric. Two options are allowed 
            %           for mask specification: 1) Either the user specifies a single mask to be used 
            %           for all stages or 2) the user specifies a mask for each stage. With the latter 
            %           one can select to which stages masks are applied by supplying valid file names. 
            %           If the file does not exist, a mask will not be used for that stage. Note that we 
            %           handle the fixed and moving masks separately to enforce this constraint. 
            % 
            %      --float 
            %           Use 'float' instead of 'double' for computations. 
            %           <VALUES>: 0
            % 
            %      --minc 
            %           Use MINC file formats for transformations. 
            %           <VALUES>: 0
            % 
            %      --random-seed seedValue
            %           Use a fixed seed for random number generation. By default, the system clock is 
            %           used to initialize the seeding. The fixed seed can be any nonzero int value. 
            % 
            %      -v, --verbose (0)/1
            %           Verbose output. 
            % 
            %      -h 
            %           Print the help menu (short version). 
            % 
            %      --help 
            %           Print the help menu. Will also print values used on the current command line 
            %           call. 
            %%
            
            ip = inputParser;
            addOptional(ip, 't2', []);
            parse(ip, varargin{:})
            ipr = ip.Results;
            
            % EPI
            epi = mlfourd.ImagingContext2(epi);
            if ~contains(epi.fileprefix, 'n4')
                epi_n4 = mlfourd.ImagingContext2(strcat(this.fqfp_add_proc(epi.fileprefix, 'n4'), '.nii.gz'));
                if ~isfile(epi_n4.fqfn)
                    epi_n4 = this.N4BiasFieldCorrection(epi, epi_n4);
                end
                epi = epi_n4;
            end
            epi_mskt = mlfourd.ImagingContext2( ...
                mlfsl.Flirt.msktgen(epi.fqfn, 'dof', 6, 'dilation', ''));
            epi_brain = epi_mskt .* epi;
            epi_brain.fileprefix = strcat(epi.fileprefix, '_brain');
            epi_brain.save();            
            
            % MPR
            mpr = mlfourd.ImagingContext2(mpr);            
            if ~contains(mpr.fileprefix, 'n4')
                mpr_n4 = mlfourd.ImagingContext2(strcat(this.fqfp_add_proc(mpr.fileprefix, 'n4'), '.nii.gz'));
                if ~isfile(mpr_n4.fqfn)
                    mpr_n4 = this.N4BiasFieldCorrection(mpr, mpr_n4);
                end
                mpr = mpr_n4;
            end
            if isfile(strcat(mpr.fqfp, '_brain.nii.gz'))
                targ_brain = mlfourd.ImagingContext2(strcat(mpr.fqfp, '_brain.nii.gz'));
            else
                tic
                mpr_dlicv = this.deepmrseg_apply(mpr);
                mpr_brain = mpr_dlicv .* mpr;
                mpr_brain.fileprefix = strcat(mpr.fileprefix, '_brain');
                mpr_brain.save();
                targ_brain = mpr_brain;
                fprintf('ANTs.deepmrseg_apply(mpr), make mpr_brain: ');
                toc
            end
                
            % T2
            if ~isempty(ipr.t2)
                t2 = mlfourd.ImagingContext2(ipr.t2);                
                if ~contains(t2.fileprefix, 'n4')
                    t2_n4 = mlfourd.ImagingContext2(strcat(this.fqfp_add_proc(t2.fileprefix, 'n4'), '.nii.gz'));
                    if ~isfile(t2_n4.fqfn)
                        t2_n4 = this.N4BiasFieldCorrection(t2, t2_n4);
                    end
                    t2 = t2_n4;
                end
                if isfile(strcat(t2.fqfp, '_on_mpr_brain.nii.gz'))                    
                    targ_brain = mlfourd.ImagingContext2(strcat(t2.fqfp, '_on_mpr_brain.nii.gz'));
                else
                    tic 
                    f = mlfsl.Flirt( ...
                        'in', t2, ...
                        'ref', mpr, ...
                        'out', strcat(t2.fqfp, '_on_mpr.nii.gz'), ...
                        'omat', strcat(t2.fqfp, '_on_mpr.mat'), ...
                        'dof', 6, ...
                        'searchx', 90);
                    f.flirt();
                    t2 = f.out;
                    t2_brain = mpr_dlicv .* t2;
                    t2_brain.fileprefix = strcat(t2.fileprefix, '_brain');
                    t2_brain.save();
                    targ_brain = t2_brain;                    
                    fprintf('Flirt.flirt(t2, mpr), make t2_brain: ');
                    toc
                end
            end
            
            pwd0 = pushd(mpr.filepath);
            
            % collect epi and mpr in same folder
            if ~strcmp(mpr.filepath, epi.filepath) 
                epi.filepath = mpr.filepath;
                epi.save();
            end
            transbase = mlfourd.ImagingContext2(strcat(epi.fileprefix, '_to_mpr.nii.gz'));
            
            % run SyN to map epi_brain to targ_brain
            a{1} = sprintf('--dimensionality 3 --float 0 --output [%s_,%s_Warped.nii.gz] ', ...
                transbase.fileprefix, transbase.fileprefix);
            a{2} = '--interpolation Linear --winsorize-image-intensities [0.005,0.995] --use-histogram-matching 0 ';
            a{3} = sprintf('--initial-moving-transform [%s,%s,1] ', ...
                targ_brain.filename, epi_brain.filename);
            a{4} = sprintf('--transform Rigid[0.1] --metric MI[%s,%s,1,32,Regular,0.20] ', ...
                targ_brain.filename, epi_brain.filename);
            a{5} = '--convergence [1000x500x100x0,1e-6,10] --shrink-factors 8x4x2x1 --smoothing-sigmas 3x2x1x0vox ';
            a{6} = '--transform SyN[0.1,3,0] --restrict-deformation 1x1x0 ';
            a{7} = sprintf('--metric CC[%s,%s,1,4] ', ...
                targ_brain.filename, epi_brain.filename);
            a{8} = '--convergence [10,1e-6,10] --shrink-factors 1 --smoothing-sigmas 0vox ';
            a{9} = '--verbose ';
            if ~isfile(sprintf('%s_Warped.nii.gz', transbase.fileprefix))
                tic
                cmd = sprintf('antsRegistration %s%s%s%s%s%s%s%s%s', a{:});
                mlbash(cmd);
                fprintf('%s: \n', cmd);
                toc                
            end
            
            % combine displacement field and affine matrix into concatenated transformation stored as displacement field
            b{1} = sprintf('-d 3 -o [%s_CollapsedWarp.nii.gz,1] ', ...
                transbase.fileprefix);
            b{2} = sprintf('-t %s_1Warp.nii.gz -t %s_0GenericAffine.mat ', ...
                transbase.fileprefix, transbase.fileprefix);
            b{3} = sprintf('-r %s ', ...
                targ_brain.filename);
            if ~isfile(sprintf('%s_CollapsedWarp.nii.gz', transbase.fileprefix))
                tic
                cmd = sprintf('antsApplyTransforms %s%s%s', b{:});
                mlbash(cmd);
                fprintf('%s: \n', cmd)
                toc
            end
            
            % apply all transformations to inference on EPI
            c{1} = sprintf('-d 3 -o %s_Warped.nii.gz ', ...
                inference.fileprefix);
            c{2} = sprintf('-t %s_CollapsedWarp.nii.gz ', ...
                transbase.fileprefix, transbase.fileprefix);
            c{3} = sprintf('-r %s -i %s ', ...
                targ_brain.filename, inference.filename);
            if ~isfile(sprintf('%s_Warped.nii.gz', inference.fileprefix))
                tic
                cmd = sprintf('antsApplyTransforms %s%s%s', c{:});
                mlbash(cmd);
                fprintf('%s: \n', cmd)
                toc
            end
            
            popd(pwd0);
            
            out = mlfourd.ImagingContext2(fullfile(mpr.filepath, strcat(inference.fileprefix, '_Warped.nii.gz')));
        end
        function fp1 = fqfp_add_proc(~, fp, tag)
            assert(istext(fp));
            assert(istext(tag));
            tag = strip(tag, '-');
            if ~contains(fp, '_proc-')
                fp1 = strcat(fp, '_proc-n4');
                return
            end
            re = regexp(fp, '(?<inclproc>\S+_proc\-\S+)(?<postproc>_\S*)', 'names');
            fp1 = strcat(re.inclproc, '-', tag, re.postproc);
        end
        function out = N4BiasFieldCorrection(~, in, out)
            in = mlfourd.ImagingContext2(in);
            out = mlfourd.ImagingContext2(out);
            exec = fullfile(getenv('ANTSPATH'), 'N4BiasFieldCorrection');
            cmd = sprintf('%s -d 3 -i %s -o %s', exec, in.fqfn, out.fqfn);
            mlbash(cmd);

            % jsonrecode(strcat(in.fqfp, '.json'), ...
            %     struct(clientname(true, 2), cmd), ...
            %     'filenameNew', strcat(out.fqfp, '.json'));
        end
        function tf = on_cluster(~)
            tf = contains(hostname, 'cluster');
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
