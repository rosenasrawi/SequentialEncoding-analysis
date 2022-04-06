%% Clear workspace
clc; clear; close all

%% Load
param = rn3_gen_param(1);
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/cvsi_perf_all'], 'cvsi_perf_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_perf_all'], 'mean_cvsi_perf_all');

%% Load 2 cluster mask

load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_cvsi_encoding_all'], 'mean_cvsi_encoding_all');

clust_freq_index = sum(squeeze(mean_cvsi_encoding_all.mask_motor_load_two),2) > 0;
clust_time_index = sum(squeeze(mean_cvsi_encoding_all.mask_motor_load_two),1) > 0;

%% Time-frames
T1_index = mean_cvsi_perf_all.time >= param.T1(1) & mean_cvsi_perf_all.time <= param.T1(2);
T2_index = mean_cvsi_perf_all.time >= param.T2(1) & mean_cvsi_perf_all.time <= param.T2(2);
T1_enc_index    = mean_cvsi_perf_all.time >= param.T1_enc(1) & mean_cvsi_perf_all.time <= param.T1_enc(2);

%% General params
beta_index              = cvsi_perf_all.freq >= param.betaband(1) & cvsi_perf_all.freq <= param.betaband(2);
alpha_index             = cvsi_perf_all.freq >= param.alphaband(1) & cvsi_perf_all.freq <= param.alphaband(2);

titles_perf_contrasts = {'load two - T1', 'load two - T2'};
titles_perf_contrasts_L1 = {'load one - T1', 'load one - T2'};

%% --------------------- Fast versus slow ---------------------

%% ----------- Plot TFR - MOTOR -----------

%% fast
main_title = 'cvsi motor fast';
perf_contrasts = {'motor_load_two_T1_fast', 'motor_load_two_T2_fast'};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim = [-7,7];
cfg.maskstyle = 'outline';

sgtitle(main_title)

for contrast = 1:length(perf_contrasts)
    subplot(1, length(perf_contrasts), contrast);   
    
    cfg.parameter       = perf_contrasts{contrast};
    
    if contrast == 1
        cfg.maskparameter = 'mask_motor_load_two_T1_fast';
    else
        cfg.maskparameter = '';
    end    
    
    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    title(titles_perf_contrasts{contrast})
end

%% slow
main_title = 'cvsi motor slow';
perf_contrasts = {'motor_load_two_T1_slow', 'motor_load_two_T2_slow'};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim = [-7,7];

sgtitle(main_title)

for contrast = 1:length(perf_contrasts)
    subplot(1, length(perf_contrasts), contrast);   
    
    cfg.parameter       = perf_contrasts{contrast};
    
    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    title(titles_perf_contrasts{contrast})
end


%% ----------- Time-courses -----------

%% Motor beta (from cluster)

%% Fast, slow; Load 1

cvsi_motor_beta_fast    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T1_fast(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T2_fast(:,:,clust_freq_index,:)),2))};
cvsi_motor_beta_slow    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T1_slow(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T2_slow(:,:,clust_freq_index,:)),2))};

figure; sgtitle("motor beta: fast v slow")

for i = 1:length(titles_perf_contrasts_L1)

    subplot(1,2,i)
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_fast{i}, [140/255, 69/255, 172/255], 'se');
    hold on;
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_slow{i}, [80/255, 172/255, 123/255], 'se');

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-12 12])
    title(titles_perf_contrasts_L1{i})

end


%% Fast, slow; Load 2

cvsi_motor_beta_fast    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_fast(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_fast(:,:,clust_freq_index,:)),2))};
cvsi_motor_beta_slow    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_slow(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_slow(:,:,clust_freq_index,:)),2))};

figure; sgtitle("motor beta: fast v slow")

for i = 1:length(titles_perf_contrasts)

    subplot(1,2,i)
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_fast{i}, [140/255, 69/255, 172/255], 'se');
    hold on;
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_slow{i}, [80/255, 172/255, 123/255], 'se');

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-7 7])
    title(titles_perf_contrasts{i})

end

%% Fast, slow; Load 2; post-encoding bargraph

mean_cvsi_motor_beta_perf_postenc = [];

cvsi_motor_beta = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_fast(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_fast(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_slow(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_slow(:,:,clust_freq_index,:)),2))};

for contrast = 1:length(cvsi_motor_beta)
    mean_cvsi_motor_beta_perf_postenc = [mean_cvsi_motor_beta_perf_postenc, mean(cvsi_motor_beta{contrast}(:,clust_time_index),2)];    
end    

mean_cvsi_motor_beta_perf_postenc = [zeros(1,size(mean_cvsi_motor_beta_perf_postenc,2)); mean_cvsi_motor_beta_perf_postenc];
header_perf = {'load2-T1-fast', 'load2-T2-fast', 'load2-T1-slow', 'load2-T2-slow'};

%% Save as .csv

writematrix(mean_cvsi_motor_beta_perf_postenc, [param.path 'Processed/EEG/Locked encoding/timecourse average/mean_cvsi_motor_beta_perf_postenc.csv'] ) 
writecell(header_perf, [param.path 'Processed/EEG/Locked encoding/timecourse average/header_mean_cvsi_motor_beta_perf_postenc.csv'] ) 


%% --------------------- Precise versus imprecise ---------------------

%% ----------- Plot TFR - MOTOR -----------

%% precise
main_title = 'cvsi motor precise';
perf_contrasts = {'motor_load_two_T1_prec', 'motor_load_two_T2_imprec'};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim = [-7,7];

sgtitle(main_title)

for contrast = 1:length(perf_contrasts)
    subplot(1, length(perf_contrasts), contrast);   
    
    cfg.parameter       = perf_contrasts{contrast};
    
    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    title(titles_perf_contrasts{contrast})
end

%% imprecise
main_title = 'cvsi motor imprecise';
perf_contrasts = {'motor_load_two_T1_imprec', 'motor_load_two_T2_imprec'};

figure;
cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'C3';
cfg.colorbar  = 'no';
cfg.zlim = [-7,7];

sgtitle(main_title)

for contrast = 1:length(perf_contrasts)
    subplot(1, length(perf_contrasts), contrast);   
    
    cfg.parameter       = perf_contrasts{contrast};
    
    ft_singleplotTFR(cfg, mean_cvsi_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    xline(0); xline(1); xline(3)
    
    title(titles_perf_contrasts{contrast})
end

%% ----------- Time-courses -----------

%% Motor beta (from cluster)

%% prec, imprec; Load 1

cvsi_motor_beta_prec    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T1_prec(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T2_prec(:,:,clust_freq_index,:)),2))};
cvsi_motor_beta_imprec  = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T1_imprec(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_one_T2_imprec(:,:,clust_freq_index,:)),2))};

figure; sgtitle("motor beta: prec v imprec")

for i = 1:length(titles_perf_contrasts)

    subplot(1,2,i)
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_prec{i}, [140/255, 69/255, 172/255], 'se');
    hold on;
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_imprec{i}, [80/255, 172/255, 123/255], 'se');

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-7 7])
    title(titles_perf_contrasts{i})

end

%% prec, imprec; Load 2

cvsi_motor_beta_prec    = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_prec(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_prec(:,:,clust_freq_index,:)),2))};
cvsi_motor_beta_imprec  = {squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T1_imprec(:,:,clust_freq_index,:)),2)), squeeze(mean(squeeze(cvsi_perf_all.motor_load_two_T2_imprec(:,:,clust_freq_index,:)),2))};

figure; sgtitle("motor beta: prec v imprec")

for i = 1:length(titles_perf_contrasts)

    subplot(1,2,i)
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_prec{i}, [140/255, 69/255, 172/255], 'se');
    hold on;
    frevede_errorbarplot(mean_cvsi_perf_all.time, cvsi_motor_beta_imprec{i}, [80/255, 172/255, 123/255], 'se');

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3.5]); ylim([-7 7])
    title(titles_perf_contrasts{i})

end

