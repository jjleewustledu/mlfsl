classdef BrainExtractionVisitor < mlfsl.FslVisitor 
	%% BETVISITOR   

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BrainExtractionVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: BrainExtractionVisitor.m 2629 2013-09-16 06:19:00Z jjlee $ 
 	 
    properties (Constant)
        BET_PREFIXES     = { 'b' '' };
        BET_SUFFIXES     = { ''  '_brain' };
        EXCLUSION_TOKENS = { 'bin*' '*_mask*' 'one_over*' 'oneOver*' '*ooho*' '*grey*' '*white*' '*csf*' 'fieldmap*' 't1Hires*' 'pdHires*' };
        MASK_SUFFIX      = '_mask';
    end
    
    methods (Static)
        function tf    = isbetted(in)
            %% ISBETTED returns true if string in has bet pre/suffixes, otherwise false
            %  FSL default suffix "_brain" always returns true
            %  Usage:   tf = BrainExtractionVisitor.isbetted(strin)

            in   = imcast(in, 'fileprefix');
            tkns = mlfsl.BrainExtractionVisitor.betTokens;
            for b = 1:length(tkns)
                p = tkns(b).prefix;
                s = tkns(b).suffix;
                if (length(p) < length(in) && length(s) < length(in))                    
                    if (strfound(in, p) && ...
                        strfound(in(length(in)-length(s)+1:end), s))
                        tf = true;
                        return
                    end
                end
            end
            tf = false;
            
            function tf = strfound(pfix, str)
                tf = strncmp(pfix, str, length(str));
            end
        end % static isbetted
        function tkns  = betTokens
            import mlfsl.*;
            assert(length(BrainExtractionVisitor.BET_PREFIXES) == length(BrainExtractionVisitor.BET_SUFFIXES));
            for t = 1:length(BrainExtractionVisitor.BET_PREFIXES)
                tkns(t) = struct( ...
                         'prefix', BrainExtractionVisitor.BET_PREFIXES{t}, ...
                         'suffix', BrainExtractionVisitor.BET_SUFFIXES{t}); %#ok<AGROW>
            end
        end % static betTokens
        function name  = bettedFilename(name)
            %% BETTEDFILENAME adds bet prefix/suffix
            %  Usage:   name = BrainExtractionVisitor.bettedFilename(image_object)
            %           ^ filename
            %                                                        ^ fileprefix, filename, NIfTIInterface

            name = filename( ...
                   mlfsl.BrainExtractionVisitor.bettedFileprefix(name), ...
                   mlfourd.NIfTId.FILETYPE_EXT);
        end % static bettedFilename  
        function pfix  = bettedFileprefix(pfix)
            %% BETTEDFILEPREFIX adds bet prefix/suffix
            %  Usage:   name = BrainExtractionVisitor.bettedFileprefix(image_object)
            %           ^ filename
            %                                                          ^ fileprefix, filename, NIfTIInterface

            import mlfsl.*;
                 pfix  = imcast(pfix, 'fqfileprefix');
            [pth,pfix] = myfileparts(pfix);
                 pfix  = fullfile(pth, ...
                         [BrainExtractionVisitor.betTokens.prefix pfix BrainExtractionVisitor.betTokens.suffix]);
        end
        function lbl   = guessContrast(varargin)
            p = inputParser;
            addRequired(p, 'imobj', @(o) isa(o, 'mlfourd.ImagingContext'));
            parse(p, varargin{:});
            
            hint    = imcast(p.Results.imobj, 'fileprefix');
            reg     = mlchoosers.SpectralRegistry.instance;
            spectra = properties(reg);
            for s = 1:length(spectra)
                if (lstrfind(hint, reg.(spectra{s})))
                    lbl = reg.(spectra{s}); return; end
            end
        end
        function name  = unbettedFilename(name)
            %% UNBETTEDFILENAME strips bet prefix/suffix preserving path and extensions if present
            %  Usage:   filename = BrainExtractionVisitor.unbettedFilename(filename)
            
            name = filename( ...
                   mlfsl.BrainExtractionVisitor.unbettedFileprefix(name), ...
                   mlfourd.NIfTId.FILETYPE_EXT);
        end % static unbettedFilename
        function pfix  = unbettedFileprefix(pfix)
            %% UNBETTEDFILENAME strips bet prefix/suffix preserving path if present
            %  Usage:   fileprefix = BrainExtractionVisitor.unbettedFilename(fileprefix)
           
            import mlfsl.*;
            pfix = imcast(pfix, 'fqfileprefix');
            if (BrainExtractionVisitor.isbetted(pfix))
                [pth,pfix] = myfileparts(pfix);                
                tkns = mlfsl.BrainExtractionVisitor.betTokens;
                for b = 1:length(tkns)                    
                    p = tkns(b).prefix;
                    s = tkns(b).suffix;
                        
                    ppos = strfind(pfix, p);
                    if (~isempty(ppos))
                        pfix = pfix(ppos+length(p):end); end                    
                    spos = strfind(pfix, s);
                    if (~isempty(spos))
                        pfix = pfix(1:spos-1); end
                end
                pfix = fullfile(pth, pfix);
            end
        end
    end
    
	methods 
 		function bldr = visitMRAlignmentBuilder(this, bldr) 
            assert(lexist(bldr.product.fqfilename, 'file'));
            this.product = mlfourd.ImagingContext.load(bldr.product);
            opts         = mlfsl.BrainExtractionOptions.newStrategy( ...
                           this.guessContrast(bldr.product), this);
            if (~lexist(filename(opts.out_tag)))
                this = this.bet(opts); end
            this.product = mlfourd.ImagingContext.load(opts.out_tag);
            bldr.product = this.product;
        end 
        function bldr = visitMorphingBuilder(this, bldr)
            bldr = this.visitMRAlignmentBuilder(bldr);
        end
 		function this = BrainExtractionVisitor(varargin) 
 			%% BRAINEXTRACTIONVISITOR 
 			%  Usage:  this = BrainExtractionVisitor() 

 			this = this@mlfsl.FslVisitor(varargin{:}); 
 		end 
    end 
    
    %% PRIVATE 
    
    methods (Access = 'private')
        function this = bet(this, opts)
            assert(isa(opts, 'mlfsl.BrainExtractionOptions'));
            [~,log] = mlfsl.FslVisitor.cmd('bet', opts);
                      this.logger.add(log);  
            this.product = mlfourd.ImagingContext.load(opts.out_tag);
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

