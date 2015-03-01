classdef Np755Maker
    %% NP755MAKER makes the contents of the fsl-folder in the patient path
    
    properties
        reg
        mrmk
        petmk
    end
    
    methods (Static)
        
        function tester(ptfold)
            fprintf('Np755Maker.tester received %s\n', ptfold);
            try
                cd(ptfold);                
                maker = mlfsl.Np755Maker;
            catch ME
                handexcept(ME);
            end             
            fprintf('Np755Maker.tester.maker.reg ->\n');
            disp(maker.reg);
            fprintf('Np755Maker.tester.reg.irreducibleNames->\n');
            disp(maker.reg.irreducibleNames);
        end
        
        function makeRename(ptfold)
            import mlfsl.*;            
            if (   ~exist('ptfold','var'))
                ptfold = '.'; 
            elseif (exist( ptfold, 'dir'))
            else
                ptfold = ['*' ptfold '*'];
            end
            pwd0 = pwd;
            try
                cd(ptfold);                
                maker = Np755Maker;
            catch ME
                handexcept(ME);
            end
            maker.mrmk  = maker.makeRenameReorient;
            maker.petmk = maker.makePetRenameReorient;
            cd(pwd0);
        end % makeRename
        
        function makeAll(ptfold, noEp2d)
            import mlfsl.*;            
            if (~exist('ptfold','var'))
                ptfold = '.'; 
            elseif (exist(ptfold, 'dir'))
            else
                ptfold = ['*' ptfold '*'];
            end            
            if (~exist('noEp2d', 'var')); noEp2d = false; end
            pwd0  = pwd;
            try
                cd(ptfold);                
                maker = Np755Maker;
            catch ME
                handexcept(ME);
            end            
            
            % MR

            maker.mrmk = maker.makeMoco;
            maker.mrmk = maker.makeBet;
            maker.mrmk = maker.makeMRflirt;

            % PET

            maker.petmk = maker.makePetFlirt;

            % NONLINEAR

            cd(maker.mrmk.fslPath);
            FnirtBuilder.makeFnirt(ptfold, noEp2d);
            
            cd(pwd0);
        end % static makeAll
        
        function makeNext(csfidx, ptfold, noEp2d)
            import mlfsl.*;            
            if (~exist('ptfold','var'))
                ptfold = '.'; 
            elseif (exist(ptfold, 'dir'))
            else
                ptfold = ['*' ptfold '*'];
            end
            if (~exist('noEp2d', 'var')); noEp2d = false; end
            pwd0  = pwd;
            try
                cd(ptfold);                
                maker = Np755Maker;
            catch ME
                handexcept(ME);
            end 
            
            cd(maker.mrmk.fslPath);
            FnirtBuilder.makeFnirt2(csfidx, noEp2d);
            cd(pwd0);
        end % static makeNExt
        
    end % static methods
    
    methods (Access = 'private')
        
        function this = Np755Maker(ptfold)
            import mlfsl.* mlfourd.*;
            if (~exist('ptfold','var')); ptfold = '.'; end
            this.reg   = Np797Registry.instance('initialize');
            this.mrmk  = MRMake( ptfold);
            this.petmk = mlpet.PETMake(ptfold);
        end

        function mk = makeMcverted(this)
            cd(this.mrmk.mcverterPath)
            mk =  this.mrmk.mcvert;
        end

        function mk = makeAse(this, mk)
            cd(mk.fslPath);
            mk.aseFileprefixes = {}; % disables mrmk.makeAse
            mk.makeAse;
            mk.collectTransformations;
        end

        function mk = makeMoco(this)
            cd(this.mrmk.fslPath);        
            delete('*_mcf*');
            try
                movefiles('irllepi*', this.mrmk.backupFolder, this.mrmk.force);                
                movefiles('*asl*', this.mrmk.backupFolder, this.mrmk.force);
                movefiles('*ase*', this.mrmk.backupFolder, this.mrmk.force);
            catch ME
                warning(ME.getReport);
            end
            try
                movefiles('*.par',    this.mrmk.backupFolder, this.mrmk.force);
            catch ME1
                warning(ME1.getReport);
            end
            flirtf = mlfsl.FlirtBuilder;
            flirtf.doMotionCorrect;
            flirtf.cleanMoco;
            this.mrmk.collectTransformations;
            mk = this.mrmk;
        end

        function mk = makeBet(this)
            import mlfsl.* mlfourd.*;
            cd(this.mrmk.patientPath);
            betf = BetBuilder;        
            cd(this.mrmk.fslPath); 
            betf.parbet;      
            t2ont1 = NIfTI.load('t2_rot_on_t1_rot');
            t1mask = NIfTI.load('bt1_rot_mask.nii.gz');
            t2ont1 = t2ont1 .* t1mask;
            t2ont1.fileprefix = 'bt2_rot_on_t1_rot';
            t2ont1.save;      
            cd(this.mrmk.fslPath);
            flirtf = FlirtBuilder;
            flirtf.coregister('flair_rot_abs', 't1_rot', 'matrices/flair_rot_on_t1_rot.mat', 'flair_rot_abs_on_t1_rot');
            
            flont1 = NIfTI.load('flair_rot_abs_on_t1_rot');
            t1mask = NIfTI.load('bt1_rot_mask.nii.gz');
            flont1 = flont1 .* t1mask;
            flont1.fileprefix = 'bflair_rot_abs_on_t1_rot';
            flont1.save;
            %flirtf.move2OnFolders;            
            %betf.moveBetted;  
            BetBuilder.ensureFolder(this.mrmk.backupFolder);
            movefiles('*_on_*', this.mrmk.backupFolder);
            cd(this.mrmk.bettedPath);
            movefiles({'*mesh*' '*skull*' '*skin*' '*.vtk' '*.par'}, this.mrmk.backupFolder);        
            movefiles('*_mask*.nii.gz',                              this.mrmk.backupFolder);        
            this.mrmk.collectTransformations;
            mk = this.mrmk;
        end

        function mk = makeMRflirt(this)
            import mlfsl.*;
            cd(this.mrmk.fslPath);
            copyfiles('bet/b*.nii.gz');
            flirtf = FlirtBuilder;
            flirtf = flirtf.coregister('t2_rot',        't1_rot');
            flirtf = flirtf.coregister('flair_rot',     't1_rot');
            this.mrmk.flirtMROntoRefs;
            this.mrmk.collectTransformations;
            cd(this.mrmk.fslPath);
            mk = this.mrmk;
        end

        function mk = makePetRenameReorient(this)
            cd(this.reg.fslPath);
            this.petmk.rename;
            this.petmk.reorient;
            mk = this.petmk;
        end

        function mk = makePetFlirt(this)
            import mlfsl.*;
            cd(this.petmk.fslPath);
            copyfiles(fullfilename(this.petmk.bettedPath, 'bt1_rot'));
            this.petmk.coregisterPet;
            %this.petmk.flirtPETOntoRefs;        
            this.petmk.collectTransformations;        
            cd(this.petmk.fslPath);
            %flirtf = FlirtBuilder;
            %flirtf.move2OnFolders;
            %mk = mk.quantifyPet0('Backups/bep2d2_rot_mcf_meanvol_mask', 'bep2d2_rot_mcf_meanvol');
            mk = this.petmk;
        end
    
    end
end