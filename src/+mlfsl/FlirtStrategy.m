classdef FlirtStrategy < mlfsl.FlirtBuilder
    %% FLIRTTYPE
    %  This class must be inherited. The child class must deliver the
    %  FlirtStrategy method that accepts the concrete Flirt class
    %  TODO:  hide FlirtBuilder & delegate

	%  $Revision: 2571 $
 	%  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtStrategy.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FlirtStrategy.m 2571 2013-08-23 12:16:08Z jjlee $

    methods (Abstract)
        preprocess(imagingComponent)
        costfun(imout, imref)
    end
    
    methods (Static)
        function concrete = newStrategy(preprocess, bldr)
            %% NEWTYPE
            %  Usage:   concrete_flirtbuilder = FlirtStrategy.newStrategy(choice, builder)
            %                                                     ^ string
            %                                                             ^ any FlirtBuilder
            
            import mlfsl.*;
            assert(ischar(preprocess));
            assert(isa(bldr, 'mlfsl.FlirtBuilder'));
            switch lower(preprocess)
                % If you want to add more strategies, simply put them in
                % here and then create another class file that inherits
                % this class and implements the preprocessing method
                case {'none' 'nopreprocess' 'default'}
                    concrete = FlirtNoPreprocess(bldr.converter);
                case {'gauss' 'gaussian' 'blur' 'blurring'}
                    concrete = FlirtGauss(bldr.converter);
                case {'blindd' 'blinddeconv' 'blinddeconvolution'}
                    concrete = FlirtBlindDeconv(bldr.converter);
                case  'susan'
                    concrete = FlirtSusan(bldr.converter);
                otherwise
                    error('mlfourd:UnsupportedValue', 'newStrategy.value->%s', preprocess);
            end
        end
    end
    
    methods 
        function [this,omat] = coregister(this, in, ref)
            import mlfourd.*;
            opts     = mlfsl.FlirtOptions;
            opts.in  = this.preprocess(in);
            opts.ref = this.preprocess(ref);
            [this,omat] = this.coregisterByOptions(opts);
        end  
    end
    
    methods (Access = 'protected')
        function this = FlirtStrategy(varargin)
            this = this@mlfsl.FlirtBuilder(varargin{:});
        end
    end

end 

%EOF