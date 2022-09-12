%% Clear workspace

clc; clear; close all

%% Define parameters

subjectIDs = [1:5,7:15];%19,21:27];
subjects = 1:14;%25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    %% load 
    load([param.path, 'Processed/EEG/Locked encoding/erp contrasts encoding/' 'erp_encoding_' param.subjectIDs{sub}], 'erp');

    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        erp_all = selectfields(erp,{'label', 'time', 'dimord'});
    end
    
    erp_all.cvsi_motor_load_one_T1(this_subject,:)       = erp.cvsi_motor_load_one_T1;
    erp_all.cvsi_motor_load_one_T2(this_subject,:)       = erp.cvsi_motor_load_one_T2;
    erp_all.cvsi_motor_load_two(this_subject,:)          = erp.cvsi_motor_load_two;

    erp_all.cvsi_visual_load_one_T1(this_subject,:)      = erp.cvsi_visual_load_one_T1;
    erp_all.cvsi_visual_load_one_T2(this_subject,:)      = erp.cvsi_visual_load_one_T2;
    erp_all.cvsi_visual_load_two(this_subject,:)         = erp.cvsi_visual_load_two;

    erp_all.cvsi_EMG_mot_load_one_T1(this_subject,:)     = erp.cvsi_EMG_mot_load_one_T1;
    erp_all.cvsi_EMG_mot_load_one_T2(this_subject,:)     = erp.cvsi_EMG_mot_load_one_T2;
    erp_all.cvsi_EMG_mot_load_two(this_subject,:)        = erp.cvsi_EMG_mot_load_two;
    
    erp_all.cvsi_EMG_vis_load_one_T1(this_subject,:)     = erp.cvsi_EMG_vis_load_one_T1;
    erp_all.cvsi_EMG_vis_load_one_T2(this_subject,:)     = erp.cvsi_EMG_vis_load_one_T2;
    erp_all.cvsi_EMG_vis_load_two(this_subject,:)        = erp.cvsi_EMG_vis_load_two;
    
end

%% Plot

timecourse_titles = {'Load one - T1', 'Load one - T2', 'Load two'};

erp_motor = {erp_all.cvsi_motor_load_one_T1, erp_all.cvsi_motor_load_one_T2, erp_all.cvsi_motor_load_two};
erp_visual = {erp_all.cvsi_visual_load_one_T1, erp_all.cvsi_visual_load_one_T2, erp_all.cvsi_visual_load_two};
erp_EMG_mot = {erp_all.cvsi_EMG_mot_load_one_T1, erp_all.cvsi_EMG_mot_load_one_T2, erp_all.cvsi_EMG_mot_load_two};
erp_EMG_vis = {erp_all.cvsi_EMG_vis_load_one_T1, erp_all.cvsi_EMG_vis_load_one_T2, erp_all.cvsi_EMG_vis_load_two};

%% Motor

figure; sgtitle("Motor (C3/C4)")
linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(erp_all.time, erp_motor{i}, linecolors{i}, 'se');
    xline(0); xline(1); xline(3); yline(0); xlim([0.25 4]);
    title(timecourse_titles{i})
end

%% Visual

figure; sgtitle("Visual (PO7/PO8)")
linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(erp_all.time, erp_visual{i}, linecolors{i}, 'se');
    xline(0); xline(1); xline(3); yline(0); xlim([0.25 4]);
    title(timecourse_titles{i})
end

%% EMG (motor)

figure; sgtitle("EMG (L/R response)")
linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(erp_all.time, erp_EMG_mot{i}, linecolors{i}, 'se');
    xline(0); xline(1); xline(3); yline(0); xlim([0.25 4]);
    title(timecourse_titles{i})
end

%% EMG (visual)

figure; sgtitle("EMG (L/R item location)")
linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(erp_all.time, erp_EMG_vis{i}, linecolors{i}, 'se');
    xline(0); xline(1); xline(3); yline(0); xlim([0.25 4]);
    title(timecourse_titles{i})
end