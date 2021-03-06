classdef (Abstract) AlignmentBuilder 
	%% ALIGNMENTBUILDER is the abstraction for alignment, or co-registration.
    %  Its implementaions are organized according to the builder design pattern.   
    %  See also:  mlpatterns.Builder for pattern ideas;
    %             AlignmentBuilderPrototype, mlpet.AlignmentBuilderPrototype, 
    %             PETAlignmentBuilder, MRAlignmentBuilder, MorphingBuilder, 
    %             mlderdeyn.RoisBuilder, PETSegstatsBuilder for legacy builders;
    %             IAlignmentDirector, AlignmentDirector, AlignmentDirectorDecorator, 
    %             PETAlignmentDirector, MRAlignmentDirector, MorphingDirector for legacty directors;
    %             FlirtVisitor, FslVisitor, PipelineVisitor, mlunpacking.UnpackingVisitor 
    %             for auxiliary use of the visitor design pattern;
    %             GluTAlignmentBuilder, GluTAlignmentDirector for 2nd generation examples.
    
	% $Revision: 2644 $ 
 	% $Date: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	% $Author: jjlee $  
 	% $LastChangedDate: 2013-09-21 17:58:45 -0500 (Sat, 21 Sep 2013) $ 
 	% Repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/AlignmentBuilder.m $  
 	% Developed on Matlab 8.1.0.604 (R2013a) 
 	% $Id: AlignmentBuilder.m 2644 2013-09-21 22:58:45Z jjlee $ 
 	 
	properties (Abstract)
        sessionPath
        sourceWeight
        referenceWeight
        sourceImage    % needed by FlirtVisitor
        referenceImage % "
        product        % "
        xfm            
    end 
    
    methods 
        
        %% Empty, to be subclassed by concrete builders
        
        function this = buildAligned(this)
        end
        function this = buildBetted(this)
        end
        function this = buildBiasCorrected(this)
        end
        function this = buildFasted(this)
        end
        function this = buildFieldCorrected(this)
        end
        function this = buildInverseAligned(this)
        end
        function this = buildInverseTransformed(this)
        end
        function this = buildMeanVolume(this)
        end
        function this = buildMeanVolumeByComponent(this)
        end
        function this = buildMotionCorrected(this)
        end
        function this = buildTransformed(this)
        end
        function this = buildWarped(this)
        end
        function obj  = clone(~)
            obj = [];
        end
    end
    
	methods (Access = 'protected')
 		function this = AlignmentBuilder() 
 		end 
 	end 

	% Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

