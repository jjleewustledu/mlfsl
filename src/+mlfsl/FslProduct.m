classdef FslProduct < mlfsl.Product
	%% FSLPRODUCT provides data objects for processed images
	%  $Revision: 2376 $
 	%  was created $Date: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslProduct.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslProduct.m 2376 2013-03-05 13:46:20Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Dependent)
        in
        ref
        omat
        invmat
        out
        warp
        invwarp
    end

    methods %% set/get
        function this = set.in(this, in)
            this.opts_.in = in;
        end
        function in = get.in(this)
            in = this.opts_.in;
        end
        function this = set.ref(this, ref)
            this.opts_.ref = ref;
        end
        function ref = get.ref(this)
            ref = this.opts_.ref;
        end
        function this = set.omat(this, omat)
            this.opts_.omat = omat;
        end
        function omat = get.omat(this)
            omat = this.opts_.omat;
        end
        function out = get.out(this)
            out = this.opts_.out;
        end
        function this = set.out(this, out)
            this.opts_.out = out;
        end
        function this = set.warp(this, warp)
            this.warp_ = warp;
        end
        function warp = get.warp(this)
            warp = this.opts_.warp;
        end
        function invmat = get.invmat(this)
            assert(~isempty(this.omat));
            error('mlfsl.notImplemented');
        end
        function invwarp = get.invwarp(this)
            assert(~isempty(this.warp));
            error('mlfsl.notImplemented');
        end
    end

    methods
        function this = FslProduct(varargin)
            this = this@mlfsl.Product(varargin{:});
        end
    end
    
    properties (Access = 'private')
        omat_
        out_
        warp_
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

