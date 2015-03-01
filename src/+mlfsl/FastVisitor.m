classdef FastVisitor < mlfsl.FslVisitor 
	%% FASTVISITOR   

	%  $Revision: 2629 $ 
 	%  was created $Date: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-16 01:19:00 -0500 (Mon, 16 Sep 2013) $ 
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FastVisitor.m $,  
 	%  developed on Matlab 8.1.0.604 (R2013a) 
 	%  $Id: FastVisitor.m 2629 2013-09-16 06:19:00Z jjlee $ 

	methods
 		function bldr = visitMRAlignmentBuilder_t1channel(this, bldr) 
            opts         = mlfsl.FastOptions;
                           this.fast(opts, bldr.product.fqfileprefix);
            bldr.product = imcast([bldr.product.fqfileprefix '_restore.nii.gz'], 'mlfourd.ImagingContext');
 		end 
 		function this = FastVisitor(varargin) 
 			%% FASTVISITOR 
 			%  Usage:  this = FastVisitor() 

 			this = this@mlfsl.FslVisitor(varargin{:}); 
 		end 
 	end 

    methods (Access = 'protected')
        function this = fast(this, opts, infiles)
            assert(isa(opts, 'mlfsl.FastOptions'));
            if (iscell(infiles))
                infiles = this.cell2strf(infiles); end
            [~,log] = mlfsl.FslVisitor.fslcmd('fast', opts, infiles);
                      this.logged.add(log);  
        end
        function str = cell2strf(~, cll)
           str = '';
           for c = 1:length(cll)
               assert(ischar(cll{c}));
               str = [str ' ' cll{c}]; %#ok<AGROW>
           end
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

