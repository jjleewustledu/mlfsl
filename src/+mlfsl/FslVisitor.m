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
        function fn      = fslchfiletype(fn, varargin)
            ip = inputParser;
            addRequired(ip, 'fn', @(x) lexist(x, 'file'));
            addOptional(ip, 'type', 'NIFTI_GZ', @ischar);
            parse(ip, fn, varargin{:});
            
            fprintf('mlfsl.FslVisitor.fslchfiletype is working on %s\n', ip.Results.fn);
            mlpipeline.PipelineVisitor.cmd('fslchfiletype', 'NIFTI_GZ', ip.Results.fn);
            [p,f] = myfileparts(fn);
            fn = fullfile(p, [f mlfourd.NIfTId.FILETYPE_EXT]);
        end
        function dat     = fslhdParameter(fprefix, pname)
            %% FSLHDPARAMETER accepts NIfTI fileprefixes/names; it returns the stringified value of the first match 
            %  of an FSL-header parameter.
            %  Usage:   datum = FslVisitor.fslhdParameter(fileprefix, param-name)
            %                                            ^ or filename
            %           ^                                            ^ all strings
            
            dat = '';
            [~,xmlish] = mlbash(strcat('fslhd -x ', fprefix));
            
            expression = ['\s+' pname '\s+=\s+''(?<value>\S+|\S+\s\S+|[\d\.\+\s\-]+)''$'];
            [~, names] = regexp(xmlish, expression, 'tokens', 'names', 'lineanchors');
            if (~isempty(names))
                   dat = names(:,1).value;
            end
        end
        function [s,r,c] = fslmaths(varargin)
            [s,r,c] = mlfsl.FslVisitor.cmd('fslmaths', varargin{:});
        end       
        function [s,r,c] = fslstats(args, optstrct)
            [s,r,c] = mlfsl.FslVisitor.cmd('fslstats', args, optstrct);
        end 
        function [s,r,c] = fslsusan(inname, hwhh, outname)
            inname  = ensureFilenameExists(inname);
            outname = ensureFilename(outname);
            [s,r,c] = mlfsl.FslVisitor.cmd('susan', inname, num2str([-1 hwhh 3 1 0]), outname);
        end 
        function [s,r,c] = slices(fns, optstrct)
            %% SLICES launches slices with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.slices( 'file1')
            %           [sta, std] = obj.slices({'file1' [, 'file2', options_struct]})
            %                                     ^          ^ string or cell array 
            %                                                        ^ e.g., struct('s', scale, 'i', [num2str(intmin) num2str(intmax)])
            
            import mlfsl.*;
            fns   = fileprefixes(fns);
            if (~exist('optstrct','var'))
                optstrct = struct([]); 
            end
            [s,r,c] = FslVisitor.cmd('slices', optstrct, fns);
        end    
        function [s,r,c] = slicesdir(fns, optstrct)
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
            [s,r,c] = FslVisitor.cmd('slicesdir', optstrct, fns);
        end
        
        function [s,r,c] = view(fns)
            %% VIEW launches fsleyes with NIfTI files named in the filelist
            %  Usage:   [sta, std] = obj.fslview( 'file1')
            %           [sta, std] = obj.fslview({'file1' [, 'file2', options_struct]})
            %                                     ^          ^ string or cell array 
            %                                                        ^ cf. fslview -h
            
            import mlfsl.*;
            fns = fileprefixes(fns);
            fns = ensureCell(  fns);    
            if (~exist('optstrct','var')); optstrct = struct([]); end
            fns{length(fns)+1} = ' &';
            [s,r,c] = FslVisitor.cmd('fsleyes', optstrct, fns);
        end 
        function fqfn    = transformFilename(varargin)
            if (1 == length(varargin))
                fqfn = filename( ...
                       fileprefix( ...
                       imcast(varargin{1}, 'char')), mlfsl.FlirtVisitor.XFM_SUFFIX);
                return
            end
            
            import mlfsl.*;
            nameStruct = mlpipeline.PipelineVisitor.coregNameStruct(varargin{:});
            fqfn       = fullfile(nameStruct.path, ...
                                 [nameStruct.pre FslRegistry.INTERIMAGE_TOKEN nameStruct.post FlirtVisitor.XFM_SUFFIX]);
        end
        function fqfn    = concatTransformFilename(fqfn1, fqfn2)
            fqfn = mlfsl.FslVisitor.transformFilename(fqfn1, fqfn2);
        end
        function fqfn    = inverseTransformFilename(fqfn)
            import mlfsl.*;
            nameStruct = mlpipeline.PipelineVisitor.coregNameStruct(fqfn);
            fqfn       = fullfile(nameStruct.path, ...
                                 [nameStruct.post FslRegistry.INTERIMAGE_TOKEN nameStruct.pre FlirtVisitor.XFM_SUFFIX]);
        end

        % See also:  PipelineVisitor.thisOnThatImageFilename, 
        %            PipelineVisitor.thisOnThatExtFilename 
        
    end
    
    methods
        function this  = FslVisitor(varargin)
            this = this@mlpipeline.PipelineVisitor(varargin{:});
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

