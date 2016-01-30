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
        
        % See also:  PipelineVisitor.thisOnThatImageFilename, 
        %            PipelineVisitor.thisOnThatExtFilename 
        
        function [s,r,c] = view(fns)
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
            [s,r,c] = FslVisitor.cmd('fslview', optstrct, fns);
        end 
        function fqfn    = xfmName(varargin)
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
        function fqfn    = xfmConcatName(fqfn1, fqfn2)
            fqfn = mlfsl.FslVisitor.xfmName(fqfn1, fqfn2);
        end
        function fqfn    = xfmInverseName(fqfn)
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

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

