classdef ImageDirectorInterface
	%% IMAGEDIRECTORINTERFACE is the interface for directing all image builders that follow the GoF builder pattern
	
	%  $Revision: 2470 $
 	%  was created $Date: 2013-08-10 21:36:10 -0500 (Sat, 10 Aug 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-08-10 21:36:10 -0500 (Sat, 10 Aug 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/ImageDirectorInterface.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: ImageDirectorInterface.m 2470 2013-08-11 02:36:10Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Abstract)
        adc
        asl
        builder
        diff
        epi
        epiMeanvol
        gre
        ho
        hoMeanvol
        ir
        logged
        oc
        oo
        ooMeanvol
        products
        t1
        t2
 	end

	methods  (Abstract)
        [this,img]  = applyTransform(this, xfm, img)
        [this,img]  = applyTransformSequence(this, xfmlist, img)
        [this,xfm]  = coregister(this, img, ref)
        [this,xfms] = coregisterSequence(this, imglist)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

