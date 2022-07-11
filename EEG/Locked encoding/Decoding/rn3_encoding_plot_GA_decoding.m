%% Clear workspace

clc; clear; close all

%% Define parameters

subjectIDs = [1:5,7:15];
subjects = 1:14;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    load([param.path, 'Processed/EEG/Locked encoding/decoding/' 'decoding_' param.subjectIDs{sub}], 'decoding');

    decoding_all.motor_correct_one_T1(this_subject,:)       = squeeze(mean(decoding.motor_correct_one_T1));
    decoding_all.motor_correct_one_T2(this_subject,:)       = squeeze(mean(decoding.motor_correct_one_T2));
    decoding_all.motor_correct_two(this_subject,:)          = squeeze(mean(decoding.motor_correct_two));

    decoding_all.motor_distance_one_T1(this_subject,:)      = squeeze(mean(decoding.motor_distance_one_T1));
    decoding_all.motor_distance_one_T2(this_subject,:)      = squeeze(mean(decoding.motor_distance_one_T2));
    decoding_all.motor_distance_two(this_subject,:)         = squeeze(mean(decoding.motor_distance_two));

    decoding_all.visual_correct_one_T1(this_subject,:)      = squeeze(mean(decoding.visual_correct_one_T1));
    decoding_all.visual_correct_one_T2(this_subject,:)      = squeeze(mean(decoding.visual_correct_one_T2));
    decoding_all.visual_correct_two(this_subject,:)         = squeeze(mean(decoding.visual_correct_two));

    decoding_all.visual_distance_one_T1(this_subject,:)     = squeeze(mean(decoding.visual_distance_one_T1));
    decoding_all.visual_distance_one_T2(this_subject,:)     = squeeze(mean(decoding.visual_distance_one_T2));
    decoding_all.visual_distance_two(this_subject,:)        = squeeze(mean(decoding.visual_distance_two));

end

%% Load time param (temporary)

load([param.path, 'Processed/EEG/Locked encoding/decoding/' 'time_all'], 'time');
% time = time{1}*1000;

%% Plot variables
decoding_titles = {'Load one - T1', 'Load one - T2', 'Load two'};

motor_correct   = {decoding_all.motor_correct_one_T1, decoding_all.motor_correct_one_T2, decoding_all.motor_correct_two};
motor_distance  = {decoding_all.motor_distance_one_T1, decoding_all.motor_distance_one_T2, decoding_all.motor_distance_two}; 

visual_correct   = {decoding_all.visual_correct_one_T1, decoding_all.visual_correct_one_T2, decoding_all.motor_correct_two};
visual_distance  = {decoding_all.visual_distance_one_T1, decoding_all.visual_distance_one_T2, decoding_all.motor_distance_two}; 

linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

%% Plot motor

figure;
sgtitle('Motor selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    frevede_errorbarplot(time, motor_correct{i}, linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .7]); xlim([0 3500]); 

end

%% Plot visual

figure;
sgtitle('Visual selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    frevede_errorbarplot(time, visual_correct{i}, linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .6]); xlim([0 3500]); 

end
