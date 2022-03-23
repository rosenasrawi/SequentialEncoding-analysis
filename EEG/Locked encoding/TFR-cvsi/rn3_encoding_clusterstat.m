%% Clean workspace

clc; clear; close all

%% Load data structures

param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_encoding_all'], 'cvsi_encoding_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_encoding_all'], 'mean_cvsi_encoding_all');

%% Define structure for statistics (1D)

statcfg = [];

statcfg.xax = cvsi_encoding_all.time;
statcfg.npermutations = 10000;
statcfg.clusterStatEvalaluationAlpha = 0.05;
statcfg.nsub = size(cvsi_encoding_all.cvsi_motor_load_one_T1, 1);
statcfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

%% Beta response 

beta_index                              = cvsi_encoding_all.freq >= param.betaband(1) & cvsi_encoding_all.freq <= param.betaband(2);
cvsi_motor_beta                         = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,beta_index,:)),2))};
data_zero                               = zeros(size(cvsi_motor_beta{1}));

% Run stats (1D)

stat_encoding.motor_beta_load_one_T1    = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{1}, data_zero);
stat_encoding.motor_beta_load_one_T2    = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{2}, data_zero);
stat_encoding.motor_beta_load_two       = frevede_ftclusterstat1D(statcfg, cvsi_motor_beta{3}, data_zero);

%% Alpha response

alpha_index                             = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.alphaband(2);
cvsi_motor_alpha                        = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,alpha_index,:)),2))};

% Run stats (1D)

stat_encoding.motor_alpha_load_one_T1   = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha{1}, data_zero);
stat_encoding.motor_alpha_load_one_T2   = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha{2}, data_zero);
stat_encoding.motor_alpha_load_two      = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha{3}, data_zero);

%% Alpha-mu-beta response

alpha_mu_beta_index                             = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.betaband(2);
cvsi_motor_alpha_mu_beta                        = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,alpha_mu_beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,alpha_mu_beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,alpha_mu_beta_index,:)),2))};

% Run stats (1D)

stat_encoding.motor_alpha_mu_beta_load_one_T1   = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha_mu_beta{1}, data_zero);
stat_encoding.motor_alpha_mu_beta_load_one_T2   = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha_mu_beta{2}, data_zero);
stat_encoding.motor_alpha_mu_beta_load_two      = frevede_ftclusterstat1D(statcfg, cvsi_motor_alpha_mu_beta{3}, data_zero);

%% Define structure for statistics (2D)

time_index = cvsi_encoding_all.time >= 0 & cvsi_encoding_all.time <= 3;
freq_index = cvsi_encoding_all.freq >= 5 & cvsi_encoding_all.freq <= 30;

statcfg = [];

statcfg.xax = cvsi_encoding_all.time(time_index);
statcfg.yax = cvsi_encoding_all.freq(freq_index);
statcfg.npermutations = 10000; % usually use 10.000 (but less for testing)
statcfg.clusterStatEvalaluationAlpha = 0.025;
statcfg.statMethod = 'montecarlo';  % statcfg.statMethod = 'analytic';

%% TFR response

cvsi_motor                        = {squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,freq_index,time_index)), squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,freq_index,time_index)), squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,freq_index,time_index))};
data_zero                         = zeros(size(cvsi_motor{1}));

% Run stats (2D)

stat_encoding.motor_load_one_T1   = frevede_ftclusterstat2D(statcfg, cvsi_motor{1}, data_zero);
stat_encoding.motor_load_one_T2   = frevede_ftclusterstat2D(statcfg, cvsi_motor{2}, data_zero);
stat_encoding.motor_load_two      = frevede_ftclusterstat2D(statcfg, cvsi_motor{3}, data_zero);

%% Save

save ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_encoding'], 'stat_encoding');
