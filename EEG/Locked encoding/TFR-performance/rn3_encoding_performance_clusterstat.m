%% Clear workspace
clc; clear; close all

%% Load
param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_perf_all'], 'cvsi_perf_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

%% Selections

time_index = cvsi_perf_all.time >= 0 & cvsi_perf_all.time <= 3;
freq_index = cvsi_perf_all.freq >= 5 & cvsi_perf_all.freq <= 30;
beta_index = cvsi_perf_all.freq >= param.betaband(1) & cvsi_perf_all.freq <= param.betaband(2);

%% Define structure for statistics (1D)

statcfg = [];

statcfg.xax = cvsi_perf_all.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = size(cvsi_perf_all.motor_load_two_T1_fast, 1);
statcfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

%% Beta response 
cvsi_motor_beta  = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_fast(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_fast(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_slow(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_slow(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_fast_slow(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_fast_slow(:,:,beta_index,:)),2))};
data_zero        = zeros(size(cvsi_motor_beta{1}));

stat_perf_encoding.motor_beta_load_two_T1_fast          = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{1}, data_zero);
stat_perf_encoding.motor_beta_load_two_T2_fast          = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{2}, data_zero);
stat_perf_encoding.motor_beta_load_two_T1_slow          = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{3}, data_zero);
stat_perf_encoding.motor_beta_load_two_T2_slow          = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{4}, data_zero);
stat_perf_encoding.motor_beta_load_two_T1_fast_slow     = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{5}, data_zero);
stat_perf_encoding.motor_beta_load_two_T2_fast_slow     = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{6}, data_zero);

%% Define structure for statistics (2D)

statcfg = [];

statcfg.xax = cvsi_perf_all.time(time_index);
statcfg.yax = cvsi_perf_all.freq(freq_index);
statcfg.npermutations = 10000; % usually use 10.000 (but less for testing)
statcfg.clusterStatEvalaluationAlpha = 0.025;
statcfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

%% TFR response

cvsi_motor = {squeeze(cvsi_perf_all.motor_load_two_T1_fast(:,:,freq_index,time_index)), squeeze(cvsi_perf_all.motor_load_two_T2_fast(:,:,freq_index,time_index)), squeeze(cvsi_perf_all.motor_load_two_T1_slow(:,:,freq_index,time_index)), squeeze(cvsi_perf_all.motor_load_two_T2_slow(:,:,freq_index,time_index)), squeeze(cvsi_perf_all.motor_load_two_T1_fast_slow(:,:,freq_index,time_index)), squeeze(cvsi_perf_all.motor_load_two_T2_fast_slow(:,:,freq_index,time_index))};
data_zero  = zeros(size(cvsi_motor{1}));

stat_perf_encoding.motor_load_two_T1_fast       = frevede_ftclusterstat2D(statcfg, cvsi_motor{1}, data_zero);
stat_perf_encoding.motor_load_two_T2_fast       = frevede_ftclusterstat2D(statcfg, cvsi_motor{2}, data_zero);
stat_perf_encoding.motor_load_two_T1_slow       = frevede_ftclusterstat2D(statcfg, cvsi_motor{3}, data_zero);
stat_perf_encoding.motor_load_two_T2_slow       = frevede_ftclusterstat2D(statcfg, cvsi_motor{4}, data_zero);
stat_perf_encoding.motor_load_two_T1_fast_slow  = frevede_ftclusterstat2D(statcfg, cvsi_motor{5}, data_zero);
stat_perf_encoding.motor_load_two_T2_fast_slow  = frevede_ftclusterstat2D(statcfg, cvsi_motor{6}, data_zero);

%% Save

save ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_perf_encoding'], 'stat_perf_encoding');


