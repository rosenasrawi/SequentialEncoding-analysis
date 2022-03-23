%% Clean workspace

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
    load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_' param.subjectIDs{sub}], 'cvsi_encoding');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_encoding_all = selectfields(cvsi_encoding,{'label', 'time', 'freq', 'dimord'});
        cvsi_encoding_all.label = {'C3'};
    end
    
    %% add to all sub structure
    cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up(this_subject,:,:,:)        = cvsi_encoding.cvsi_motor_load_one_T1_dial_up;
    cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up(this_subject,:,:,:)        = cvsi_encoding.cvsi_motor_load_one_T2_dial_up;
    cvsi_encoding_all.cvsi_motor_load_two_dial_up(this_subject,:,:,:)           = cvsi_encoding.cvsi_motor_load_two_dial_up;
    cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right(this_subject,:,:,:)     = cvsi_encoding.cvsi_motor_load_one_T1_dial_right;
    cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right(this_subject,:,:,:)     = cvsi_encoding.cvsi_motor_load_one_T2_dial_right;
    cvsi_encoding_all.cvsi_motor_load_two_dial_right(this_subject,:,:,:)        = cvsi_encoding.cvsi_motor_load_two_dial_right;
    cvsi_encoding_all.cvsi_motor_load_one_T1(this_subject,:,:,:)                = cvsi_encoding.cvsi_motor_load_one_T1;
    cvsi_encoding_all.cvsi_motor_load_one_T2(this_subject,:,:,:)                = cvsi_encoding.cvsi_motor_load_one_T2;
    cvsi_encoding_all.cvsi_motor_load_two(this_subject,:,:,:)                   = cvsi_encoding.cvsi_motor_load_two;
    
    cvsi_encoding_all.cvsi_visual_load_one_T1_dial_up(this_subject,:,:,:)       = cvsi_encoding.cvsi_visual_load_one_T1_dial_up;
    cvsi_encoding_all.cvsi_visual_load_one_T2_dial_up(this_subject,:,:,:)       = cvsi_encoding.cvsi_visual_load_one_T2_dial_up;
    cvsi_encoding_all.cvsi_visual_load_two_dial_up(this_subject,:,:,:)          = cvsi_encoding.cvsi_visual_load_two_dial_up;
    cvsi_encoding_all.cvsi_visual_load_one_T1_dial_right(this_subject,:,:,:)    = cvsi_encoding.cvsi_visual_load_one_T1_dial_right;
    cvsi_encoding_all.cvsi_visual_load_one_T2_dial_right(this_subject,:,:,:)    = cvsi_encoding.cvsi_visual_load_one_T2_dial_right;
    cvsi_encoding_all.cvsi_visual_load_two_dial_right(this_subject,:,:,:)       = cvsi_encoding.cvsi_visual_load_two_dial_right;
    cvsi_encoding_all.cvsi_visual_load_one_T1(this_subject,:,:,:)               = cvsi_encoding.cvsi_visual_load_one_T1;
    cvsi_encoding_all.cvsi_visual_load_one_T2(this_subject,:,:,:)               = cvsi_encoding.cvsi_visual_load_one_T2;
    cvsi_encoding_all.cvsi_visual_load_two(this_subject,:,:,:)                  = cvsi_encoding.cvsi_visual_load_two;

end  
    
%% Average

mean_cvsi_encoding_all = selectfields(cvsi_encoding_all,{'label', 'time', 'freq', 'dimord'});
mean_cvsi_encoding_all.label = {'C3'};

mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up        = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up        = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_two_dial_up           = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_two_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right     = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right     = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_two_dial_right        = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_two_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_one_T1                = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T1)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_one_T2                = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_one_T2)), 1,38,94);
mean_cvsi_encoding_all.cvsi_motor_load_two                   = reshape(squeeze(mean(cvsi_encoding_all.cvsi_motor_load_two)), 1,38,94);

mean_cvsi_encoding_all.cvsi_visual_load_one_T1_dial_up       = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T1_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_one_T2_dial_up       = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T2_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_two_dial_up          = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_two_dial_up)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_one_T1_dial_right    = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T1_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_one_T2_dial_right    = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T2_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_two_dial_right       = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_two_dial_right)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_one_T1               = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T1)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_one_T2               = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_one_T2)), 1,38,94);
mean_cvsi_encoding_all.cvsi_visual_load_two                  = reshape(squeeze(mean(cvsi_encoding_all.cvsi_visual_load_two)), 1,38,94);

%% Stat parameters

load ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_encoding'], 'stat_encoding');

%% Define size of stat & data

masksize = size(stat_encoding.motor_load_two.mask, 2:3);
datasize = size(mean_cvsi_encoding_all.cvsi_motor_load_two, 2:3);

% Frequency (top & bottom)

freqselection = [5 30];
freq_top = sum(mean_cvsi_encoding_all.freq > freqselection(2));
freq_bot = sum(mean_cvsi_encoding_all.freq < freqselection(1));

mask_top = zeros(freq_top, masksize(2));
mask_bot = zeros(freq_bot, masksize(2));

% Time (left & right)

timeselection = [0 3];
time_left = sum(mean_cvsi_encoding_all.time < timeselection(1));
time_right = sum(mean_cvsi_encoding_all.time > timeselection(2));

mask_left = zeros(datasize(1), time_left);
mask_right = zeros(datasize(1), time_right);

%% Add reshaped mask to structure

mean_cvsi_encoding_all.mask_motor_load_one_T1   = logical(reshape([mask_left, [mask_bot; squeeze(stat_encoding.motor_load_one_T1.mask); mask_top], mask_right], 1,38,94));
mean_cvsi_encoding_all.mask_motor_load_one_T2   = logical(reshape([mask_left, [mask_bot; squeeze(stat_encoding.motor_load_one_T2.mask); mask_top], mask_right], 1,38,94));
mean_cvsi_encoding_all.mask_motor_load_two      = logical(reshape([mask_left, [mask_bot; squeeze(stat_encoding.motor_load_two.mask); mask_top], mask_right], 1,38,94));

%% Save

save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_encoding_all'], 'cvsi_encoding_all');
save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_encoding_all'], 'mean_cvsi_encoding_all');
