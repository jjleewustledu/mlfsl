classdef BetStrategy < mlfsl.BetBuilder
    % Interface / Abstract Class
    % This class must be inherited. The child class must deliver the
    % BetStrategy method that accepts the concrete Bet class

    properties (Dependent)
        betOptions
        in_tag
    end
    
    methods %% set/get
        function this = set.betOptions(this, bo)
            assert(isa(bo, 'mlfsl.BetOptions'));
            this.betOptions_ = bo;
        end
        function bo = get.betOptions(this)
            if (isempty(this.betOptions_))
                this.betOptions_ = mlfsl.BetOptions; end
            bo = this.betOptions_;
        end
        function this = set.in_tag(this, fp)
            assert(lexist(filename(fp)));
            bo = this.betOptions;
            bo.in_tag = fp;
            this.betOptions = bo;
        end
        function fp = get.in_tag(this)
            fp = this.betOptions.in_tag;
        end
    end
    
    methods (Abstract)
        bet(imcmp)
    end
    
    methods (Static)
        function concrete = newStrategy(choice, bldr)
            import mlfsl.*;
            p = inputParser;
            addRequired(p, 'choice', @ischar);
            addRequired(p, 'bldr',   @(x) isa(x, 'mlfsl.BetBuilder'));
            parse(p, choice, bldr);
            switch lower(p.Results.choice)
                % If you want to add more strategies, simply put them in
                % here and then create another class file that inherits
                % this class and implements the bet method
                case {'asl' 'casl' 'pasl' 'pcasl'}
                    concrete = BetAsl(p.Results.bldr.converter);
                case {'ciss'}
                    concrete = BetCiss(p.Results.bldr.converter);
                case {'epi' 'ep2d'}
                    concrete = BetEp2d(p.Results.bldr.converter);
                case {'gre' 'swi'}
                    concrete = BetGre(p.Results.bldr.converter);
                case {'mpr' 'mprage' 't1'}
                    concrete = BetT1(p.Results.bldr.converter);
                case {'t2'}
                    concrete = BetT2(p.Results.bldr.converter);
                case {'tof'}
                    concrete = BetTof(p.Results.bldr.converter);
                case {'flair' 'ir'}
                    concrete = BetFlair(p.Results.bldr.converter);
                otherwise
                    error('mlfourd:UnsupportedValue', 'newStrategy.value->%s', p.Results.choice);
            end
        end
    end
    
    %% PROTECTED
    
    properties (Access = 'protected')
        betOptions_
        imagingChoosers_
    end
    
    methods (Static, Access = 'protected')
        function r = radius(imobj)
            nii = imcast(imobj, 'mlfourd.NIfTI');
            r   = norm(nii.size .* nii.mmppix)/4;
        end
        function c = center(imobj)
            nii = imcast(imobj, 'mlfourd.NIfTI');
            c   = (nii.size)/2;
        end
    end
    
    methods (Access = 'protected')
        function fp = inOnT2(this)
            fp = fileprefix( ...
                    this.imagingChoosers_.imageObject( ...
                        this.in_tag, this.imagingChoosers_.choose_t2));
            this.coregister(this.in_tag, this.imagingChoosers_.choose_t2);
        end
        function this = BetStrategy(varargin)
            this = this@mlfsl.BetBuilder(varargin{:});
            this.imagingChoosers_ = mlchoosers.ImagingChoosers(this.fslPath);
        end
    end
    
end

%EOF