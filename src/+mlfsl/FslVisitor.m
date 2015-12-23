classdef FslVisitor < mlpipeline.PipelineVisitor
	%% FSLVISITOR   

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FslVisitor.m 2629 2013-09-16 06:19:00Z jjlee $ 
    
	methods (Static)
        function [s,r]   = cmd(exe, opts, varargin)
            [s,r] = mlfsl.FslVisitor.fslcmd(exe, opts, varargin{:});
        end
        function msg     = help(exe)
            msg = mlfsl.FslVisitor.fslhelp(exe);
        end
        function [s,r]   = view(fns)
            [s,r] = mlfsl.FslVisitor.fslview(fns);
        end
        function [s,r,c] = fslcmd(exe, opts, varargin)
            %% FSLCMD is a mini-facade to the FSL command-line
            %  [s,r] = FslVisitor.fslcmd(executable[, option, option2, ...])
            %                           ^ cmd name; without options, typically returns usage help 
            %                                        ^ structs, strings or cell-arrays of
            %  structs, strings and cells of options may be arranged to reflect cmd-line ordering 
            
            import mlfsl.*;
            opts = FslVisitor.oany2str(opts, exe);
            for v = 1:length(varargin)
                opts = sprintf('%s %s', opts, FslVisitor.oany2str(varargin{v}, exe));
            end
            c = sprintf('%s %s %s', exe, opts, FslVisitor.outputRedirection);
            r = '';
            try
                [s,r] = mlbash(c);
                if (0 ~= s); error('mlfsl:shellFailure', 'FslVisitor.fslcmd %s\nreturned %i', c, s); end
            catch ME
                handexcept(ME,r);
            end
        end 
        function dat     = fslhdParameter(fprefix, pname)
            %% FSLHDPARAMETER accepts NIfTI fileprefixes/names; it returns the stringified value of the first match 
            %  of an FSL-header parameter.
            %  Usage:   datum = FslVisitor.fslhdParameter(fileprefix, param-name)
            %                                            ^ or filename
            %           ^                                            ^ all strings
            
            dat = '';
            [~,xmlish] = mlbash(['fslhd -x ' fprefix]);
            
            expression = ['\s+' pname '\s+=\s+''(?<value>\S+|\S+\s\S+|[\d\.\+\s\-]+)''$'];
            [~, names] = regexp(xmlish, expression, 'tokens', 'names', 'lineanchors');
            if (~isempty(names))
                   dat = names(:,1).value;
            end
        end 
        function msg     = fslhelp(exe)
            %% FSLHELP returns cmd-line help in a single string
           
            assert(~isemptyChar(exe));
            cmds = { '%s -h' '%s' '%s -?' }; msg = '';
            for c = 1:length(cmds)
                try
                    [~,v] = mlbash(sprintf(cmds{c}, exe));
                    if (~allempty(strfind(v, 'Usage')) && ~allempty(strfind(v, exe)))
                        msg = v;
                        break
                    end
                catch ME
                    handexcept(ME);
                end
            end
        end 
        function [s,r]   = fslmaths(args)
            [s,r] = mlfsl.FslVisitor.fslcmd('fslmaths', args);
        end       
        function [s,r]   = fslstats(args, optstrct)
            [s,r] = mlfsl.FslVisitor.fslcmd('fslstats', args, optstrct);
        end 
        function [s,r]   = fslsusan(inname, hwhh, outname)
            inname  = ensureFilenameExists(inname);
            outname = ensureFilename(outname);
            [s,r]   = mlfsl.FslVisitor.fslcmd('susan', inname, num2str([-1 hwhh 3 1 0]), outname);
        end 
        function [s,r]   = fslview(fns)
            %% FSLVIEW launches fslview with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.fslview( 'file1')
            %           [sta, std] = obj.fslview({'file1' [, 'file2', options_struct]})
            %                                     ^          ^ string or cell array 
            %                                                        ^ cf. fslview -h
            
            import mlfsl.*;
            fns = fileprefixes(fns);
            fns = ensureCell(  fns);    
            if (~exist('optstrct','var')); optstrct = struct([]); end
            fns{length(fns)+1} = ' &';
            [s,r] = FslVisitor.fslcmd('fslview', optstrct, fns);
        end 
        function [s,r]   = slices(fns, optstrct)
            %% SLICES launches slices with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.slices( 'file1')
            %           [sta, std] = obj.slices({'file1' [, 'file2', options_struct]})
            %                                     ^          ^ string or cell array 
            %                                                        ^ e.g., struct('s', scale, 'i', [num2str(intmin) num2str(intmax)])
            
            import mlfsl.*;
            fns   = fileprefixes(fns);
            if (~exist('optstrct','var')); optstrct = struct([]); end
            [s,r] = FslVisitor.fslcmd('slices', optstrct, fns);
        end    
        function [s,r]   = slicesdir(fns, optstrct)
            %% SLICESDIR launches slicesdir with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.slicesdir( 'file1')
            %           [sta, std] = obj.slicesdir({'file1' [, 'file2', options_struct]})
            %                                        ^          ^ string or cell array 
            %                                                           ^ e.g., struct('p', image, 'e', threshold)
            %  use <image> as red-outline image on top of all images in <filelist>
            %  use the specified <threshold> for edges (if >0 use this proportion of max-min, if <0, use the absolute value)
            
            import mlfsl.*;
            fns   = fileprefixes(fns);
            if (exist('optstrct','var'))
            else
                optstrct = struct([]); 
            end
            [s,r] = FslVisitor.fslcmd('slicesdir', optstrct, fns);
        end
        function str     = outputRedirection
            if (mlpipeline.PipelineRegistry.instance.logging)
                str = sprintf(' >> %s 2>&1', ...
                             ['FslVisitor_' datestr(now,30) '.log']); %% KLUDGE 
            else
                str = '';
            end            
        end
        
        %% See also:  PipelineVisitor.thisOnThatImageFilename, PipelineVisitor.thisOnThatXfmFilename
        
        function fqfn  = xfmName(varargin)
            if (1 == length(varargin))
                fqfn = filename( ...
                       fileprefix(varargin{1}), mlfsl.FlirtVisitor.XFM_SUFFIX);
                return
            end
            
            import mlchoosers.* mlfsl.*;
            namstr = ImagingChoosers.coregNameStruct(varargin{:});
            fqfn = fullfile(namstr.path, ...
                           [namstr.pre FslRegistry.INTERIMAGE_TOKEN namstr.post FlirtVisitor.XFM_SUFFIX]);
        end
        function fqfn  = xfmConcatName(fqfn1, fqfn2)
            fqfn = mlfsl.FslVisitor.xfmName(fqfn1, fqfn2);
        end
        function fqfn  = xfmInverseName(fqfn)
            assert(ischar(fqfn));
            nameStruct = mlchoosers.ImagingChoosers.coregNameStruct(fqfn);
            fqfn       = fullfile(nameStruct.path, [nameStruct.post '_on_' nameStruct.pre mlfsl.FlirtVisitor.XFM_SUFFIX]);
        end
    end
    
    methods
        function this  = FslVisitor(varargin)
            this = this@mlpipeline.PipelineVisitor(varargin{:});
        end
    end
    
    %% PROTECTED
    
    methods (Static, Access = 'protected')
        function str   = oany2str(obj, exe)
            import mlfsl.*;
            switch (class(obj))
                case 'char'
                    str = obj;
                case 'struct'
                    str = FslVisitor.ostruct2str(obj, exe);
                case 'cell'
                    str = FslVisitor.ocell2str(obj, true, false);
                case 'function_handle'
                    str = func2str(obj);
                otherwise
                    str = FslVisitor.otherwise2str(obj);
            end
        end
        function str   = otherwise2str(obj)
            if (isnumeric(obj))
                str = mat2str(obj);
            elseif (isa(obj, 'mlfourd.NIfTIInterface'))
                str = obj.fqfilename;
            elseif (isobject(obj))
                try
                    str = char(obj);
                catch ME                
                    handexcept(ME);
                end
            else
                error('mfiles:unsupportedType', 'FslVisitor.otherwise2str does not support objects of type %s', class(ob));
            end
        end
        function str   = ocell2str(opts)
            assert(~isemptyCell(opts));
            opts = cellfun(@(x) [x ' '], opts, 'UniformOutput', false);
            str  = cell2str(opts);
        end
        function str   = ostruct2str(opts, ~)
            assert(~isstructEmpty(opts));
            fields = fieldnames(opts);
            str = '';
            for f  = 1:length(fields)
                assert(~isempty(fields{f}));
                if (~isemptyChar(opts.(fields{f})))
                    opts.(fields{f}) = ensureString(opts.(fields{f}));
                end                
                if (exist('exe','var'))
                    mlfsl.FslVisitor.assertOptionAllowed(fields{f}, exe);
                end
                assert(1 == length(opts))
                str = sprintf(' %s -%s %s', str,  fields{f}, opts.(fields{f}));
            end
        end
        function         assertOptionAllowed(opt, exe)
            warning('mlfsl:notImplemented', 'FslVisitor.assertOptionAllowed');
            assert(isstruct(opt));
            assert(ischar(exe));
            msg = mlfsl.FslVisitor.fslhelp(exe);
            fields = fieldnames(opt);
            for f = 1:length(fields)
                assert(lstrfind(fields{f}), msg);
            end
        end
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

