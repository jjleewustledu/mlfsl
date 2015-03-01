classdef FlirtBuilder < mlfsl.FslBuilder 
	%% FLIRTBUILDER is a builder design pattern, delegates naming tasks to mlchoosers.ImagingChoosers, mlchoosers.ImagingParser
	%  Version $Revision: 2610 $ 
    %  was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ 
    %  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ 
    %  and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtBuilder.m $
 	%  Developed on Matlab 7.14.0.739 (R2012a)
 	%  $Id: FlirtBuilder.m 2610 2013-09-08 00:15:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Constant)
             MCF_SUFFIX = '_mcf';
         MEANVOL_SUFFIX = '_meanvol';
              KL_METRIC =  'kldivergence';
        PREPROCESS_LIST = { 'none' 'gauss' 'susan' 'blindd' };
    end
    
    properties (Dependent)
        preprocess
        transformationsPath
    end
    
    methods (Static) 
        function this = createFromConverter(cvtr)
            this = mlfsl.FlirtBuilder(cvtr);
        end
        function this = createFromModalityPath(mpth)
            assert(lexist(mpth, 'dir'));
            this = mlfsl.FlirtBuilder( ...
                   mlsurfer.SurferDicomConverter.createFromModalityPath(mpth));
        end
        function fns  = notMcf(fns)
            fns = mlfsl.FlirtBuilder.fileFilter(@foo, fns);
            
            function fn = foo(fn0)
                fn = '';
                if (~lstrfind(fn0, mlfsl.FlirtBuilder.MCF_SUFFIX))
                    fn = fn0;
                end
            end % foo
        end % static notMcf
        function fns  = notFlirted(fns)
            fns = mlfsl.FlirtBuilder.fileFilter(@foo, fns);
            
            function fn = foo(fn0)
                fn = '';
                if (~lstrfind(fn0, mlchooseres.ImagingChoosersInterface.INTERIMAGE_TOKEN))
                    fn = fn0;
                end
            end % foo
        end % static notFlirted
        function fns  = notBetted(fns)
            fns = mlfsl.FlirtBuilder.fileFilter(@foo, fns);
            
            function fn = foo(fn0)
                fn = '';
                if (~mlfsl.BetBuilder.isbetted(fn0))
                    fn = fn0;
                end
            end % foo
        end % static notBetted  
        function nm   = ensureMeanvolFilename(nm)
            import mlfsl.*;
            if (~lstrfind(nm, FlirtBuilder.MEANVOL_SUFFIX))
                nm = filenames([fileprefix(nm) FlirtBuilder.MEANVOL_SUFFIX]);
            end
        end
        function nm   = ensureMcfFilename(nm)
            import mlfsl.*;
            if (~lstrfind(nm, FlirtBuilder.MCF_SUFFIX))
                nm = filename([fileprefix(nm) FlirtBuilder.MCF_SUFFIX]);
            end
        end
        function nm   = blockedFilename(nm, block)
            str = num2str(block, '_%i_%i_%i');
            nm  = filename([fileprefix(nm) str]);
        end
        function nm   = blurredFilename(nm, blur)
            str = num2str(blur, '_%3.2g_%3.2g_%3.2g_mm');
            nm  = filename([fileprefix(nm) str]);
        end
        function nm   = flirtedFilename(nm, targ)
            if (~lstrfind(targ, mlfsl.FlirtBuilder.FLIRT_TOKEN))
                targ = [mlchooseres.ImagingChoosersInterface.INTERIMAGE_TOKEN targ];
            end
            nm = filename([fileprefix(nm) targ]);
        end         
        function m    = klMeasure(varargin)
            kl = mlentropy.KL(varargin{:});
            m  = kl.(mlfsl.FlirtBuilder.KL_METRIC);            
        end
        function tf   = consistentBettedStates(varargin)
            import mlfsl.*;
            assert(length(varargin) > 1);
            allbetted = all( ...
                        cellfun(@(v) BetBuilder.isbetted(v), varargin));
            allnotbetted = all( ...
                           cellfun(@(v) ~BetBuilder.isbetted(v), varargin));
            tf = allbetted || allnotbetted;
        end
    end % static methods
    
    methods %% set/get
        function this = set.preprocess(this, pp)
            assert(lstrfind(pp, this.PREPROCESS_LIST));
            this.preprocess_ = pp;
        end
        function pp   = get.preprocess(this)
            pp = this.preprocess_;
        end
        function pth  = get.transformationsPath(this)
            pth = fullfile(this.fslPath, this.fslRegistry.transformationsFolder, '');
        end        
    end
    
    methods
        
        %% Create FslOptions and pass on the tasks
        
        function [this,omat] = coregister(this, varargin)
            %% COREGISTER is the front-end method for flirting 
            %  Usage:  [this,xfm] = this.coregister(image_object, reference_object)
            %           ^ FlirtBuilder w/ updated products, logs
            %                                  ^ NIfTIInterface, filename, ...
            %          [this,xfm] = this.coregister(FlirtOptions_object)

                opts = mlfsl.FlirtOptions;
                switch (length(varargin))
                    case 1
                        if (isa(varargin{1}, 'mlfsl.FlirtOptions'))
                            opts = varargin{1}; 
                        else
                            opts.in = varargin{1};
                        end
                    case 2
                        opts.in  = varargin{1};
                        opts.ref = varargin{2};
                    case 3
                        opts.in  = varargin{1};
                        opts.ref = varargin{2};
                        opts.out = varargin{3};
                    otherwise
                        error('mlfsl:unsupportedPassedParams', 'FlirtBuilder.coregister.varargin->%s', cell2str(varargin));
                end
                [this,omat] = this.coregisterByOptions(opts);
        end % coregister
        function [this,fp]   = moco(this, varargin)
            %% MOCO is the front-end method for mcflirt
            
            try
                opts = mlfsl.McflirtOptions;
                if (isa(varargin{1}, 'mlfsl.McflirtOptions'))
                    opts = varargin{1}; end
                switch (length(varargin))
                    case 1
                        if (~isa(varargin{1}, 'mlfsl.McflirtOptions'))
                            opts.in_tag = varargin{1}; end
                    otherwise
                        error('mlfsl:UnexpectedPassedParams', 'FlirtBuilder.moco.varargin length->%s', length(varargin));
                end
                [this,fp] = this.mocoByOptions(opts);
            catch ME                
                handexcept(ME);
            end
        end % moco        
        function               cleanMoco(this)
            %% CLEANMOCO tidies up the FSL work-directory by moving intermediates in NamingRegistry.backupFolder

            import mlfourd.* mlfsl.* mlsystem.*;  
            dt = DirTool(fullfile(this.fslPath, '*.mat')); 
            dt.mv(dt.fqfns, this.transformationsPath, '-f');  
            
            bak = fullfile(this.fslPath, this.namingInterface.backupFolder);
            this.movePatterns( ...
                {'*.par' '*_mean_*.nii.gz' '*_sigma*.nii.gz' '*_variance*.nii.gz' '*_mcf.nii.gz'}, ...
                this.fslPath, bak);
            dt = DirTool( ...
                fullfile(this.fslPath, this.namingInterface.allNIfTI));
            dt.mv( ...
                this.notMcf( ...
                FilenameFilters.timeDependent(dt.fqfns)), bak, '-f');
        end % cleanMoco  
        function               movePatterns(this, patts, pth, targ)
            %% MOVEPATTERNS 
            %  Usage:  FlirtBuilder.movePatterns(string_pattern, from_path, to_path)
            
            p = inputParser;
            addRequired(p, 'patts', @ischar);
            addOptional(p, 'pth', this.fslPath, @(x) lexist(x,'dir'));
            addOptional(p, 'targ', ...
                       fullfile(this.fslPath, this.namingInterface.backupFolder, ''), ...
                       @(x) lexist(x,'dir'));
            parse(p, patts, pth, targ);
            patts = ensureCell(p.Results.patts);
            for p = 1:length(patts)
                dt = mlsystem.DirTool(fullfile(p.Results.pth, patts{p}));
                dt.mv(dt.fqfns, p.Results.targ, '-f');
            end  
        end
        function [this,im]   = applyTransform(this, varargin)
            %% APPLYTRANSFORM is the front-end method for applyxfm operations
            %  Usage:  [this,image_object] = flirtf.applyTransform([FlirtOptions_object | xfmatrix, image_obj])
            
            opts = mlfsl.FlirtOptions;
            try
                switch (length(varargin))
                    case 1
                        assert(isa(varargin{1}, 'mlfsl.FlirtOptions'));  
                        opts      = varargin{1};                           
                    case 2
                        opts.init = varargin{1};
                        opts.in   = varargin{2};
                    case 3                         
                        opts.init = varargin{1};
                        opts.in   = varargin{2};
                        opts.ref  = varargin{3};
                    case 4      
                        opts.init = varargin{1};
                        opts.in   = varargin{2};
                        opts.ref  = varargin{3};
                        opts.out  = varargin{4};
                    otherwise
                        error('mlfsl:unsupportedPassedParams', 'FlirtBuilder.applyTransform.varargin->%s', cell2str(varargin));
                end
                if (isempty(opts.ref))
                    opts.ref = this.mrReference; end
                opts.applyxfm = true; 
                opts.omat = [];
                [this,im] = this.applyTransformByOptions(opts);
            catch ME
                handexcept(ME);
            end
        end % applyTransform                       
        function [this,xfm]  = invertTransform(this, varargin)
            %% INVERTTRANSFORM  is the front-end method for convertxfm -inverse
            %  Usage:  [sta, std] = flirtf.invertTransform(options_structs[, more_options)
            %                                        ^ fields:  [omat, ]inverse[, options]
            
            try 
                opts = mlfsl.ConvertXfmOptions;
                if (isa(varargin{1}, 'mlfsl.ConvertXfmOptions'))
                    opts = varargin{1}; end
                switch (length(varargin))
                    case 1
                        if (~isa(varargin{1}, 'mlfsl.ConvertXfmOptions'));
                            opts.init = varargin{1}; end
                    otherwise
                        opts.init = this.xfmName(varargin{:});
                end
            catch ME
                handexcept(ME);
            end
            [this,xfm] = this.invertTransformByOptions(opts);
        end % invertTransform        
        function [this,xfm]  = concatTransforms(this, varargin)
            %% CONCATTRANSFORMS is the front-end method for convertxfm -concat
            %  Usage:  [sta, std] = flirtf.concatTransforms(options_structs[, more_options)
            %                                        ^ fields:  AtoB, BtoC[, AtoC, options])
            
            try
                opts = mlfsl.ConvertXfmOptions;
                if (isa(varargin{1}, 'mlfsl.ConvertXfmOptions'))
                    opts = varargin{1}; end
                switch (length(varargin))
                    case 1
                        if (~isa(varargin{1}, 'mlfsl.ConvertXfmOptions'))
                            opts.concat = varargin{1}; end
                    case 2
                        opts.concat = sprintf('%s %s', imcast(varargin{1},'fileprefix'), imcast(varargin{2},'fileprefix'));
                    otherwise
                        for v = 1:length(varargin)-1
                            opts.concat = [ ...
                                imcast(varargin{v},   'fileprefix') ' ' ...
                                imcast(varargin{v+1}, 'fileprefix')];
                            [this,xfm] = this.concatTransformsByOptions(opts);
                            varargin{v+1} = xfm;
                        end
                        return
                end
                [this,xfm] = this.concatTransformsByOptions(opts);
            catch ME
                handexcept(ME);
            end
        end % concatTransforms  
        function pth         = inBet(this, fp)
            [~,fp,e] = filepartsx(fp, mlsystem.NIfTIInterface.FILETYPE_EXT);
            pth = fullfile(this.bettedPath, [fp e]);
        end         
        
        %% Pass FslOptions, check for missing values, insert default values
        
        function [this,omat]     = coregisterByOptions(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            if (isempty(opts.ref));
                opts.ref = this.mrReference; end
            [~,this.lastLogged] = mlfsl.FlirtBuilder.fslcmd('flirt', opts);
               this.lastProduct = opts.omat;
                           omat = this.lastProduct;
        end
        function [this,omatbest] = coregisterBiByOptions(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            opts2 = opts;
            opts2.in = opts.ref;
            opts2.ref = opts.in;
            opts2.omat = '';
            opts2.out = '';
            [this,omat]  = this.coregisterByOptions(opts);
            [this.omat2] = this.coregisterByOptions(opts2);
            kl  = this.klMeasure(this.imageObject(omat),  opts.ref);
            kl2 = this.klMeasure(this.imageObject(omat2), opts.ref);
            if (kl < kl2)
                this.lastProduct = omat;
                omatbest = this.lastProduct;
            else                
                this.lastProduct = this.invertTransform(opts2.omat);
                omatbest = this.lastProduct;
            end
        end
        function [this,fprefix]  = mocoByOptions(this, opts)
            assert(isa(opts, 'mlfsl.McflirtOptions'));
            [~,this.lastLogged] = mlfsl.FlirtBuilder.fslcmd('mcflirt', opts);
            this.lastProduct = opts.out;
            fprefix = this.lastProduct;
        end
        function [this,im]       = applyTransformByOptions(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            [~,this.lastLogged] = mlfsl.FlirtBuilder.fslcmd('flirt', opts); 
               this.lastProduct = this.imageObject(opts.in, opts.init);
                             im = this.lastProduct;
        end
        function [this,xfm]      = invertTransformByOptions(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            [~,this.lastLogged] = mlfsl.FlirtBuilder.fslcmd('convert_xfm', opts); 
            this.lastProduct = this.xfmName(opts);
            xfm = this.lastProduct;
        end
        function [this,xfm]      = concatTransformByOptions(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));            
            [~,this.lastLogged] = mlfsl.FlirtBuilder.fslcmd('convert_xfm', opts); 
            this.lastProduct = this.xfmName(opts);
            xfm = this.lastProduct;
        end
    end % methods
    
    %% PROTECTED 
    
    methods (Access = 'protected') 
        function this = FlirtBuilder(varargin)
 			%  Usage:  obj = FlirtBuilder(cverter[, ...]);
            %                            ^ ConverterInterface
            %                                      ^ See FslBuilder
            
            this = this@mlfsl.FslBuilder(varargin{:});
        end % ctor 
        function opts = flirtChecks(this, opts)
            %% FLIRTCHECKS asserts that fields ref, in, out, omat exist,
            %  and that ref and in have consistent betted states; many checks moved directly into FlirtOptions
            
            import mlfsl.*;
            assert(this.consistentBettedStates(opts.in, opts.ref), ...
                   'flirtChecks:  inconsistent bet-states for %s and %s', opts.in, opts.ref);
        end
    end 

    %% PRIVATE
    
    properties (Access = 'private')
        preprocess_
    end
    
    methods (Static, Access = 'private')
        function found = fileFilter(h, fns)
            import mlfourd.*;            
            assert(~isempty(           fns));
            fns   = ensureCell(        fns);
            tmp   = cellfun(@(x) h(x), fns, 'UniformOutput', false);
            found = {};
            for t = 1:length(tmp)
                if (~isempty(tmp{t}))
                    found = [found tmp{t}];  %#ok<AGROW>
                end
            end
        end
    end

    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
