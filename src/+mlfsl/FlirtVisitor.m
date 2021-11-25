classdef FlirtVisitor < mlfsl.FslVisitor 
	%% FLIRTVISITOR gathers behaviors using FSL's flirt.
    %  Data are received as builder objects, acted upon, then returned as builder objects.

	%  $Revision: 2644 $ 
 	%  was created $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FlirtVisitor.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
    
    properties (Constant)
        MCF_SUFFIX      = '_mcf';
        MEANVOL_SUFFIX  = '_meanvol';
        PREPROCESS_LIST = { 'none' 'gauss' 'susan' 'blindd' };
        XFM_SUFFIX      = '.mat';
        ALWAYS_SAVE     = false;
    end
    
    properties (Dependent)
        filetypeExt
    end    

    methods 
        
        %% GET/SET

        function e = get.filetypeExt(~)
            e = '.nii.gz';
        end

        %%

        function              ensureBuilderSaved(~, bldr)
            ims = {'sourceImage' 'referenceImage' 'sourceWeight' 'referenceWeight'};
            for idx = 1:length(ims)
                if (~isempty(bldr.(ims{idx})))
                    if (~lexist(bldr.(ims{idx}).fqfn, 'file'))
                        warning('mlfsl:imageNotSavedBeforeFlirt', ...
                                'FlirtVisitor.ensureBuilderSaved saved %s', bldr.(ims{idx}).fqfn);
                        bldr.(ims{idx}).save;
                    end
                end
            end
        end   
        function [bldr,xfm] = concatTransforms(this, bldr, varargin)
            xfms = varargin;
            opts = mlfsl.ConvertXfmOptions;
            for x = 1:length(xfms)-1                
                opts.concat = sprintf('%s %s', xfms{x+1}, xfms{x});
                opts.omat   = this.concatTransformFilename(xfms{x}, xfms{x+1});
                xfms{x+1}   = this.concatTransforms__(opts);
            end            
            xfm      = xfms{end};
            bldr.xfm = xfm;
        end 
        function c          = cost(this, bldr, cfun)
            %% COST
            %  @param bldr is an mlfsl.RegistrationBuilder with resampled image in product
            %  @param cfun is a cost function from flirt
            %
            %  Subject: Re: quantify registration evaluation
            %  From: Mark Jenkinson <[log in to unmask]>
            %  Reply-To: FSL - FMRIB's Software Library <[log in to unmask]>
            %  Date: Fri, 2 Oct 2009 08:24:23 +0100
            % 
            %  Hi,
            % 
            %  Yes, you can get this information from FLIRT.
            %  Just do:
            %     flirt -in resampled_image -ref refimage -schedule measurecost1.sch
            %  You can also select the similarity metric you want with -cost ...
            % 
            %  The measurecost1.sch file has been posted on the list before, but
            %  I'm attaching another copy here.  Just save it (as plain text)
            %  somewhere and give the full path in the command above.
            % 
            %  The cost value is the first number printed.  If you want to automatically
            %  select only this then you can do:
            %      flirt .... | head -1 | cut -f1 -d' '
            %  with the above flirt command.
            % 
            %  All the best,
            %  Mark

            assert(lstrfind(cfun, {'mutualinfo' 'corratio' 'normcorr' 'normmi' 'leastsq' 'labeldiff' 'bbr'}))
            
            opts              = mlfsl.FlirtOptions;
            opts.in           = bldr.product;
            opts.ref          = bldr.referenceImage;
            opts.cost         = cfun;
            opts.schedule     = fullfile(getenv('FSLDIR'), 'etc', 'flirtsch', 'measurecost1.sch');
            
            [~,r] = this.cmd('flirt', opts, ' | head -1 | cut -f1 -d'' ''');
            c = str2double(r);
        end
        function [bldr,xfm] = invertTransform(this, bldr)
            opts         = mlfsl.ConvertXfmOptions;
            opts.inverse = bldr.xfm;
            opts.omat    = this.inverseTransformFilename(bldr.xfm);
            xfm          = this.invertTransform__(opts);
            bldr.xfm     = xfm;
        end
        function bldr       = motionCorrect(this, bldr)
            opts         = mlfsl.McflirtOptions;
            opts.in      = this.assignIn(bldr);
            bldr.product = this.mcflirt__(opts);
        end    
        function [bldr,xfm] = registerInjective(this, bldr, proxyBldr)
            this.ensureBuilderSaved(bldr);
            this.ensureBuilderSaved(proxyBldr);
            
            opts              = mlfsl.FlirtOptions;
            opts.in           = proxyBldr.sourceImage;
            opts.ref          = proxyBldr.referenceImage;
            opts.cost         = 'corratio';
            opts.dof          = 6;  
            opts.inweight     = proxyBldr.sourceWeight;
            opts.refweight    = proxyBldr.referenceWeight;           
            opts.init         = this.flirt__(opts);
            
            opts.in           = bldr.sourceImage;
            opts.ref          = bldr.referenceImage;
            opts.inweight     = bldr.sourceWeight;
            opts.refweight    = bldr.referenceWeight; 
            bldr.product      = this.transform__(opts);
            bldr.product.addLog( ...
                ['FlirtVisitor.registerInjective.bldr.sourceImage\n' bldr.sourceImage.logger.contents]);
            bldr.xfm          = opts.init;
            xfm               = opts.init;
        end
        function [bldr,xfm] = registerSurjective(this, bldr, proxyBldr)
            this.ensureBuilderSaved(bldr);
            this.ensureBuilderSaved(proxyBldr);
            
            opts              = mlfsl.FlirtOptions;
            opts.in           = proxyBldr.referenceImage;
            opts.ref          = proxyBldr.sourceImage;
            opts.cost         = 'corratio';
            opts.dof          = 6;  
            opts.inweight     = proxyBldr.referenceWeight;
            opts.refweight    = proxyBldr.sourceWeight;           
            opts.init         = this.flirt__(opts);
            
            opts              = this.inverseTransformOptions__(opts);
            
            opts.in           = bldr.sourceImage;
            opts.ref          = bldr.referenceImage;
            opts.inweight     = bldr.sourceWeight;
            opts.refweight    = bldr.referenceWeight; 
            bldr.product      = this.transform__(opts);
            bldr.product.addLog( ...
                ['FlirtVisitor.registerSurjective.bldr.sourceImage\n' bldr.sourceImage.logger.contents]);
            bldr.xfm          = opts.init;
            xfm               = opts.init;
        end
        function bldr       = transform(this, bldr)
            if (isfolder(bldr.xfm))
                bldr = this.transform4D(bldr);
                return
            end
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            opts.interp  = bldr.interp;
            bldr.product = this.transform__(opts);
        end 
        function bldr       = transform4D(this, bldr)
            opts.input          = this.assignIn(bldr);
            opts.ref            = this.assignRef(bldr);
            opts.output         = this.mcf_fqfn(bldr.sourceImage);
            opts.transformation = bldr.xfm;
            bldr.product        = this.applyxfm4D__(opts);
            bldr.product.addLog('mlfsl.FlirtVisitor.transform4D');
            bldr.product.addLog(bldr.sourceImage.logger.contents);
            
            if (strcmp(bldr.interp, 'nearestneighbor'))
                p = bldr.product.numericalNiftid;
                bldr.product = p.binarized;
            end
        end
        
        %% LEGACY
        
        function [bldr,xfm] = alignMultispectral(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.dof     = 6;
            opts.cost    = 'normmi';
            opts         = this.assignWeights(bldr, opts);
            xfm          = this.flirt__(opts);
            
            opts.init    = xfm;
            bldr.xfm     = xfm;
            bldr.product = this.transform__(opts);            
        end  
        function [bldr,xfm] = alignPET(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.cost    = 'corratio';
            opts.dof     = 6;
            opts         = this.assignWeights(bldr, opts);
            xfm          = this.flirt__(opts);
            
            opts.init    = xfm;
            bldr.xfm     = xfm;
            bldr.product = this.transform__(opts);
        end
        function [bldr,xfm] = alignPETUsingTransmission(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignRef(bldr);
            opts.ref     = this.assignIn(bldr);
            opts.dof     = 6;
            opts         = this.assignWeights(bldr, opts);
            xfm          = this.flirt__(opts);
            
            bldr.xfm     = xfm;
            [bldr,xfm]   = this.invertTransform(bldr);
            
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.dof     = 6;
            opts.init    = xfm;
            bldr.xfm     = xfm;
            bldr.product = this.transform__(opts); 
        end
        function [bldr,xfm] = alignSmallAngles12DoF(this, bldr)
            opts          = mlfsl.FlirtOptions;
            opts.in       = this.assignIn(bldr);
            opts.ref      = this.assignRef(bldr);
            opts.dof      = 12;
            opts.cost     = 'normmi';
            opts.searchrx = ' -10 10 ';
            opts.searchry = ' -10 10 ';
            opts.searchrz = ' -10 10 ';
            opts          = this.assignWeights(bldr, opts);
            xfm           = this.flirt__(opts);
            
            opts.init     = xfm;
            bldr.xfm      = xfm;
            bldr.product  = this.transform__(opts);            
        end
        function [bldr,xfm] = alignSmallAnglesGluT(this, bldr)
            opts          = mlfsl.FlirtOptions;
            opts.in       = this.assignIn(bldr);
            opts.ref      = this.assignRef(bldr);
            opts.dof      = 6;  
            opts.cost     = 'normmi';
            opts.searchrx = ' -20 20 ';
            opts.searchry = ' -20 20 ';
            opts.searchrz = ' -20 20 ';
            opts          = this.assignWeights(bldr, opts);            
            xfm           = this.flirt__(opts);
            bldr.xfm      = xfm;
        end     
        function [bldr,xfm] = alignSmallAnglesForPET(this, bldr)
            opts          = mlfsl.FlirtOptions;
            opts.in       = this.assignIn(bldr);
            opts.ref      = this.assignRef(bldr);
            opts.cost     = 'corratio';
            opts.dof      = 6;
            opts.searchrx = ' -10 10 ';
            opts.searchry = ' -10 10 ';
            opts.searchrz = ' -10 10 ';
            opts          = this.assignWeights(bldr, opts);
            xfm           = this.flirt__(opts);
            
            opts.init     = xfm;
            bldr.xfm      = xfm;
            bldr.product  = this.transform__(opts);
        end
        function  bldr      = alignToFsaverage1mm(this, bldr)
            workpth = fullfile(getenv('MLUNIT_TEST_PATH'), 'np755/fsaverage_2013nov18/fsl', '');
            xfm     = fullfile(workpth, 'brainmask_2mm_on_brainmask_1mm.mat');
            assert(lexist(xfm, 'file'))
            
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = fullfile(workpth, 'brainmask_1mm');
            opts.init    = xfm;
            bldr.xfm     = xfm;
            bldr.product = this.transform__(opts);
        end        
        
        %% CTOR
        
        function this = FlirtVisitor(varargin)
            this = this@mlfsl.FslVisitor(varargin{:});
        end
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function prod = applyxfm4D__(this, opts)
            assert(isstruct(opts));
            opts = this.ensureFieldsAreFilenames(opts);
            [~,c] = mlbash(sprintf('applyxfm4D %s %s %s %s -fourdigit', ...
                opts.input, opts.ref, opts.output, opts.transformation));
            prod = mlfourd.ImagingContext2(opts.output);
            lg = this.getLog(opts.input);
            prod.addLog(['From FlirtVisitor.applyxfm4D__.opts.input:\n' lg.contents]);
            prod.addLog(c);            
        end
        function opts = concatTransformOptions__(this, varargin)
            cellfun(@(x) assert( ismember('init', properties(x))), varargin);
            cellfun(@(x) assert(~isempty(x.init)),                 varargin);
            
            opts = mlfsl.ConvertXfmOptions;
            for v = 1:length(varargin)-1
                opts.concat   = sprintf('%s %s', varargin{v+1}.init, varargin{v}.init);
                opts.omat     = this.concatTransformFilename(varargin{v}.init, varargin{v+1}.init);
                varargin{v+1} = this.concatTransforms__(opts);
            end
            opts.init = varargin{end};
        end
        function xfm  = concatTransforms__(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.concat));
            assert(~isempty(opts.omat));
            this.cmd('convert_xfm', opts); 
            xfm = opts.omat;
        end
        function omat = flirt__(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            this.cmd('flirt', opts);
            omat = opts.omat;
        end
        function opts = inverseTransformOptions__(this, opts)
            assert( ismember('init', properties(opts)));
            assert(~isempty(opts.init));
            
            opts2         = mlfsl.ConvertXfmOptions;
            opts2.inverse = opts.init;
            opts2.omat    = this.inverseTransformFilename(opts.init);
            opts.init     = this.invertTransform__(opts2);
        end
        function xfm  = invertTransform__(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.inverse));
            assert(~isempty(opts.omat));
            this.cmd('convert_xfm', opts);
            xfm = opts.omat;
        end
        function fqdn = mat_fqdn(this, ic)
            assert(isa(ic, 'mlfourd.ImagingContext2'));
            fqdn = [ic.fqfileprefix this.XFM_SUFFIX]; 
        end
        function fqfn = mcf_fqfn(this, ic)
            assert(isa(ic, 'mlfourd.ImagingContext2'));
            fqfn = [ic.fqfileprefix this.MCF_SUFFIX ic.filesuffix];
        end
        function fqdn = mcf_mat_fqdn(this, ic)
            assert(isa(ic, 'mlfourd.ImagingContext2'));            
            fqdn = [ic.fqfileprefix this.MCF_SUFFIX this.XFM_SUFFIX]; 
        end
        function prod = mcflirt__(this, opts)
            assert(isa(opts, 'mlfsl.McflirtOptions'));
            [~,~,c] = this.cmd('mcflirt', opts);
            prod = mlfourd.ImagingContext2([opts.in this.MCF_SUFFIX this.filetypeExt]);
            lg = this.getLog(opts.in);
            prod.addLog(['From FlirtVisitor.mclfirt__.opts.in\n' lg.contents]);
            prod.addLog(c);
        end
        function prod = transform__(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            opts.applyxfm = true;
            opts.omat = [];
            [~,~,c] = this.cmd('flirt', opts); 
            prod = mlfourd.ImagingContext2( ...
                this.thisOnThatImageFilename(opts.in, opts.init));
            lg = this.getLog(opts.in);
            prod.addLog(['From FlirtVisitor.transform__.opts.in:\n' lg.contents]);
            prod.addLog(c);
        end
    end
    
    %% PRIVATE
    
    methods (Access = private)
        function in   = assignIn(~, bldr)
            if (~isempty(bldr.sourceImage))
                in = bldr.sourceImage.fqfileprefix;
                return
            end
            in = bldr.product.fqfileprefix; % legacy work-flow
        end
        function ref  = assignRef(~, bldr)
            assert(~isempty(bldr.referenceImage));
            ref = bldr.referenceImage.fqfileprefix;
        end
        function opts = assignWeights(~, bldr, opts)
            if (~isempty(bldr.sourceWeight))
                if (~lexist(bldr.sourceWeight.fqfilename, 'file'))
                    bldr.sourceWeight.save; 
                end
                opts.inweight = bldr.sourceWeight.fqfileprefix;
            end
            if (~isempty(bldr.referenceWeight))
                if (~lexist(bldr.referenceWeight.fqfilename, 'file'))
                    bldr.referenceWeight.save; 
                end
                opts.refweight = bldr.referenceWeight.fqfileprefix;
            end
        end
        function s     = ensureFieldsAreFilenames(~, s)
            fn = fieldnames(s);
            for sidx = 1:length(fn)
                field = fn{sidx};
                if (~ischar(s.(field)))
                    assert(isa(s.(field), 'mlio.IOInterface') || isa(s.(field), 'mlfourd.ImagingContext2'));
                    s.(field) = s.(field).fqfilename;
                end
            end
        end
        function addLog(this, fn, c)
            [p,f] = myfileparts(fn);
            fn = fullfile(p, [f mlpipeline.Logger.FILETYPE_EXT]);
            
            lg = mlpipeline.Logger(fn, this);
            lg.add(c);
            lg.save;
        end
        function lg = getLog(this, fn)
            [p,f] = myfileparts(fn);
            fn = fullfile(p, [f mlpipeline.Logger.FILETYPE_EXT]);
            
            lg = mlpipeline.Logger(fn, this);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

