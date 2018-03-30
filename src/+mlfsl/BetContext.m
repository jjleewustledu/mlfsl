classdef BetContext < mlfsl.FslContext
    %% BETSTRATEGY dispatches properties and methods to a chosen BetStrategy concrete class;
    %  changes may be made at run-time and thus the class must be handle.
    
    %  $Revision: 2571 $
    %  was created $Date: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
    %  by $Author: jjlee $,
    %  last modified $LastChangedDate: 2013-08-23 07:16:08 -0500 (Fri, 23 Aug 2013) $
    %  and checked into repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/BetContext.m $,
    %  developed on Matlab 8.0.0.783 (R2012b)
    %  $Id: BetContext.m 2571 2013-08-23 12:16:08Z jjlee $
    
    methods
       function thish = BetContext(varargin)
           %% BetContext is a strategy pattern for selcting flirt processing variationsw
           %  Usage:   obj = BetContext(strategy_label, image_builder)

           thish = thish@mlfsl.FslContext(varargin{:});
       end       
       function setStrategy(thish, choice)
           %% SETSTRATEGY permits run-time changes of bet strategies
           %  Usage:   obj = betStrategy.setStrategy(new_strategy);
           %                                         ^ string or FlirtStrategy concrete class

           if (isa(choice, 'mlfsl.BetStrategy'))
               thish.theStrategy_ = choice; return; end
           assert(ischar(choice));
           thish.theStrategy_ = mlfsl.BetStrategy.newStrategy(choice, thish.builder); % builder from last theStrategy_
       end       
       function [st,im] = bet(this, im)
           [this.theStrategy_,im] = this.theStrategy.bet(im);
           st = this.theStrategy;
       end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

