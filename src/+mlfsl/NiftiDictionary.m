classdef NiftiDictionary < mlpatterns.Singleton
	%% NIFTIDICTIONARY maps DICOM/IMA filenames to canonical names for NIfTI 
	%  Version $Revision: 1552 $ was created $Date: 2012-08-23 22:39:41 -0500 (Thu, 23 Aug 2012) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2012-08-23 22:39:41 -0500 (Thu, 23 Aug 2012) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/NiftiDictionary.m $ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id: NiftiDictionary.m 1552 2012-08-24 03:39:41Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient)
        dict % containers.Map object patterns -> canonical word
        filename
    end
    
    properties (Constant)
        PATTERNS = { ...
         'local'                   'SCOUT' ...
         'IRLLEPI' ...
         '_ADC'                    'Diiff'              'DIFF'          'iPaT_2_ADC' ...
         'mpr'                     'MPRAGE'             't1_mpr'        '_SE_T1'     '_SET1'   't1_se_'   'tfl3d1_t1' 'T1_' ...
         't2_space'                't2space'            't2_tse'        'T2_TSE'     'TSE_T2'  't2_blade' ...
         'Blood_SWI' ...
         'PERFUSION_TTP'           'PERFUSION_PBP'      'PERFUSION_GBP' ...
         'ep2d_perf_with_contrast' ...
         'MoCoSeries'              'Perfusion_Weighted' 'relCBF' ...
         'ep2d_perf'               'mocoPasl'           'pwAsl' ...       
         'pCASL' 'cbfPasl'         'ASL1_black-ances'   'ep2d_pasl'     'pasl' ...
         'FirstECHO'               'SecondECHO'         '_ase_'         'ASE'        '_OEF_' ...
         'EPI_PERFUSION' ...
         'MIP'                     'TOF_FL2D'           'tof3d'         'Short_TOF.' ...
         'field_mapping' ...
         'ciss3d'                  'tse_T1w.'           'tse_PDw.'      'tse_T2w' ...
         'GRE_T2'                  'gre'  ...
         'flair_rot_abs'           'flair'              'FLAIR'         'space_ir'   'spaceir' 'ir' ...
         'lat'                     '-mask' ...
         'oc1'                     'oo1_g3'             'ho1_g3' ...
         'oo1_f'                   'ho1_f'              'oo1_sum'       'ho1_sum' ...
         'oo1'                     'ho1' ...
         'oc2'                     'oo2_g3'             'ho2_g3' ...
         'oo2_f'                   'ho2_f'              'oo2_sum'       'ho2_sum' ...
         'oo2'                     'ho2'};
        WORDS    = { ...
         'local'                   'local' ...
         'irllepi' ...
         'adc'                     'dwi'                'dwi'           'adc' ...
         't1'                      't1'                 't1'            't1'         't1'      't1'       't1'        't1' ...
         't2'                      't2'                 't2'            't2'         't2'      't2' ...
         'swi' ...
         'ttp'                     'pbp'                'gbp' ...
         'ep2d'  ...
         'paslmoco'                'pwPasl'             'cbfPasl' ...
         'ep2d'                    'paslmoco'           'pwAsl' ...
         'pcasl'                   'cbfPasl'            'pasl'                       'pasl'    'pasl' ...
         'ase'                     'ase2nd'             'ase'           'ase'        'oef' ...
         'ep2d' ...
         'mip'                     'tof'                'tof'           'tof' ...
         'fieldmap' ...
         'ciss'                    't1Hires'            'pdHires'       't2Hires' ...
         'gre'                     'gre' ...
         'flair_rot_abs'           'flair'              'flair'         'flair'      'flair'   'flair' ...
         'lat'                     'mask' ...
         'oc'                      'oog3'               'hog3' ...
         'oosum'                   'hosum'              'oosum'         'hosum' ...
         'oo'                      'ho' ...
         'oc'                      'oog3'               'hog3' ...
         'oosum'                   'hosum'              'oosum'         'hosum' ...
         'oo'                      'ho'};
    end

	methods
 		
        function this  = addMapping(this, from, to)
            this.dict(from) = to;
        end % addMapping
        
        function this  = deleteMapping(this, from)
            this.dict.remove(from);
        end % deleteMapping
        
        function this  = load(this, matFilename)
            if (nargin < 2 || isempty(matFilename))
                this = this.loadDefault;
            else
                this.dict = load(matFilename, 'dict');
            end
        end % loadDict
        
        function this  = loadDefault(this)
            this.dict = containers.Map(this.PATTERNS, this.WORDS);
        end % loadDefault
        
        function         save(this, matFilename) %#ok<MANU>
            save(matFilename, '-struct', 'this', 'dict');
        end % saveDict
        
        function matches  = definitions(this, str)
            
            %% DEFINITIONS returns a cell-array of canonical words that correspond to the passed string.
            %  Internal patterns are compared against the string and matching patterns & matching 
            %  canonical words are returned in ranked order, best first.
            %  Usage:   matches = obj.definitions(string-to-parse)
            %           ^ struct('pattern', p, 'word', w)
            matches  = {};
            patterns = this.dict.keys;
            for p = 1:length(patterns) %#ok<FORFLG>
                indices = strfind(str, patterns{p});
                if (~isempty(indices))
                    matches = [matches struct('string', str, 'pattern', patterns{p}, 'word', this.dict(patterns{p}))]; %#ok<PFBNS>
                end
            end
            if (isempty(matches))
                matches = struct('string', str, 'pattern', '', 'word', '');
            end
            if (numel(matches) > 1)
                pattLengths = zeros(1,numel(matches));
                for p = 1:length(pattLengths)
                    pattLengths(p) = length(matches{p}.pattern);
                end
                [~,ix] = sort(pattLengths, 'descend');
                 matches = matches(ix);
            end
        end % definitions
        
        function dmatches = dir(this, dirstr)
            
            dmatches = {};
            dlist = dir(dirstr);
            assert(~isempty(dlist), dirstr);
            for d = 1:length(dlist) %#ok<FORFLG>
                if (~dlist(d).isdir & ~isempty(strfind(dlist(d).name, '.nii')))
                    dmatches = [dmatches this.definitions(dlist(d).name)]; %#ok<PFBNS>
                end
            end
        end % dir
        
        function dmatches = patientDir(this, patPth)
            
            dmatches = this.dir(fullfile(patPth, 'Magnetom', 'MRIConvert', ''));
        end % patientDir
        
        function dmatches = patientDirs(this, wild)
            dstructs = dir(wild);
            dmatches = {};
            for d = 1:length(dstructs)
                if (dstructs(d).isdir)
                    dmatches = [dmatches this.patientDir(dstructs(d).name)];
                end
            end
        end % patientDirs
    end
    
    methods (Static)

        function this = instance(qualifier)
            
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            persistent uniqueInstance
            
            fname = '';
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    case 'clear'
                        clear uniqueInstance;
                        return;
                    case 'delete'
                        if (~isempty(uniqueInstance))
                            uniqueInstance.delete;
                            return;
                        end
                    otherwise
                        fname = qualifier;
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlfsl.NiftiDictionary;
                if (~isempty(fname))
                    this.filename = fname;
                end
                this = this.load(this.filename);
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end % static methods

	methods (Access = 'private')
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
        function this = NiftiDictionary
 		end % NiftiDictionary (ctor) 
 	end % private methods
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
