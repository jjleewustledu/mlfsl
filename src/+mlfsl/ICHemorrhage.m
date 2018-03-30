classdef ICHemorrhage
	%% ICHEMMORHAGE  
	%  Usage:  ich = ICHemorrhage(queries[, mtt, adc, masks])
    %                             ^ cell-arrays of data to query, filename, NIfTI, NIfTI-subclass
    %
	%  Version $Revision$ was created $Date$ by $Author$  
	%  and checked into svn repository $URL$ 
	%  Developed on Matlab 7.10.0.499 (R2010a) 
	%  $Id$ 

    properties (Constant)
        downsampled_fp   = 'ep2d_0_mcf_meanvol';
        grey_fp          = 'grey';
        white_fp         = 'white';
        csf_fp           = 'csf';
        hemorrhage_fp    = 'hemorrhage';
        contralateral_fp = 'contralateral';
        mtt_fp           = 'mtt_tp1';
        t1_fp            = 'bt1_tp1';
        t2_fp            = 'bt2_tp1';
        flair_fp         = 'bflair_tp1';
		adc_fp           = 'badc_tp1'
        kindExport       = '.xlsx';
        spssExport       = '.dat';
        topFolder        = '/Volumes/LLBQuadra/cvl/MROMI/ICH';
        predictors       = { 'adc' 'dwi' 'flair' 't1' 't2' 'ep2d_0_mcf_meanvol' 'ase_mcf_meanvol' };
        derived          = { 'mtt' 'cbf' 'cbv' };
        times            = { 'tp1' 'tp2' };
    end
    
	properties
        pnum                  = '';
        mttDelayThreshold    = 400;
        adcThreshold         = 160;
        defaultMnrfitOptions = {'estdisp' 'on'};
        rescaling            = ''; % 'relative' or 'normalized' or 'std_moment' or ''
        compact
    end
    
    properties (Dependent, SetAccess = 'private')
        ref_fp
        rank
        size
        mmppix
        pixdim
        downsampled
        queries
        grey
        white
        csf
        hemorrhage
        nohemorrhage
        contralateral
        queriesMask
        mtt
        adcBounded
        mttImpaired
        foreground
        parenchyma
    end
    
    properties (SetAccess = 'private')
        mnr
        designMatrix
        binomialOutcomes
    end
    
    properties (Hidden, Access = 'private')
        downsampled_internal
        queries_internal
        queriesMask_internal
        grey_internal
        white_internal
        csf_internal
        hemorrhage_internal
        contralateral_internal
        mtt_internal
        mttImpaired_internal
        adcBounded_internal
        pipereg_
    end
    
    methods (Static)
        
        function ich = make_all(make_multi)
            
            import mlfsl.*;
            if (exist('make_multi', 'var') && ~isempty(make_multi))
                
                multi = horzcat(ICHemorrhage.predictors, ICHemorrhage.derived);
                for m = 1:numel(multi)
                    multi{m} = ['d' multi{m} '_tp2'];
                end
                ich = ICHemorrhage.prepQueries(multi);
            else
                
                for p = 1:numel(ICHemorrhage.derived)
                    try
                        ich = ICHemorrhage.prepQuery(['d' ICHemorrhage.derived{p} '_tp2']);
                    catch ME
                        warning('mlfsl:MethodExecFailure', '%s\n', getReport(ME));
                    end
                    for t = 1:numel(ICHemorrhage.times)
                        try
                            ich = ICHemorrhage.prepQuery([ICHemorrhage.derived{p} '_' ICHemorrhage.times{t}]);
                        catch ME
                            warning('mlfsl:MethodExecFailure', '%s\n', getReport(ME));
                        end
                    end
                end

                for p = 1:numel(ICHemorrhage.predictors)
                    try
                        ich = ICHemorrhage.prepQuery(['d' ICHemorrhage.predictors{p} '_tp2']);
                    catch ME
                        warning('mlfsl:MethodExecFailure', '%s\n', getReport(ME));
                    end
                    for t = 1:numel(ICHemorrhage.times)
                        try
                            ich = ICHemorrhage.prepQuery(['b' ICHemorrhage.predictors{p} '_' ICHemorrhage.times{t}]);
                        catch ME
                            handexcept(ME, 'mlfsl:MethodExecFailure');
                        end
                    end
                end
            end % if (exist('make_multi'...
        end % static make_all
        
        function obj = prepQuery(query, mtt, adc, msks)
            
            %% PREPQUERY
            %  Usage:  obj = prepQuery(query[, mtt(tp1), adc(tp1), msks])
            %                          ^ univariate predictor variable
            import mlfsl.* mlfourd.*;
            if (~exist('mtt', 'var'))
                mtt = NIfTI.load(ICHemorrhage.mtt_fp);
            end
            if (~exist('adc', 'var'))
                adc = NIfTI.load(ICHemorrhage.adc_fp);
            end
            if (~exist('msks', 'var'))
                obj = ICHemorrhage.prepQueries(ensureNiiCell(query), mtt, adc);
            else
                obj = ICHemorrhage.prepQueries(ensureNiiCell(query), mtt, adc, msks); 
            end
        end % static prepQuery
        
        function [obj,compact] = prepQueries(qries, mtt, adc, msks)
            
            %% PREPQUERIES
            %  Usage:  obj = prepQueries(queries[, mtt(tp1), adc(tp1), msks])
            %                            ^         ^ cell-array of filename strings, NIfTIs, NIfTI subclasses
            %                                        of predictor variables to use simultaneously in logistic regression
            import mlfsl.* mlfourd.*;
            qries = ensureNiiCell(qries);
            if (~exist('mtt', 'var'))
                mtt = NIfTI.load(ICHemorrhage.mtt_fp);
            end
            if (~exist('adc', 'var'))
                adc = NIfTI.load(ICHemorrhage.adc_fp);
            end
            if (~exist('msks', 'var'))
                msks = ICHemorrhage.loadDefaultMasks; 
            end
            msks    = ensureNiiCell(msks);
            obj     = ICHemorrhage(qries, mtt, adc, msks);
            rois    = { obj.foreground }; % { obj.foreground obj.grey obj.white obj.csf };
            compact = cell(1,numel(rois));
            for r = 1:numel(rois)
                fprintf(1, 'obj = ICHemorrhage.prepQueries.make_mnr(%s)\n', rois{r}.label, rois{r}.label);
                obj = obj.make_mnr(rois{r});
            end
        end % static prepQueries

        function [pnii1,pnii0,obj] = prepProbMaps(query)
            import mlfsl.* mlfourd.*;
            query   = ensureNii(query);
            obj     = ICHemorrhage.prepQueries(query);
            queryBr = NiiBrowser(query);
            queryBl = queryBr.blockedBrowser(obj.mmppix ./ query.mmppix);
            mnrf    = @(x) mnrval(obj.mnr.B, x);
            imgs    = arrayfun(mnrf, queryBl.img, 'UniformOutput', false);
            im0     = cell2mat(imgs);
            im1     = cell2mat(imgs);
            pnii0   = queryBl.makeSimilar(im0(:,2:2:end,:), 'prob map of no-hem', '_probmap0');
            pnii1   = queryBl.makeSimilar(im1(:,1:2:end,:), 'prob map of hem', '_probmap1');
            pnii1.dipshow
        end
        
        function obj = plot4Hongyu(query, dquery, mtt, adc, msks)
            
            import mlfsl.* mlfourd.*;
            query  = ensureNiiCell(query);
            dquery = ensureNiiCell(dquery);
            if (~exist('mtt', 'var'))
                mtt = NIfTI.load(ICHemorrhage.mtt_fp);
            end
            if (~exist('adc', 'var'))
                adc = NIfTI.load(ICHemorrhage.adc_fp);
            end
            if (~exist('msks', 'var'))
                msks = ICHemorrhage.loadDefaultMasks; 
            end
            msks = ensureNiiCell(msks);
             obj = ICHemorrhage( query, mtt, adc, msks);
            dobj = ICHemorrhage(dquery, mtt, adc, msks);
            
            [ nohem, hem] =  obj.hemorrhageSpanVecs(obj.parenchyma);
            [dnohem,dhem] = dobj.hemorrhageSpanVecs(obj.parenchyma);
             nohem =  nohem{1};
               hem =    hem{1};
            dnohem = dnohem{1};
              dhem =   dhem{1};
            if (length(hem) ~= length(dhem))
                newlen = min(length(hem), length(dhem));
                   hem =    hem(1:newlen);
                  dhem =   dhem(1:newlen);
                 nohem =  nohem(1:newlen);
                dnohem = dnohem(1:newlen);
            end
            % que = vertcat( hem,  nohem);
            %dque = vertcat(dhem, dnohem);
            %grp  = vertcat(2*ones(size(hem)), ones(size(nohem)));
            %gscatter(que, dque, grp, 'rb', '..');
            obj.make_hongyusPlot(hem, dhem, nohem, dnohem, query{1}.label, dquery{1}.label);
        end
        
        function msks = loadDefaultMasks
            
            import mlfsl.* mlfourd.*;
            msks = cell(1, 6);
            msks{1} = NIfTI_mask.load(ICHemorrhage.downsampled_fp);
            msks{2} = NIfTI_mask.load(ICHemorrhage.grey_fp);
            msks{3} = NIfTI_mask.load(ICHemorrhage.white_fp);
            msks{4} = NIfTI_mask.load(ICHemorrhage.csf_fp);
            msks{5} = NIfTI_mask.load(ICHemorrhage.hemorrhage_fp);
            msks{6} = NIfTI_mask.load(ICHemorrhage.contralateral_fp);
        end % static loadDefaultMasks
                     
        function nii = cellIntersectionMask(c)
            
            import mlfsl.* mlfourd.*;
            assert(iscell(c)); assert(~isempty(c));
            c1  = NIfTI(c{1});
            nii = NIfTI_mask(c1, 'binary', 0.02);
            for ci = 1:numel(c)
                cwork = NIfTI(c{ci});
                assert(all(c1.size == cwork.size));
                nii   = ICHemorrhage.intersectionMask(nii, cwork);
            end
        end % static cellIntersectionMask
        
        function nii = intersectionMask(nii1, nii2)
            
            %% INTERSECTION returns the set-intersectionMask of two NIfTIs as a NIfTI
            %  Usage:  mask = intersectionMask(nii1, nii2)
            %                                  ^     ^ any real-valued NIfTI
            import mlfourd.*;
            nii1           = NIfTI_mask(nii1, 'binary', 0.02);
            nii2           = NIfTI_mask(nii2, 'binary', 0.02);
            nii            = nii1 & nii2;
            nii.fileprefix = [nii1.fileprefix '_and_' nii2.fileprefix];
            nii.descrip    = ['intersection-mask of ' nii1.label ' and ' nii2.label];
            assert(nii.dipmax <= 1);
            assert(nii.dipmin >= 0);
            assert(nii.dipsum >  0);
            clear('nii1', 'nii2');
        end % static intersectionMask
        
        function make_seg_mrp(seg_fp, csfId, greyId, whiteId, bldr)
            import mlfsl.* mlfourd.*;
            flirtf    = FlirtBuilder(bldr);
            opts      = FlirtOptions;
			opts.ref  = 't1';
			opts.in   = seg_fp;
			opts.out  = [seg_fp '_on_bt1'];
			opts.init =  'bflair_to_bt1.mat';
            flirtf.applyTransform(opts);
            seg       = NIfTI.load([seg_fp '_on_bt1']);
            csf_      = seg.makeSimilar(seg.img == csfId, 'csf',     ICHemorrhage.white_fp);
            grey_     = seg.makeSimilar(seg.img == greyId, 'grey',   ICHemorrhage.white_fp);
            white_    = seg.makeSimilar(seg.img == whiteId, 'white', ICHemorrhage.white_fp);
            csf_.save;
            grey_.save;
            white_.save;
        end % static make_seg_mrp
        
        function [v0,v1] = balance_data(v0, v1)
            
            v0bigger = numel(v0) > numel(v1);
            if (v0bigger)
                bigger = v0; smaller = v1;
            else
                bigger = v0; smaller = v0;
            end
            tmp = zeros(numel(smaller), 1);
            for t = 1:numel(smaller)
                tmp(t) = bigger(randi(numel(smaller)));
            end 
            bigger = tmp;
            if (v0bigger)
                v0 = bigger; v1 = smaller;
            else
                v0 = smaller; v1 = bigger; 
            end
            disp('WARNING:   sampling with replacement');
        end % static balance_data

        function nii = make_contralateral_fromMNI(target, bldr)
            
            import mlfourd.* mlfsl.*;
            target  = NIfTI(target);
            if (~NIfTI.isNIfTI(target.fqfn)); target.save; end
            
            fslf    = FslBuilder(bldr);
            mni     = NIfTI.load(fslf.std_fp);
            msz     = mni.size;
            mni.img = zeros(msz);
            tmp     = zeros(msz(1), msz(2));
            mni.img = repmat(tmp, [1 1 msz(3)]);
            mni.fileprefix = 'contralateral_on_MNI';
            mni.noclobber  = 'true';
            mni.save
            
            assert(NIfTI.isNIfTI('MNI_to_bt1.mat'));
            opts      = FlirtOptions;
			opts.ref  = target.fileprefix;
			opts.in   = mni.fileprefix;
			opts.out  = ICHemorrhage.contralateral_fp;
			opts.init = 'MNI_to_bt1.mat';
            flirtf.applyTransform(opts);
            assert(NIfTI.isNIfTI(ICHemorrhage.contralateral_fp));
            nii        = NIfTI.load(ICHemorrhage.contralateral_fp);
        end % make_contralateral_fromMNI

        
    end % static methods

    methods
        
        function this = ICHemorrhage(qries, mtt, adc, msks)
            
            %% ICHEMMORHAGE (ctor)
            %  Usage:  obj = ICHemorrhage(queries[, mtt, adc, masks])
            %                             ^ cell-arrays of data to query, filename, NIfTI, NIfTI-subclass
            import mlfsl.* mlfourd.*;
            if (~iscell(qries))
                qries = {NIfTI(qries)};
            end
            this.queries = qries;
            if (~exist('mtt', 'var'))
                mtt = NIfTI.load(ICHemorrhage.mtt_fp);
            end
			this.mtt_internal = NIfTI(mtt);
            if (~exist('adc', 'var'))
                this.adcBounded = NIfTI.load(ICHemorrhage.adc_fp);
            else
                this.adcBounded = adc;
            end
            if (~exist('msks', 'var'))
                msks = ICHemorrhage.loadDefaultMasks; 
            end
            for m = 1:numel(msks)
                msks{m} = NIfTI_mask(msks{m});
                switch (msks{m}.fileprefix)
                    case this.downsampled_fp
                        msks{m}.protect             =  false;
                        msks{m}                     =  msks{m}.rescaleToUnity;
                        this.downsampled_internal   =  msks{m}.asBinaryMask(0.05);
                    case this.grey_fp
                        this.grey_internal          =  msks{m} & not(this.adcBounded);
                    case this.white_fp
                        this.white_internal         =  msks{m} & not(this.adcBounded);
                    case this.csf_fp
                        this.csf_internal           =  msks{m} | this.adcBounded;
                    case this.hemorrhage_fp
                        msks{m}.protect             =  false;
                        msks{m}                     =  msks{m}.rescaleToUnity;
                        this.hemorrhage_internal    =  msks{m};
                    case this.contralateral_fp
                        this.contralateral_internal =  msks{m};
                end
            end
            this.pipereg_ = mlpipeline.PipelineRegistry.instance;
            
            if (this.pipereg_.verbose > 0.5)
                this.save_and_show(this.downsampled);
                this.save_and_show(this.grey);
                this.save_and_show(this.white);
                this.save_and_show(this.csf);
                this.save_and_show(this.hemorrhage);
                this.save_and_show(this.nohemorrhage);
                this.save_and_show(this.contralateral);
                this.save_and_show(this.mtt);
                this.save_and_show(this.mttImpaired); 
                this.save_and_show(this.queriesMask);
                this.save_and_show(this.foreground);
                this.save_and_show(this.parenchyma);
            end
        end % ctor
        
        %% MTT metohds
        
        function this = set.mtt(this, m)
            this.mtt_internal          = mlfourd.NIfTI(m);
            this.mttImpaired_internal = mlfourd.NIfTI_mask( ...
                                         this.mttDelay > this.mttDelayThreshold, ...
                                         'binary', eps);
            this.mttImpaired_internal = this.mttImpaired_internal & this.parenchyma;
            this.mttImpaired_internal.fileprefix = 'mttImpaired';
        end
        
        function m = get.mtt(this)
            m = mlfourd.NIfTI(this.mtt_internal);
        end
                
        function m = get.mttImpaired(this)
            if (isempty(this.mttImpaired_internal) || ~isa(this.mttImpaired_internal, 'mlfourd.INIfTI'))
                this.mttImpaired_internal = mlfourd.NIfTI_mask( ...
                                            this.make_relative(this.mtt) > this.mttDelayThreshold, 'binary', eps);
                this.mttImpaired_internal = this.mttImpaired_internal & this.parenchyma;
                this.mttImpaired_internal.fileprefix = 'mttImpaired';
            end
            m = this.mttImpaired_internal;
        end
        
        function delay = mttDelay(this)
            
            %% MTTDELAY is the local MTT relative to the mean MTT oft he contralateral hemisphere
            delay = this.make_relative(this.mtt_internal);
        end
        
        %% Queries methods        
        
        function this = set.queries(this, qs)
            this.queries_internal = cell(1,numel(qs));
            
            % preloading this.queries to set queriesMask
            for q = 1:numel(qs)
                this.queries_internal{q} = mlfourd.NIfTI(qs{q});
            end
            this.queriesMask_internal = mlfsl.ICHemorrhage.cellIntersectionMask(this.queries_internal);
            this.queriesMask_internal.fileprefix = 'queriesMask';
            
            % make calls to queriesMask as needed
            for q = 1:numel(qs)
                aq = this.queries{q};
                if (isempty(aq.rescaling))
                    this.queries_internal{q} = this.make_rescaled(aq);
                end
            end
        end
        
        function qs = get.queries(this)
            assert(~isempty(this.queries_internal));
            qs            = this.queries_internal;
        end
        
        %% ADC methods
        
        function this = set.adcBounded(this, adc)
            import mlfourd.*;
            this.adcBounded_internal = NIfTI_mask(NIfTI(adc) > this.adcThreshold);
        end
        
        function msk = get.adcBounded(this)
            if (isempty(this.adcBounded_internal) || ~isa(this.adcBounded_internal, 'mlfourd.INIfTI'))
                try 
                    tmp = mlfourd.NIfTI.load(this.adc_fp);
                    this.adcBounded_internal = mlfourd.NIfTI_mask(tmp > this.adcThreshold);
                    clear('tmp');
                catch ME
                    handexcept(ME, ['ICHemorrhage.get.adcBounded could not find this.adcBounded_internal and could not read file ' ...
                                     this.adc_fp]);
                end
            end    
            msk = this.adcBounded_internal;
        end
        
        %% Reference/Target methods
        
        function fp = get.ref_fp(this)
            assert(~isempty(this.t1_fp));
            fp = this.t1_fp;
        end
        
        function r = get.rank(this)
            r = this.downsampled;
            r = r.rank;
        end
   
        function s = get.size(this)
            s = this.downsampled;
            s = s.size;
        end    
        
        function p = get.pixdim(this)
            p = this.downsampled;
            p = p.pixdim;
        end        
        
        function m = get.mmppix(this)
            m = this.downsampled;
            m = m.mmppix;
        end
        
        function d = get.downsampled(this)
                this.downsampled_internal = mlfourd.NIfTI(this.downsampled_internal);
            d = this.downsampled_internal;
            d.fileprefix = 'downsampledTarget';
        end
        
        %% ROI methods
        
        function g = get.grey(this)
                this.grey_internal = mlfourd.NIfTI(this.grey_internal);
            g = this.grey_internal & this.queriesMask & not(this.adcBounded);
            g.fileprefix = 'greyQueries';
        end
                        
        function g = get.white(this)
                this.white_internal = mlfourd.NIfTI(this.white_internal);
            g = this.white_internal & this.queriesMask & not(this.adcBounded);
            g.fileprefix = 'whiteQueries';
        end
                         
        function g = get.csf(this)
            this.white_internal = mlfourd.NIfTI(this.white_internal);
            g = this.csf_internal | this.adcBounded;
            g = g                 & this.queriesMask;
            g.fileprefix = 'csfQueries';
        end
           
        function h = get.hemorrhage(this)
                this.hemorrhage_internal = mlfourd.NIfTI(this.hemorrhage_internal);
                this.hemorrhage_internal = double(this.hemorrhage_internal);
                this.hemorrhage_internal = this.hemorrhage_internal ./ this.hemorrhage_internal.dipmax;
                this.hemorrhage_internal = mlfourd.NIfTI_mask(this.hemorrhage_internal, 'binary', 0.98);
            h = this.hemorrhage_internal & this.parenchyma;
            h.fileprefix = 'hemorrhageQueries';
        end
        
        function nh = get.nohemorrhage(this)
            mttimp = this.mttImpaired;
            hem    = this.hemorrhage;
            if (mttimp.dipsum > hem.dipsum)
                nh = not(this.contralateral) & not(hem) & mttimp;
            else
                nh = not(this.contralateral) & not(hem);
                warning('mlfsl:StrategyChange', ...
                       ['N{hem vxls}->' num2str(hem.dipsum) ', N{mtt-impaired vxls}->' num2str(mttimp.dipsum) ...
                        '; dropping requirement for mtt_impairment in no-hemorrhage voxels']);
            end
            nh = mlfourd.NIfTI_mask(nh, 'binary', 0.05);
            nh = nh & this.parenchyma;
            nh.fileprefix = ['no' this.hemorrhage.fileprefix];
        end
        
        function c = get.contralateral(this)
            c            =  mlfourd.NIfTI(this.contralateral_internal);
            c.fileprefix = 'contralateralQueries';
        end

        function qm = get.queriesMask(this)
            qm = this.queriesMask_internal;
        end
        
        function f = get.foreground(this)
            f = this.parenchyma;
        end
        
        function p = get.parenchyma(this)
            p            = mlfourd.NIfTI_mask(this.grey | this.white, 'binary', 0.95);
            p            = p & this.queriesMask;
            p.fileprefix = 'parenchymaMask';
        end
        
        %% OTHER CALCULATION METHODS
        
        function rs = rescalingfind(~, str) 
            if (isa(str, 'mlfourd.INIfTI'))
                str = str.fileprefix; 
            end
            assert(ischar(str));
            if     (lstrfind(lower(str), 'adc'))
                rs = 'none';
            elseif (lstrfind(lower(str), 'mtt'))
                rs = 'relative';
            else
                rs = 'std_moment';
            end
        end % rescalingfind
        
        function cmean = contralat_mean(this, nii)
            nii       = mlfourd.NIfTI(nii);
            contralat = this.contralateral .* this.parenchyma;
            cnii      = contralat .* nii ./ contralat.dipsum;
            cmean     = cnii.dipsum;
            assert(numel(cmean) == 1);
            assert(~isnan(cmean));
            clear('nii','cmat');
        end % contralat_mean
        
        function cstd = contralat_std(this, nii)
            nii       = mlfourd.NIfTI(nii);
            contralat = this.contralateral .* this.parenchyma;
            cmat      = contralat.img .* nii.img;
            cvec      = cmat(cmat ~= 0);
            cstd       = std(cvec);
            assert(numel(cstd) == 1);
            assert(~isnan(cstd));
            clear('nii','cmat','cvec');
        end % contralat_std      
        
        function nii = make_relative(this, nii)

            %% MAKE_RELATIVE to mean of contralateral hemisphere
            nii = nii - this.contralat_mean(nii);
            nii = nii.append_fileprefix('_relative'); 
        end % make_relative
             
        function nii = make_rescaled(this, nii, rescaling)

            %% RESCALE to mean of contralateral hemisphere; checks value of this.rescaling
            if (~exist('rescaling', 'var'))
                rescaling = this.rescalingfind(nii.fileprefix);
            end
            switch (lower(rescaling))
                case { '', 'none', 'no' }
                    nii.rescaling = 'none';
                case 'relative'
                    nii.rescaling = 'relative';
                    nii           =  this.make_relative(nii);
                case {'over_contralateral_mean', 'normalized'}
                    nii.rescaling = 'over_contralateral_mean';
                    nii           =  nii ./ abs(this.contralat_mean(nii)); 
                    nii           =  nii.append_fileprefix('_over_contralat_mean');
                case 'std_moment'
                    nii.rescaling = 'std_moment';
                    nii           = (nii - this.contralat_mean(nii)) ./ this.contralat_std(nii);
                    nii           =  nii.append_fileprefix('_std_moment');
                otherwise
                    paramError(this, 'this.rescaling', this.rescaling);
            end
            nii = this.labelrescaling(nii, rescaling);
            %% nii.img = scrubNaNs(nii.img); % crashes NIfTI.set.img
            if (this.pipereg_.verbose > eps)
                fprintf(1, 'ICHemorrhage.make_rescaled:  rescaled %s by %s\n', nii.label, rescaling);
                disp(nii);
            end
        end % make_rescaled
        
        function nii = labelrescaling(~, nii, rescaling) 
            
            %% LABELRESCALING updates passed NIfTI with rescaling info and updates label field
            if (~exist('rescaling', 'var')); rescaling = nii.rescaling; end
            
            % pretty printing
                                      lbl = upper(nii.label);
            if (strcmp('B', lbl(1))); lbl = lbl(2:end); end
            if (strcmp('D', lbl(1))); lbl = ['Delta ' lbl(2:end)]; end
            found = strfind(lbl, '_TP1');
            if (~isempty(found));     lbl(found:found+3) = '(t1)'; end
            found = strfind(lbl, '_TP2');
            if (~isempty(found));     lbl(found:found+3) = '(t2)'; end
            found = strfind(lbl, '_TP3');
            if (~isempty(found));     lbl(found:found+3) = '(t3)'; end
            found = strfind(lbl, '_TP24HR');
            if (~isempty(found))
                lbl_end = lbl(found+7:end);
                lbl     = [lbl(1:found-1) '(24hr)' lbl_end];
            end
            nii.label = lbl;
            
            % ensuring nii.rescaling
            if (isempty(nii.rescaling))
                nii.rescaling = rescaling;
            else
                nii.rescaling = [nii.rescaling '_' rescaling];
            end
        end % labelrescaling

        function nii = downsample(this, nii)
            import mlfourd.*;
            nii = NiiBrowser(nii);
            nii = NIfTI(nii.blockedBrowser(this.mmppix ./ nii.mmppix));
        end % downsample
        
        %% Vector-creation methods
        
        function vecs = queriesToVecs(this, roi)
            import mlfourd.*;
            vecs        = cell(1, numel(this.queries));
            for q = 1:numel(this.queries)
                nii     = this.downsample(this.queries{q}) .* roi;
                vecs{q} = nii.img(roi.img ~= 0);
                fprintf(1, 'ICHemorrhage.queriesToVecs:  roi->%s, query->%s, length->%i\n', ...
                            roi.label, this.queries{q}.label, length(vecs{q}));
            end
        end % queriesToVecs
        
        function [noHVecs,hVecs] = hemorrhageSpanVecs(this, roi)
            
            import mlfsl.* mlfourd.*;
            roi0 = this.downsample(roi .* this.nohemorrhage);
            roi1 = this.downsample(roi .* this.hemorrhage);
            [roi0,roi1] = NIfTI_mask.matchMasks(roi0, roi1);
            roi0.fileprefix = ['roi0_nohemorrhage_' roi.fileprefix '_' datestr(now, 30)];
            roi1.fileprefix = ['roi1_hemorrhage_'   roi.fileprefix '_' datestr(now, 30)];
            roi0.save;
            roi1.save;
            noHVecs = this.queriesToVecs(roi0);
              hVecs = this.queriesToVecs(roi1);
              
            % final adjustments of vector lengths
            for q = 1:numel(this.queries)
                len0 = length(noHVecs{q});
                len1 = length(hVecs{q});
                if     (len0 > len1)
                    noHVecs{q} = noHVecs{q}(1:len1);
                elseif (len0 < len1)
                      hVecs{q} =   hVecs{q}(1:len0);
                end
                fprintf(1, 'ICHemorrhage.hemorrhageSpanVecs:  query->%s, N{no-hem}->%g, N{hem}->%g\n', ...
                            this.queries{q}.label, length(noHVecs{q}), length(hVecs{q}));
            end
        end % hemorrhageSpanVecs

        %% Make and write methods
        
        function this = make_mnr(this, roi)
            
			import mlfourd.*;
            qlabels    = this.queries{1}.label;
            rescalings = this.queries{1}.rescaling;
            for q = 2:numel(this.queries)
                qlabels    = strtrim([this.queries{q}.label     '(x)' qlabels]);
                rescalings = strtrim([this.queries{q}.rescaling ','   rescalings]);
            end
            this = this.mnrfit(roi);
            this = this.mnrval;
            this.fprintf(            ['ICH_' roi.label '_' qlabels '.txt'], rescalings);
            this.writeModelCoeff_xls(['ICH_' roi.label '_' qlabels this.kindExport]);
        end % make_mnr
        
        function ti = make_title(this, q)
            ti     = ['Logistic Regression, pt ' this.pnum ', ' this.queries{q}.label];
        end % make_title
        
        function fprintf(this, fn, rescalings)
            
            %% FPRINTF 
            %  Usage:  count = obj.fprintf(fn)
            import mlpublish.*;
            if (isempty(rescalings)); rescalings = 'none'; end
            try
                if (exist('fn', 'var'))
                    fid = fopen(fn, 'a'); % appends
                else
                    fid = 1;
                end
                
                B     = this.mnr.B;
                dev   = this.mnr.dev;
                stats = this.mnr.stats;
                fprintf(fid, '\n\n');
                fprintf(fid, 'Design Matrix, Model Params, Exp(B_i), Std Err B, Corr Matrix B, ..., Covar B, ..., T-statistic, P-value, Dispersion, N no-hem voxels, N hem voxels, rescalings\n');
                for k = 1:numel(B)
                    fprintf(fid, '%s, B(%i)=%10.5g, %10.5g, %10.5g, %10.5g, %10.5g, %10.5g, %10.5g, %10.5g, %10.5g, %10.5g', ...
                                 this.flabel(k-1), k-1, B(k), exp(B(k)), stats.se(k), stats.coeffcorr(k,1), ...
                                 stats.coeffcorr(k,2), stats.covb(k,1), stats.covb(k,2), stats.t(k), stats.p(k), ...
                                 stats.sfit);
                    if (1 == k)
                        fprintf(fid, ', %i, %i, %s\n', this.mnr.numNoHVoxels, this.mnr.numHVoxels, rescalings);
                    else
                        fprintf(fid, '\n');
                    end
                end
                fprintf(fid, '\n\n');
                fprintf(fid, 'Deviance of fit:  %10.5g\n\n', dev);

                phat = this.mnr.phat;
                dhi  = this.mnr.dhi;
                dlo  = this.mnr.dlo;
				for k = 1:size(phat,2)
					phat_ = phat(:,k);
					dhi_  = dhi(:,k);
					dlo_  = dlo(:,k);
					try
                		this.make_figure(this.designMatrix, horzcat(cumsum(phat_,2), cumsum(phat_+dhi_,2), cumsum(phat_-dlo_,2)));
					catch ME
						disp(ME);
					end
				end
                if (exist('fn', 'var')); fclose(fid); end   
            catch ME
                fprintf(1, '%s\n', getReport(ME));
            end
        end % fprintf
        
        function figure1 = make_figure(this, X1, YMatrix1, title_str, xlbl_str, ylbl_str)
            
            %% MAKE_FIGURE(X1,YMATRIX1,TITLE_STR,XLABEL,YLABEL)
            %  X1:  vector of x data
            %  YMATRIX1:  matrix of y data

            %  Auto-generated by MATLAB on 13-Aug-2010 17:51:37

            % Create figure
            figure1 = figure('XVisual','0x24 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)',...
                'InvertHardcopy','off',...
                'Color',[1 1 1]);

            % Create axes
            axes1 = axes('Parent',figure1,'FontSize',12);
            % Uncomment the following line to preserve the X-limits of the axes
            % xlim(axes1,[-2500 1500]);
            % Uncomment the following line to preserve the Y-limits of the axes
            % ylim(axes1,[0 1.4]);
            % Uncomment the following line to preserve the Z-limits of the axes
            % zlim(axes1,[-1 1]);
            box(axes1,'on');
            hold(axes1,'all');

            % Create multiple lines using matrix input to plot
            plot1 = plot(X1,YMatrix1,'MarkerSize',4,'Marker','.','LineStyle','none','Parent',axes1);
            set(plot1(1),'MarkerFaceColor',[1 0 0],'Marker','o','Color',[1 0 0]);
            set(plot1(2),'MarkerFaceColor',[0 0 0],'Marker','o','Color',[0 0 0]);
            set(plot1(3),'MarkerFaceColor',[0.847058832645416 0.160784319043159 0],...
                'Color',[0.847058832645416 0.160784319043159 0]);
            set(plot1(4),'MarkerFaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
                'Color',[0.501960813999176 0.501960813999176 0.501960813999176]);
            set(plot1(5),'MarkerFaceColor',[0.847058832645416 0.160784319043159 0],...
                'Color',[0.847058832645416 0.160784319043159 0]);
            set(plot1(6),'MarkerFaceColor',[0.501960813999176 0.501960813999176 0.501960813999176],...
                'Color',[0.501960813999176 0.501960813999176 0.501960813999176]);

            % Create xlabel
            if (~exist('xlbl_str', 'var'))
                xlbl_str = [this.queries{1}.label ', ' this.queries{1}.rescaling];
            end
            xlabel(xlbl_str,'FontWeight','bold','FontSize',14);

            % Create ylabel
            if (~exist('ylbl_str', 'var'))
                ylbl_str = 'Cumulative probability of hemorrhage';
            end
            ylabel(ylbl_str,'FontWeight','bold','FontSize',14);

            % Create title
            if (~exist('title_str', 'var'))
                title_str = ['Logistic regression, pt ' num2str(this.pnum) ', ' this.queries{1}.label];
            end
            title(title_str,'FontSize',14);
            
            
            
            props = PublishProperties(fn, this.make_title(k-1));
                    ScatterPublisher.refinePlotForPublication(props, gcf);
                    ScatterPublisher.printFigure(gcf, props);
        end
        
        function figure1 = make_hongyusPlot(this, XData1, YData1, XData2, YData2, label, dlabel)
            %CREATEFIGURE(XDATA1,YDATA1,XDATA2,YDATA2)
            %  XDATA1:  line xdata
            %  YDATA1:  line ydata
            %  XDATA2:  line xdata
            %  YDATA2:  line ydata

            %  Auto-generated by MATLAB on 18-Aug-2010 03:13:50

            % Create figure
            figure1 = figure('XVisual','0x24 (TrueColor, depth 24, RGB mask 0xff0000 0xff00 0x00ff)','Color',[1 1 1]);

            % Create axes
            axes1 = axes('Parent',figure1,'FontSize',12);
            % Uncomment the following line to preserve the X-limits of the axes
            % xlim(axes1,[20 166.814224243164]);

            % Create line
            line(XData1,YData1,'Parent',axes1,'Marker','+','LineStyle','none','Color',[1 0 0],'DisplayName','hem');

            % Create line
            line(XData2,YData2,'Parent',axes1,'MarkerSize',4,'Marker','o','LineStyle','none','Color',[0 0 1],...
                'DisplayName','no-hem');

            % Create xlabel
            xlabel(label,'FontSize',14);

            % Create ylabel
            ylabel(['',sprintf('\n'),dlabel],'FontSize',14);

            % Create title
            title({['pt ' this.pnum ', hemorrhage and no-hemorrhage']},'FontSize',16,'BackgroundColor',[1 1 1]);

            % Create legend
            legend(axes1,'show');
            
            filename = ['ICH_' label '_vs_' dlabel];
            disp(['Printing EPSC2 in CMYK at ' num2str(200) ' dpi to ' filename '.eps..........']);
            print(gcf, '-depsc2', '-cmyk', ['-r' 200], [filename '.eps']); %#ok<MCPRT>
        end % make_hongyusPlot
        
        function lbl = flabel(this,q)
            if (0 == q)
                lbl = 'intercept';
            else
                lbl = this.queries{q}.label;
            end
        end
        
        function [success,msg] = writeModelCoeff_xls(this, filename)
            try
                [success,msg] = xlswrite(filename, cat(2, this.designMatrix, this.binomialOutcomes(:,1)));
            catch ME
                fprintf(1, '%s\n', getReport(ME));
            end
        end % write_xls
        
        function writeModelCoeff_spss(this, filename)
            mat    = horzcat(this.designMatrix, this.binomialOutcomes - 1);
            labels = cell(1, numel(this.queries));
            for  q = 1:numel(this.queries)
                labels{q} = this.queries{q}.label;
            end
            try
                save4spss(mat, labels, filename);
            catch ME
                fprintf(1, '%s\n', getReport(ME));
            end
        end % write_spss
    end % methods
    
    methods (Access='protected')
        
        function this = mnrfit(this, roi)
            
            %% MNRFIT performs logistic regression on predictive parameters in this.queries (cell-array).
            %  Same masks used for all instances of this.
            
            Nq              = length(this.queries);
            [noHVecs,hVecs] = this.hemorrhageSpanVecs(roi);
            mat0            = noHVecs{1};
            mat1            =   hVecs{1};
            N0              = numel(noHVecs{1});
            N1              = numel(  hVecs{1});
            assert(N0 == N1);
            if (Nq > 1)
                for q = 2:Nq
                    noHVec = noHVecs{q};
                      hVec =   hVecs{q};
                    assert(N0 == numel(noHVec));
                    assert(N1 == numel(  hVec));
                    mat0 = horzcat(mat0, noHVec); %#ok<AGROW>
                    mat1 = horzcat(mat1,   hVec); %#ok<AGROW>
                end
            end
            assert(size(mat0,2)  == numel(noHVecs)); % match number of predictor variables
            assert(size(mat1,2)  == numel(  hVecs));
            this.designMatrix     = vertcat(mat1, mat0);
            hemorrhages           = horzcat( ones(size(mat1,1),1), zeros(size(mat1,1),1));
            nohemorrhages         = horzcat(zeros(size(mat0,1),1),  ones(size(mat0,1),1));
            this.binomialOutcomes = vertcat(hemorrhages, nohemorrhages);
            if (this.pipereg_.debugging)
                for q = 1:Nq
                    figure
                    hist(noHVecs{q}, 100);
                    h = findobj(gca,'Type','patch');
                    set(h,'FaceColor', [0.1 0.1 (q/Nq)],'EdgeColor','w')
                    title(['No-hemorrhage Voxels; Predictor:  ' this.queries{q}.label])
                    figure
                    hist(hVecs{q}, 100);
                    h = findobj(gca,'Type','patch');
                    set(h,'FaceColor', [(q/Nq) 0.1 0.1],'EdgeColor','w')
                    title(['Hemorrhage Voxels; Predictor:  ' this.queries{q}.label])
                end
            end
            [B,dev,stats]              = mnrfit(this.designMatrix, this.binomialOutcomes);
            this.mnr = struct('B', B, 'dev', dev, 'stats', stats, 'numNoHVoxels', N0, 'numHVoxels', N1);
        end % mnrfit
        
        function this = mnrval(this)
            
            %% MNRVAL
            assert(~isempty(this.mnr));
            assert( isstruct(this.mnr));
            [this.mnr.phat, this.mnr.dlo, this.mnr.dhi] = mnrval(this.mnr.B, this.designMatrix, this.mnr.stats);
        end % mnrval
        
        function c = make_compact(this)
            
            c = struct('dateCreated', datestr(now, 30));
            c.labels               = cell(1, numel(this.queries));
            for l = 1:numel(this.queries)
                c.labels{l}        = this.queries{l}.label;
            end
            c.rank                 = this.rank;
            c.size                 = this.size;
            c.rescaling            = this.rescaling;
            c.defaultMnrfitOptions = this.defaultMnrfitOptions;
            c.designMatrix         = this.designMatrix;
            c.binomialOutcomes     = this.binomialOutcomes;
            c.mttDelayThreshold    = this.mttDelayThreshold;
            %c.mnr                  = this.mnr;
        end % make_compact
        
        function [sta,std] = save_and_show(this, nii, new_fp)
            
            %% SAVE_AND_SHOW clobbers
            if (exist('new_fp', 'var')); nii.fileprefix = new_fp; end
            nii.noclobber = false;
            nii.save;
            if (this.pipereg_.verbose > eps); [sta,std] = mlbash(['slices ' nii.fileprefix ' t1']); end
        end
    end % protected methods
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
