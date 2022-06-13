%% Clear workspace
clc; clear; close all

%% Load data structures

param = rn3_gen_param(1);

load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/full_perf_all'], 'full_perf_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_full_perf_all'], 'mean_full_perf_all');

%% Add masked contrasts by significance (t-test)

[h,~,~,~] = ttest(full_perf_all.load_two_T1_fast_slow);
mean_full_perf_all.mask_load_two_T1_fast_slow = mean_full_perf_all.load_two_T1_fast_slow .* squeeze(h);

[h,~,~,~] = ttest(full_perf_all.load_two_T2_fast_slow);
mean_full_perf_all.mask_load_two_T2_fast_slow = mean_full_perf_all.load_two_T2_fast_slow .* squeeze(h);

[h,~,~,~] = ttest(full_perf_all.load_two_T1_prec_imprec);
mean_full_perf_all.mask_load_two_T1_prec_imprec = mean_full_perf_all.load_two_T1_prec_imprec .* squeeze(h);

[h,~,~,~] = ttest(full_perf_all.load_two_T2_prec_imprec);
mean_full_perf_all.mask_load_two_T2_prec_imprec = mean_full_perf_all.load_two_T2_prec_imprec .* squeeze(h);

%% Fast versus slow

fvs_contrasts = {'load_two_T1_fast_slow', 'load_two_T2_fast_slow'};
fvs_contrasts_masked = {'mask_load_two_T1_fast_slow', 'mask_load_two_T2_fast_slow'};

titles_fvs_contrasts = {'Load two (T1)', 'Load two (T2)'};

%% TFR AFz

figure;
sgtitle('Fast versus slow (AFz)')

cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'AFz';
cfg.zlim      = 'maxabs';

for contrast = 1:length(fvs_contrasts)
    subplot(1, length(fvs_contrasts), contrast);   
    
    cfg.parameter       = fvs_contrasts{contrast};
    ft_singleplotTFR(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    xline(0); xline(1); xline(3)
    xlim([0 3]); ylim([4 31])
    
    title(titles_fvs_contrasts{contrast})
end

%% TFR AFz (masked by sign)

figure;
sgtitle('[Masked] Fast versus slow (AFz)')

cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'AFz';
cfg.zlim      = 'maxabs';

for contrast = 1:length(fvs_contrasts_masked)
    subplot(1, length(fvs_contrasts_masked), contrast);   
    
    cfg.parameter       = fvs_contrasts_masked{contrast};
    ft_singleplotTFR(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    xline(0); xline(1); xline(3)
    xlim([0 3]); ylim([4 31])
    
    title(titles_fvs_contrasts{contrast})
end

%% Topography theta-band

time_select = {[0.5 1], [1.5 2], [2.5 3]};
p = 0;

figure;

cfg = [];

cfg.layout    = 'easycapM1.mat';
cfg.zlim      = 'maxabs';
cfg.ylim      = [4 7];
cfg.comment   = 'no';
cfg.style     = 'straight';
cfg.colorbar  = 'yes';    

for contrast = 1:length(fvs_contrasts)
    cfg.parameter       = fvs_contrasts{contrast};

    for time = 1:length(time_select)
        cfg.xlim            = time_select{time};

        p = p + 1; subplot(length(fvs_contrasts), length(time_select), p)

        ft_topoplotTFR(cfg, mean_full_perf_all);
        colormap(flipud(brewermap(100,'RdBu')));
        title(titles_fvs_contrasts{contrast})
    end

end

%% Multiplot all channels

cfg = [];

cfg.figure      = "gcf";
cfg.layout      = 'easycapM1.mat';
cfg.zlim        = 'maxabs';  
cfg.showlabel   = 'yes';

for contrast = 1:length(fvs_contrasts_masked)
    figure;
    
    cfg.parameter   = fvs_contrasts_masked{contrast};

    ft_multiplotTFR_2(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    title(titles_fvs_contrasts{contrast})
end

%% Precise versus imprecise

pvi_contrasts = {'load_two_T1_prec_imprec', 'load_two_T2_prec_imprec'};
pvi_contrasts_masked = {'mask_load_two_T1_prec_imprec', 'mask_load_two_T2_prec_imprec'};

titles_pvi_contrasts = {'Load two (T1)', 'Load two (T2)'};

%% TFR AFz

figure;
sgtitle('Precise versus imprecise (AFz)')

cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'AFz';
cfg.zlim      = 'maxabs';

for contrast = 1:length(pvi_contrasts)
    subplot(1, length(pvi_contrasts), contrast);   
    
    cfg.parameter       = pvi_contrasts{contrast};
    ft_singleplotTFR(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    xline(0); xline(1); xline(3)
    xlim([0 3]); ylim([4 31])
    
    title(titles_pvi_contrasts{contrast})
end

%% TFR AFz (masked)

figure;
sgtitle('[Masked] Precise versus imprecise (AFz)')

cfg = [];

cfg.figure    = "gcf";
cfg.channel   = 'AFz';
cfg.zlim      = 'maxabs';

for contrast = 1:length(pvi_contrasts_masked)
    subplot(1, length(pvi_contrasts_masked), contrast);   
    
    cfg.parameter       = pvi_contrasts_masked{contrast};
    ft_singleplotTFR(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    xline(0); xline(1); xline(3)
    xlim([0 3]); ylim([4 31])
    
    title(titles_pvi_contrasts{contrast})
end

%% Topography theta-band

time_select = {[0.5 1], [1.5 2], [2.5 3]};
p = 0;

figure;

cfg = [];

cfg.layout    = 'easycapM1.mat';
cfg.zlim      = 'maxabs';
cfg.ylim      = [4 7];
cfg.comment   = 'no';
cfg.style     = 'straight';
cfg.colorbar  = 'yes';    

for contrast = 1:length(pvi_contrasts)
    cfg.parameter       = pvi_contrasts{contrast};

    for time = 1:length(time_select)
        cfg.xlim            = time_select{time};

        p = p + 1; subplot(length(pvi_contrasts), length(time_select), p)

        ft_topoplotTFR(cfg, mean_full_perf_all);
        colormap(flipud(brewermap(100,'RdBu')));
        title(titles_pvi_contrasts{contrast})
    end

end

%% Multiplot

cfg = [];

cfg.figure      = "gcf";
cfg.layout      = 'easycapM1.mat';
cfg.zlim        = 'maxabs';  
cfg.showlabel   = 'yes';

for contrast = 1:length(pvi_contrasts_masked)
    figure;
    
    cfg.parameter   = pvi_contrasts_masked{contrast};

    ft_multiplotTFR_2(cfg, mean_full_perf_all);
    colormap(flipud(brewermap(100,'RdBu')));  
    
    title(titles_pvi_contrasts{contrast})
end
