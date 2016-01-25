classdef FlirtGauss < mlfsl.FlirtStrategy 
	%% FLIRTGAUSS 
    %
	%  Version $Revision: 2610 $ was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtGauss.m $ 
 	%  Developed on Matlab 7.14.0.739 (R2012a) 
 	%  $Id: FlirtGauss.m 2610 2013-09-08 00:15:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    properties (Dependent)
        averagingStrategy
        blur
    end
    
    methods %% set/get
        function as   = get.averagingStrategy(this)
            assert(isa(this.averagingStrategy_, 'mlaveraging.AveragingContext'));
            as = this.averagingStrategy_;
        end
        function this = set.blur(this, bl)
            assert(isnumeric(bl));
            this.averagingStrategy.blur = bl;
        end
        function bl   = get.blur(this)
            bl = this.averagingStrategy.blur;
        end
    end
    
	methods   
 		function this        = FlirtGauss(varargin)
            this = this@mlfsl.FlirtStrategy(varargin{:});
            this.averagingStrategy_ = mlaveraging.AveragingContext(this, 'gauss');
 		end % ctor 
        function im          = preprocess(this, im)
            im = this.averagingStrategy.average( ...
                 imcast(im, 'mlfourd.NIfTI'));
            im.save;
            im = imcast(im, 'fqfilename');
        end
        function cst         = costfun(this, out, ref)
            p = inputParser;
            addOptional(p, 'out', this.imOut, @(x) isa(x, 'mlfourd.INIfTI'));
            addOptional(p, 'ref', this.imRef, @(x) isa(x, 'mlfourd.INIfTI'));
            parse(p, out, ref);
            theKL = mlentropy.KL(p.Results.out, p.Results.ref);
            cst = theKL.kldivergence;
        end    
        function [this,omat] = coregister(this, in, ref)
            import mlfourd.*;
            opts     = mlfsl.FlirtOptions;
            opts.in  = this.preprocess(in);
            opts.ref = this.preprocess(ref);
            opts.dof = 6;
            [this,omat] = this.coregisterByOptions(opts);
        end  
    end
    properties %(Access = 'protected')
        averagingStrategy_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

