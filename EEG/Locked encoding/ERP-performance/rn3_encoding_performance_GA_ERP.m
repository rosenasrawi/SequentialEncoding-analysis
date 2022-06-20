%% Clear workspace

clc; clear; close all

%% Define parameters

subjectIDs = [1:5,7:19,21:27];
subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    %% load 
    load([param.path, 'Processed/EEG/Locked encoding/erp contrasts encoding/' 'erp_encoding_performance_' param.subjectIDs{sub}], 'erp');

    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        erp_all = selectfields(erp, {'label', 'time', 'dimord'});
    end
    
    %% Motor

    % FAST
    erp_all.cvsi_motor_load_one_T1_fast(this_subject,:)     = erp.cvsi_motor_load_one_T1_fast;
    erp_all.cvsi_motor_load_one_T2_fast(this_subject,:)     = erp.cvsi_motor_load_one_T2_fast;
    erp_all.cvsi_motor_load_two_T1_fast(this_subject,:)     = erp.cvsi_motor_load_two_T1_fast;
    erp_all.cvsi_motor_load_two_T2_fast(this_subject,:)     = erp.cvsi_motor_load_two_T2_fast;

    % SLOW
    erp_all.cvsi_motor_load_one_T1_slow(this_subject,:)     = erp.cvsi_motor_load_one_T1_slow;
    erp_all.cvsi_motor_load_one_T2_slow(this_subject,:)     = erp.cvsi_motor_load_one_T2_slow;
    erp_all.cvsi_motor_load_two_T1_slow(this_subject,:)     = erp.cvsi_motor_load_two_T1_slow;
    erp_all.cvsi_motor_load_two_T2_slow(this_subject,:)     = erp.cvsi_motor_load_two_T2_slow;

    % PREC
    erp_all.cvsi_motor_load_one_T1_prec(this_subject,:)     = erp.cvsi_motor_load_one_T1_prec;
    erp_all.cvsi_motor_load_one_T2_prec(this_subject,:)     = erp.cvsi_motor_load_one_T2_prec;
    erp_all.cvsi_motor_load_two_T1_prec(this_subject,:)     = erp.cvsi_motor_load_two_T1_prec;
    erp_all.cvsi_motor_load_two_T2_prec(this_subject,:)     = erp.cvsi_motor_load_two_T2_prec;

    % IMPREC
    erp_all.cvsi_motor_load_one_T1_imprec(this_subject,:)   = erp.cvsi_motor_load_one_T1_imprec;
    erp_all.cvsi_motor_load_one_T2_imprec(this_subject,:)   = erp.cvsi_motor_load_one_T2_imprec;
    erp_all.cvsi_motor_load_two_T1_imprec(this_subject,:)   = erp.cvsi_motor_load_two_T1_imprec;
    erp_all.cvsi_motor_load_two_T2_imprec(this_subject,:)   = erp.cvsi_motor_load_two_T2_imprec;

    %% Visual

    % FAST
    erp_all.cvsi_visual_load_one_T1_fast(this_subject,:)     = erp.cvsi_visual_load_one_T1_fast;
    erp_all.cvsi_visual_load_one_T2_fast(this_subject,:)     = erp.cvsi_visual_load_one_T2_fast;
    erp_all.cvsi_visual_load_two_T1_fast(this_subject,:)     = erp.cvsi_visual_load_two_T1_fast;
    erp_all.cvsi_visual_load_two_T2_fast(this_subject,:)     = erp.cvsi_visual_load_two_T2_fast;

    % SLOW
    erp_all.cvsi_visual_load_one_T1_slow(this_subject,:)     = erp.cvsi_visual_load_one_T1_slow;
    erp_all.cvsi_visual_load_one_T2_slow(this_subject,:)     = erp.cvsi_visual_load_one_T2_slow;
    erp_all.cvsi_visual_load_two_T1_slow(this_subject,:)     = erp.cvsi_visual_load_two_T1_slow;
    erp_all.cvsi_visual_load_two_T2_slow(this_subject,:)     = erp.cvsi_visual_load_two_T2_slow;

    % PREC
    erp_all.cvsi_visual_load_one_T1_prec(this_subject,:)     = erp.cvsi_visual_load_one_T1_prec;
    erp_all.cvsi_visual_load_one_T2_prec(this_subject,:)     = erp.cvsi_visual_load_one_T2_prec;
    erp_all.cvsi_visual_load_two_T1_prec(this_subject,:)     = erp.cvsi_visual_load_two_T1_prec;
    erp_all.cvsi_visual_load_two_T2_prec(this_subject,:)     = erp.cvsi_visual_load_two_T2_prec;

    % IMPREC
    erp_all.cvsi_visual_load_one_T1_imprec(this_subject,:)   = erp.cvsi_visual_load_one_T1_imprec;
    erp_all.cvsi_visual_load_one_T2_imprec(this_subject,:)   = erp.cvsi_visual_load_one_T2_imprec;
    erp_all.cvsi_visual_load_two_T1_imprec(this_subject,:)   = erp.cvsi_visual_load_two_T1_imprec;
    erp_all.cvsi_visual_load_two_T2_imprec(this_subject,:)   = erp.cvsi_visual_load_two_T2_imprec;

end

%% Plot

timecourse_titles = {'Load one - T1', 'Load one - T2', 'Load two - T1', 'Load two - T2'};
linecolors = {[80/255, 172/255, 123/255], [167/255, 216/255, 188/255]};

erp_motor_fast      = {erp_all.cvsi_motor_load_one_T1_fast, erp_all.cvsi_motor_load_one_T2_fast, erp_all.cvsi_motor_load_two_T1_fast, erp_all.cvsi_motor_load_two_T2_fast};
erp_motor_slow      = {erp_all.cvsi_motor_load_one_T1_slow, erp_all.cvsi_motor_load_one_T2_slow, erp_all.cvsi_motor_load_two_T1_slow, erp_all.cvsi_motor_load_two_T2_slow};
erp_motor_prec      = {erp_all.cvsi_motor_load_one_T1_prec, erp_all.cvsi_motor_load_one_T2_prec, erp_all.cvsi_motor_load_two_T1_prec, erp_all.cvsi_motor_load_two_T2_prec};
erp_motor_imprec    = {erp_all.cvsi_motor_load_one_T1_imprec, erp_all.cvsi_motor_load_one_T2_imprec, erp_all.cvsi_motor_load_two_T1_imprec, erp_all.cvsi_motor_load_two_T2_imprec};

erp_visual_fast     = {erp_all.cvsi_visual_load_one_T1_fast, erp_all.cvsi_visual_load_one_T2_fast, erp_all.cvsi_visual_load_two_T1_fast, erp_all.cvsi_visual_load_two_T2_fast};
erp_visual_slow     = {erp_all.cvsi_visual_load_one_T1_slow, erp_all.cvsi_visual_load_one_T2_slow, erp_all.cvsi_visual_load_two_T1_slow, erp_all.cvsi_visual_load_two_T2_slow};
erp_visual_prec     = {erp_all.cvsi_visual_load_one_T1_prec, erp_all.cvsi_visual_load_one_T2_prec, erp_all.cvsi_visual_load_two_T1_prec, erp_all.cvsi_visual_load_two_T2_prec};
erp_visual_imprec   = {erp_all.cvsi_visual_load_one_T1_imprec, erp_all.cvsi_visual_load_one_T2_imprec, erp_all.cvsi_visual_load_two_T1_imprec, erp_all.cvsi_visual_load_two_T2_imprec};

%% Motor fast vs slow

figure; sgtitle("Motor (C3/C4) - fast versus slow")

for i = 1:length(timecourse_titles)
    
    subplot(1,length(timecourse_titles),i)
    frevede_errorbarplot(erp_all.time, erp_motor_fast{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(erp_all.time, erp_motor_slow{i}, linecolors{2}, 'se');

    xline(0); xline(1); xline(3); yline(0); xlim([0.25 3]);
    title(timecourse_titles{i})

end

%% Motor precise vs imprecise

figure; sgtitle("Motor (C3/C4) - precise versus imprecise")

for i = 1:length(timecourse_titles)
    
    subplot(1,length(timecourse_titles),i)
    frevede_errorbarplot(erp_all.time, erp_motor_prec{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(erp_all.time, erp_motor_imprec{i}, linecolors{2}, 'se');

    xline(0); xline(1); xline(3); yline(0); xlim([0.25 3]);
    title(timecourse_titles{i})

end

%% Visual fast vs slow

figure; sgtitle("Visual (PO7/PO8) - fast versus slow")

for i = 1:length(timecourse_titles)
    
    subplot(1,length(timecourse_titles),i)
    frevede_errorbarplot(erp_all.time, erp_visual_fast{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(erp_all.time, erp_visual_slow{i}, linecolors{2}, 'se');

    xline(0); xline(1); xline(3); yline(0); xlim([0.25 3]);
    title(timecourse_titles{i})

end

%% Visual precise vs imprecise

figure; sgtitle("Visual (PO7/PO8) - precise versus imprecise")

for i = 1:length(timecourse_titles)
    
    subplot(1,length(timecourse_titles),i)
    frevede_errorbarplot(erp_all.time, erp_visual_prec{i}, linecolors{1}, 'se');
    hold on
    frevede_errorbarplot(erp_all.time, erp_visual_imprec{i}, linecolors{2}, 'se');

    xline(0); xline(1); xline(3); yline(0); xlim([0.25 3]);
    title(timecourse_titles{i})

end

