classdef BetBuilder < mlfsl.FslBuilder
	%% BETBUILDER
	%  Usage:  obj = BetBuilder(builder [, option, value, ...]) 
	%                          ^ cf. mlfourd.ImagingBulider 
    %                                              ^ booleans
	%% Version $Revision: 2610 $ was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $  
	%% and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetBuilder.m $ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id: BetBuilder.m 2610 2013-09-08 00:15:00Z jjlee $ 

    properties (Constant)
        BET_PREFIXES = { 'b' '' };
        BET_SUFFIXES = { ''  '_brain' };
        EXCLUSION_TOKENS = { 'bin*' '*_mask*' 'one_over*' '*ooho*' '*grey*' '*white*' '*csf*' 'fieldmap*' 't1Hires*' 'pdHires*' };
        MASK_SUFFIX = '_mask';
    end
    
    properties (Dependent)
        excludedFiles
    end
         
    methods (Static)
        function this  = createFromSessionPath(sesspth)
            this = mlfsl.BetBuilder.createFromConverter( ...
                mlsurfer.SurferDicomConverter.createFromSessionPath(sesspth));
        end                
        function this  = createFromModalityPath(modalpth)
            this = mlfsl.BetBuilder.createFromConverter( ...
                mlsurfer.SurferDicomConverter.createFromModalityPath(modalpth));
        end
        function this  = createFromConverter(cvtr)
            assert(isa(cvtr, 'mlfourd.AbstractConverter'));
            this = mlfsl.BetBuilder(cvtr);
        end  
        function tf    = isbetted(in)
            %% ISBETTED returns true if string in has bet pre/suffixes, otherwise false
            %  FSL default suffix "_brain" always returns true
            %  Usage:   tf = BetBuilder.isbetted(strin)

            in = imcast(in, 'fileprefix');
            tkns = mlfsl.BetBuilder.betTokens;
            for b = 1:length(tkns)
                p = tkns(b).prefix;
                s = tkns(b).suffix;
                if (length(p) + length(s) < length(in))                    
                    if (strncmp(in,                             p, length(p)) && ...
                        strncmp(in(length(in)-length(s)+1:end), s, length(s)))
                        tf = true;
                        return
                    end
                end
            end
            tf = false;
        end % static isbetted
        function tkns  = betTokens
            import mlfsl.*;
            assert(length(BetBuilder.BET_PREFIXES) == length(BetBuilder.BET_SUFFIXES));
            for t = 1:length(BetBuilder.BET_PREFIXES)
                tkns(t) = struct('prefix', BetBuilder.BET_PREFIXES{t}, 'suffix', BetBuilder.BET_SUFFIXES{t}); %#ok<AGROW>
            end
        end % static betTokens
        function name  = bettedFilename(name, varargin)
            %% bettedFilename adds bet prefix/suffix
            %  Usage:   names = BetBuilder.bettedFilename(obj0 [, 'fn', 'fq', full_path, ...])
            %           ^ char, cell-array of
            %                                         ^ fileprefix, filename, INIfTI, cell-arrays of
            %                                                  ^ forwarded to ImagingChooser.createFilename
            %  cf. mlchoosers.ImagingChoosers.createFilename

            import mlfsl.* mlfourd.*;
            name = imcast(name, 'fqfilename');
            if (~BetBuilder.isbetted(name))
                [pth,fp,ext] = filepartsx(name, NIfTId.FILETYPE_EXT);
                 name = ImagingParser.formFilename( ...
                                   fullfile(pth, [BetBuilder.betTokens.prefix fp BetBuilder.betTokens.suffix ext]), ...
                                   varargin{:}, 'fqfn');
            end
        end % static bettedFilename  
        function pfix  = bettedFileprefix(name, varargin)
            pfix = fileprefix( ...
                   mlfsl.BetBuilder.bettedFilename(name, varargin{:}));
        end
        function name  = unbettedFilename(name)
            %% UnbettedFilename strips bet prefix/suffix preserving path and extensions if present
            %  Usage:   fn = BetBuilder.unbettedFilename(fn)
            
            import mlfsl.* mlfourd.*;
            name = imcast(name, 'fqfilename');
            if (BetBuilder.isbetted(name))
                 name = ImagingParser.formFilename(...
                        scrubFqFilename(name, 'fqfn'));
            end
        end % static unbettedFilename
        function pfix  = unbettedFileprefix(name)
            pfix = prefix(mlfsl.BetBuilder.unbettedFilename(name));
        end
        function names = ensureBettedExist(names, cverter)
            %% ENSUREBETTEDEXIST runs bet as needed
            import mlfsl.*;
            names = ensureCell(names);
            this = BetBuilder(cverter);
            for n = 1:length(names)
                names{n} = BetBuilder.ensureBettedExists(names{n}, this);
            end
        end
        function name  = ensureBettedExists(name, bldrObj)
            %% ENSUREBETTEDEXISTS runs bet as needed
            
            import mlfsl.*;
            name = ensureFilename(name);
            if (isa(bldrObj, 'mlfsl.BetBuilder'))
                this = bldrObj; end
            if (isa(bldrObj, 'mlfourd.AbstractConverter'))
                this = BetBuilder(bldrObj); end
            assert(isa(this, 'mlfsl.BetBulder'));
            if (~BetBuilder.isbetted(name))
                bo = BetOptions;
                bo.in_tag = name;
                this.bet(bo);
            end
            name = BetBuilder.bettedFilename(name);
        end
    end % static methods
    
    methods %% set/get
        function fns   = get.excludedFiles(this)
            tokens = [this.EXCLUSION_TOKENS this.converter.tracerTokens];
            fns = flattencell( ...
                      cellfun(@(y) y.fqfns, ...
                          cellfun(@(x) mlsystem.DirTool(fullfile(this.fslPath, x)), tokens)));
        end
    end
    
	methods
        function [this,prod]  = bet(this, options)
            %% BET is a wrapper to FSL's bet
            %  Usage:  this = this.bet(bet_options)
            %                          ^ mlfsl.BetOptions
            
            import mlfsl.*;
            assert(isa(options, 'mlfsl.BetOptions'));
            if (BetBuilder.isbetted(options.in_tag)); return; end
            if (this.toExclude(options.in_tag)); return; end
            try
                [~,r] = this.fslcmd('bet', options); %#ok<NASGU>
            catch ME
                handexcept(ME, r); %#ok<NODEF>
            end
            this.lastProduct = options.out_tag;
            prod = this.lastProduct;
        end % bet  
        function [this,imobj] = betUsingReference(this,imobj)
            import mlfsl.*;
            [this,bt1] = this.betT1;
            [this,omat] = this.coregisterT1On(imobj);
            [~,bt1mask] = this.flirtBuilder_.applyTransform( ...
                          omat, this.betMaskName(bt1));
            [~,imobj] = this.applyBetMask(bt1mask, imobj);
        end % betUsingReference 
        function this = moveBetted(this)
            this.bettedPath = ensuredir(this.bettedPath);
            tokens = mlfsl.BetBuilder.betTokens;
            for b = 1:length(tokens)
                movefiles([tokens(b).prefix '*' tokens(b).suffix '*' mlfourd.NIfTId.FILETYPE_EXT], ...
                           this.bettedPath);
            end
        end % moveBetted         
	end % methods
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function this  = BetBuilder(varargin)
            %% BETBUILDER
            %  Usage:  obj = BetBuilder(imaging_converter[, ...]);
            
            this = this@mlfsl.FslBuilder(varargin{:}); 
            this.flirtBuilder_ = mlfsl.FlirtBuilder.createFromOtherBuilder(this);
        end % ctor
    end
    
    %% PRIVATE
    
    properties (Access = 'private')
        flirtBuilder_
    end
    
    methods (Access = 'private')
        function tf = toExclude(this, lbl)
            tf = lstrfind(this.excludedFiles, fileprefix(lbl));
        end 
        function [this,bt1] = betT1(this) 
            import mlfsl.*;
            if (~lexist(this.bettedFilename(this.mrReference)))
                betT1 = BetT1(this.flirtBuilder_);
                [~,bt1] = betT1.bet(this.t1);
            end
        end
        function [this,omat] = coregisterT1On(this, imobj)
            if (~lexist(this.imageObject(this.mrReference, imobj)))
                [~, omat] = this.flirtBuilder_.coregister(this.t1, imobj);
            end
        end
        function fn = betMaskName(this, fn)
            import mlfsl.*;
            if (~this.isbetted(fn))
                fn = this.bettedFilename(fn);
            end
            fn = filenameSuffixed(fn, this.MASK_SUFFIX);
        end
        function [this,imobj] = applyBetMask(this, mskobj, imobj)
            import mlfsl.*;
            typclass = class(imobj);
            imobj  = imcast(imobj, 'mlfourd.NIfTI');
            mskobj = imcast(mskobj, 'mlfourd.NIfTI');
            imobj  = imobj .* mskobj;
            imobj.saveas( ...
                  this.bettedFilename(imobj));
            imobj = imcast(imobj, typclass);
        end
    end % private methods
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
