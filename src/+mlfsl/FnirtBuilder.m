classdef FnirtBuilder  < mlfsl.FlirtBuilder
	%% FNIRTBUILDER is a builder design pattern
    %  http://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FNIRT/UserGuide#Software_implementation
    %
	%  Version $Revision: 2610 $ was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ 
    %  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ 
    %  and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FnirtBuilder.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: FnirtBuilder.m 2610 2013-09-08 00:15:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)
    
    properties (Dependent)
        transformationsPath
        petFilterSuffix
        warpcoefSuffix
        invwarpSuffix
        warpedSuffix
        fnirtCfg
        segmentationLabel
        regionLabel
    end
    
    methods %% set/get
        function pth  = get.transformationsPath(this)
            pth = fullfile(this.fslPath, this.fslRegistry.transformationsFolder, '');
        end   
        function cfg  = get.fnirtCfg(this) %#ok<MANU>
            cfg = '';
        end
        function sfx  = get.warpcoefSuffix(this) %#ok<MANU>
            sfx = '_warpcoef';
        end
        function sfx  = get.invwarpSuffix(this) %#ok<MANU>
            sfx = '_invwarpcoef';
        end
        function sfx  = get.warpedSuffix(this) %#ok<MANU>
            sfx = '_warped';
        end
        function sfx  = get.petFilterSuffix(this) %#ok<MANU>
            sfx = '';
        end
        function lbl  = get.segmentationLabel(this) %#ok<MANU>
            lbl = 'rois_seg';
        end 
        function lbl  = get.regionLabel(this) %#ok<MANU>
            lbl = '_region';
        end
    end
    
    methods (Static)
        function this    = createFromConverter(cvtr)
            this = mlfsl.FnirtBuilder(cvtr);
        end
        function this    = createFromModalityPath(mpth)
            assert(lexist(mpth, 'dir'));
            this = mlfsl.FnirtBuilder( ...
                   mlsurfer.SurferDicomConverter.createFromModalityPath(mpth));
        end
        function           makeFnirt(bldr, channels)
            %% MAKEFNIRT uses . as its work directory
            %  Usage:  makeFnirt(filter_str, noEp2d)
            %                    ^ string    ^ logical   
            
            import mlfsl.* mlsystem.*;
            fnb = FnirtBuilder(bldr);
            dt = DirTools(bldr.fslPath);
            if (~exist('noEp2d','var')); noEp2d = allempty(strfind(dt.fqfns, 'ep2d')); end
            movefiles(fullfilename(fnb.bettedPath, 'b*'));
            t1  = fnb.inFsl(fnb.t1);  
            assert(lexist(filename(t1),  'file'));
            bt1 = fnb.inFsl(fnb.t1('fp', 'bet'));
            assert(lexist(filename(bt1), 'file'));
                
            if (~lexist('bt1_rot_on_MNI152_T1_2mm_brain.nii.gz', 'file'))
                try    
                    fnb.fnirt_t1toMNI(t1);
                catch ME_T1
                    handexcept(ME_T1);
                end
                try
                    fnb.invwarp(fnb.warpcoef(t1), bt1);
                catch ME_INV
                    handexcept(ME_INV);
                end
            end
            if (~noEp2d)
                try
                    ep2d  = fnb.inFsl(fnb.ep2dMean);
                    bep2d = BetBuilder.bettedFilename(ep2d);
                    fnb.fnirt_ep2dtoMNI(      ep2d, t1);
                    fnb.invwarp( fnb.warpcoef( t1), fnb.imageObject(bep2d, bt1));
                catch ME_EP2D
                    handwarning(ME_EP2D);
                end
            end
            
            if (~lexist('rois_seg.nii.gz','file'))
                try                    
                    FnirtBuilder.makeFast(filtStr, channels);
                catch ME
                    handexcept(ME);
                end
            else
                warning('mlfsl:RequirementsMissing', ...
                        'FnirtBuilder.makeFast:  found rois_seg.nii.gz in work-path %s\n%s\n%s\n', mkr.mrmk.fslPath, ...
                        '                      skipping FAST processing............', ...
                        '                      override by deleting rois_seg.nii.gz');
            end
        end % static makeFnirt        
        function imaging = makeFnirt2(csfidx, noEp2d, bldr)
            
            import mlfsl.* mlfourd.* mlsystem.*;
            dt = DirTools(bldr.fslPath);
            if (~exist('noEp2d','var')); noEp2d = allempty(strfind(dt.fqfns, 'ep2d')); end
            imaging = ImagingComponent; 
            copyfiles(fullfile(bldr.fslPath, 'bet', 'onBt1_rot', '*_mask*'));
            copyfiles(fullfile(bldr.fslPath, 'bet', 'Backups',   '*_mask*'));
            FnirtBuilder.makeROIs(csfidx);
            if (~noEp2d)
                FnirtBuilder.restrictEpiROIs;
            end
            FnirtBuilder.separateSegmentations;
            if (~noEp2d)
                FnirtBuilder.restrictEpiROIs;
            end
            FnirtBuilder.remakeRight;
            FnirtBuilder.makeInvwarpedROIs;
            FnirtBuilder.makePetROIs
        end % static makeFnirt2        
        function str2    = makeFnirt3
            
            import mlfsl.*;
             str        = FnirtBuilder.tagROIs('hosum_rot', 'qcbf');
            [strR,strL] = FnirtBuilder.prepCftool(str);
             str2       = struct('raw', str, 'fittedR', strR, 'fittedL', strL);
        end % static makeFnirt3        
        function [s,r]   = makeFast(filtStr, channels)
            %% MAKEFAST calls FSL's fast segmentations with t1, t2, flair, swi, ...
            %  Usage:  [s,r] = makeFast(patient_path, channels)
            
            import mlfsl.* mlfourd.*;
            if (exist('filtStr','var'))
                fastf = FastBuilder(filtStr);
            else
                fastf = FastBuilder;
            end
            if (exist('channels','var'))
                [s,r] = fastf.fast(fastf.roisLabel, channels);
            else
                [s,r] = fastf.fast(fastf.roisLabel);
            end
        end % static makeFast        
        function [s,r]   = makeROIs(csf_class_idx, bldr)
            %% MAKEROIS
            
            import mlfsl.* mlfourd.*;
            N_CHANNELS = 4;
            s = -1;  r = 'FnirtBuilder.makeROIs:  entering method function'; %#ok<NASGU>
            fnb         = FnirtBuilder(bldr);
            
            % setup csf
            didx  = double( csf_class_idx);
            cidx  = num2str(csf_class_idx);
            csf   = NIfTI.load(fnb.inFsl([fnb.segmentationLabel '_' cidx]));
            csf.fileprefix = fnb.csf;
            csf.save;
            
            % make nocsf
            z            = csf.zeros;
            z.fileprefix =   ['zeros_seg_' cidx];
            z.save;
            for c = 0:N_CHANNELS-1 %#ok<FORFLG>
                if (didx ~= c)
                    rois_seg = fnb.segmentationLabel;
                    [s,r] = FnirtBuilder.fslmaths([z.fqfileprefix ' -add ' rois_seg '_' num2str(c) ' ' z.fqfileprefix]); %#ok<ASGLU>
                end
            end
            movefile(filename(z.fqfileprefix), fnb.nocsf('fqfn'), 'f');
            
            % warp nocsf to atlas
            [s,r] = fnb.applywarp(fnb.nocsf('fqfp'), fnb.mni('fqfp'), fnb.warpcoef(fnb.referenceImage)); %#ok<ASGLU>
            
            % update atlas
            copyfile(           fnb.mni('fqfn'), '.', 'f');
            fileattrib(         fnb.mni('fqfn'), '+w')
            noCsfOnStd = fnb.warped(fnb.nocsf('fqfn'));
            
            [s,r]         = FnirtBuilder.fslmaths([noCsfOnStd          ' -thrP ' num2str(fnb.fslRegistry.confidenceInterval) ' ' noCsfOnStd]); %#ok<ASGLU>
            [s,r]         = FnirtBuilder.fslmaths([fnb.mni('fqfp') ' -mul ' noCsfOnStd ' ' fnb.mni]); %#ok<ASGLU>
            
            [s,r]         = FnirtBuilder.fslmaths([noCsfOnStd '          -bin ' noCsfOnStd]); %#ok<ASGLU>
            [s,r]         = FnirtBuilder.fslmaths([fnb.mni('fqfp') ' -mas ' noCsfOnStd ' MNI-maxprob-nocsf']);
            
            %FnirtBuilder.fslmaths(['MNI-maxprob-thr0-2mm -mas rois_seg_nocsf_warped MNI-maxprob-nocsf']);
        end % static makeROIs        
        function [s,r]   = restrictEpiROIs(bldr)
            
            import mlfsl.*;
            fnb  = FnirtBuilder(bldr);
             epi = fnb.inFsl(fnb.ep2dMean);
            bepi = BetBuilder.bettedFilename(epi);
            mepi = [bepi '_mask'];
                   copyfiles(fullfile(fnb.bettedPath, filename(mepi)));
             t1  = fnb.inFsl(fnb.t1);
            bt1  = BetBuilder.bettedFilename(t1);  
            
            bepiMaskWarped = fnb.warped(mepi, 'fp');
                             fnb.applywarp(mepi, fnb.standardReference, fnb.warpcoef(bt1), fnb.xfmName(bepi, bt1), bepiMaskWarped);
            [s,r]          = FnirtBuilder.fslmaths([bepiMaskWarped ' -thrP ' num2str(fnb.fslRegistry.confidenceInterval) ' ' bepiMaskWarped]); %#ok<ASGLU>
            [s,r]          = FnirtBuilder.fslmaths([fnb.mni '  -mul  ' bepiMaskWarped ' ' fnb.mni]);
        end % static restrictEpiROIs        
        function [s,r]   = separateSegmentations(plusEp2d, plusHO, bldr)
            %% SEPARATEROIS separates segmentation maps by integer map intensities.
            %  Inverse-warps segmentations to T1, inverse-transforms to, e.g., EP2D, H15O
            %  Usage:   [s,r] = FnirtBuilder.separateSegmentations(plusEp2d, plusHO)
            %                                                     ^         ^ logical
            
            import mlfsl.* mlfourd.*;
            if (~exist('plusEp2d','var')); plusEp2d = true; end
            if (~exist('plusHO',  'var')); plusHO   = true; end
            fnb = FnirtBuilder(bldr);
            if (plusEp2d)
                ep2dm = fnb.inFsl(fnb.ep2dMean);
               bep2dm = BetBuilder.bettedFilename(ep2dm);
            end
            if (plusHO)
                   ho = fnb.inFsl([fnb.h15o fnb.petFilterSuffix]);
            end
                  ref = fnb.inFsl(fnb.builder_.referenceImage);
                   t1 = fnb.inFsl(fnb.t1);
               atlnii = NIfTI(fnb.standardAtlas);
            
            %% Iterate atlas regions
            for a = floor(atlnii.dipmin):ceil(atlnii.dipmax) %#ok<FORFLG>
                
                roi            = atlnii.ones; 
                roi.img        = double((a - 0.5)*atlnii.ones.img <= atlnii.img) .* double(atlnii.img < (a + 0.5)*atlnii.ones.img); 
                roi.filepath   = fnb.fslPath;
                roi.fileprefix = [fnb.mni fnb.regionLabel num2str(a)]; 
                roi.save; % save MNI-space
                fprintf('separateSegmentations:  a->%i roi.dipsum->%g\n', a, roi.dipsum);

                %% INV-WARP MNI to T1

                affineRegion   = roi.fqfileprefix;
                [s,r] = fnb.applywarp(roi.fqfileprefix, ref, [t1 fnb.invwarpSuffix], '', ...
                                      [affineRegion '_on_t1']);  

                %% INVERT AND APPLY ONLY AFFINE TRANSFORMATIONS of MNI -> T1

                import mlfsl.*;
                if (plusEp2d)
                    iopts.inverse = fnb.xfmName(bep2dm, ref);
                    fnb           = fnb.invertTransform(iopts); 
                    aopts         = FlirtOptions;
                    aopts.ref     = bep2dm;
                    aopts.in      = fnb.imageObject(affineRegion, t1);
                    aopts.out     = fnb.imageObject(affineRegion, ep2dm);
                    aopts.init    = fnb.xfmName(ref, bep2dm);
                                    fnb.applyTransform(aopts); 
                end
                if (plusHO)
                    copyfiles(fullfile(  fnb.bettedPath, 'onBt1_rot', fnb.ho_to_t1));  
                    iopts.inverse = fnb.ho_to_t1;
                              fnb = fnb.invertTransform(iopts); 
                    
                    aopts      = FlirtOptions;
                    aopts.ref  = ho;
                    aopts.in   = fnb.imageObject(affineRegion, t1);
                    aopts.out  = fnb.imageObject(affineRegion, ho);
                    aopts.init = fnb.t1_to_ho;
                                 fnb.applyTransform(aopts);
                end
            end
        end % static separateSegmentations        
        function [s,r]   = makeInvwarpedROIs(bldr)
            
            import mlfsl.*;
            fnb       = FnirtBuilder(bldr);
            epm      = fnb.inFsl(fnb.ep2dMean);
            bepm     = BetBuilder.bettedFilename(epm);
            invwarp_ = [fnb.t1 fnb.invwarpSuffix];
            roi_fp   = [fnb.mni fnb.regionLabel];
            
            % atlas to epi
            [~,r] = fnb.applywarp(fnb.mni, ref, invwarp_, '',  ...
                    fnb.imageObject(roi_fp, fnb.t1));  %#ok<ASGLU>
            opts      = FlirtOptions;
			opts.ref  = bepm;
			opts.in   = fnb.imageObject(roi_fp, fnb.t1);
			opts.out  = fnb.imageObject(roi_fp, epm);
			opts.init = fnb.xfmName(ref, bepm);
            fnb.applyTransform(opts); 
                            
            % right ROI
            [s,r] = fnb.applywarp(fnb.right('fqfp', fnb.standardPath), ref, invwarp_, '', ...
                    fnb.imageObject(fnb.right, fnb.t1)); 
			opts.in   = fnb.imageObject(fnb.right, fnb.t1);
			opts.out  = fnb.imageObject(fnb.right, epm);
            fnb.applyTransform(opts);
        end % static makeInvwarpedROIs        
        function           makePetROIs(bldr)
            %% MAKEPETROIS
            
            import mlfsl.*;
            fnb  = FnirtBuilder(bldr);
            ho  = fnb.inFsl(fnb.h15o);
            t1  = fnb.inFsl(fnb.t1);
            
            copyfiles(fullfilename(fnb.bettedPath, 'onBt1_rot', fnb.imageObject(ho, t1)));
            copyfiles(fullfile(    fnb.bettedPath, 'onBt1_rot', fnb.ho_to_t1), fnb.transformationsPath);

            roi_fp = fnb.inFsl([fnb.mni fnb.regionLabel]);
            ho     = fnb.inFsl([ho          fnb.petFilterSuffix]);
            opts      = FlirtOptions;
			opts.ref  = ho;
			opts.in   = fnb.imageObject(  roi_fp,   t1);
			opts.out  = fnb.imageObject(  roi_fp,   ho);
			opts.init = fnb.xfmName(t1, ho);
            fnb.applyTransform(opts); 
			opts.in   = fnb.imageObject(  fnb.right, t1);
			opts.out  = fnb.imageObject(  fnb.right, ho);
            fnb.applyTransform(opts);
        end % static makePetROIs        
        function [s,r]   = remakeRight(bldr)
            %% REMAKERIGHT works ab initio or repeatedly
            
            import mlfsl.*;
            fnb   = FnirtBuilder(bldr);
            rhs   = fnb.inFsl(fnb.right);
            t1    = fnb.inFsl(fnb.t1);
            [s,r] = fnb.applywarp(fnb.right('fqfp'), ...
                                  fnb.inFsl(bldr.referenceImage), ...
                                  fnb.inFsl([t1 fnb.invwarpSuffix]), ...
                                          '', ...
                                  fnb.imageObject(rhs, t1));                 
            
             epm  = fnb.ep2dMean;
            bepm  = BetBuilder.bettedFilename(epm);
            
            opts      = FlirtOptions;
			opts.ref  = fnb.inFsl(bepm);
			opts.in   = fnb.imageObject(  rhs, t1);
			opts.out  = fnb.imageObject(  rhs, epm);
			opts.init = fnb.xfmName(bldr.referenceImage, bepm);
                        fnb.applyTransform(opts);      
            
            ho        = fnb.inFsl(    fnb.h15o);
            hos       = fnb.inFsl(   [fnb.h15o fnb.petFilterSuffix]);            
			opts.ref  = ho;
			opts.in   = fnb.imageObject(  rhs, t1);
			opts.out  = fnb.imageObject(  rhs, hos);
			opts.init = fnb.xfmName(t1,  hos);
                        fnb.applyTransform(opts);
        end % static remakeRight 
        function [ra,la] = splitAxis(axis)
            %% SPLITAXIS maintains the internal convention of listing right-sided ROIs first
            
            Nhalf = length(axis)/2;
            ra    = axis(1:Nhalf);
            la    = axis(Nhalf+1:end);
        end % static splitAxis      
        function fn      = diary_fn
            
            fn = ['FnirtBuilder_tagROIs_' mlfsl.Np797Registry.ensurePnum(pwd) '.log'];
        end % static diary_fn               
        function fn      = xfmOnStd(fp)
            %% XFMONSTD affine transformation on standard atlas
            
            import mlfsl.*;
            fn  = fullfile(this.fslPath, this.fslRegistry.transformationsFolder, [FnirtBuilder.fpOnStd(fp) mlfsl.FlirtVisitor.XFM_SUFFIX]);
        end % static xfmOnStd        
        function fp      = fpOnStd(fp)
            %% FPONSTD fileprefix on standard atlas
            
            [~,fp,~] =  filepartsx(fp, mlfourd.INIfTI.FILETYPE_EXT);
               imaging   = ImagingComponent;
               fp    = [fileprefix(fp) '_on_' imaging.mniStandard('brain','fp')];
        end % static fpOnStd
        function [str,pubR,pubL] = tagROIs(pdata_fp, edata_fp)
            %% TAGROIS
            %  Usage:  [data_struct, publisher] = ...
            %           FnirtBuilder.tagROIs(pet_fileprefix, ep2d_fileprefix);
            %                        ^ ScatterPublisher object
            %           ^ struct:  fileprefixes  {string    string}
            %                      estats        struct:  mean, median, std, min, max, N
            %                      axes          for plotting
            %                      vecs          cell or doubles
            %                      erois         {pet_nii   ep2d_nii}
            %                      browsers      {pet_niib  ep2d_niib}
            %                      blurs         {pet_flur  ep2d_blur}
            
            import mlfsl.* mlfourd.* mlpublish.*;
            
            diary(FnirtBuilder.diary_fn);
            if (~exist('pdata_fp',    'var')); pdata_fp = 'hosum_rot'; end
            if (~lexist('qcbf.nii.gz','file'))
                copyfiles(fullfile('HideFromBet', 'qcb*.nii.gz'));
                copyfiles(fullfile('Backups',     'qcb*.nii.gz'));
            end
            if (~exist('edata_fp',    'var')); edata_fp = 'qcbf';      end
            fprintf('FnirtBuilder.tagROIs:\n');
            fprintf('\tpdata_fp -> %s\n', pdata_fp);
            fprintf('\tedata_fp -> %s\n\n', edata_fp);

            s = cell(1,2);
            v = cell(1,2);
            r = cell(1,2);
            d = cell(1,2);
            paxis = []; %#ok<NASGU>
            eaxis = []; %#ok<NASGU>
            import mlpet.*;
            [s{1},paxis,v{1},r{1},d{1}] = FnirtBuilder.sampleVoxels(pdata_fp, sqrt(2)*PETBuilder.petPointSpread);
            [s{2},eaxis,v{2},r{2},d{2}] = FnirtBuilder.sampleVoxels(edata_fp,         PETBuilder.petPointSpread);
                     
            paxis = scrubZeros(scrubNaNs(paxis, true));
            eaxis = scrubZeros(scrubNaNs(eaxis, true));
            
            str = struct('fileprefixes', {pdata_fp edata_fp}, ...
                         'estats', s, 'paxis', paxis, 'eaxis', eaxis, 'vecs', v, 'erois', r, 'browsers', d, ...
                         'blurs', {sqrt(2)*PETBuilder.petPointSpread PETBuilder.petPointSpread});
                     
            [paxisR,paxisL] = FnirtBuilder.splitAxis(paxis);
            [eaxisR,eaxisL] = FnirtBuilder.splitAxis(eaxis);
            
            pubR = ScatterPublisher.makeScatterFromVecs(paxisR', eaxisR');
            pubR.plotScatter(    'right');
            pubR.plotBlandAltman('right');
            pubL = ScatterPublisher.makeScatterFromVecs(paxisL', eaxisL');
            pubL.plotScatter(    'left');
            pubL.plotBlandAltman('left');
            
            fprintf('\nFnirtBuilder.tagROIs.str  -> '); disp(str);
            fprintf('\nFnirtBuilder.tagROIs.pubR -> '); disp(pubR);
            fprintf('\nFnirtBuilder.tagROIs.pubL -> '); disp(pubL);
            fprintf('\n\n');
            diary off;
        end % static tagROIs
        function [rightStr,leftStr] = prepCftool(tagStruct)
            %% PREPCFTOOL
            %  Usage:  [rightStruct,leftStruct] = FnirtBuilder.prepCftool(struct_from_tagROIs)
            
            import mlfourd.* mlfsl.*;
            
            diary(FnirtBuilder.diary_fn);
            eaxis = zeros(size(tagStruct(1).eaxis));
            paxis = zeros(size(tagStruct(1).paxis));
            for a = 1:length(eaxis) %#ok<FORFLG>
                eaxis(a) = tagStruct(1).eaxis(a); 
                paxis(a) = tagStruct(1).paxis(a);
            end
            
            [rightStr,leftStr] = createFit(paxis, eaxis);
            disp(rightStr.cf);
            disp(rightStr.gof);
            disp(rightStr.out);
            disp( leftStr.cf);
            disp( leftStr.gof);
            disp( leftStr.out);
            
            createfigureBilateral(paxis, eaxis, rightStr.cf, leftStr.cf);
            cftool(paxis, eaxis)
            
            imaging = ImagingComponent.createStudyFromPath(pwd);
            save(['prepCftool_' imaging.pnum '_' datestr(now, 1)]);
            diary off; 
        end % static prepCftool
        function [estats, axis, vecs, erois, datBrow] = sampleVoxels(edata_fp, blur, bldr)
            %% SAMPLEVOXELS returns statistics, vector of samples, ROIs for sampling, NiiBrowser for data
            %  Usage:   [stats, axes, vecs, ROIs, dataBrowser] = ...
            %           FnirtBuilder.sampleVoxels(data_fp [, blur, mni, right]);
            %            ^ struct:  N, mean, std, min, max
            %                   ^ vectors for plotting
            %                         ^ cell or doubles
            %                               ^ cell of NIfTI
            %                                   ^ NiiBrowser for data
            
            import mlfsl.* mlfourd.*; 
            fnb       = FnirtBuilder(bldr); 
            pimaging = PETStudy(pwd);
            
                raster = fnb.ep2dMean;         
            if (~exist('blur', 'var'))
                blur   = [0 0 0]; 
            end
            if (lstrfind(edata_fp, 'q'))
                raster = fnb.ep2dMean;
            end
            if (lstrfind(edata_fp, 'hosum'))
                fnb     = FnirtBuilder(bldr);
                raster = [pimaging.h15o fnb.petFilterSuffix]; 
            end
              right = [FnirtBuilder.right '_on_' raster]; %#ok<*PROP>
            if (~lexist([right '_ori'], 'file') && exist(filename(right), 'file'))
                   copyfile(filename(right), [right '_ori']);
            end
            rhs  = NIfTI.load(right);
            edat = NIfTI.load(edata_fp);
            
            datBrow = NiiBrowser(edat);
            if (sum(blur) > 0)
                fprintf('FnirtBuilder.sampleVoxels:   blurring %s by %s\n', datBrow.label, num2str(blur));
                datBrow = datBrow.blurredBrowser(blur);
            end
            E        = 9;
            Enii     = rhs.ones; 
            Enii.img = E*Enii.img;
            erois    = cell( 1,2*E);
            vecs     = cell( 1,2*E);
            axis     = zeros(1,2*E);
            estats   = cell2struct(cell(2*E,6), {'mean' 'median' 'std' 'min' 'max' 'N'}, 2);
            
            % DO BUSINESS
            
            fprintf('ROI index \t\t N \t\t mean \t\t median \t\t std \t\t min \t\t max \n');
            roi_fp = [fnb.mni fnb.regionLabel];
            for e = 1:2*E %#ok<FORFLG>
                if (e <= E)
                    erois{e}     = NIfTI.load([roi_fp num2str(e)   '_on_' raster]);
                    erois{e}     = erois{e} .*  rhs;
                else
                    erois{e}     = NIfTI.load([roi_fp num2str(e-E) '_on_' raster]);
                    erois{e}     = erois{e} .* (rhs.ones - rhs);
                end
                vecs{e}          = datBrow.sampleVoxels(erois{e}); 
                if (strcmp(raster, [pimaging.h15o fnb.petFilterSuffix]))  
                    vecs{e}      = mlpet.PETBuilder.count2cbf(vecs{e}, pimaging.hdrinfo_filename('ho1')); 
                end
                estats(e).N      = erois{e}.dipsum;
                estats(e).mean   =   mean(vecs{e});
                estats(e).median = median(vecs{e});
                estats(e).std    =    std(vecs{e});
                estats(e).min    =    min(vecs{e});
                estats(e).max    =    max(vecs{e});
                axis(e)          = estats(e).mean;
                fprintf('%g \t\t %g \t\t %g \t\t %g \t\t %g \t\t %g \t\t %g \n', ...
                        e, estats(e).N, estats(e).mean, estats(e).median, estats(e).std, estats(e).min, estats(e).max);
                
            end
        end % static sampleVoxels
    end % static methods
    
	methods
        function [this,nlxfm]      = morphSingle(this, varargin)
            try 
               opts = mlfsl.FnirtOptions;
               switch (length(varargin))
                   case 1
                        if (isa(varargin{1}, 'mlfsl.FnirtOptions'))
                            opts = varargin{1}; 
                        else
                            opts.in = imcast(varargin{1}, 'fileprefix');
                            opts.ref = this.standardReference;
                        end
                   case 2                       
                        opts.in  = imcast(varargin{1}, 'fileprefix');
                        opts.ref = imcast(varargin{2}, 'fileprefix');
                   otherwise
                       error('mlfsl:UnexpectedPassedParams', 'FnirtBuilder.morph.varargin length->%s', length(varargin));
                end
                [this,nlxfm] = this.morphByOptions(opts);
            catch ME
                handexcept(ME);
            end
        end
        function [this,morphedobj] = applyMorph(this, varargin) % imobj, standard, nlxfm, varargin)
            if (nargin < 4)
                nlxfm = this.xfmName(imobj, standard); end
            opts = mlfsl.ApplywarpOptions;
            opts.in = this.fqfileprefix(imobj);
            opts.ref = this.fqfileprefix(standard);
            opts.out = this.warped(this.imageObject(imobj, standard));
            opts.warp = this.warpcoef(nlxfm);
            if (nargin > 4)
                opts.premat = this.xfmName(varargin{1}); end
            if (nargin > 5)
                opts.postmat = this.xfmName(varargin{2}); end
            this = this.fnirtcmd('applywarp', opts);
            morphedobj = opts.out;
            
            
            try 
               switch (length(varargin))
                   case 1
                       opts = varargin{1};
                       
                       if (isa(varargin{1}, 'mlfsl.FnirtOptions'))
                           opts = varargin{1};
                       else
                       end
                   case 2
                       opts = mlfsl.FnirtOptions;
                   otherwise
               end
            catch ME
                handexcept(ME);
            end
        end
        function [this,inlxfm]     = invertMorph(this, varargin) % nlxfm, standard)
            if (nargin < 3)
                standard = this.bettedStandard; end
            opts = mlfsl.InversewarpOptions;
            opts.warp = nlxfm;
            opts.out = this.invwarpcoef(nlxfm);
            opts.ref = standard;
            this = this.fnirtcmd('invwarp', opts);
            inlxfm = opts.out;
            
            
            try 
                opts = mlfsl.FnirtOptions;
                switch (length(varargin))
                    case 1
                        if (isa(varargin{1}, 'mlfsl.FnirtOptions'))
                            opts = varargin{1};
                        else
                        end
                    otherwise
                end
            catch ME
                handexcept(ME);
            end
        end            
        function                     convertMorph(~, varargin)
            warning('mlfsl:NotImplemented', 'convertMorph is a stub for FSL app convertwarp');            
            
            try 
               opts = mlfsl.FnirtOptions;
               switch (length(varargin))
                   case 1
                        if (isa(varargin{1}, 'mlfsl.FnirtOptions'))
                            opts = varargin{1}; 
                        else
                        end
                   otherwise
               end
            catch ME
                handexcept(ME);
            end
        end         
    end % methods  
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this           = FnirtBuilder(varargin)
            %% FNIRTBUILDER
            %  http://www.fmrib.ox.ac.uk/fsl/fnirt/warp_utils.html
            
            this = this@mlfsl.FlirtBuilder(varargin{:});
        end % ctor
        function [this,nlxfm]   = morphByOptions(this, opts)
            assert(isa(opts, 'mlfsl.FnirtOptions'));
            [this,nlxfm] = this.warpLeaf( ...
                           this.warpChecks(opts));
        end
        function [this,morphed] = applyMorphByOptions(this, opts)
            assert(isa(opts, 'mlfsl.FnirtOptions'));
            [this,morphed] = this.applyWarpLeaf( ...
                           this.warpChecks(opts));
        end
        function [this,nlxfm]   = invertMorphByOptions(this, opts)
            assert(isa(opts, 'mlfsl.ConvertWarpOptions'));
            [this,nlxfm] = this.invertWarpLeaf( ...
                            this.convertWarpChecks(opts));
        end
        function [this,nlxfm]   = convertMorphByOptions(this, opts)
            assert(isa(opts, 'mlfsl.ConvertWarpOptions'));
            [this,nlxfm] = this.convertWarpLeaf( ...
                           this.convertWarpChecks(opts));
        end
        function opts           = warpChecks(~, opts)
        end
        function opts           = convertWarpChecks(~, opts)
        end
        function nm             = fqaffinename(this, objs)
            nm = affcast(objs{:});
            if (~lstrfind(nm, this.fslPath))
                nm = fullfile(this.fslPath, nm); end
        end
        function nm             = fqfieldcoef(this, objs)
            nm = fieldcoefcast(objs{:});
            if (~lstrfind(nm, this.fslPath))
                nm = fullfile(this.fslPath, nm); end
        end
    end
    
    %% PRIVATE
    
    methods (Access = 'private')  
        function fn = warped(this, label, varargin)
            [~,label] = fileparts(label);
            [~,label] = fileparts(label);
            fn = mlfourd.ImagingParser.formFilename([label this.warpedSuffix], varargin{:});
            fn = this.fqfilename(fn);
        end        
        function fn = warpcoef(this, label, varargin)
            [~,label] = fileparts(label);
            [~,label] = fileparts(label);
            fn = mlfourd.ImagingParser.formFilename([label this.warpcoefSuffix], varargin{:});
            fn = this.fqfilename(fn);
        end        
        function fn = invwarpcoef(this, label, varargin)
            [~,label] = fileparts(label);
            [~,label] = fileparts(label);
            pos_underscore = strfind(label, this.warpcoefSuffix);
            label = label(1:pos_underscore-1);
            fn = mlfourd.ImagingParser.formFilename([label this.invwarpSuffix], varargin{:});
            fn = this.fqfilename(fn);
        end    
        function fn = csf(this, varargin)
            fn = mlfourd.ImagingParser.formFilename([this.segmentationLabel '_csf'], varargin{:});
        end        
        function fn = nocsf(this, varargin)
            fn = mlfourd.ImagingParser.formFilename([this.segmentationLabel '_nocsf'], varargin{:});
        end        
        function fn = right(~, varargin)
            fn = mlfourd.ImagingParser.formFilename('right-MNI152-2mm', varargin{:});
        end   
        
        %% KLUDGE:   ho_to_t1, t1_to_ho
        
        function fn = ho_to_t1(this)
            fn = this.xfmName(  [this.h15o this.petFilterSuffix], this.t1);
        end
        function fn = t1_to_ho(this)
            fn = this.xfmName(   this.t1, [this.h15o this.petFilterSuffix]);
        end
    end
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
