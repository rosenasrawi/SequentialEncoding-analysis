%% Clear workspace
clc; clear; close all

%% Load data structures
param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_encoding_all'], 'cvsi_encoding_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_encoding_all'], 'mean_cvsi_encoding_all');

%% Load stat
load ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_encoding'], 'stat_encoding');

%% Time-frames
T1_index        = cvsi_encoding_all.time >= param.T1(1) & cvsi_encoding_all.time <= param.T1(2);
T2_index        = cvsi_encoding_all.time >= param.T2(1) & cvsi_encoding_all.time <= param.T2(2);

T1_enc_index    = cvsi_encoding_all.time >= param.T1_enc(1) & cvsi_encoding_all.time <= param.T1_enc(2);
T2_enc_index    = cvsi_encoding_all.time >= param.T2_enc(1) & cvsi_encoding_all.time <= param.T2_enc(2);

%% General params
beta_index              = cvsi_encoding_all.freq >= 13 & cvsi_encoding_all.freq <= 30;
alpha_index             = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.alphaband(2);
alpha_mu_beta_index     = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.betaband(2);

timecourse_titles = {'load one - T1', 'load one - T2', 'load two'};

%% Electrode selections

% Complete
load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_encoding_s01'], 'cvsi_encoding');
complete_label = cvsi_encoding.label;

% C3
C3_label = mean_cvsi_encoding_all.label;

%% TFR

%% Motor

titles_enc_contrasts = {'load one - T1', 'load one - T2', 'load two'};
enc_contrasts = {'cvsi_motor_load_one_T1', 'cvsi_motor_load_one_T2', 'cvsi_motor_load_two'};
enc_masks = {'mask_motor_load_one_T1', 'mask_motor_load_one_T2', 'mask_motor_load_two'};

zlims = {[-10,10], [-10,10], [-5,5]};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.maskstyle = 'outline';

for contrast = 1:length(enc_contrasts)
    subplot(1, length(enc_contrasts), contrast);   
    
    cfg.parameter       = enc_contrasts{contrast};
    cfg.maskparameter   = enc_masks{contrast};
    cfg.zlim            = zlims{contrast};
    
    ft_singleplotTFR(cfg, mean_cvsi_encoding_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    xlim([0 3]); ylim([4 31])
    title(titles_enc_contrasts{contrast})
end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1500 300]);

%% Save fig

saveas(gcf, [param.figpath 'TFR-cvsi/TFR-motor'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/TFR-motor'], 'png');

%% Visual

titles_enc_contrasts = {'load one - T1', 'load one - T2', 'load two'};
enc_contrasts = {'cvsi_visual_load_one_T1', 'cvsi_visual_load_one_T2', 'cvsi_visual_load_two'};
enc_masks = {'mask_visual_load_one_T1', 'mask_visual_load_one_T2', 'mask_visual_load_two'};

zlims = {[-15,15], [-15,15], [-15,15]};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.maskstyle = 'outline';

for contrast = 1:length(enc_contrasts)
    subplot(1, length(enc_contrasts), contrast);   
    
    cfg.parameter       = enc_contrasts{contrast};
    cfg.maskparameter   = enc_masks{contrast};
    cfg.zlim            = zlims{contrast};
    
    ft_singleplotTFR(cfg, mean_cvsi_encoding_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    xlim([0 3]); ylim([4 31])
    title(titles_enc_contrasts{contrast})
end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1500 300]);

%% Save fig

saveas(gcf, [param.figpath 'TFR-cvsi/TFR-visual'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/TFR-visual'], 'png');

%% Time-courses

%% Motor (13-30Hz)

%% stat mask
stat_motor_beta = {double(stat_encoding.motor_beta_load_one_T1.mask), double(stat_encoding.motor_beta_load_one_T2.mask), double(stat_encoding.motor_beta_load_two.mask)};

for i = 1:length(stat_motor_beta)
    x = stat_motor_beta{i};
    x(x==0) = nan;
    stat_motor_beta{i} = x;
end

%% full time
cvsi_motor_beta = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,beta_index,:)),2))};

linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};
ylims = {[-10,10],[-10,10],[-5,5]};
figure;

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_motor_beta{i}, linecolors{i}, 'se');
    
    plot(mean_cvsi_encoding_all.time, stat_motor_beta{i} * -0.3, 'k', 'LineWidth', 2);
    
    xline(0); xline(1); xline(3); yline(0)
    xlim([0 3]); ylim(ylims{i})
    title(timecourse_titles{i})

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1500 300]);

%% Save fig

saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-motor'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-motor'], 'png');

%% Visual (8-12Hz)

%% stat mask
stat_visual_alpha = {double(stat_encoding.visual_alpha_load_one_T1.mask), double(stat_encoding.visual_alpha_load_one_T2.mask), double(stat_encoding.visual_alpha_load_two.mask)};

for i = 1:length(stat_visual_alpha)
    x = stat_visual_alpha{i};
    x(x==0) = nan;
    stat_visual_alpha{i} = x;
end

%% full time
cvsi_visual_alpha = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_one_T1(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_one_T2(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_two(:,:,alpha_index,:)),2))};

linecolors = {[140/255, 69/255, 172/255],[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};
ylims = {[-20,20],[-20,20],[-20,20]};
figure;

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_visual_alpha{i}, linecolors{i}, 'se');
    
    plot(mean_cvsi_encoding_all.time, stat_visual_alpha{i} * -1, 'k', 'LineWidth', 2);
    
    xline(0); xline(1); xline(3); yline(0)
    xlim([0 3]); ylim(ylims{i})
    title(timecourse_titles{i})

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1500 300]);

%% Save fig

saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-visual'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-visual'], 'png');

%% Topography

mean_cvsi_encoding_all.label = complete_label;

%% Motor

topo_contrasts = {'rvsl_resp_load_one_T1', 'rvsl_resp_load_one_T1', 'rvsl_resp_load_one_T2', 'rvsl_resp_load_one_T2', 'rvsl_resp_load_two'};
time_select = {[0.7 1], [2.15 3], [1.5 1.7], [2.2 3], [0.6 0.8]}; % Time-course cluster timings
load = {'one-t1-enc', 'one-t1-prep', 'one-t2-enc', 'one-t2-prep', 'two-t1'};

figure;

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1250 250]);

for contrast = 1:length(topo_contrasts)  
   
    subplot(1,5,contrast)
    title(load{contrast});
    
    cfg = [];

    cfg.layout    = 'easycapM1.mat';
    cfg.zlim      = 'maxabs';
    cfg.ylim      = [13 30];
    cfg.xlim      = time_select{contrast};

    cfg.comment   = 'no';
    cfg.style     = 'straight';
    cfg.colorbar  = 'no'; 
    cfg.parameter = topo_contrasts{contrast};
    
    ft_topoplotTFR(cfg, mean_cvsi_encoding_all);
    colormap(flipud(brewermap(100,'RdBu')));

end

%% Save

saveas(gcf, [param.figpath 'TFR-cvsi/new/topo-motor'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/new/topo-motor'], 'png');

%% Visual

topo_contrasts = {'rvsl_item_load_one_T1','rvsl_item_load_one_T2','rvsl_item_load_two', 'rvsl_item_load_two'};
time_select = {[0.35 1.05], [1.35 2.3], [0.35 1.05], [1.35 2.45]}; % Time-course cluster timings
load = {'one-t1', 'one-t1', 'two-t1', 'two-t2'};

figure;

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1000 250]);

for contrast = 1:length(topo_contrasts)  
    
    subplot(1,4,contrast);

    title(load{contrast});
    
    cfg = [];

    cfg.layout    = 'easycapM1.mat';
    cfg.zlim      = 'maxabs';
    cfg.ylim      = [8 12];
    cfg.xlim      = time_select{contrast};

    cfg.comment   = 'no';
    cfg.style     = 'straight';
    cfg.colorbar  = 'no'; 
    cfg.parameter = topo_contrasts{contrast};

    ft_topoplotTFR(cfg, mean_cvsi_encoding_all);
    colormap(flipud(brewermap(100,'RdBu')));

end

%% Save

saveas(gcf, [param.figpath 'TFR-cvsi/new/topo-visual'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/new/topo-visual'], 'png');
