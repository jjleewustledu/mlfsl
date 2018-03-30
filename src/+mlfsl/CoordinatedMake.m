classdef CoordinatedMake 
	%% COORDINATEDMAKE coordinates other *Make classes 
    %  Usage:  ctor is private; use static factory methods
    %          mlfsl.CoordinatedMake.makeAll
    %          mlfsl.CoordinatedMake.makeNp(location)
	%  Version $Revision: 2481 $ was created $Date: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-08-18 01:44:27 -0500 (Sun, 18 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfsl/src/+mlfsl/trunk/CoordinatedMake.m $ 
 	%  Developed on Matlab 7.12.0.635 (R2011a) 
 	%  $Id: CoordinatedMake.m 2481 2013-08-18 06:44:27Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
 		% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, ... 
 		%       Constant, Dependent, Hidden, Transient) 
        
        fslreg;
        npreg;
        mrmake;
        petmake;
 	end 

	methods 

        function this = makeMcverted(this)
            this.mrmake = this.mrmake.mcvert;
        end

        function mk = makeAse(this, mk)
            cd(mk.fslPath);
            mk.aseFileprefixes = {}; % disables mrmk.makeAse
            mk.makeAse;
            mk.collectTransformations;
        end

        function mk = makeMoco(this, mk)        
            cd(mk.fslPath);        
            delete('*_mcf*');
            try
                movefiles('irllepi*', mk.backupFolder, mk.force);
            catch ME
                warning(ME.getReport);
            end
            try
                movefiles('*.par',    mk.backupFolder, mk.force);
            catch ME1
                warning(ME1.getReport);
            end
            flirtf = mlfsl.FlirtBuilder;
            flirtf.makeMotionCorrect;
            flirtf.cleanMoco;
            mk.collectTransformations;
        end

        function mk = makeBet(this, mk)
            import mlfsl.*;
            cd(mk.fslPath);
            betf = BetBuilder;
            betf.parbet;
            cd(mk.fslPath);        
            betf.moveBetted;        
            cd(mk.fslPath);
            flirtf = FlirtBuilder;
            flirtf.move2OnFolders;
            BetBuilder.ensureFolder(mk.backupFolder);
            movefiles('*_on_*', mk.backupFolder);
            cd(mk.bettedPath);
            movefiles({'*mesh*' '*skull*' '*skin*' '*.vtk' '*.par'}, mk.backupFolder);        
            movefiles('*_mask*.nii.gz',                              mk.backupFolder);        
            mk.collectTransformations;
        end

        function mk = makeMRflirt(this, mk)
            cd(mk.fslPath);
            copyfiles('bet/b*.nii.gz');
            flirtf = mlfsl.FlirtBuilder;
            flirtf = flirtf.coregister('t2_rot',        't1_rot');
            flirtf = flirtf.coregister('flair_rot',     't1_rot');
                     flirtf.coregister('flair_rot_abs', 't1_rot');
                     
            mk.flirtMROntoRefs;
            mk.collectTransformations;
            cd(mk.fslPath);
            flirtf = FlirtBuilder;
            flirtf.move2OnFolders;
        end

        function mk = makePetRenameReorient(this, mk)
            cd(mk.fslPath);
            mk.rename;
            mk.reorient;
        end

        function mk = makePetFlirt(this, mk)
            cd(mk.fslPath);
            mk.aseFileprefixes = {};
            copyfiles(fullfilename(mk.bettedPath, 'bt1_rot'));
            mk.coregisterPet;
            mk.flirtPETOntoRefs;        
            mk.collectTransformations;        
            cd(mk.fslPath);
            flirtf = mlfsl.FlirtBuilder;
            flirtf.move2OnFolders;
            %mk = mk.quantifyPet0('Backups/bep2d2_rot_mcf_meanvol_mask', 'bep2d2_rot_mcf_meanvol');
        end
 	end 

	methods (Static)
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 
        
        function [mrmk,petmk] = makeNp(ptfold)
            
            %% MAKENP
            %  Usage:  [mrmake, petmake, fnirtBuilder] = makeNp(patientFolder)
            import mlfsl.* mlfourd.*;
            
            if (nargin < 1); ptfold = pwd; end            
            pwd0   = pwd;            
            coordm = CoordinatedMake(ptfold);
            
            cd(ptfold);       %#ok<*MCCD>
            coordm.npreg           = Np797Registry.instance;
            coordm.npreg.sid       = 'np797';
            coordm.npreg.reference = 'bt1_rot';
            coordm.npreg.h15o      = 'hosum_rot';
            coordm.npreg.o15o      = 'oosum_rot';
            coordm.npreg.c15o      = 'oc_rot';
            coordm.npreg.t1        = 't1_rot';
            coordm.npreg.t2        = 't2_rot';
            coordm.npreg.ir        = 'ir_rot_abs';
            
            mrmk  = MRMake( ptfold);
            petmk = mlpet.PETMake(ptfold);
            
            hidden = fullfile(mrmk.fslPath, 'HideFromBet', '');
            FlirtBuilder.ensureFolder(hidden);
            copyfiles('q*.nii.gz', hidden);
            
            
            % MR
            
            mrmk = makeMcverted(mrmk);
            mrmk = makeRenameReorient(mrmk);
            mrmk = makeAse(mrmk);
            mrmk = makeMoco(mrmk);
            mrmk = makeBet(mrmk);
            mrmk = makeMRflirt(mrmk);
            
            % PET
            
            petmk = makePetRenameReorient(petmk);
            petmk = makePetFlirt(petmk);
            
            % NONLINEAR
            
            cd(mrmk.fslPath);
            mlbash('for m in $(echo `ls -d matrices/*.mat`); do ln -s $m; done');
            FnirtBuilder.makeFnirt(ptfold);
            cd(pwd0);
        end % makeNp
        
        function makeAll
        end
        
        function help
        end
    end 
    
    methods (Access = 'private')
        
        function this = CoordinatedMake(location) 
            
 			%% COORDINATEDMAKE (ctor) 
            import mlfsl.*;
            this.mrmake  = MRMake( location);
            this.petmake = mlpet.PETMake(location);
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
