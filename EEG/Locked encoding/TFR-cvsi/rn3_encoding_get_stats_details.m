%% Clean workspace

clc; clear; close all

%% Open stats file

param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_encoding'], 'stat_encoding');


%% Time-frequency clusters (2D)

squeeze(stat_encoding.motor_load_one_T1.prob(1,:,:))
squeeze(stat_encoding.motor_load_one_T2.prob(1,:,:))
squeeze(stat_encoding.motor_load_two.prob(1,:,:))

stat_encoding.motor_beta_load_one_T1.prob
stat_encoding.motor_beta_load_one_T2.prob
stat_encoding.motor_beta_load_two.prob