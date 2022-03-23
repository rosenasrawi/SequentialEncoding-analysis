%% Clear workspace
clc; clear; close all

%% Load data structures
param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_encoding_all'], 'cvsi_encoding_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_encoding_all'], 'mean_cvsi_encoding_all');

%% Load stat
load ([param.path, '/Processed/EEG/Locked encoding/tfr stats encoding/stat_encoding'], 'stat_encoding');

%% TFR plot settings
masked = true;

%% --------------------- Plot TFR motor ---------------------

%% both dials

titles_enc_contrasts = {'cvsi motor - load1-T1', 'cvsi motor - load1-T2', 'cvsi motor - load2'};
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
    
    
    title(titles_enc_contrasts{contrast})
end

%% up vs right
titles_enc_contrasts = {'cvsi motor - load1-T1 - dial up', 'cvsi motor - load1-T2 - dial up', 'cvsi motor - load2 - dial up', 'cvsi motor - load1-T1 - dial right', 'cvsi motor - load1-T2 - dial right', 'cvsi motor - load2 - dial right'};
enc_contrasts = {mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_two_dial_up, mean_cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right, mean_cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right, mean_cvsi_encoding_all.cvsi_motor_load_two_dial_right};

if masked
    enc_contrasts_sub = {cvsi_encoding_all.cvsi_motor_load_one_T1_dial_up, cvsi_encoding_all.cvsi_motor_load_one_T2_dial_up, cvsi_encoding_all.cvsi_motor_load_two_dial_up, cvsi_encoding_all.cvsi_motor_load_one_T1_dial_right, cvsi_encoding_all.cvsi_motor_load_one_T2_dial_right, cvsi_encoding_all.cvsi_motor_load_two_dial_right};
    for c = 1:length(enc_contrasts)
        enc_contrasts{c} = enc_contrasts{c} .* squeeze(ttest(enc_contrasts_sub{c}));
    end
end   

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

%% --------------------- Plot TFR visual --------------------- 

%% both dials
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

%% up vs right
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

%% --------------------- Time-courses ---------------------


%% Time-frames
T1_index        = cvsi_encoding_all.time >= param.T1(1) & cvsi_encoding_all.time <= param.T1(2);
T2_index        = cvsi_encoding_all.time >= param.T2(1) & cvsi_encoding_all.time <= param.T2(2);

T1_enc_index    = cvsi_encoding_all.time >= param.T1_enc(1) & cvsi_encoding_all.time <= param.T1_enc(2);
T2_enc_index    = cvsi_encoding_all.time >= param.T2_enc(1) & cvsi_encoding_all.time <= param.T2_enc(2);

%% General params

beta_index              = cvsi_encoding_all.freq >= param.betaband(1) & cvsi_encoding_all.freq <= param.betaband(2);
alpha_index             = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.alphaband(2);
alpha_mu_beta_index     = cvsi_encoding_all.freq >= param.alphaband(1) & cvsi_encoding_all.freq <= param.betaband(2);

timecourse_titles = {'load one - T1', 'load one - T2', 'load two'};

%% ----------- Motor 13-30 - both dials -----------

%% stat mask
stat_motor_beta = {double(stat_encoding.motor_beta_load_one_T1.mask), double(stat_encoding.motor_beta_load_one_T2.mask), double(stat_encoding.motor_beta_load_two.mask)};

for i = 1:length(stat_motor_beta)
    x = stat_motor_beta{i};
    x(x==0) = nan;
    stat_motor_beta{i} = x;
end

%% full time
cvsi_motor_beta = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,beta_index,:)),2))};

linecolors = {'black','black','black'};
ylims = {[-10,10],[-10,10],[-5,5]};
figure; sgtitle("motor 13-30 Hz")

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_motor_beta{i}, linecolors{i}, 'se');
    
    plot(mean_cvsi_encoding_all.time, stat_motor_beta{i} * -0.3, 'k', 'LineWidth', 2);
    
    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim(ylims{i})
    title(timecourse_titles{i})

end

%% post-encoding timecourse
cvsi_motor_beta_postenc = {cvsi_motor_beta{1}(:,T1_index), cvsi_motor_beta{2}(:,T1_index), cvsi_motor_beta{3}(:,T1_index)};

postenc_titles = {'load one-T1', 'load one-T2', 'load two'};
linecolors = {'blue','red', 'black'};

figure; sgtitle("motor 13-30 Hz: encoding response")

frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_beta_postenc{1}, linecolors{1}, 'se');
hold on 
frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_beta_postenc{2}, linecolors{2}, 'se');
frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_beta_postenc{3}, linecolors{3}, 'se');

xline(0); xline(1); xline(3); yline(0)
xlim([-0.5 2]); ylim([-5 5])

%% post-encoding bargraph

mean_cvsi_motor_beta_postenc = [];

for contrast = 1:length(cvsi_motor_beta)
    
    mean_cvsi_motor_beta_postenc = [mean_cvsi_motor_beta_postenc, mean(cvsi_motor_beta{contrast}(:,T1_enc_index),2)];
    mean_cvsi_motor_beta_postenc = [mean_cvsi_motor_beta_postenc, mean(cvsi_motor_beta{contrast}(:,T2_enc_index),2)];
    
end    
mean_cvsi_motor_beta_postenc = [zeros(1,size(mean_cvsi_motor_beta_postenc,2)); mean_cvsi_motor_beta_postenc];
header = {'load1-T1-T1', 'load1-T1-T2', 'load1-T2-T1', 'load1-T2-T2', 'load2-T1', 'load2-T2'};

writematrix(mean_cvsi_motor_beta_postenc, [param.path 'Processed/EEG/Locked encoding/timecourse average/mean_cvsi_motor_beta_postenc.csv'] ) 
writecell(header, [param.path 'Processed/EEG/Locked encoding/timecourse average/header_mean_cvsi_motor_beta_postenc.csv'] ) 
%%
% ---------- Continue in R ----------


%% ----------- Motor 8-12 - both dials -----------

%% stat mask
stat_motor_alpha = {double(stat_encoding.motor_alpha_load_one_T1.mask), double(stat_encoding.motor_alpha_load_one_T2.mask), double(stat_encoding.motor_alpha_load_two.mask)};

for i = 1:length(stat_motor_alpha)
    x = stat_motor_alpha{i};
    x(x==0) = nan;
    stat_motor_alpha{i} = x;
end

%% full time
cvsi_motor_alpha = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,alpha_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,alpha_index,:)),2))};
linecolors = {'blue','red','black'};

figure; sgtitle("motor 8-12 Hz")

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_motor_alpha{i}, linecolors{i}, 'se');
    plot(mean_cvsi_encoding_all.time, stat_motor_alpha{i} * -0.3, 'k', 'LineWidth', 2);

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-10 10])
    title(timecourse_titles{i})

end

%% post-encoding response
cvsi_motor_alpha_postenc = {cvsi_motor_alpha{1}(:,T1_index), cvsi_motor_alpha{3}(:,T1_index)};

postenc_titles = {'load one', 'load two'};
linecolors = {'blue','red'};

figure; sgtitle("motor 8-12 Hz: encoding response")

frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_alpha_postenc{1}, linecolors{1}, 'se');
hold on 
frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_alpha_postenc{2}, linecolors{2}, 'se');
xline(0); xline(1); xline(3); yline(0)
xlim([-0.5 2]); ylim([-7 7])

%% ----------- Motor 8-30 - both dials -----------

%% stat mask
stat_motor_alpha_mu_beta = {double(stat_encoding.motor_alpha_mu_beta_load_one_T1.mask), double(stat_encoding.motor_alpha_mu_beta_load_one_T2.mask), double(stat_encoding.motor_alpha_mu_beta_load_two.mask)};

for i = 1:length(stat_motor_alpha_mu_beta)
    x = stat_motor_alpha_mu_beta{i};
    x(x==0) = nan;
    stat_motor_alpha_mu_beta{i} = x;
end

%% full time
cvsi_motor_alpha_mu_beta = {squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T1(:,:,alpha_mu_beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_one_T2(:,:,alpha_mu_beta_index,:)),2)), squeeze(mean(squeeze(cvsi_encoding_all.cvsi_motor_load_two(:,:,alpha_mu_beta_index,:)),2))};
linecolors = {'blue','red','black'};

figure; sgtitle("motor 8-30 Hz")

for i = 1:length(timecourse_titles)
    
    subplot(1,3,i)
    frevede_errorbarplot(mean_cvsi_encoding_all.time, cvsi_motor_alpha_mu_beta{i}, linecolors{i}, 'se');
    plot(mean_cvsi_encoding_all.time, stat_motor_alpha_mu_beta{i} * -0.3, 'k', 'LineWidth', 2);

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-10 10])
    title(timecourse_titles{i})

end

%% post-encoding response
cvsi_motor_alpha_mu_beta_postenc = {cvsi_motor_alpha_mu_beta{1}(:,T1_index), cvsi_motor_alpha_mu_beta{3}(:,T1_index)};

postenc_titles = {'load one', 'load two'};
linecolors = {'blue','red'};

figure; sgtitle("motor 8-30 Hz: encoding response")

frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_alpha_mu_beta_postenc{1}, linecolors{1}, 'se');
hold on 
frevede_errorbarplot(mean_cvsi_encoding_all.time(T1_index), cvsi_motor_alpha_mu_beta_postenc{2}, linecolors{2}, 'se');
xline(0); xline(1); xline(3); yline(0)
xlim([-0.5 2]); ylim([-5 5])

%% ----------- Visual 8-12 - both dials -----------

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
