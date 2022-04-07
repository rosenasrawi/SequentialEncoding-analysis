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

%% --------------------- MOTOR ---------------------

%% ----- TFR -----

%% Dials collapsed

titles_enc_contrasts = {'load one - T1', 'load one - T2', 'load two'};
enc_contrasts = {'cvsi_motor_load_one_T1', 'cvsi_motor_load_one_T2', 'cvsi_motor_load_two'};
enc_masks = {'mask_motor_load_one_T1', 'mask_motor_load_one_T2', 'mask_motor_load_two'};

zlims = {[-10,10], [-10,10], [-5,5]}

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

%% Dial up vs right
titles_enc_contrasts = {'cvsi motor - load1-T1 - dial up', 'cvsi motor - load1-T2 - dial up', 'cvsi motor - load2 - dial up', 'cvsi motor - load1-T1 - dial right', 'cvsi motor - load1-T2 - dial right', 'cvsi motor - load2 - dial right'};
enc_contrasts = {mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_two_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right, mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right, mean_cvsi_encoding_all.cvsi_motor_load_two_dial_right};

cfg = []; cfg.colorbar = 'no';
cfg.zlim = {[-10,10], [-10,10], [-5,5], [-10,10], [-10,10], [-5,5]};

figure;

for contrast = 1:length(enc_contrasts)
    subplot(1, length(enc_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(enc_contrasts{contrast}); % select data
    contourf(mean_cvsi_encoding_all.time, mean_cvsi_encoding_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)
    xline(1)
    xline(3)

    title(titles_enc_contrasts{contrast})

    caxis(cfg.zlim{contrast})
    colorbar
end    

%% ----- time-course -----

%% Motor 13-30 (both dials)

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
figure; %sgtitle("motor 13-30 Hz")

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_motor_beta{i}, linecolors{i}, 'se');
    
    plot(mean_cvsi_encoding_all.time, stat_motor_beta{i} * -0.3, 'k', 'LineWidth', 2);
    
    xline(0); xline(1); xline(3); yline(0)
    xlim([0 3]); ylim(ylims{i})
    title(timecourse_titles{i})

end

%% post-encoding timecourse
cvsi_motor_beta_postenc = {(cvsi_motor_beta{1}(:,T1_index) + cvsi_motor_beta{2}(:,T2_index)) / 2, cvsi_motor_beta{3}(:,T1_index)};

postenc_titles = {'load one', 'load two'};
linecolors = {[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

figure;

frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_beta_postenc{1}, linecolors{1}, 'se');
hold on 
frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_beta_postenc{2}, linecolors{2}, 'se');

xline(0); xline(1); yline(0)
xlim([0 1.2]); ylim([-5 5])

% %% post-encoding bargraph
% 
% mean_cvsi_motor_beta_postenc = [];
% 
% for contrast = 1:length(cvsi_motor_beta)
%     
%     mean_cvsi_motor_beta_postenc = [mean_cvsi_motor_beta_postenc, mean(cvsi_motor_beta{contrast}(:,T1_enc_index),2)];
%     mean_cvsi_motor_beta_postenc = [mean_cvsi_motor_beta_postenc, mean(cvsi_motor_beta{contrast}(:,T2_enc_index),2)];
%     
% end    
% mean_cvsi_motor_beta_postenc = [zeros(1,size(mean_cvsi_motor_beta_postenc,2)); mean_cvsi_motor_beta_postenc];
% header = {'load1-T1-T1', 'load1-T1-T2', 'load1-T2-T1', 'load1-T2-T2', 'load2-T1', 'load2-T2'};
% 
% writematrix(mean_cvsi_motor_beta_postenc, [param.path 'Processed/EEG/Locked encoding/timecourse average/mean_cvsi_motor_beta_postenc.csv'] ) 
% writecell(header, [param.path 'Processed/EEG/Locked encoding/timecourse average/header_mean_cvsi_motor_beta_postenc.csv'] ) 

%% ----- topography -----

mean_cvsi_encoding_all.label = complete_label;
topo_contrasts = {'rvsl_resp_load_one_T1','rvsl_resp_load_one_T2','rvsl_resp_load_two'};
time_select = {[0.5 3], [1.5 3], [0.5 1]};

figure;

cfg = [];

cfg.layout    = 'easycapM1.mat';
cfg.zlim      = 'maxabs';
cfg.ylim      = [13 30];
cfg.comment   = 'no';
cfg.style     = 'straight';
cfg.colorbar  = 'no';    

for contrast = 1:length(time_select)    
    cfg.parameter = topo_contrasts{contrast};
    cfg.xlim      = time_select{contrast};

    subplot(1,3,contrast);
    ft_topoplotTFR(cfg, mean_cvsi_encoding_all);
    colormap(flipud(brewermap(100,'RdBu')));
    
    title(titles_enc_contrasts{contrast}, 'FontSize', 14,  'FontWeight', 'normal', 'Position', [0, -1, 0]);

end

%% using time-course clusters

% Eye-balling clusters
% [cvsi_encoding_all.time;stat_motor_beta{1}]
% [cvsi_encoding_all.time;stat_motor_beta{2}]
% [cvsi_encoding_all.time;stat_motor_beta{3}]

mean_cvsi_encoding_all.label = complete_label;

topo_contrasts = {'rvsl_resp_load_one_T1','rvsl_resp_load_one_T2','rvsl_resp_load_two'};
time_select = {{[0.7 1], [2.15 3]}, {[1.5 1.7], [2.2 3]}, {[0.6 0.8], [2 3]}};
time_titles = {'post-encoding','pre-probe'};

for contrast = 1:length(topo_contrasts)  
    
    figure;
    sgtitle(titles_enc_contrasts{contrast});
    
    cfg = [];

    cfg.layout    = 'easycapM1.mat';
    cfg.zlim      = 'maxabs';
    cfg.ylim      = [13 30];
    cfg.comment   = 'no';
    cfg.style     = 'straight';
    cfg.colorbar  = 'no'; 
    cfg.parameter = topo_contrasts{contrast};
    
    for time = 1:length(time_select{1})
        cfg.xlim      = time_select{contrast}{time};

        subplot(1,2,time);
        ft_topoplotTFR(cfg, mean_cvsi_encoding_all);
        colormap(flipud(brewermap(100,'RdBu')));
    
        title(time_titles{time}, 'FontSize', 14,  'FontWeight', 'normal', 'Position', [0, -1, 0]);
    end
end



%% --------------------- Visual --------------------- 

%% ----- TFR -----

%% Dials collapsed

titles_enc_contrasts = {'cvsi visual - load1-T1', 'cvsi visual - load1-T2', 'cvsi visual - load2'};
enc_contrasts = {mean_cvsi_encoding_all.cvsi_visual_load_one_T1, mean_cvsi_encoding_all.cvsi_visual_load_one_T2, mean_cvsi_encoding_all.cvsi_visual_load_two};

if masked
    enc_contrasts_sub = {cvsi_encoding_all.cvsi_visual_load_one_T1, cvsi_encoding_all.cvsi_visual_load_one_T2, cvsi_encoding_all.cvsi_visual_load_two};
    for c = 1:length(enc_contrasts)
        enc_contrasts{c} = enc_contrasts{c} .* squeeze(ttest(enc_contrasts_sub{c}));
    end
end    

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(enc_contrasts)
    subplot(1, length(enc_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(enc_contrasts{contrast}); % select data
    contourf(mean_cvsi_encoding_all.time, mean_cvsi_encoding_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)
    xline(1)
    xline(3)

    title(titles_enc_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Dial up vs right
titles_enc_contrasts = {'cvsi visual - load1-T1 - dial up', 'cvsi visual - load1-T2 - dial up', 'cvsi visual - load2 - dial up', 'cvsi visual - load1-T1 - dial right', 'cvsi visual - load1-T2 - dial right', 'cvsi visual - load2 - dial right'};
enc_contrasts = {mean_cvsi_encoding_all.cvsi_visual_load_one_T1_dial_up, mean_cvsi_encoding_all.cvsi_visual_load_one_T2_dial_up, mean_cvsi_encoding_all.cvsi_visual_load_two_dial_up, mean_cvsi_encoding_all.cvsi_visual_load_one_T1_dial_right, mean_cvsi_encoding_all.cvsi_visual_load_one_T2_dial_right, mean_cvsi_encoding_all.cvsi_visual_load_two_dial_right};

if masked
    enc_contrasts_sub = {cvsi_encoding_all.cvsi_visual_load_one_T1_dial_up, cvsi_encoding_all.cvsi_visual_load_one_T2_dial_up, cvsi_encoding_all.cvsi_visual_load_two_dial_up, cvsi_encoding_all.cvsi_visual_load_one_T1_dial_right, cvsi_encoding_all.cvsi_visual_load_one_T2_dial_right, cvsi_encoding_all.cvsi_visual_load_two_dial_right};
    for c = 1:length(enc_contrasts)
        enc_contrasts{c} = enc_contrasts{c} .* squeeze(ttest(enc_contrasts_sub{c}));
    end
end 

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(enc_contrasts)
    subplot(1, length(enc_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(enc_contrasts{contrast}); % select data
    contourf(mean_cvsi_encoding_all.time, mean_cvsi_encoding_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)
    xline(1)
    xline(3)

    title(titles_enc_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% ----- time-course -----

%% Visual 8-12 (both dials)

cvsi_visual_alpha = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_one_T1(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_one_T2(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_visual_load_two(:,:,alpha_index,:)),2))};
linecolors = {'blue','red','black'};

figure; sgtitle("motor alpha")

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_visual_alpha{i}, linecolors{i}, 'se');
    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-20 20])
    title(timecourse_titles{i})

end
