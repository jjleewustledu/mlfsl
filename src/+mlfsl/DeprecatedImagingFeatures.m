classdef DeprecatedImagingFeatures < mlpatterns.Singleton
	%% DEPRECATEDIMAGINGFEATURES collects legacy data & behaviors of imaging-study objects
    %                            commonly found in classes *DBase*
	%                            is a singleton design pattern
	%  Version $Revision: 1529 $ was created $Date: 2012-08-23 22:39:40 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 22:39:40 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/DeprecatedImagingFeatures.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: DeprecatedImagingFeatures.m 1529 2012-08-24 03:39:40Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties (SetAccess = 'private')
 		moyamoyaIdMap
        northwesternIdMap
        dateMap
        jessyFileMap
    end 
    
    properties (Access = private)
        
        pnumNp797         = ...
        {'p7118'  'p7153'  'p7146'   'p7189'  'p7191'  'p7194'     'p7217'  'p7219'     'p7229'  'p7230'  ...
         'p7243'  'p7248'  'p7257'   'p7260'  'p7266'  'p7267'     'p7270'  'p7309'     'p7321'  'p7335'  ...
         'p7336'  'p7338'  'p7377'   'p7395'  'p7216'}; 
        moyamoyaIdNp797   = ...
        {'mm01-010_'       'mm01-008_'        'mm02-001_'          'mm01-011_'          ''          ...
         ''                'mm01-012_'        ''                   'mm03-001_'          ''          ...
         'mm01-003_'       'mm01-002_'        'mm01-004_'          'mm01-006_'          'mm01-009_' ...
         'mm01-007_'       'mm01-005_'        ''                   'mm06-001_'          'mm01-018_' ...
         ''                'mm01-019_'        ''                   ''                   'mm01-014_'};
        prefixNp797       = ...
        {'wu001_'          'wu002_'           'wu003_'             'wu005_'             'wu006_' ...
         'wu007_'          'wu009_'           'wu010_'             'wu011_'             'wu012_' ...
         'wu014_'          'wu015_'           'wu016_'             'wu017_'             'wu018_' ...
         'wu019_'          'wu021_'           ''                   'wu024_'             'wu026_' ...
         'wu027_'          'wu028_'           '01-020_'            'wu029_'             ''};
        suffixNp797       = ...
        {'_2007oct16'      '_2008jan16'       '_2008jan4'          '_2008mar12'         '_2008mar13' ...
         '_2008mar14'      '_2008apr14'       '_2008apr23'         '_2008apr28'         '_2008apr29' ...
         '_2008may21'      '_2008may23'       '_2008jun4'          '_2008jun9'          '_2008jun16' ...
         '_2008jun16'      '_2008jun18'       '_2008aug20'         '_2008sep8'          '_2008oct21' ...
         '_2008oct21'      '_2008oct30'       '_2009feb5'          '_2009mar12'         '_2008apr11'};
        jessyFilenameStem = ...
        {''                'P003GE_MSS-1.mat' 'P002GE_M.mat'       'P004GE_A_SVD.mat'   'P005GE_A.mat'    ...
         'P006GE_A.mat'    'P008GE_A.mat'     'P009GE_A.mat'       'P010GE_A.mat'       'P011GE_A_FS.mat' ...
         'P012GE_A_FS.mat' 'P013GE_A_FS.mat'  'P013GE_A_p7257.mat' 'P014GE_A_p7260.mat' 'P003GE_A.mat'    ...
         'P004GE_A.mat'    'P005GE_A.mat'     'P006GE_M.mat'       'P007GE_A.mat'       'P007GE_A.mat'    ...
         'P003GE_A.mat'    'P013GE_A.mat'     ''                   'P014GE_MSS.mat'     'P007GE_A.mat'};
         mimaging
    end

	methods 
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
    
        function p    = getPnumNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.pnumNp797)); idx = length(this.pnumNp797); end
            p = this.pnumNp797{idx};
        end        
        function p    = getMoyamoyaIdNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.moyamoyaIdNp797)); idx = length(this.moyamoyaIdNp797); end
            p = this.moyamoyaIdNp797{idx};
        end        
        function p    = getPrefixNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.prefixNp797)); idx = length(this.prefixNp797); end
            p = this.prefixNp797{idx};
        end        
        function p    = getSuffixNp797(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.suffixNp797)); idx = length(this.suffixNp797); end
            p = this.suffixNp797{idx};
        end        
        function p    = getJessyFilenameStem(this, idx)
            if (idx < 1); idx = 1; end
            if (idx > length(this.jessyFilenameStem)); idx = length(this.jessyFilenameStem); end
            p = this.jessyFilenameStem{idx};
        end          
        function l    = lenPnumNp797(this)
            l = length(this.pnumNp797);
        end        
        function l    = lenMoyamoyaIdNp797(this)
            l = length(this.moyamoyaIdNp797);
        end        
        function l    = lenPrefixNp797(this)
            l = length(this.prefixNp797);
        end        
        function l    = lenSuffixNp797(this)
            l = length(this.suffixNp797);
        end        
        function l    = lenJessyFilenameStem(this)
            l = length(this.jessyFilenameStem);
        end              
        function fld  = abinitioPatientFolder(this, pnum)
            
            if (~exist('pnum','var') || isempty(pnum) || strcmp('unknown',pnum));
                fld = '.';
            else
                pnum = mlfsl.ImagingComponent.ensurePnum(pnum);
                fld = [this.moyamoyaIdMap(pnum) ...
                       this.northwesternIdMap(pnum) ...
                       pnum ...
                       this.dateMap(pnum)];
            end
        end
        function fn   = jessy_filename(this, tag)
            %% JESSY_FILENAME  
            %  Usage:  filename = obj.jessy_filename([tag])
            %                                         ^ pnum or bool
            %                                           bool==true -> return fully qualified filename
            if (2 == nargin)
                switch (class(tag))
                    case {'logical' numeric_types}
                        isfq = logical(tag);
                        fn   = this.jessyFileMap(this.pnum);
                    case 'char'
                        isfq = true;
                        fn   = this.jessyFileMap(mlfsl.Np797Registry.ensurePnum(tag));
                    otherwise
                        isfq = true;
                end
            else
                isfq = true;
                fn   = this.jessyFileMap(this.pnum);
            end
            this.mimaging.pnum = this.pnum;
            if (isfq); fn = fullfile(this.mimaging.mrPath, this.bookendsFolder, fn); end
        end % jessy_filename  
    end
    
    methods (Static)
        function this = instance            
            %% INSTANCE 
            %  Usage:   obj = DeprecatedImagingFeatures.instance
            persistent uniqueInstance;            
            if (isempty(uniqueInstance))
                this = mlfsl.DeprecatedImagingFeatures;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end % static instance  
    end % static methods
    methods (Access = 'private')
 		function this = DeprecatedImagingFeatures
            
 			%% DEPRECATEDIMAGINGFEATURES (ctor)
            this                   = this@mlpatterns.Singleton;
 			this.moyamoyaIdMap     = containers.Map;
            this.northwesternIdMap = containers.Map;
            this.dateMap           = containers.Map;
            this.jessyFileMap      = containers.Map;
            
            for p = 1:length(this.pnumNp797) %#ok<*PFUNK,FORFLG>
                this.moyamoyaIdMap(    this.pnumNp797{p}) = this.moyamoyaIdNp797{p};  %#ok<*PFPIE>
                this.northwesternIdMap(this.pnumNp797{p}) = this.prefixNp797{p};
                this.dateMap(          this.pnumNp797{p}) = this.suffixNp797{p};
                this.jessyFileMap(     this.pnumNp797{p}) = this.jessyFilenameStem{p};
            end 
            
            this.mimaging = mlfsl.MRImaging;
 		end % DeprecatedImagingFeatures (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
