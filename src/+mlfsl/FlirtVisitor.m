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
    
	methods         
        function [bldr,xfm] = align6DOF(this, bldr)
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
            [bldr,xfm]   = this.inverseTransformBuilder(bldr);            
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.dof     = 6;
            opts.init    = xfm;
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
            bldr.product = this.transform__(opts);
        end
        
        function [bldr,xfm] = concatTransformsOfBuilder(this, bldr, xfms)
            assert(iscell(xfms));
            opts = mlfsl.ConvertXfmOptions;
            for x = 1:length(xfms)-1                
                opts.concat = sprintf('%s %s', xfms{x+1}, xfms{x});
                opts.omat   = this.xfmConcatName(xfms{x}, xfms{x+1});
                xfms{x+1}   = this.concatTransforms__(opts);
            end            
            xfm      = xfms{end};
            bldr.xfm = xfm;
        end
        function [bldr,xfm] = inverseTransformBuilder(this, bldr)
            opts         = mlfsl.ConvertXfmOptions;
            opts.inverse = bldr.xfm;
            opts.omat    = this.xfmInverseName(bldr.xfm);
            bldr.xfm     = this.inverseTransform__(opts);
            xfm          = bldr.xfm;
        end    
        function bldr       = transformBuilder(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            bldr.product = this.transform__(opts);
        end
        function bldr       = transformNearestNeighbor(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.interp  = 'nearestneighbour';
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            bldr.product = this.transform__(opts);
        end
        function bldr       = transformForGluT(this, bldr)
            opts         = mlfsl.FlirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.ref     = this.assignRef(bldr);
            opts.init    = bldr.xfm;
            bldr.product = this.transform__(opts);
        end    
        function bldr       = motionCorrect(this, bldr)
            opts         = mlfsl.McflirtOptions;
            opts.in      = this.assignIn(bldr);
            opts.dof     = 6;
            bldr.product = this.mcflirt__(opts);
        end
        
        function this = FlirtVisitor(varargin)
            this = this@mlfsl.FslVisitor(varargin{:});
        end
    end 
    
    %% PROTECTED
    
    methods (Access = 'protected')
        function omat = flirt__(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            this.cmd('flirt', opts);
            omat = opts.omat;
        end
        function prod = mcflirt__(this, opts)
            assert(isa(opts, 'mlfsl.McflirtOptions'));
            [~,~,c] = this.cmd('mcflirt', opts);
            prod = mlfourd.ImagingContext.load([opts.in this.MCF_SUFFIX this.filetypeExt]);
            prod.addLog(c);
        end
        function prod = applyxfm4D__(~, opts)
            assert(isstruct(opts));
            [~,c] = mlbash(sprintf('applyxfm4D %s %s %s %s -fourdigit', ...
                opts.input, opts.ref, opts.output, opts.transformation));
            prod = mlfourd.ImagingContext.load(opts.output);
            prod.addLog(c);            
        end
        function prod = transform__(this, opts)
            assert(isa(opts, 'mlfsl.FlirtOptions'));
            opts.applyxfm = true;
            opts.omat = [];
            [~,~,c] = this.cmd('flirt', opts); 
            prod = mlfourd.ImagingContext.load( ...
                mlpipeline.PipelineVisitor.thisOnThatImageFilename(opts.in, opts.init));
            prod.addLog(c);
        end
        function xfm  = concatTransforms__(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.concat));
            assert(~isempty(opts.omat));
            this.cmd('convert_xfm', opts); 
            xfm = opts.omat;
        end
        function xfm  = inverseTransform__(this, opts)
            assert(isa(opts, 'mlfsl.ConvertXfmOptions'));
            assert(~isempty(opts.inverse));
            assert(~isempty(opts.omat));
            this.cmd('convert_xfm', opts);
            xfm = opts.omat;
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
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

