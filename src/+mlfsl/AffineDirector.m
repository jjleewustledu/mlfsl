classdef AffineDirector < mlfsl.FslDirector
	%% AFFINEDIRECTOR takes part in a builder design pattern for affine registration.
    %  Data representation should be reserved for FslBuilder & concrete subclasses.
    %
	%  $Revision: 2610 $
 	%  was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AffineDirector.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: AffineDirector.m 2610 2013-09-08 00:15:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Dependent)
        lastOmat
    end

    methods (Static)
        function this = createFromModalityPath(pth)
            import mlfsl.*;
            assert(lexist(pth, 'dir'));
            this = AffineDirector.createFromBuilder( ...
                   FlirtBuilder.createFromModalityPath(pth));
        end
        function this = createFromConverter(cvrtr)
            import mlfsl.*;
            this = AffineDirector.createFromBuilder( ...
                FlirtBuilder.createFromConverter(cvrtr));
        end
        function this = createFromBuilder(bldr)
            assert(isa(bldr, 'mlfsl.FslBuilder'), '%s is not supported', class(bldr));
            this = mlfsl.AffineDirector(bldr);
        end
    end
    
	methods % get/set, delegated to this.builder
        function omat = get.lastOmat(this)
            omat = this.builder_.lastProduct.omat;
        end
    end
    
	methods
        function [this,xfms,out] = coregisterSequence(this, varargin)
            %% coregisterSequence coregisters img = img1 (on) img2 (on) img3 (on) ... 
            
            import mlfourd.*;
            imlist = ImagingArrayList.ensureImagingArrayList(varargin);
            xfms   = ImagingArrayList;
            for s = 1:length(imlist)-1
                [this, x] = this.coregister(imlist.get(s), imlist.get(s+1));
                xfms.add(x);
            end
            [this,out] = this.applyTransformationSequence(ImagingArrayList(xfms), imlist.get(1));
        end
        function [this,xfm,out] = coregister(this, img, ref)
            try
                [this.builder_,xfm] = this.builder_.coregister(img, ref);
                [this.builder_,out] = this.applyTransform(xfm, img);
            catch ME
                handwarning(ME);
                try
                    [this.builder_,invXfm] = this.builder_.coregister(ref, img);
                    [this.builder_,out] = this.applyInverseOfTransform(invXfm, img);
                catch ME2
                    handerror(ME2);
                end
            end
        end
        function [this,img] = applyTransform(this, xfm, img)
            [this.builder_,img] = this.builder_.applyTransform(xfm,img);
        end        
        function [this,img] = applyInverseOfTransform(this, xfm, img)
            [this.builder_,invXfm] = this.builder_.invertTransform(xfm);
            [this,img] = this.applyTransform(invXfm, img);
        end
        function [this,img] = applyTransformSequence(this, xfmlist, img)
            %% applyTransformSequence applies:   img = xfm1.xfm2.xfm3 ... img for xfmlist = {xmf1 xfm2 xfm3 ...}
            
            xfmlist = mlfourd.ImagingArrayList.ensureImagingArrayList(xfmlist);
            for s = length(xfmlist):-1:1
                [this,img] = this.applyTransform(xfmlist.get(s), img);
            end
        end
    end
    
    methods (Access = 'protected')
 		function this = AffineDirector(varargin) 
 			%% AFFINEDIRECTOR 
 			%  Usage:  obj = AffineDirector() 

 			this = this@mlfsl.FslDirector(varargin{:}); 
 		end %  ctor 
    end 



    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

