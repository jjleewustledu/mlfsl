classdef Product
	%% PRODUCTS provides data objects for processed images
	%  $Revision: 2629 $
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/Product.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: Product.m 2629 2013-09-16 06:19:00Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Dependent)
        opts
        omat
        out
        logger
    end

    methods (Static)
        function this = createProductWithOptions(opts)
            assert(isstruct(opts) || isa(opts, 'mlfsl.FslOptions'))
            this = mlfsl.Product;
            this.opts = opts;
        end
    end
    
    methods %% set/get
        function this = set.opts(this, opts)
            assert(~isempty(opts));
            this.opts_ = opts;
        end
        function opts = get.opts(this)
            opts = this.opts_;
        end
        function lggr = get.logger(this)
            lggr = this.logger_.clone;
        end
        function mat  = get.omat(this)
            assert(~isempty(this.opts), 'mlfsl.Product.get.omat:  opts is empty');
            if (isfield(this.opts, 'omat'))
                mat = this.opts.omat; return; end
            mat = mlfsl.FslVisitor.transformFilename( ...
                fileprefix(this.opts.in), fileprefix(this.opts.ref));
        end
        function fn   = get.out(this)
            assert(~isempty(this.opts), 'mlfsl.Product.get.out:  opts is empty');
            if (isfield(this.opts, 'out'))
                fn = this.opts.out; return; end
            fn = mlchoosers.ImagingChoosers.imageObject( ...
                fileprefix(this.opts.in), fileprefix(this.opts.ref));
        end
    end

    methods
        function this = addlog(this, lg)
            assert(~isempty(lg));
            if (isempty(this.logger_))
                this.logger_ = mlfourd.ImagingArrayList; end
            this.logger_.add(lg);
        end
        function this = Product(inobj)
            %% PRODUCT ctor; argument may be logging object (char, cell, cal)
            %  or opts object in struct format
            
            if (exist('inobj','var'))
                switch (class(inobj))
                    case 'char'
                        this = this.addlog(inobj);
                    case 'cell'
                        this = this.addlog(inobj);
                    case 'mlfourd.ImagingArrayList'
                        this.logger_ = inobj;
                    case 'struct' 
                        this.logger_ = mlfourd.ImagingArrayList;
                        this.opts = inobj;
                    otherwise
                        error('mlfsl:unsupportedType', 'Product.ctor.lggr->%s', class(inobj));
                end
                return
            end
            this.logger_ = mlfourd.ImagingArrayList;
        end
    end

    properties (Access = 'private')
        opts_
        namingInterface_
        logger_
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

