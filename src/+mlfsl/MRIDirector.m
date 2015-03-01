classdef MRIDirector < mlfsl.FslDirector
	%% MRIDIRECTOR is the client wrapper for building MRI imaging analyses; 
    %              takes part in builder design patterns
	
	%  Version $Revision: 2610 $ was created $Date: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-07 19:15:00 -0500 (Sat, 07 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/MRIDirector.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: MRIDirector.m 2610 2013-09-08 00:15:00Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 
    
    properties (Dependent)
        allMr
        mrReference
    end
    
    methods (Static)
        function this = doAll(mpth)
            this = mlfourd.FslDirector.createFromModalityPath(mpth);
            for m = 1:length(this.allMr)
                this = this.coregisterMr2T1(this.allMr.get(m));
            end
        end
        function this = createFromModalityPath(pth)
            import mlfsl.*;
            assert(lexist(pth, 'dir'));
            this = MRIDirector.createFromBuilder( ...
                   MRIBuilder.createFromModalityPath(pth));
        end   
        function this = createFromBuilder(bldr)
            assert(isa(bldr, 'mlfsl.MRIBuilder'));
            this = mlfsl.MRIDirector(bldr);
        end        
        function cntr = mrContrasts(mr, mr0)
            cntr = sprintf('%s_on_%s', clusterName(mr), clusterName(mr0));
            
            function clst = clusterName(obj)
                [~,obj] = filepartsx(fileprefix(obj), mlfourd.NIfTIInterface.FILETYPE_EXT);
                if     (lstrfind(obj, 'ir')); clst = 'ir'; 
                elseif (lstrfind(obj, {'t1' 'gre' 'fieldmap' 'pd'})); clst = 't1';
                elseif (lstrfind(obj, {'tof' 't2' 'dwi' 'swi'})); clst = 't2'; 
                elseif (lstrfind(obj, {'ep2d' 'asl'})); clst = 'ep2d'; 
                else
                    clst = 'unknown';
                end
            end
        end
    end
    
    methods % set/get
        function cal  = get.allMr(this)
            assert(isa(this.builder.allMr, 'mlpatterns.ValueList'));
            cal = this.builder.allMr;
        end
        function ref  = get.mrReference(this)
            ref = this.builder_.mrReference;
        end
    end
    
    methods        
        function [this,xfm] = coregisterMr2Reference(this, mr)
            [this,xfm] = this.coregisterMr2Mr(mr, this.mrReference);
        end     
        function [this,xfm] = coregisterMr2T1(this, mr)
            try
                [this,xfm] = this.coregisterMr2Mr(mr, this.t1);
            catch ME
                handwarning(ME)
                [this,xfm] = this.coregisterMr2T2(mr, this.t2);
            end
        end        
        function [this,xfm] = coregisterMr2T2(this, mr)
            try
                [this,xfm] = this.coregisterMr2Mr(mr, this.t2);
            catch ME
                handwarning(ME)
                [this,xfm] = this.coregisterMr2Ir(mr, this.ir);
            end
        end
        function [this,xfm] = coregisterMr2Ir(this, mr)
            try
                [this,xfm] = this.coregisterMr2Mr(mr, this.ir);
            catch ME
                handerror(ME)
            end
        end
        function [this,xfm] = coregisterMr2Mr(this, mr, mr0)
            %% COREGISTERMR2MR 
            %  Usage:  [this, xfm] = this.coregisterMr2Mr(mri, target_mri)
            %                                                  ^ this.mrReference is default
            
            p = inputParser;
            addRequired(p, 'mr', @(x) ~isempty(x));
            addOptional(p, 'mr0', this.mrReference, @(x) ~isempty(x));
            parse(p, mr, mr0);
            [this,xfm] = this.coregister(mr, mr0);
            this.products_.add(transform2filename(xfm));
        end
        function [this,xfms] = coregisterSequence2Mr(this, mrlist, mr0)
            %% COREGISTERSEQUENCE2MR
            %  Usage:  [this, xfms] = this.coregisterSequence2Mr([reference])
            %                 ^ cell-array list                   ^ this.mrReference is default
            
            p = inputParser;
            addRequired(p, 'mrlist', @(x) isa(x, 'mlpatterns.ValueList') && ~isempty(x))
            addOptional(p, 'mr0', this.mrReference, @(x) ~isempty(x));
            parse(p, mrlist, mr0);
            allmr = mlfourd.ImagingArrayList(p.Results.mrlist);
            allmr.add(mr0);            
            [this, xfms] = this.coregisterSequence(allmr);
            for x = 1:length(xfms)
                this.products_.add(transform2filename(xfms.get(x)));
            end
        end
        function [this, mat, warp] = morphMr2Atlas(this, mr, atl) %#ok<INUSD>
            mat = []; %#ok<NASGU>
            warp = []; %#ok<NASGU>
            error('mlfsl:NotImplemented', 'FslDirector.morphMr2Atlas');
        end
        function [this,imat,iwarp] = morphAtlas2Mr(this, atl, mr)
            p = inputParser;
            addRequired(p, 'atl', @(x) lexist(filename(x), 'file'));
            addRequired(p, 'mr',  @(x) lexist(filename(x), 'file'));
            parse(p, atl, mr);
            mat  = this.transformationFilename(mr, atl);
            warp = this.warpFilename(mr, atl);
            if (~lexist(mat) && ~lexist(warp))
                [this, mat, warp] = this.morphMr2Atlas(mr, atl);
            end
            imat  = this.inverseXfm(mat);
            iwarp = this.inverseWarp(warp);
            this.products_.add(this.warpedFilename(atl,mr));
        end
    end
    
    %% PROTECTED
    
    methods (Access = 'protected')
 		function this = MRIDirector(bldr) 
 			%% MRIDIRECTOR 
 			%  Usage:  prefer creation methods
            
            assert(isa(bldr, 'mlfsl.MRIBuilder'));
			this = this@mlfsl.FslDirector(bldr);
 		end 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

