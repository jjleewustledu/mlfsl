classdef FslBuilder < mlfourd.ImageBuilder
    %% FSLBUILDER is DEPRECATED; prefer mlfsl.FslVisitor
    %
	%  Version $Revision: 2610 $ was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslBuilder.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: FslBuilder.m 2610 2013-09-08 00:15:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (Dependent)
        atlasPath
        bettedPath
        bettedStandard
        fslPath
        fslRegistry
        mrReference
        namingInterface
        standardAtlas
        standardPath
        standardReference
        roisLabel
    end

    methods (Static)
        function this =  createFromModalityPath(mpth)
            assert(lexist(mpth, 'dir'));
            this = mlfsl.FslBuilder( ...
                   mlsurfer.SurferDicomConverter.createFromModalityPath(mpth));
        end
        function this  = createFromConverter(cvtr)
            assert(isa(cvtr, 'mlfourd.AbstractConverter'));
            this = mlfsl.FslBuilder(cvtr);
        end        
        function [s,r] = fslcmd(exe, opts, varargin)
            %% FSLCMD is a mini-facade to the FSL command-line
            %  [s,r] = FslBuilder.fslcmd(executable[, option, option2, ...])
            %                           ^ cmd name; without options, typically returns usage help 
            %                                        ^ structs, strings or cell-arrays of
            %  structs, strings and cells of options may be arranged to reflect cmd-line ordering 
            
            import mlfsl.*;
            opts = FslBuilder.oany2str(opts, exe);
            for v = 1:length(varargin)
                opts = sprintf('%s %s', opts, FslBuilder.oany2str(varargin{v}, exe));
            end
            r = '';
            try
                [s,r] = mlbash(sprintf('%s %s %s', exe, opts, FslBuilder.outputRedirection));
            catch ME
                handexcept(ME,r);
            end
        end % static fslcmd
        function dat   = fslhdParameter(fprefix, pname)
            %% FSLHDPARAMETER accepts NIfTI fileprefixes/names; it returns the stringified value of the first match 
            %  of an FSL-header parameter.
            %  Usage:   datum = FslBuilder.fslhdParameter(fileprefix, param-name)
            %                                            ^ or filename
            %           ^                                            ^ all strings
            
            dat = '';
            [~,xmlish] = mlbash(['fslhd -x ' fprefix]);
            
            expression = ['\s+' pname '\s+=\s+''(?<value>\S+|\S+\s\S+|[\d\.\+\s\-]+)''$'];
            [~, names] = regexp(xmlish, expression, 'tokens', 'names', 'lineanchors');
            if (~isempty(names))
                   dat = names(:,1).value;
            end
        end % static fslhdParameter  
        function msg   = fslhelp(exe)
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
        end % static fslhelp
        function [s,r] = fslmaths(args)
            [s,r] = mlfsl.FslBuilder.fslcmd('fslmaths', args);
        end % static fslmaths        
        function [s,r] = fslstats(args, optstrct)
            [s,r] = mlfsl.FslBuilder.fslcmd('fslstats', args, optstrct);
        end % static fslstats
        function [s,r] = fslsusan(inname, hwhh, outname)
            inname  = ensureFilenameExists(inname);
            outname = ensureFilename(outname);
            [s,r]   = mlfsl.FslBuilder.fslcmd('susan', inname, num2str([-1 hwhh 3 1 0]), outname);
        end % static fslsusan
        function [s,r] = fslview(fns)
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
            [s,r] = FslBuilder.fslcmd('fslview', optstrct, fns);
        end % static fslview
        function [s,r] = slices(fns, optstrct)
            %% SLICES launches slices with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.slices( 'file1')
            %           [sta, std] = obj.slices({'file1' [, 'file2', options_struct]})
            %                                     ^          ^ string or cell array 
            %                                                        ^ e.g., struct('s', scale, 'i', [num2str(intmin) num2str(intmax)])
            
            import mlfsl.*;
            fns   = fileprefixes(fns);
            if (~exist('optstrct','var')); optstrct = struct([]); end
            [s,r] = FslBuilder.fslcmd('slices', optstrct, fns);
        end % static slices    
        function [s,r] = slicesdir(fns, optstrct)
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
            [s,r] = FslBuilder.fslcmd('slicesdir', optstrct, fns);
        end % static slicesdir
        function str   = outputRedirection
            if (mlpipeline.PipelineRegistry.instance.logging)
                str = sprintf(' >> %s 2>&1', ...
                             ['FslBuilder.log']);
            else
                str = '';
            end            
        end
        function fqfn  = xfmName(varargin)
            if (1 == length(varargin))
                fqfn = filename( ...
                       fileprefix(varargin{1}), mlfsl.FlirtVisitor.XFM_SUFFIX);
                return
            end
            namstr = mlchoosers.ImagingChoosers.coregNameStruct(varargin{:});
            fqfn = fullfile(namstr.path, [namstr.pre mlfsl.FslRegistry.INTERIMAGE_TOKEN namstr.post mlfsl.FlirtVisitor.XFM_SUFFIX]);
        end
        function niis  = xfms2niis(xfms)
            assert(iscell(xfms));
            niis = mlfourd.ImagingArrayList;
            for x = 1:length(xfms)
                niis.add(mlfsl.FlirtBuilder.xfm2nii(xfms{x}));
            end
        end
        function nii   = xfm2nii(xfm)
            nii = mlfourd.NIfTI.load(mlfsl.FlirtBuilder.xfm2imgfn(xfm));
        end
        function imgfn = xfm2imgfn(xfm)
            assert(ischar(xfm));
            imgfn = [fileprefix(xfm, mlfsl.FlirtVisitor.XFM_SUFFIX) mlfourd.INIfTI.FILETYPE_EXT];
        end
    end
        
	methods % set/get, some delegation to mlfsl.FslRegistry
        function pth  = get.atlasPath(this)
            pth = this.fslRegistry.atlasPath;
        end
        function pth  = get.bettedPath(this)
            pth = fullfile(this.fslPath, this.fslRegistry.betFolder, '');
        end 
        function ref  = get.bettedStandard(this)
            ref = this.fslRegistry.bettedStandard;
        end 
        function pth  = get.fslPath(this)
            pth = fullfile(this.sessionPath, this.fslRegistry.fslFolder, '');
        end
        function reg  = get.fslRegistry(this) %#ok<MANU>
            reg = mlfsl.FslRegistry.instance; 
        end
        function ref  = get.mrReference(this)
            ref = this.namingInterface.t1;
        end
        function ni   = get.namingInterface(this)
            if (isempty(this.imagingChoosers_))
                 this.imagingChoosers_ = mlfourd.ImagingParser(this.fslPath);
            end
            ni = this.imagingChoosers_;
        end
        function ref  = get.standardAtlas(this)
            ref = this.fslRegistry.standardAtlas;
        end 
        function pth  = get.standardPath(this)
            pth = this.fslRegistry.standardPath;
        end 
        function ref  = get.standardReference(this)
            ref = this.fslRegistry.standardReference;
        end 
        function lbl  = get.roisLabel(this) %#ok<MANU>
            lbl = 'rois';
        end
    end
    
    methods
        function pth   = inFsl(this, fp)
            [~,fp,e] = filepartsx(fp, mlfourd.INIfTI.FILETYPE_EXT);
            pth = fullfile(this.fslPath, [fp e]);
        end
        function         visualCheck(this, objs)
            files = cell2str(ensureCell(objs));
            try
                r = ''; [~,r] = this.fslview(files); %#ok<NASGU>
            catch ME
                handexcept(ME, r);
            end
        end
        function fqfn  = fqfilename(this, imobj)
            fqfn = imcast(imobj, 'fqfilename');
            ensureFolderExists(this.fslPath);
            if (~lstrfind(fqfn, this.fslPath))
                fqfn = fullfile(this.fslPath, fqfn); end
        end
        function fqfp  = fqfileprefix(this, imobj)
            fqfp = fileprefix(this.fqfilename(imobj));
        end
        function imobj = imageObject(~, varargin)
            len = length(varargin);
            varargin{len} = imcast(varargin{len}, 'fqfilename');
            imobj = mlchoosers.ImagingChoosers.imageObject(varargin{:});
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
                    str = FslBuilder.ostruct2str(obj, exe);
                case 'cell'
                    str = FslBuilder.ocell2str(obj, true, false);
                case 'function_handle'
                    str = func2str(obj);
                otherwise
                    str = FslBuilder.otherwise2str(obj);
            end
        end
        function str   = otherwise2str(obj)
            if (isnumeric(obj))
                str = mat2str(obj);
            elseif (isa(obj, 'mlfourd.INIfTI'))
                str = obj.fqfilename;
            elseif (isobject(obj))
                try
                    str = char(obj);
                catch ME                
                    handexcept(ME);
                end
            else
                error('mfiles:unsupportedType', 'FslBuilder.otherwise2str does not support objects of type %s', class(ob));
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
                    mlfsl.FslBuilder.assertOptionAllowed(fields{f}, exe);
                end
                assert(1 == length(opts))
                str = sprintf(' %s -%s %s', str,  fields{f}, opts.(fields{f}));
            end
        end
        function         assertOptionAllowed(opt, exe)
            warning('mlfsl:notImplemented', 'FslBuilder.assertOptionAllowed');
            assert(isstruct(opt));
            assert(ischar(exe));
            msg = mlfsl.FslBuilder.fslhelp(exe);
            fields = fieldnames(opt);
            for f = 1:length(fields)
                assert(lstrfind(fields{f}), msg);
            end
        end
    end 
       
    methods (Access = 'protected')
        function this = FslBuilder(varargin)
            %  Usage:  obj = FslBuilder(cverter[, ...])
            %                           ^ ConverterInterface
            %                                     ^ See mlfourd.ImageBuilder
            
            this = this@mlfourd.ImageBuilder(varargin{:});
        end % ctor        
    end
        
    properties (Access = 'protected')
        mrReference_
        imagingChoosers_
        standardAtlas_
    end
    
end