classdef FastBuilder < mlfsl.FlirtBuilder
	%% FASTBUILDER is a facade and decorator design pattern for the segmentation tools of FSL
    %  See also:  http://www.fmrib.ox.ac.uk/fsl/fast4/index.html
	%% Version $Revision: 2315 $ was created $Date: 2013-01-17 15:05:05 -0600 (Thu, 17 Jan 2013) $ by $Author: jjlee $  
	%% and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FastBuilder.m $ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id: FastBuilder.m 2315 2013-01-17 21:05:05Z jjlee $ 

    properties (Constant)
        OPTION_NAMES = { 'classes'  'iter' 'lowpass' 'type' 'fHard' 'segments' 'a'     'A'       'nopve'     'b' 'B' 'nobias' ...
                         'channels' 'out'  'Prior'   'init' 'mixel' 'fixed'    'Hyper' 'verbose' 'manualseg' 'p' };
    end
    
    properties
        classes         = 4; % number of tissue-type classes
        iter            = 4; % number of main-loop iterations during bias-field removal
        lowpass         = 20; % bias field smoothing extent (FWHM) in mm
        typeOfImage     = 1; % type of image 1=T1, 2=T2, 3=PD; default=T1
        fHard           = 0.02; % initial segmentation spatial smoothness
        segments        = 'NIL';
        standard2input  = 'NIL'; % <standard2input.mat> initialise using priors; you must supply a FLIRT transform
        alternativePriors = 'NIL'; % <prior1> <prior2> <prior3> alternative prior images
        nopve           = 'NIL'; % turn off PVE (partial volume estimation)
        biasField       = 'NIL'; % output estimated bias field
        biasCorrected   = 'NIL'; % output bias-corrected image
        nobias          = 'NIL'; % do not remove bias field
        Prior           = 'NIL'; % use priors throughout; you must also set the standard2input option
        init            = 15; % number of segmentation-initialization iterations
        mixel           = 0.3; % spatial smoothness for mixeltype    
        fixed           = 4; % number of main-loop iterations after bias-field removal
        Hyper           = 0.1; % segmentation spatial smoothness
        manualseg       = 'NIL'; % filename containing intensities
        probabilityMaps = 'NIL';
    end
    
    properties (Dependent)
        toSegment        
        channelNames       
    end
    
    methods (Static)
        function this = createFromConverter(cverter)
            assert(isa(cverter, 'mlfourd.AbstractDicomConverter'));
            this = mlfsl.FastBuilder(cverter);
        end
    end
    
    methods %% get/set        
        function this   = set.toSegment(this, obj)
            import mlfsl.* mlfourd.*;
            this.toSegment_ = ...
                BetBuilder.ensureBettedExist( ...
                    ensureFilenamesExist( ...
                        ImagingSeries.load(obj)), this.converter);
        end
        function toseg  = get.toSegment(this)
            ensureFilenameExists(this.toSegment);
            toseg = this.toSegment_;
        end
        function this   = set.channelNames(this, chnnls)
            import mlfsl.*;
            this.channelNames_ = ...
                BetBuilder.ensureBettedExist( ...
                        ensureFilenamesExist( ...
                            ImagingComponent.load(chnnls)), this.converter);
        end
        function chnnls = get.channelNames(this)
            ensureFilenamesExist(this.channelNames_);
            chnnls = this.channelNames_;
        end
    end
    
	methods
        function this   = FastBuilder(cverter)
            this = this@mlfsl.FlirtBuilder(cverter);  
        end
        function this   = fastWithFilenames(this, toseg, varargin)
            import mlfsl.*;
            this.toSegment = toseg;
            this.channelNames = varargin;
            this.fast;
        end        
        function [s,r]  = fast(this, varargin)
            %% FAST calls FSL's FAST routines with management of prerequisites
            %  Usage:  [status, stdout] = obj.fast([...])
            
            p = inputParser;
            p.KeepUnmatched = true;
            addParamValue(p, 'toSegment', this.toSegment);
            addParamValue(p, 'channelNames', this.channelNames);
            addParamValue(p, 'classes', this.classes);
            addParamValue(p, 'iter', this.iter);
            addParamValue(p, 'lowpass', this.lowpass);
            addParamValue(p, 'type', this.typeOfImage);
            addParamValue(p, 'fHard', this.fHard);
            addParamValue(p, 'segments', this.segments);
            addParamValue(p, 'a', this.standard2input);
            addParamValue(p, 'A', this.alternativePriors);
            addParamValue(p, 'nopve', this.nopve);
            addParamValue(p, 'b', this.biasField);
            addParamValue(p, 'B', this.biasCorrected);
            addParamValue(p, 'nobias', this.nobias);
            addParamValue(p, 'channels', length(channelNames));
            addParamValue(p, 'out', [this.toSegment '_class']);
            addParamValue(p, 'Prior', this.Prior);
            addParamValue(p, 'init', this.init);
            addParamValue(p, 'mixel', this.mixel);
            addParamValue(p, 'Hyper', this.Hyper);
            addParamValue(p, 'verbose', double(mlpipeline.PipelineRegistry.instance.verbose));
            addParamValue(p, 'manualseg', this.manualseg);
            addParamValue(p, 'p', this.probabilityMaps);
            parse(p, varargin{:});
            assert(~isempty(p.Result.toSegment));
            assert(~isempty(p.Result.channelNames));
            
            fastOptions = struct([]);
            for n = 1:length(this.OPTION_NAMES)
                fastOptions = setOptions(fastOptions, p, this.OPTION_NAMES{n});
            end
            [s,r] = this.fslcmd('fast', fastOptions, p.Result.toSegment, p.Result.channelNames);
            
            function opts = setOptions(opts, p, oname)
                try
                    if (~strcmp('NIL', p.Result.(oname)))
                        opts.(oname) = p.Result.(oname);
                    end
                catch ME
                    handwarning(ME);
                end
            end
        end
    end % methods
    
    %% PRIVATE
    
    properties (Access = 'private')
        toSegment_
        channelNames_
    end
    
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
