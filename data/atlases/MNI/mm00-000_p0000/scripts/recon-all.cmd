#--------------------------------------------
#@# MotionCor Fri Mar  7 00:08:53 CST 2014
\n cp /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/orig/001.mgz /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/rawavg.mgz \n
\n mri_convert /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/rawavg.mgz /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/orig.mgz --conform \n
\n mri_add_xform_to_header -c /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/transforms/talairach.xfm /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/orig.mgz /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/orig.mgz \n
#--------------------------------------------
#@# Talairach Fri Mar  7 00:09:01 CST 2014
\n mri_nu_correct.mni --n 1 --proto-iters 1000 --distance 50 --no-rescale --i orig.mgz --o orig_nu.mgz \n
\n talairach_avi --i orig_nu.mgz --xfm transforms/talairach.auto.xfm \n
\n cp transforms/talairach.auto.xfm transforms/talairach.xfm \n
#--------------------------------------------
#@# Talairach Failure Detection Fri Mar  7 00:10:15 CST 2014
\n talairach_afd -T 0.005 -xfm transforms/talairach.xfm \n
\n awk -f /Applications/freesurfer/bin/extract_talairach_avi_QA.awk /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/transforms/talairach_avi.log \n
\n tal_QC_AZS /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/transforms/talairach_avi.log \n
#--------------------------------------------
#@# Nu Intensity Correction Fri Mar  7 00:10:15 CST 2014
\n mri_nu_correct.mni --i orig.mgz --o nu.mgz --uchar transforms/talairach.xfm --n 2 \n
\n mri_add_xform_to_header -c /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/transforms/talairach.xfm nu.mgz nu.mgz \n
#--------------------------------------------
#@# Intensity Normalization Fri Mar  7 00:11:16 CST 2014
\n mri_normalize -g 1 nu.mgz T1.mgz \n
#--------------------------------------------
#@# Skull Stripping Fri Mar  7 00:13:21 CST 2014
\n mri_em_register -skull nu.mgz /Applications/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta \n
\n mri_watershed -T1 -brain_atlas /Applications/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull.lta T1.mgz brainmask.auto.mgz \n
\n cp brainmask.auto.mgz brainmask.mgz \n
#-------------------------------------
#@# EM Registration Fri Mar  7 00:31:01 CST 2014
\n mri_em_register -uns 3 -mask brainmask.mgz nu.mgz /Applications/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta \n
#--------------------------------------
#@# CA Normalize Fri Mar  7 00:47:45 CST 2014
\n mri_ca_normalize -c ctrl_pts.mgz -mask brainmask.mgz nu.mgz /Applications/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.lta norm.mgz \n
#--------------------------------------
#@# CA Reg Fri Mar  7 00:49:11 CST 2014
\n mri_ca_register -nobigventricles -T transforms/talairach.lta -align-after -mask brainmask.mgz norm.mgz /Applications/freesurfer/average/RB_all_2008-03-26.gca transforms/talairach.m3z \n
#--------------------------------------
#@# CA Reg Inv Fri Mar  7 03:10:57 CST 2014
\n mri_ca_register -invert-and-save transforms/talairach.m3z \n
#--------------------------------------
#@# Remove Neck Fri Mar  7 03:11:46 CST 2014
\n mri_remove_neck -radius 25 nu.mgz transforms/talairach.m3z /Applications/freesurfer/average/RB_all_2008-03-26.gca nu_noneck.mgz \n
#--------------------------------------
#@# SkullLTA Fri Mar  7 03:12:47 CST 2014
\n mri_em_register -skull -t transforms/talairach.lta nu_noneck.mgz /Applications/freesurfer/average/RB_all_withskull_2008-03-26.gca transforms/talairach_with_skull_2.lta \n
#--------------------------------------
#@# SubCort Seg Fri Mar  7 03:36:02 CST 2014
\n mri_ca_label -align norm.mgz transforms/talairach.m3z /Applications/freesurfer/average/RB_all_2008-03-26.gca aseg.auto_noCCseg.mgz \n
\n mri_cc -aseg aseg.auto_noCCseg.mgz -o aseg.auto.mgz -lta /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/mm00-000_p0000/mri/transforms/cc_up.lta mm00-000_p0000 \n
#--------------------------------------
#@# Merge ASeg Fri Mar  7 03:55:02 CST 2014
\n cp aseg.auto.mgz aseg.mgz \n
#--------------------------------------------
#@# Intensity Normalization2 Fri Mar  7 03:55:02 CST 2014
\n mri_normalize -aseg aseg.mgz -mask brainmask.mgz norm.mgz brain.mgz \n
#--------------------------------------------
#@# Mask BFS Fri Mar  7 03:58:42 CST 2014
\n mri_mask -T 5 brain.mgz brainmask.mgz brain.finalsurfs.mgz \n
#--------------------------------------------
#@# WM Segmentation Fri Mar  7 03:58:44 CST 2014
\n mri_segment brain.mgz wm.seg.mgz \n
\n mri_edit_wm_with_aseg -keep-in wm.seg.mgz brain.mgz aseg.mgz wm.asegedit.mgz \n
\n mri_pretess wm.asegedit.mgz wm norm.mgz wm.mgz \n
#--------------------------------------------
#@# Fill Fri Mar  7 04:01:30 CST 2014
\n mri_fill -a ../scripts/ponscc.cut.log -xform transforms/talairach.lta -segmentation aseg.auto_noCCseg.mgz wm.mgz filled.mgz \n
#--------------------------------------------
#@# Tessellate lh Fri Mar  7 04:02:13 CST 2014
\n mri_pretess ../mri/filled.mgz 255 ../mri/norm.mgz ../mri/filled-pretess255.mgz \n
\n mri_tessellate ../mri/filled-pretess255.mgz 255 ../surf/lh.orig.nofix \n
\n rm -f ../mri/filled-pretess255.mgz \n
\n mris_extract_main_component ../surf/lh.orig.nofix ../surf/lh.orig.nofix \n
#--------------------------------------------
#@# Smooth1 lh Fri Mar  7 04:02:21 CST 2014
\n mris_smooth -nw -seed 1234 ../surf/lh.orig.nofix ../surf/lh.smoothwm.nofix \n
#--------------------------------------------
#@# Inflation1 lh Fri Mar  7 04:02:27 CST 2014
\n mris_inflate -no-save-sulc ../surf/lh.smoothwm.nofix ../surf/lh.inflated.nofix \n
#--------------------------------------------
#@# QSphere lh Fri Mar  7 04:02:54 CST 2014
\n mris_sphere -q -seed 1234 ../surf/lh.inflated.nofix ../surf/lh.qsphere.nofix \n
#--------------------------------------------
#@# Fix Topology lh Fri Mar  7 04:06:05 CST 2014
\n cp ../surf/lh.orig.nofix ../surf/lh.orig \n
\n cp ../surf/lh.inflated.nofix ../surf/lh.inflated \n
\n mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 mm00-000_p0000 lh \n
\n mris_euler_number ../surf/lh.orig \n
\n mris_remove_intersection ../surf/lh.orig ../surf/lh.orig \n
\n rm ../surf/lh.inflated \n
#--------------------------------------------
#@# Make White Surf lh Fri Mar  7 04:21:45 CST 2014
\n mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs mm00-000_p0000 lh \n
#--------------------------------------------
#@# Smooth2 lh Fri Mar  7 04:27:15 CST 2014
\n mris_smooth -n 3 -nw -seed 1234 ../surf/lh.white ../surf/lh.smoothwm \n
#--------------------------------------------
#@# Inflation2 lh Fri Mar  7 04:27:20 CST 2014
\n mris_inflate ../surf/lh.smoothwm ../surf/lh.inflated \n
\n mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/lh.inflated \n
\n#-----------------------------------------
#@# Curvature Stats lh Fri Mar  7 04:28:53 CST 2014
\n mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/lh.curv.stats -F smoothwm mm00-000_p0000 lh curv sulc \n
#--------------------------------------------
#@# Sphere lh Fri Mar  7 04:29:00 CST 2014
\n mris_sphere -seed 1234 ../surf/lh.inflated ../surf/lh.sphere \n
#--------------------------------------------
#@# Surf Reg lh Fri Mar  7 05:01:00 CST 2014
\n mris_register -curv ../surf/lh.sphere /Applications/freesurfer/average/lh.average.curvature.filled.buckner40.tif ../surf/lh.sphere.reg \n
#--------------------------------------------
#@# Jacobian white lh Fri Mar  7 05:21:31 CST 2014
\n mris_jacobian ../surf/lh.white ../surf/lh.sphere.reg ../surf/lh.jacobian_white \n
#--------------------------------------------
#@# AvgCurv lh Fri Mar  7 05:21:33 CST 2014
\n mrisp_paint -a 5 /Applications/freesurfer/average/lh.average.curvature.filled.buckner40.tif#6 ../surf/lh.sphere.reg ../surf/lh.avg_curv \n
#-----------------------------------------
#@# Cortical Parc lh Fri Mar  7 05:21:35 CST 2014
\n mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 lh ../surf/lh.sphere.reg /Applications/freesurfer/average/lh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/lh.aparc.annot \n
#--------------------------------------------
#@# Make Pial Surf lh Fri Mar  7 05:22:24 CST 2014
\n mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs mm00-000_p0000 lh \n
#--------------------------------------------
#@# Surf Volume lh Fri Mar  7 05:34:08 CST 2014
\n mris_calc -o lh.area.mid lh.area add lh.area.pial \n
\n mris_calc -o lh.area.mid lh.area.mid div 2 \n
\n mris_calc -o lh.volume lh.area.mid mul lh.thickness \n
#-----------------------------------------
#@# WM/GM Contrast lh Fri Mar  7 05:34:08 CST 2014
\n pctsurfcon --s mm00-000_p0000 --lh-only \n
#-----------------------------------------
#@# Parcellation Stats lh Fri Mar  7 05:34:15 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.stats -b -a ../label/lh.aparc.annot -c ../label/aparc.annot.ctab mm00-000_p0000 lh white \n
#-----------------------------------------
#@# Cortical Parc 2 lh Fri Mar  7 05:34:34 CST 2014
\n mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 lh ../surf/lh.sphere.reg /Applications/freesurfer/average/lh.destrieux.simple.2009-07-29.gcs ../label/lh.aparc.a2009s.annot \n
#-----------------------------------------
#@# Parcellation Stats 2 lh Fri Mar  7 05:35:31 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.a2009s.stats -b -a ../label/lh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab mm00-000_p0000 lh white \n
#-----------------------------------------
#@# Cortical Parc 3 lh Fri Mar  7 05:35:52 CST 2014
\n mris_ca_label -l ../label/lh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 lh ../surf/lh.sphere.reg /Applications/freesurfer/average/lh.DKTatlas40.gcs ../label/lh.aparc.DKTatlas40.annot \n
#-----------------------------------------
#@# Parcellation Stats 3 lh Fri Mar  7 05:36:45 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/lh.cortex.label -f ../stats/lh.aparc.DKTatlas40.stats -b -a ../label/lh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab mm00-000_p0000 lh white \n
#--------------------------------------------
#@# Tessellate rh Fri Mar  7 05:37:06 CST 2014
\n mri_pretess ../mri/filled.mgz 127 ../mri/norm.mgz ../mri/filled-pretess127.mgz \n
\n mri_tessellate ../mri/filled-pretess127.mgz 127 ../surf/rh.orig.nofix \n
\n rm -f ../mri/filled-pretess127.mgz \n
\n mris_extract_main_component ../surf/rh.orig.nofix ../surf/rh.orig.nofix \n
#--------------------------------------------
#@# Smooth1 rh Fri Mar  7 05:37:15 CST 2014
\n mris_smooth -nw -seed 1234 ../surf/rh.orig.nofix ../surf/rh.smoothwm.nofix \n
#--------------------------------------------
#@# Inflation1 rh Fri Mar  7 05:37:23 CST 2014
\n mris_inflate -no-save-sulc ../surf/rh.smoothwm.nofix ../surf/rh.inflated.nofix \n
#--------------------------------------------
#@# QSphere rh Fri Mar  7 05:37:54 CST 2014
\n mris_sphere -q -seed 1234 ../surf/rh.inflated.nofix ../surf/rh.qsphere.nofix \n
#--------------------------------------------
#@# Fix Topology rh Fri Mar  7 05:41:35 CST 2014
\n cp ../surf/rh.orig.nofix ../surf/rh.orig \n
\n cp ../surf/rh.inflated.nofix ../surf/rh.inflated \n
\n mris_fix_topology -mgz -sphere qsphere.nofix -ga -seed 1234 mm00-000_p0000 rh \n
\n mris_euler_number ../surf/rh.orig \n
\n mris_remove_intersection ../surf/rh.orig ../surf/rh.orig \n
\n rm ../surf/rh.inflated \n
#--------------------------------------------
#@# Make White Surf rh Fri Mar  7 05:55:41 CST 2014
\n mris_make_surfaces -noaparc -whiteonly -mgz -T1 brain.finalsurfs mm00-000_p0000 rh \n
#--------------------------------------------
#@# Smooth2 rh Fri Mar  7 06:01:23 CST 2014
\n mris_smooth -n 3 -nw -seed 1234 ../surf/rh.white ../surf/rh.smoothwm \n
#--------------------------------------------
#@# Inflation2 rh Fri Mar  7 06:01:29 CST 2014
\n mris_inflate ../surf/rh.smoothwm ../surf/rh.inflated \n
\n mris_curvature -thresh .999 -n -a 5 -w -distances 10 10 ../surf/rh.inflated \n
\n#-----------------------------------------
#@# Curvature Stats rh Fri Mar  7 06:02:59 CST 2014
\n mris_curvature_stats -m --writeCurvatureFiles -G -o ../stats/rh.curv.stats -F smoothwm mm00-000_p0000 rh curv sulc \n
#--------------------------------------------
#@# Sphere rh Fri Mar  7 06:03:06 CST 2014
\n mris_sphere -seed 1234 ../surf/rh.inflated ../surf/rh.sphere \n
#--------------------------------------------
#@# Surf Reg rh Fri Mar  7 06:34:41 CST 2014
\n mris_register -curv ../surf/rh.sphere /Applications/freesurfer/average/rh.average.curvature.filled.buckner40.tif ../surf/rh.sphere.reg \n
#--------------------------------------------
#@# Jacobian white rh Fri Mar  7 06:58:32 CST 2014
\n mris_jacobian ../surf/rh.white ../surf/rh.sphere.reg ../surf/rh.jacobian_white \n
#--------------------------------------------
#@# AvgCurv rh Fri Mar  7 06:58:34 CST 2014
\n mrisp_paint -a 5 /Applications/freesurfer/average/rh.average.curvature.filled.buckner40.tif#6 ../surf/rh.sphere.reg ../surf/rh.avg_curv \n
#-----------------------------------------
#@# Cortical Parc rh Fri Mar  7 06:58:36 CST 2014
\n mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 rh ../surf/rh.sphere.reg /Applications/freesurfer/average/rh.curvature.buckner40.filled.desikan_killiany.2010-03-25.gcs ../label/rh.aparc.annot \n
#--------------------------------------------
#@# Make Pial Surf rh Fri Mar  7 06:59:31 CST 2014
\n mris_make_surfaces -white NOWRITE -mgz -T1 brain.finalsurfs mm00-000_p0000 rh \n
#--------------------------------------------
#@# Surf Volume rh Fri Mar  7 07:13:05 CST 2014
\n mris_calc -o rh.area.mid rh.area add rh.area.pial \n
\n mris_calc -o rh.area.mid rh.area.mid div 2 \n
\n mris_calc -o rh.volume rh.area.mid mul rh.thickness \n
#-----------------------------------------
#@# WM/GM Contrast rh Fri Mar  7 07:13:05 CST 2014
\n pctsurfcon --s mm00-000_p0000 --rh-only \n
#-----------------------------------------
#@# Parcellation Stats rh Fri Mar  7 07:13:12 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.stats -b -a ../label/rh.aparc.annot -c ../label/aparc.annot.ctab mm00-000_p0000 rh white \n
#-----------------------------------------
#@# Cortical Parc 2 rh Fri Mar  7 07:13:32 CST 2014
\n mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 rh ../surf/rh.sphere.reg /Applications/freesurfer/average/rh.destrieux.simple.2009-07-29.gcs ../label/rh.aparc.a2009s.annot \n
#-----------------------------------------
#@# Parcellation Stats 2 rh Fri Mar  7 07:14:36 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.a2009s.stats -b -a ../label/rh.aparc.a2009s.annot -c ../label/aparc.annot.a2009s.ctab mm00-000_p0000 rh white \n
#-----------------------------------------
#@# Cortical Parc 3 rh Fri Mar  7 07:14:57 CST 2014
\n mris_ca_label -l ../label/rh.cortex.label -aseg ../mri/aseg.mgz -seed 1234 mm00-000_p0000 rh ../surf/rh.sphere.reg /Applications/freesurfer/average/rh.DKTatlas40.gcs ../label/rh.aparc.DKTatlas40.annot \n
#-----------------------------------------
#@# Parcellation Stats 3 rh Fri Mar  7 07:15:47 CST 2014
\n mris_anatomical_stats -mgz -cortex ../label/rh.cortex.label -f ../stats/rh.aparc.DKTatlas40.stats -b -a ../label/rh.aparc.DKTatlas40.annot -c ../label/aparc.annot.DKTatlas40.ctab mm00-000_p0000 rh white \n
#--------------------------------------------
#@# Cortical ribbon mask Fri Mar  7 07:16:07 CST 2014
\n mris_volmask --label_left_white 2 --label_left_ribbon 3 --label_right_white 41 --label_right_ribbon 42 --save_ribbon mm00-000_p0000 \n
#--------------------------------------------
#@# ASeg Stats Fri Mar  7 07:24:29 CST 2014
\n mri_segstats --seg mri/aseg.mgz --sum stats/aseg.stats --pv mri/norm.mgz --empty --brainmask mri/brainmask.mgz --brain-vol-from-seg --excludeid 0 --excl-ctxgmwm --supratent --subcortgray --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --etiv --surf-wm-vol --surf-ctx-vol --totalgray --euler --ctab /Applications/freesurfer/ASegStatsLUT.txt --subject mm00-000_p0000 \n
#-----------------------------------------
#@# AParc-to-ASeg Fri Mar  7 07:28:36 CST 2014
\n mri_aparc2aseg --s mm00-000_p0000 --volmask \n
\n mri_aparc2aseg --s mm00-000_p0000 --volmask --a2009s \n
#-----------------------------------------
#@# WMParc Fri Mar  7 07:30:54 CST 2014
\n mri_aparc2aseg --s mm00-000_p0000 --labelwm --hypo-as-wm --rip-unknown --volmask --o mri/wmparc.mgz --ctxseg aparc+aseg.mgz \n
\n mri_segstats --seg mri/wmparc.mgz --sum stats/wmparc.stats --pv mri/norm.mgz --excludeid 0 --brainmask mri/brainmask.mgz --in mri/norm.mgz --in-intensity-name norm --in-intensity-units MR --subject mm00-000_p0000 --surf-wm-vol --ctab /Applications/freesurfer/WMParcStatsLUT.txt --etiv \n
#--------------------------------------------
#@# BA Labels lh Fri Mar  7 07:41:56 CST 2014
INFO: fsaverage subject does not exist in SUBJECTS_DIR
INFO: Creating symlink to fsaverage subject...
\n cd /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI; ln -s /Applications/freesurfer/subjects/fsaverage; cd - \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA1.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA1.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA2.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA2.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA3a.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA3a.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA3b.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA3b.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA4a.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA4a.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA4p.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA4p.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA6.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA6.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA44.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA44.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA45.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA45.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.V1.label --trgsubject mm00-000_p0000 --trglabel ./lh.V1.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.V2.label --trgsubject mm00-000_p0000 --trglabel ./lh.V2.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.MT.label --trgsubject mm00-000_p0000 --trglabel ./lh.MT.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.perirhinal.label --trgsubject mm00-000_p0000 --trglabel ./lh.perirhinal.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA1.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA1.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA2.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA2.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA3a.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA3a.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA3b.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA3b.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA4a.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA4a.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA4p.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA4p.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA6.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA6.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA44.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA44.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.BA45.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.BA45.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.V1.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.V1.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.V2.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.V2.thresh.label --hemi lh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/lh.MT.thresh.label --trgsubject mm00-000_p0000 --trglabel ./lh.MT.thresh.label --hemi lh --regmethod surface \n
\n mris_label2annot --s mm00-000_p0000 --hemi lh --ctab /Applications/freesurfer/average/colortable_BA.txt --l lh.BA1.label --l lh.BA2.label --l lh.BA3a.label --l lh.BA3b.label --l lh.BA4a.label --l lh.BA4p.label --l lh.BA6.label --l lh.BA44.label --l lh.BA45.label --l lh.V1.label --l lh.V2.label --l lh.MT.label --l lh.perirhinal.label --a BA --maxstatwinner --noverbose \n
\n mris_label2annot --s mm00-000_p0000 --hemi lh --ctab /Applications/freesurfer/average/colortable_BA.txt --l lh.BA1.thresh.label --l lh.BA2.thresh.label --l lh.BA3a.thresh.label --l lh.BA3b.thresh.label --l lh.BA4a.thresh.label --l lh.BA4p.thresh.label --l lh.BA6.thresh.label --l lh.BA44.thresh.label --l lh.BA45.thresh.label --l lh.V1.thresh.label --l lh.V2.thresh.label --l lh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose \n
\n mris_anatomical_stats -mgz -f ../stats/lh.BA.stats -b -a ./lh.BA.annot -c ./BA.ctab mm00-000_p0000 lh white \n
\n mris_anatomical_stats -mgz -f ../stats/lh.BA.thresh.stats -b -a ./lh.BA.thresh.annot -c ./BA.thresh.ctab mm00-000_p0000 lh white \n
#--------------------------------------------
#@# BA Labels rh Fri Mar  7 07:45:41 CST 2014
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA1.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA1.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA2.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA2.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA3a.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA3a.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA3b.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA3b.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA4a.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA4a.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA4p.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA4p.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA6.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA6.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA44.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA44.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA45.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA45.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.V1.label --trgsubject mm00-000_p0000 --trglabel ./rh.V1.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.V2.label --trgsubject mm00-000_p0000 --trglabel ./rh.V2.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.MT.label --trgsubject mm00-000_p0000 --trglabel ./rh.MT.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.perirhinal.label --trgsubject mm00-000_p0000 --trglabel ./rh.perirhinal.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA1.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA1.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA2.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA2.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA3a.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA3a.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA3b.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA3b.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA4a.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA4a.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA4p.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA4p.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA6.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA6.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA44.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA44.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.BA45.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.BA45.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.V1.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.V1.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.V2.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.V2.thresh.label --hemi rh --regmethod surface \n
\n mri_label2label --srcsubject fsaverage --srclabel /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI/fsaverage/label/rh.MT.thresh.label --trgsubject mm00-000_p0000 --trglabel ./rh.MT.thresh.label --hemi rh --regmethod surface \n
\n mris_label2annot --s mm00-000_p0000 --hemi rh --ctab /Applications/freesurfer/average/colortable_BA.txt --l rh.BA1.label --l rh.BA2.label --l rh.BA3a.label --l rh.BA3b.label --l rh.BA4a.label --l rh.BA4p.label --l rh.BA6.label --l rh.BA44.label --l rh.BA45.label --l rh.V1.label --l rh.V2.label --l rh.MT.label --l rh.perirhinal.label --a BA --maxstatwinner --noverbose \n
\n mris_label2annot --s mm00-000_p0000 --hemi rh --ctab /Applications/freesurfer/average/colortable_BA.txt --l rh.BA1.thresh.label --l rh.BA2.thresh.label --l rh.BA3a.thresh.label --l rh.BA3b.thresh.label --l rh.BA4a.thresh.label --l rh.BA4p.thresh.label --l rh.BA6.thresh.label --l rh.BA44.thresh.label --l rh.BA45.thresh.label --l rh.V1.thresh.label --l rh.V2.thresh.label --l rh.MT.thresh.label --a BA.thresh --maxstatwinner --noverbose \n
\n mris_anatomical_stats -mgz -f ../stats/rh.BA.stats -b -a ./rh.BA.annot -c ./BA.ctab mm00-000_p0000 rh white \n
\n mris_anatomical_stats -mgz -f ../stats/rh.BA.thresh.stats -b -a ./rh.BA.thresh.annot -c ./BA.thresh.ctab mm00-000_p0000 rh white \n
#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label lh Fri Mar  7 07:49:28 CST 2014
INFO: lh.EC_average subject does not exist in SUBJECTS_DIR
INFO: Creating symlink to lh.EC_average subject...
\n cd /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI; ln -s /Applications/freesurfer/subjects/lh.EC_average; cd - \n
\n mris_spherical_average -erode 1 -orig white -t 0.4 -o mm00-000_p0000 label lh.entorhinal lh sphere.reg lh.EC_average lh.entorhinal_exvivo.label \n
\n mris_anatomical_stats -mgz -f ../stats/lh.entorhinal_exvivo.stats -b -l ./lh.entorhinal_exvivo.label mm00-000_p0000 lh white \n
#--------------------------------------------
#@# Ex-vivo Entorhinal Cortex Label rh Fri Mar  7 07:49:43 CST 2014
INFO: rh.EC_average subject does not exist in SUBJECTS_DIR
INFO: Creating symlink to rh.EC_average subject...
\n cd /Users/jjlee/Local/src/mlcvl/mlfsl/data/atlases/MNI; ln -s /Applications/freesurfer/subjects/rh.EC_average; cd - \n
\n mris_spherical_average -erode 1 -orig white -t 0.4 -o mm00-000_p0000 label rh.entorhinal rh sphere.reg rh.EC_average rh.entorhinal_exvivo.label \n
\n mris_anatomical_stats -mgz -f ../stats/rh.entorhinal_exvivo.stats -b -l ./rh.entorhinal_exvivo.label mm00-000_p0000 rh white \n
