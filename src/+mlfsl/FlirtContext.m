classdef FlirtContext < mlfsl.FslContext
    %% FLIRTCONTEXT provides the context of a strategy design pattern with FlirtStrategy,
    %  dispatching properties & methods to concrete classes that subclass FlirtStrategy.
    %  FlirtContext must be handle so as to allow run-time changes of concrete strategies.

    %  $Revision: 2571 $
    %  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
    %  by $Author: jjlee $,
    %  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
    %  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/FlirtContext.m $,
    %  developed on Matlab 8.0.0.783 (R2012b)
    %  $Id: FlirtContext.m 2571 2013-08-23 12:16:08Z jjlee $
    
   methods
       function thish = FlirtContext(varargin)
           %% FlirtContext is a strategy pattern for selcting flirt processing variationsw
           %  Usage:   obj = FlirtContext(flirt_builder, strategy_choice)
           
           thish = thish@mlfsl.FslContext(varargin{:});
       end       
       function setStrategy(thish, strat)
           %% SETSTRATEGY permits run-time changes of flirt strategies
           %  Usage:   obj = FlirtContext.setStrategy(new_strategy);
           %                                           ^ string or FlirtStrategy concrete class
           
           if (isa(strat, 'mlfsl.FlirtStrategy'))
               thish.theStrategy_ = strat; return; end
           assert(ischar(strat));
           thish.theStrategy_ = mlfsl.FlirtStrategy.newStrategy(strat, thish.builder_);
           fprintf('FlirtContext:  choosing %s\n', strat);
       end       
       function [this,xfm] = coregister(this, im, ref)
           [this.theStrategy_,xfm] = this.theStrategy.coregister(im, ref);
       end
       function imcmp = preprocess(this, imcmp)
           imcmp = this.theStrategy.preprocess(imcmp);
       end
   end

end 
