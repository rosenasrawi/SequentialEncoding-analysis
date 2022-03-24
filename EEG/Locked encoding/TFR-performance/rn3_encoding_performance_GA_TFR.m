 %% Clear workspace
clc; clear; close all

%% Define parameters
subjectIDs = [1:5,7:19,21:27];
subjects = 1:25;

%% --------------------- Load all files ---------------------

for this_subject = subjects

    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    %% load 
    load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_perf_' param.subjectIDs{sub}], 'cvsi_perf');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_perf_all = selectfields(cvsi_perf,{'label', 'time', 'freq', 'dimord'});
        cvsi_perf_all.label = {'C3'};
    end   
    
    %% add to all sub structure

    % MOTOR
    
    % Fast, slow
    
    % Load 1
    cvsi_perf_all.motor_load_one_T1_fast(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T1_fast;
    cvsi_perf_all.motor_load_one_T2_fast(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T2_fast;
    cvsi_perf_all.motor_load_one_T1_slow(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T1_slow;
    cvsi_perf_all.motor_load_one_T2_slow(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T2_slow;    
    
    % Load 2
    cvsi_perf_all.motor_load_two_T1_fast(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T1_fast;
    cvsi_perf_all.motor_load_two_T2_fast(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T2_fast;
    cvsi_perf_all.motor_load_two_T1_slow(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T1_slow;
    cvsi_perf_all.motor_load_two_T2_slow(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T2_slow;
    
    % Precise, imprecise
    
    % Load 2
    cvsi_perf_all.motor_load_one_T1_prec(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T1_prec;
    cvsi_perf_all.motor_load_one_T2_prec(this_subject,:,:,:)        = cvsi_perf.motor_load_one_T2_prec;
    cvsi_perf_all.motor_load_one_T1_imprec(this_subject,:,:,:)      = cvsi_perf.motor_load_one_T1_imprec;
    cvsi_perf_all.motor_load_one_T2_imprec(this_subject,:,:,:)      = cvsi_perf.motor_load_one_T2_imprec;    
    
    % Load 2
    cvsi_perf_all.motor_load_two_T1_prec(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T1_prec;
    cvsi_perf_all.motor_load_two_T2_prec(this_subject,:,:,:)        = cvsi_perf.motor_load_two_T2_prec;
    cvsi_perf_all.motor_load_two_T1_imprec(this_subject,:,:,:)      = cvsi_perf.motor_load_two_T1_imprec;
    cvsi_perf_all.motor_load_two_T2_imprec(this_subject,:,:,:)      = cvsi_perf.motor_load_two_T2_imprec;    
    
end  

mean_cvsi_perf_all = selectfields(cvsi_perf_all,{'label', 'time', 'freq', 'dimord'});
mean_cvsi_perf_all.label = {'C3'};

% MOTOR

% Fast, slow

% Load 1
mean_cvsi_perf_all.motor_load_one_T1_fast           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T1_fast)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T2_fast           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T2_fast)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T1_slow           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T1_slow)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T2_slow           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T2_slow)), 1,38,94);

% Load 2
mean_cvsi_perf_all.motor_load_two_T1_fast           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T1_fast)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T2_fast           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T2_fast)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T1_slow           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T1_slow)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T2_slow           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T2_slow)), 1,38,94);

% Precise, imprecise

% Load 1
mean_cvsi_perf_all.motor_load_one_T1_prec           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T1_prec)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T2_prec           = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T2_prec)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T1_imprec         = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T1_imprec)), 1,38,94);
mean_cvsi_perf_all.motor_load_one_T2_imprec         = reshape(squeeze(mean(cvsi_perf_all.motor_load_one_T2_imprec)), 1,38,94);

% Load 2
mean_cvsi_perf_all.motor_load_two_T1_prec           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T1_prec)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T2_prec           = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T2_prec)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T1_imprec         = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T1_imprec)), 1,38,94);
mean_cvsi_perf_all.motor_load_two_T2_imprec         = reshape(squeeze(mean(cvsi_perf_all.motor_load_two_T2_imprec)), 1,38,94);

%% Stat parameters

load ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_perf_encoding'], 'stat_perf_encoding');

%% Define size of stat & data

masksize = size(stat_perf_encoding.motor_load_two_T1_fast.mask, 2:3);
datasize = size(mean_cvsi_perf_all.motor_load_two_T1_fast, 2:3);

% Frequency (top & bottom)

freqselection = [5 30];
freq_top = sum(mean_cvsi_perf_all.freq > freqselection(2));
freq_bot = sum(mean_cvsi_perf_all.freq < freqselection(1));

mask_top = zeros(freq_top, masksize(2));
mask_bot = zeros(freq_bot, masksize(2));

% Time (left & right)

timeselection = [0 3];
time_left = sum(mean_cvsi_perf_all.time < timeselection(1));
time_right = sum(mean_cvsi_perf_all.time > timeselection(2));

mask_left = zeros(datasize(1), time_left);
mask_right = zeros(datasize(1), time_right);

%% Add reshaped mask to structure

mean_cvsi_perf_all.mask_motor_load_two_T1_fast   = logical(reshape([mask_left, [mask_bot; squeeze(stat_perf_encoding.motor_load_two_T1_fast.mask); mask_top], mask_right], 1,38,94));

%% Save

save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_perf_all'], 'cvsi_perf_all');
save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

