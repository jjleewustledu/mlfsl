classdef MorphingDirector < mlfsl.AlignmentDirectorDecorator
	%% MORPHINGDIRECTOR 

	%  $Revision: 2376 $
 	%  was created $Date: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/MorphingDirector.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: MorphingDirector.m 2376 2013-03-05 13:46:20Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

    properties (Dependent)
        standardImage
        bettedStandard
        fnirtConfig
        warp
        premat
        postmat
    end
    
    methods (Static)
        function md = mdFactory(varargin)
            md = mlfsl.MorphingDirector( ...
                 mlfsl.AlignmentDirector( ...
                 mlfsl.MorphingBuilder(varargin{:})));
        end
        function      morphT1ForStudy(pth)
            if (~exist('pth', 'var')); pth = pwd; end
            cd(pth);
            dt = mlsystem.DirTools('mm0*');
            for t = 1:dt.length
                cd(fullfile(dt.fqdns{t}, 'fsl', ''));
                fprintf('MorphingDirector.morphT1ForStudy is working in %s\n', ...
                         dt.fqdns{t});
                mlbash('cp -f bt1_default.nii.gz bt1_default_backup.nii.gz');
                md = mlfsl.MorphingDirector.mdFactory;
                md.morphT1;
            end
        end
    end
    
    methods %% set/get
        function this = set.standardImage(this, std)
            assert(~isempty(std));
            this.alignmentBuilder.standardImage = std;
        end
        function std  = get.standardImage(this)
            std = this.alignmentBuilder.standardImage;
        end
        function this = set.bettedStandard(this, bstd)
            assert(~isempty(bstd));
            this.alignmentBuilder.bettedStandard = bstd;
        end
        function bstd = get.bettedStandard(this)
            bstd = this.alignmentBuilder.bettedStandard;
        end
        function this = set.fnirtConfig(this, cfg)
            assert(ischar(cfg));
            import mlfsl.*;
            if (~strcmp(cfg(length(cfg)-3:end), FnirtVisitor.WARPCONFIG_EXT))
                cfg = [cfg FnirtVisitor.WARPCONFIG_EXT]; end
            this.fnirtConfig_ = cfg;
        end
        function cfg  = get.fnirtConfig(this)
            assert(lexist(this.fnirtConfig_, 'file'));
            cfg = this.fnirtConfig_;
        end
        function this = set.warp(this, w)
            this.alignmentBuilder.warp = w;
        end
        function w    = get.warp(this)
            w = this.alignmentBuilder.warp;
        end
        function this = set.premat(this, x)
            this.alignmentBuilder.premat = x;
        end
        function x    = get.premat(this)
            x = this.alignmentBuilder.premat;
        end
        function this = set.postmat(this, x)
            this.alignmentBuilder.postmat = x;
        end
        function x    = get.postmat(this)
            x = this.alignmentBuilder.postmat;
        end
    end
    
	methods
        function [prd, this] = morphT1(this, varargin)
            p = inputParser;
            addOptional(p, 'T1Image', 't1_default.nii.gz', @(x) lexist(x, 'file'));
            parse(p, varargin{:});
            prd = this.morphSingle2bettedStandard(p.Results.T1Image);
        end
        function [prd, this] = morphT2star2bettedStructural(this, t2s, t2, structural)
            alignBldr = mlmr.MRAlignmentBuilder('product', t2, 'referenceImage', structural);
            alignBldr = alignBldr.buildFlirted;
            t2_on_structural = alignBldr.product;
            bstructural = this.ensureBetted(structural);
            bt2_on_structural = t2_on_structural .* bstructural;
            morphBldr = MorphingBuilder('product', t2s, 'referenceImage', bt2_on_structural, 'premat', alignBldr.xfm);
            
        end
        function ic = ensureBetted(this, ic)
        end
        function [prd, this] = morphT2star2standard(this, t2s, t1)
            betBldr         = this.alignmentBuilder.clone;
            betBldr.product = t1;
            betBldr         = betBldr.buildBetted;
            bt1             = betBldr.product;
            
            t1Bldr                = this.alignmentBuilder.clone;
            t1Bldr.product        = bt1;
            t1Bldr.referenceImage = this.bettedStandard;
            t1Bldr                = t1Bldr.buildFlirted;
            
            t2sBldr                = this.alignmentBuilder.clone;
            t2sBldr.product        = t2s;
            t2sBldr.referenceImage = bt1;
            t2sBldr                = t2sBldr.buildFlirted;
            
            this.product           = t1;
            this.referenceImage    = this.standardImage;
            this.xfm               = t1Bldr.xfm;
            this.premat            = t2sBldr.xfm;
            this.alignmentBuilder = this.alignmentBuilder.buildFnirted;
            prd                    = this.product;
        end
        function [prd, this] = morphSingle2standard(this, img)
            this.product           = img;
            this.referenceImage    = this.standardImage;
            this.alignmentBuilder = this.alignmentBuilder.buildFnirted2standard;
            prd                    = this.product;
        end
        function [prd, this] = morphSingle2bettedStandard(this, img)
            this.product          = img;
            this.referenceImage   = this.bettedStandard;
            this.alignmentBuilder = this.alignmentBuilder.buildFnirted2bettedStandard;
            prd                   = this.product;
        end
        function [prd, this] = morphBetted2betted(this, img, img2)
            this.product          = imcast(img,  'mlfourd.ImagingContext');
            this.referenceImage   = imcast(img2, 'mlfourd.ImagingContext');
            this.alignmentBuilder = this.alignmentBuilder.buildBetted2Betted;
            prd                   = this.product;
        end
        function [prd, this] = invmorph2bt1default(this, img)
            this.product          = img;
            this.referenceImage   = this.bettedStandard;
            this.alignmentBuilder = this.alignmentBuilder.buildInvwarp;
            prd                   = this.product;
        end
        function [prd, this] = morphPair(this, varargin)
            p = inputParser;
            addOptional(p, 'img', this.product,        @(x) isa(x, 'mlfourd.ImagingContext'));
            addOptional(p, 'ref', this.referenceImage, @(x) isa(x, 'mlfourd.ImagingContext'));
            parse(p, varargin{:});
            this.product           = p.Results.img;
            this.referenceImage    = p.Results.ref;
            this.alignmentBuilder = this.alignmentBuilder.buildFnirted;
            prd                    = this.product;
        end        
        function [prd, this] = align2fsaverage1mm(this, img)
            this.product = imcast(img, 'mlfourd.ImagingContext');
            vtor = mlfsl.FlirtVisitor;
            this = vtor.visitAlign2fsaverage1mm(this);
            prd  = this.product;
        end
        function [prd,msk,this] = morph2fsaverage1mm(this, img, msk) 
            [img,this] = this.morphSingle2bettedStandard(img);
            [prd,this] = this.align2fsaverage1mm(img);
            
            this.product = msk;
            this.alignmentBuilder = this.alignmentBuilder.buildApplywarp;
            [msk,this] = this.align2fsaverage1mm(this.product);
        end
        
 		function this = MorphingDirector(varargin) 
 			%% MORPHINGDIRECTOR 
 			%  Usage:  obj = MorphingDirector(builder) 

            this = this@mlfsl.AlignmentDirectorDecorator(varargin{:});
            assert(isa(this.alignmentBuilder, 'mlfsl.MorphingBuilder'));
 		end %  ctor 
    end 
    
    %% PRIVATE
    
    properties (Access = 'private')
        alignmentDirector_
        betDirector_     
        fnirtConfig_
    end
    methods (Access = 'private')        
        function [this,morphedobj] = applyMorph(this, nlxfm, imobj, stnd, varargin)
            if (nargin < 4)
                stnd = this.standardImage; end
            [this.alignmentBuilder, morphedobj] = this.alignmentBuilder.applyMorph(imobj, stnd, nlxfm, varargin{:});
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

