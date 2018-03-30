classdef FslRegistry < mlpatterns.Singleton    
    %% FSLREGISTRY is a wrapper for simple database queries; is an mlpatterns.Singleton
    %
    %  Instantiation:  instance = mlfsl.FslRegistry.instance;
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
    
    properties (Constant)
        IMAGING_SUFFIXES = {'.nii.gz' '.nii' '.hdr'};
        INTERIMAGE_TOKEN =  '_on_';
    end
    
    properties
        alwaysBackup           = {'*mcf.mat' '*.par' '*sigma*' '*variance*' '*mean_reg*' '*skull*' '*skin*' '*.vtk'};
        atlasLibrary           =  'HarvardOxford';  
        betFolder              =  'bet'; 
        confidenceInterval     = 95;
        fslFolder              =  'fsl';
        mniIndex               =   1;
        preferredDatatype      =  'FLOAT'; 
        roiFolder              =  'ROIs';
        transformationsFolder  =  'matrices';           
    end
    
    properties (Dependent)        
        atlasPath
        baseBlur
        fsldir
        standardPath
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
                this = mlfsl.FslRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end 
    
    methods %% set/get
        function p   = get.atlasPath(this)
            p = fullfile(this.fsldir, 'data','atlases', this.atlasLibrary, '');
        end
        function bb  = get.baseBlur(~)
            bb = norm(mlpet.PETRegistry.instance.petPointSpread);
        end
        function fld = get.betFolder(this)
            fld = ensuredir(this.betFolder);
        end
        function d   = get.fsldir(this) %#ok<MANU>
            d = getenv('FSLDIR');
        end
        function       set.preferredDatatype(this, dt)
            assert(ischar(dt));
            this.preferredDatatype = dt;
        end  
        function fld = get.roiFolder(this)
            fld = ensuredir(this.roiFolder);
        end     
        function p   = get.standardPath(this)
            p = fullfile(this.fsldir, 'data','standard', '');
        end
        function fld = get.transformationsFolder(this)
            fld = ensuredir(this.transformationsFolder);
        end
    end    
    
    methods
        function fn  = standardAtlas(this, varargin) 
            fn = fullfilename(this.atlasPath, mlfourd.NamingRegistry.mniAtlases{this.mniIndex});
            fn = mlfourd.ImagingParser.formFilename(fn, varargin{:});
        end  
        function fn  = standardReference(this, varargin)
            fn = fullfilename(this.standardPath, mlfourd.NamingRegistry.mniNames{this.mniIndex});
            fn = mlfourd.ImagingParser.formFilename(fn, varargin{:});
        end      
    end

    %% PROTECTED
    
    methods (Access = 'protected')
        function this = FslRegistry
            %% CTOR is private and empty to ensure instance is the only entry into the class
            this = this@mlpatterns.Singleton;
        end % private ctor
    end % protected methods 
    
end % classdef FslRegistry
