classdef Np797Registry < mlfsl.FslRegistry    
    %% NP797REGISTRY is a wrapper for simple database queries;
    %  is an mlfsl.FslRegistry; is an mlpatterns.Singelton
    %
    %  Instantiation:  instance = mlfsl.Np797Registry.instance;
    %                  info     = instance.getter_info(param0, param1, ...)
    %                  info     = instance.macro(macro_name)
    %                  sqlout   = instance.sql(cmd)
    %
    %                  instance:     singleton instance
    %                  info:         data object
    %                  getter_info:  convenience getter
    %                  macro:        convenience macro
    %
    %  Singleton design pattern after the GoF and Petr Posik; cf. 
    %  http://www.mathworks.de/matlabcentral/newsreader/view_thread/170056
    %  Revised according to Matlab R2008b help topic "Controlling the Number of Instances"
    %
    %  Created by John Lee on 2009-02-15.
    %  Copyright (c) 2009 Washington University School of Medicine.  All rights reserved.
    %  Report bugs to <email="bugs.perfusion.neuroimage.wustl.edu@gmail.com"/>.
    
    properties     
        iscomparator        = false;
        whiteMatterAverage  = false;
        rescaleWhiteMatter  = false;
        assumedWhiteAverage = 22;
    end

    properties (Access = 'private')        
        bookendsFolder = 'qCBF';
        useQBOLD       = false; 
    end
    
    methods (Static)

        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfsl.Np797Registry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end % static methods
    
    methods (Access = 'protected')
        function this = Np797Registry
            %% CTOR is protected and empty to ensure instance is the only entry into the class 
            this = this@mlfsl.FslRegistry;
        end % protected ctor
        function fold = qcbf_folder(this, pnum)
            
            %% QCBF_FOLDER
            if (nargin > 1)
                this.pnum = mlfsl.Np797Registry.ensurePnum(pnum); 
            end
            fold = [this.extFileParts_.northwesternIdMap(pnum) pnum this.extFileParts_.dateMap(pnum)];
        end % protected qcbf_folder
    end % protected methods 
end % classdef DBase
