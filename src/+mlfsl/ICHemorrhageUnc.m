classdef ICHemorrhageUnc
	%% ICHEMMORHAGE  
	%  Usage:  obj = ICHemorrhage() 
	%                             ^ 
	%% Version $Revision$ was created $Date$ by $Author$  
	%% and checked into svn repository $URL$ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id$ 

    properties (Constant)
        smallestNii_fp   = 'bep2d_0_mcf_meanvol';
        grey_fp          = 'grey';
        white_fp         = 'white';
        csf_fp           = 'csf';
        hemorrhage_fp    = 'hemorrhage_on_t1';
        contralateral_fp = 'contralateral_on_t1';
        mtt_fp           = 'mtt_on_t1';
        mtt2_fp          = 'MTT_034_tp2_on_tp1';
        t1_fp            = 'bt1';
        t2_fp            = 'bt2_on_bt1';
        flair_fp         = 'bflair_on_bt1';
        kindExcel        = '.csv';
        topFolder        = '/Volumes/LLBQuadra/cvl/MROMI/ICH';
    end
    
	properties
        smallestNii
        foreground
        grey
        white
        csf
        hemorrhage
        contralateral
        mtt
        mtt2
        query
        defaultMnrfitOptions = {'estdisp' 'on'};
        designMatrix
        binomialOutcomes
        MTT_DELAY_THRESHOLD = 400;
        mnr
        rescaling = ''; % 'relative' or 'normalized' or ''
        
    end
    
    properties (Dependent, SetAccess = 'protected')
        nohemorrhage
        mtt_impaired
        rank
        size
        ref_fp
    end
    
    properties (Access = 'private')
        pipereg_
    end
    
    methods (Static)
        
        function obj = prepData(query, msks)
            
            %% PREPDATA
            %  Usage:  obj = prepData(query, msks)
            %                               ^ char filename, NIfTI, or cells of either
            import mlfsl.*; import mlfourd.*;
            if (~exist('msks',  'var')); msks = ICHemorrhage.loadDefaultMasks; end
            if (~exist('query', 'var'))
                obj = ICHemorrhage(msks.grey, msks.white, msks.csf, msks.hemorrhage, msks.contralateral, msks.mtt, msks.smallestNii);
            else
                obj = ICHemorrhage(msks.grey, msks.white, msks.csf, msks.hemorrhage, msks.contralateral, msks.mtt, msks.smallestNii, query); %, msks.cellmsk);
            end
        end
        
        function make_seg_mrp(seg_fp, csfId, greyId, whiteId, bldr)
            import mlfsl.* mlfourd.*;
            flirtf    = FlirtBuilder(bldr);
            opts = FlirtOptions;
			opts.ref  = 't1';
			opts.in   = seg_fp;
			opts.out  = [seg_fp '_on_bt1'];
			opts.init = 'bflair_to_bt1.mat';
            flirtf.applyTransform(opts);
            seg       = NIfTI.load([seg_fp '_on_bt1']);
            csf_      = seg.makeSimilar(seg.img == csfId, 'csf',     ICHemorrhage.white_fp);
            grey_     = seg.makeSimilar(seg.img == greyId, 'grey',   ICHemorrhage.white_fp);
            white_    = seg.makeSimilar(seg.img == whiteId, 'white', ICHemorrhage.white_fp);
            csf_.save;
            grey_.save;
            white_.save;
        end % make_seg_mrp
        
        function [sta,std] = make_fast(out_fp)
            import mlfsl.*;
            if (~exist('out_fp', 'var')); out_fp = 'tissue'; end
            fastf     = FastBuilder;
            [sta,std] = fastf.fast(out_fp, ICHemorrhage.t1_fp, ICHemorrhage.t2_fp, ICHemorrhage.ir_fp);
        end % make_fast
        
        function msks = loadDefaultMasks
            
            import mlfsl.*; import mlfourd.*;
            %msks = struct([]);
            msks.smallestNii   = NIfTI.load(ICHemorrhage.smallestNii_fp);
            msks.grey          = NIfTI.load(ICHemorrhage.grey_fp);
            msks.white         = NIfTI.load(ICHemorrhage.white_fp);
            msks.csf           = NIfTI.load(ICHemorrhage.csf_fp);
            msks.hemorrhage    = NIfTI.load(ICHemorrhage.hemorrhage_fp);
            msks.contralateral = NIfTI.load(ICHemorrhage.contralateral_fp);
            msks.mtt           = NIfTI.load(ICHemorrhage.mtt_fp);
            %msks.cellmsk       = NIfTI.load('cellsMask');
            fields = fieldnames(msks);
            for m = 1:length(fields)
                assert(~isempty(msks.(fields{m})));
            end
        end % static loadDefaultMasks
        
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
        
        function nii = randomSamplingMask(nii0, N)
            
            tic
            assert(3 == nii0.rank);
            nii      = mlfourd.NIfTI_mask(nii0);
            assert(N < nii.dipsum);
            nii      = nii.append_descrip(['randomly sampled mask, N->' num2str(N)]);
            nii      = nii.append_fileprefix(['_sampledN' num2str(N)]);
            sz       = nii.size;
            sampling = nii.img .* rand(sz);
            sampling = sampling > (1 - N/nii.dipsum);
            while (sum(dip_image(sampling)) ~= N)
                c = [randi(sz(1)) randi(sz(2)) randi(sz(3))];
                if (sum(dip_image(sampling)) < N)
                    sampling(c(1),c(2),c(3)) = 1;
                else
                    sampling(c(1),c(2),c(3)) = 0;
                end
            end
            nii.img = sampling;
            disp('ICHemorrhage.randomSamplingMask.nii:   time to make:');
            toc
        end % static randomSamplingMask
        
        function nii = make_contralateral_fromMNI(target, bldr)
            
            import mlfourd.* mlfsl.*;
            target  = ensureNii(target);
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
        end
        
        function nii = cellIntersectionMask(c)
            
            import mlfsl.* mlfourd.*;
            assert(iscell(c)); assert(~isempty(c));
            c1  = ensureNii(c{1});
            nii = NIfTI_mask(c1);
            for ci = 1:numel(c)
                cwork = ensureNii(c{ci});
                assert(all(c1.size == cwork.size));
                nii   = ICHemorrhage.intersectionMask(nii, cwork);
            end
        end % static cellIntersectionMask
        
        function nii = intersectionMask(nii1, nii2)
            
            %% INTERSECTION returns the set-intersectionMask of two NIfTIs as a NIfTI
            %  Usage:  mask = intersectionMask(nii1, nii2)
            %                                  ^     ^ any real-valued NIfTI
            nii1           = ensureNii(nii1);
            nii2           = ensureNii(nii2);
            nii1.img       = abs(nii1.img);
            nii2.img       = abs(nii2.img);
            nii            = nii1;
            nii.img        = double(nii1.dip_image > eps) & (nii2.dip_image > eps);
            nii            = nii ./ nii.dipmax;
            nii.fileprefix = [nii1.fileprefix '_and_' nii2.fileprefix];
            nii.descrip    = ['intersection-mask of ' nii1.label ' and ' nii2.label];
            clear('nii1', 'nii2');
        end % static intersectionMask
        
        function nii = make_diff(nii2, nii1, new_fp)
            
            %% MAKE_DIFF nii2 - nii1
            %  Usage:  nii = ICHemorrhage.make_diff(nii2, nii1)
            import mlfsl.*;
            nii2     = ensureNii(nii2);
            nii1     = ensureNii(nii1);
            nii      = nii2 - nii1;
            nii_fp   = nii.fileprefix;
            nii_desc = nii.descrip;
            nii      = ICHemorrhage.intersectionMask(nii1, nii2) .* nii;
            clear('nii1', 'nii2');
            if (exist('new_fp', 'var') && ischar(new_fp))
                nii.fileprefix = new_fp;
                nii.descrip    = nii_desc;
            else
                nii.fileprefix = nii_fp;
                nii.descrip    = nii_desc;
            end
        end % make_diff
        
        function       make_diff_all(fprefixes, tp1pref, tp1suff, tp2pref, tp2suff)
            
            %% MAKE_DIFF_ALL
            %  Usage:  ICHemorrhage.make_diff_all(fprefixes, tp1pref, tp1suff, tp2pref, tp2suff)
            import mlfourd.* mlfsl.*;
            assert(iscell(fprefixes));
            if(~exist('tp1pref', 'var')); tp1pref = ''; end
            if(~exist('tp2pref', 'var')); tp2pref = ''; end
            if(~exist('tp1suff', 'var')); tp1suff = ''; end
            if(~exist('tp1suff', 'var')); tp1suff = ''; end
            for f = 1:numel(fprefixes)
                if (strcmpi('b', fprefixes{f}(1)))
                    fpout = fprefixes{f}(2:end);
                else
                    fpout = fprefixes{f};
                end
                fprintf(1, 'ICHemorrhage.make_diff_all:  \n\t%s, %s, %s', ...
                      [tp2pref fprefixes{f} tp2suff], [tp1pref fprefixes{f} tp1suff], ['d' fpout tp2suff]);
                tmp = ICHemorrhage.make_diff( ...
                      [tp2pref fprefixes{f} tp2suff], [tp1pref fprefixes{f} tp1suff], ['d' fpout tp2suff]);
                tmp.noclobber = false;
                tmp.save;
                clear('tmp');
            end
        end % make_diff_all
        
        function       make_from_scratch(pnum, dcmfolder, bldr)
            
            import mlfsl.* mlfourd.*;
            if (~exist('dcmfolder', 'var')); dcmfolder = 'DICOM'; end
            cd(fullfile(ICHemorrhage.topFolder, pnum, ''));
            tps = { 'tp1_raw' 'tp2_raw' 'tp3_raw' 'tp24hr_raw' };
            fslreg = Np797Registry.instance;
            for t = 1:numel(tps)
                cd(tps{t});
                converter = MRIConverter(dcmfolder, pwd);
                converter.mcvert(dcmfolder, pwd);
                disp(['ICHemorrhage.make_all:  working from ' pwd]);
                mkdir(fslreg.betFolder);
                fslf = FslBuilder(bldr);
                fslf.rename(pwd, fslreg.betFolder);
                cd(fslreg.betFolder)
                flirtf = FlirtBuilder(bldr);
                flirtf.moco;
                flirtf.coregister();
                
                if (t > 1)
                end
            end
        end % make_from_scratch
    end % static methods

    methods
        
        function this = ICHemorrhageUnc(grey, white, csf, hemo, contra, mtt, ref, query, cellMsk)
            
            %% ICHEMMORHAGE (ctor)
            %  Usage:  obj = ICHemorrhage(fg, hemo, contra, query)
            %                             ^ NIfTI registered to betted T1, may be filename or NIfTI
            %                                               ^ data to query, filename or NIfTI
            import mlfourd.*;
            this.grey          = NIfTI_mask(ensureNii(grey));
            this.white         = NIfTI_mask(ensureNii(white));
            this.csf           = NIfTI_mask(ensureNii(csf));
            this.foreground    = this.grey | this.white;
            this.hemorrhage    = NIfTI_mask(ensureNii(hemo));
            this.contralateral = NIfTI_mask(ensureNii(contra));
            this.mtt           = ensureNii(mtt);
            this.smallestNii   = ensureNii(ref);
            if (exist('query', 'var'))
                if (iscell(query))
                    for q = 1:numel(query)
                        this.query{q} = ensureNii(query);
                    end
                else
                    this.query         = ensureNii(query);
                end
            end
            if (exist('cellMsk', 'var'))
                cellMsk = ensureNii(cellMsk);
                this.grey = this.grey .* cellMsk;
                this.white = this.white .* cellMsk;
                this.csf = this.csf   .* cellMsk;
                this.hemorrhage = this.hemorrhage .* cellMsk;
                this.contralateral = this.contralateral .* cellMsk;
                this.mtt = this.mtt .* cellMsk;
            end
            this.save_and_show(this.nohemorrhage, ['no' this.hemorrhage_fp]);
            this.save_and_show(this.mtt_impaired,  'impaired_mtt_on_tp1'); 
            clear('in');
            this.pipereg_ = mlpipeline.PipelineRegistry.instance;
        end % ctor
        
        function fp = get.ref_fp(this)
            fp = this.t1_fp;
        end
        
        function q = get.query(this)
            q = ensureCell(this.query);
        end
        
        function nii = get.nohemorrhage(this)
            nii = this.foreground & not(this.contralateral) & this.mtt_impaired & not(this.hemorrhage);
        end
        
        function nii = get.hemorrhage(this)
            nii = this.foreground & not(this.contralateral) & this.hemorrhage;
        end
        
        function nii = get.mtt_impaired(this)
            nii = this.make_relative(this.mtt) > this.MTT_DELAY_THRESHOLD;
        end

        function this = set.query(this, q)
            import mlfourd.*;
            if (~iscell(q))
                q = ensureNii(q);
                q = {q};
            end
            for idx = 1:numel(q)
                q{idx} = this.make_rescaled(q{idx});
            end
            this.query = q;
        end
        
        function r = get.rank(this)
            r = this.smallestNii;
            r = r.rank;
        end
   
        function s = get.size(this)
            s = this.smallestNii;
            s = s.size;
        end      
        
        function nii = make_relative(this, nii)

            %% MAKE_RELATIVE to mean of contralateral hemisphere
            nii    = nii - this.contralat_mean(nii);
            nii    = nii.prepend_fileprefix('relative_'); 
        end
        
        function cmean = contralat_mean(this, nii)
            chemis = this.foreground & this.contralateral & not(this.hemorrhage);
            cmean  = chemis .* nii ./ chemis.dipsum;
        end % contralat_mean
        
        function nii = make_rescaled(this, nii)

            %% RESCALE to mean of contralateral hemisphere; checks value of this.rescaling
            switch (lower(this.rescaling))
                case ''
                case 'relative'
                    nii = this.make_relative(nii);
                case 'over_contralateral_mean'
                    nii =  nii ./ abs(this.contralat_mean(nii));
                    nii =  nii.append_fileprefix('_over_contralat_mean');
                case 'std_moment'
                    nii = mlfourd.NIfTI(nii);
                    nii = (nii - this.contralat_mean(nii)) ./ nii.dipstd;
                    nii =  nii.prepend_fileprefix('stdmoment_');
                otherwise
                    paramError(this, 'this.rescaling', this.rescaling);
            end
        end % make_rescaled

        function nii = downsample(this, nii0)
            import mlfourd.*;
            assert(isa(nii0, 'mlfourd.NIfTIInterface'));
            assert(all(nii0.size == this.foreground.size));
            assert(    nii0.rank == this.foreground.rank);
            blocks = nii0.size ./ this.size;
            nii    = NiiBrowser(nii0);
            nii    = NIfTI(nii.blockedBrowser(blocks, this.foreground));
        end % downsample
        
        function im = hemorrhageImg(this, query)
            import mlfourd.*;
            blockedQuery      = this.downsample(query);
            blockedHemorrhage = this.downsample(this.hemorrhage);
            nii = blockedQuery .* blockedHemorrhage;
            im  = nii.img;
        end
        
        function im = noHemorrhageImg(this, query)
            import mlfourd.*;
            blockedQuery        = this.downsample(query);
            blockedNoHemorrhage = this.downsample(this.nohemorrhage);
            nii = blockedQuery .* blockedNoHemorrhage;
            im  = nii.img;
        end

        function c = make_mnr(this, que)
            
			import mlfourd.*;
            switch (class(que))
                case 'char'
                    que = {ensureNii(que)};
                case NIfTI.NIFTI_SUBCLASS
                    que = {que};
                case 'cell'
                otherwise
                    error('mlfsl:NotImplementedErr', ['ICHemorrhage.make_mnr.que class->' class(que)]);
            end
            this.query = que;
            longlabel  = '';
            for q = 1:numel(que)
                longlabel = strtrim([longlabel ' ' que{q}.label]); 
            end
            rois          = { this.grey this.white this.csf };
            foreground0   =   this.foreground;
            for r = 1:numel(rois)
                this.foreground = foreground0 .* rois{r};
                this            = this.mnrfit;
                this            = this.mnrval;
                this.fprintf(            ['ICH_' longlabel '_' rois{r}.label '_' this.rescaling '.txt']);
                this.writeModelCoeff_xls(['ICH_' longlabel '_' rois{r}.label '_' this.rescaling this.kindExcel]);
            end
            c = this.make_compact;
        end % make_mnr
        
        function count = fprintf(this, fn)
            
            %% FPRINTF 
            %  Usage:  count = obj.fprintf(fn)
            if (exist('fn', 'var'))
                fid = fopen(fn, 'a'); % appends
            else
                fid = 1;
            end
			B     = this.mnr.B;
			dev   = this.mnr.dev;
			stats = this.mnr.stats;
            
            count = ...
            fprintf(fid, '\n\n________________________________________________________________________________________________________________________________________________ \n');
            count = count + ...
            fprintf(fid, 'Design Matrix Content \t\t\t Model Params B \t\t\t Std Err B \t\t\t Corr Matrix B \t\t\t Covar B \t\t\t T-statistic \t\t\t P-value \t\t\t Dispersion \t\t\t Pearson Resid\n');
            
            for k = 1:numel(B)
            count = count + ...
            fprintf(fid, '%s \t\t\t B(%i)=%8.5g \t\t\t %8.5g \t\t\t %8.5g, t\t\t %8.5g \t\t\t %8.5g \t\t\t %8.5g \t\t\t %8.5g \t\t\t %8.5 \n', ...
                this.query{1}.label, k, B(k), stats.se(k), stats.coeffcorr(k), stats.covb(k), stats.t(k), stats.p(k), stats.sfit, stats.residp);
            end
            
            fprintf(fid, '\nDeviance of fit:   mean %8.5g median %8.5g mode %8.5g std %8.5g\n', ...
                mean(dev), median(dev), mode(dev), std(dev));
            
            phat = this.mnr.phat;
            dhi  = this.mnr.dhi;
            dlo  = this.mnr.dlo;
            fprintf(fid, '\nProb of Model:     mean %8.5g median %8.5g mode %8.5g std %8.5g\n', ...
                mean(phat), median(phat), mode(phat), std(phat));
            fprintf(fid, '\nLower Confidence:  mean %8.5g median %8.5g mode %8.5g std %8.5g\n', ...
                mean(dhi), median(dhi), mode(dhi), std(dhi));
            fprintf(fid, '\nUpper Confidence:  mean %8.5g median %8.5g mode %8.5g std %8.5g\n', ...
                mean(dlo), median(dlo), mode(dlo), std(dlo));
            
            if (exist('fn', 'var')); fclose(fid); end                
        end % fprintf
        
        function [success,msg] = writeModelCoeff_xls(this, filename)
            [success,msg] = xlswrite([filename this.kindExcel], cat(2, this.designMatrix, this.binomialOutcomes-1));
        end % write_xls

        function this = mnrfit(this, options)
            
            % ------------- KLUDGE --------------
            if (~exist('options', 'var'))
                options =  this.defaultMnrfitOptions; 
            else
                option0 = options;
                Ndef    = numel(this.defaultMnrfitOptions);
                Nopt    = numel(option0);
                assert(0 == mod(Ndef + Nopt, 2));
                for o = 1:Ndef
                    options{o} = this.defaultMnrfitOptions{o};
                end
                for o = Ndef+1:Ndef+Nopt
                    options{o} = option0{o-Ndef};
                end
            end
            % -----------------------------------
            
            this.query = ensureCell(this.query);
            Np     = length(this.query);
            noHImg = cell(1, Np);
            hImg   = cell(1, Np);
            idxmax   = intmax;
            for q = 1:Np
                noHImg{q}            = this.noHemorrhageImg(this.query{q});
                hImg{q}              = this.hemorrhageImg(  this.query{q});
                noHImg{q}            = noHImg{q}(noHImg{q} ~= 0.0);
                hImg{q}              = hImg{q}(  hImg{q}   ~= 0.0);
                if (numel(noHImg{q}) < idxmax); idxmax = numel(noHImg{q}); end
                if (numel(  hImg{q}) < idxmax); idxmax = numel(  hImg{q}); end
            end
            for q = 1:Np
                noHImg{q} = noHImg{q}(1:idxmax);
                  hImg{q} =   hImg{q}(1:idxmax);
            end
            mat0 = noHImg{1};
            mat1 = hImg{1};
            if (Np > 1)
                for q = 2:Np
                    mat0 = horzcat(mat0, noHImg{q});
                    mat1 = horzcat(mat1, hImg{q});
                end
                assert(size(mat0,2) == numel(noHImg));
                assert(size(mat1,2) == numel(hImg));
            end
            this.designMatrix     = vertcat(mat1, mat0);
            this.binomialOutcomes = vertcat(2*ones(size(mat1,1),1), ones(size(mat0,1),1));
            %if (exist('options', 'var'))
            %    [B,dev,stats] = mnrfit(this.designMatrix, this.binomialOutcomes, options{1}, options{2});
            %else
                [B,dev,stats] = mnrfit(this.designMatrix, this.binomialOutcomes);
            %end
            this.mnr = struct('B', B, 'dev', dev, 'stats', stats);
        end % mnrfit
        
        function this = mnrval(this)
            
            assert(~isempty(this.mnr));
            assert( isstruct(this.mnr));
            [this.mnr.phat, this.mnr.dlo, this.mnr.dhi] = mnrval(this.mnr.B, this.designMatrix, this.mnr.stats);
        end % mnrval
        
        function c = make_compact(this)
            
            c = struct('dateCreated', datestr(now, 30));
            for l = 1:numel(this.query)
                c.label{l}         = this.query{l}.label;
            end
            c.rank                 = this.rank;
            c.size                 = this.size;
            c.rescaling            = this.rescaling;
            c.defaultMnrfitOptions = this.defaultMnrfitOptions;
            c.designMatrix         = this.designMatrix;
            c.binomialOutcomes     = this.binomialOutcomes;
            c.MTT_DELAY_THRESHOLD  = this.MTT_DELAY_THRESHOLD;
            c.mnr                  = this.mnr;
        end % make_compact
        
        function [sta,std] = save_and_show(this, nii, new_fp)
            if (exist('new_fp', 'var')); nii.fileprefix = new_fp; end
            nii.save;
            if (this.pipereg_.verbose > eps); [sta,std] = mlbash(['slices ' nii.fileprefix ' t1']); end
        end
    end % methods
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
