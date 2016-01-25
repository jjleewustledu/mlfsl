classdef FileAdapter 
	%% FILEADAPTER is a polymorphic adapter pattern for accessing files on the filesystem, especially NIfTI files 
	%  Version $Revision$ was created $Date$ by $Author$  
 	%  and checked into svn repository $URL$ 
 	%  Developed on Matlab 7.11.0.584 (R2010b) 
 	%  $Id$ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        itsPath = '';
        fq = false;
        ext = mlfourd.INIfTI.FILETYPE_EXT;
        checkExist = true;
    end
    
    properties (SetAccess='protected')
        filestrings
    end

	methods 

 		function this = FileAdapter(fobj) 
            
 			%% FILEADAPTER (ctor) 
 			%  Usage:  adaptobj = FileAdapter(fileobj)
            %                                 ^ char, NIfTI
            %          fname(1) = adaptobj.filename;
            %          fname(2) = adaptobj.filename(2);
            %          for f = 1:length(adaptobj)
            %              fprefix(f) = adaptobj.fileprefix(f); 
            %          end
			import mlfourd.*;
            assert(~isempty(fobj));
            if (~iscell(fobj)); fobj = {fobj}; end
            this.filestrings = cell(size(fobj));
            f = 1; lastf = length(fobj);
            while (f <= lastf)
                switch (class(fobj{f}))
                    case 'char'
                        if (lstrfind(fobj{f},'*') || lstrfind(fobj{f},'?'))
                            dc = dir2cell(fobj{f});
                            if (f < lastf)
                                fobj = [fobj{1:f-1} dc fobj{f+1:lastf}];
                            else
                                fobj = [fobj{1:f-1} dc];
                            end
                        end
                        this.filestrings{f} = fobj{f};
                    case NIfTI.NIFTI_SUBCLASS
                        this.filestrings{f} = fobj{f}.fileprefix;
                    otherwise
                        error('mlfsl:UnsupportedTypeErr', ...
                              'Unsupported class(FileAdapter.ctor.fobj{%i})->%s', f, class(fobj));
                end % switch
                f = f + 1; lastf = length(fobj);
            end % while
 		end % FileAdapter (ctor)
        
        function ip = get.itsPath(this)
            if (isempty(this.itsPath))
                ip = pwd;
            else
                ip = this.itsPath;
            end
        end 
        
        function fp = fileprefix(this, idx)
            
            %% fileprefix overloads fileprefix
            if (~exist('idx','var')); idx = 1; end
            if ( isempty(this.filestrings) || idx > this.length)
                throw(MException('mlfsl:IndexOutOfBounds', ...
                                 'FileAdapter.fileprefix:  idx->%i but length->%i', idx, this.length));
            end
            fp = fileprefix(this.filestrings{idx});
            if (this.fq)
                fp = fullfile(this.itsPath, fp);
            end
        end % fileprefix
        
        function fps = fileprefixes(this)
            fps = cell(size(this.filestrings));
            for f = 1:length(fps)
                fps{f} = fileprefix(this.filestrings{f});
            end
        end
        
        function fns = filenames(this)
            fns = cell(size(this.filestrings));
            for f = 1:length(fns)
                fns{f} = filename(this.filestrings{f});
            end
        end
        
        function fn = filename(this, idx, ext)
            
            %% filename overloads filename
            if (~exist('idx','var')); idx = 1; end
            if (~exist('ext','var')); ext = this.ext; end
            fn = filename(this.fileprefix(idx), ext);
            if (this.checkExist && 0 == exist(fn,'file'));
                throw(MException('mlfsl:FileNotFound', ...
                                 'FileAdapter.filename->%s not found in %s', fn, pwd));
            end
        end % filename
        
        function ln = fileprefixes1line(this)
            ln = '';
            for f = 1:length(this)
                ln = horzcat(ln, ' ', this.fileprefix(f)); %#ok<AGROW>
            end
        end % fileprefixes1line
        
        function ln = filenames1line(this, ext)
            if (~exist('ext','var')); ext = this.ext; end
            ln = '';
            for f = 1:length(this)
                try
                    ln = horzcat(ln, ' ', this.filename(f,ext)); %#ok<AGROW>
                catch ME
                    fprintf('FileAdapter.filenames1line:  ignoring %s\n', ME.message);
                end
            end
        end % filenames1line
        
        function ln = length(this)
            ln = length(this.filestrings);
        end
        
        function n = numel(this)
            n = numel(this.filestrings);
        end
        
        function sz = size(this)
            sz = size(this.filestrings);
        end
 	end 

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
 	end 
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
