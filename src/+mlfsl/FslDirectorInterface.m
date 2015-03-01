classdef FslDirectorInterface
	%% FSLDIRECTORINTERFACE is the interface for directing all FSL-related builders that follow the GoF builder pattern
	
	%  $Revision: 2376 $
 	%  was created $Date: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  by $Author: jjlee $, 
 	%  last modified $LastChangedDate: 2013-03-05 07:46:20 -0600 (Tue, 05 Mar 2013) $
 	%  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FslDirectorInterface.m $, 
 	%  developed on Matlab 8.0.0.783 (R2012b)
 	%  $Id: FslDirectorInterface.m 2376 2013-03-05 13:46:20Z jjlee $
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)

	properties (Abstract)
        builder
        products
        logged
 	end

	methods  (Abstract)
        [this,xfms] = coregisterSequence(this, imglist)
        [this,xfm]  = coregister(this, img, ref)
        [this,img]  = applyTransformSequence(this, xfmlist, img)
        [this,img]  = applyTransform(this, xfm, img)
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

