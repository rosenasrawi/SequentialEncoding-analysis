%% Clear workspace
clc; clear; close all

%% Load data structures

param = rn3_gen_param(1);

load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/full_perf_all'], 'full_perf_all');
load ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_full_perf_all'], 'mean_full_perf_all');

contains(mean_full_perf_all.label, 'AFz')


%% Plot fast versus slow

fvs_contrasts = {'load_two_T1_fast_slow', 'load_two_T2_fast_slow'};
titles_fvs_contrasts = {'Load two (T1)', 'Load two (T2)'};

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

%% Plot prec versus imprec

pvi_contrasts = {'load_two_T1_prec_imprec', 'load_two_T2_prec_imprec'};
titles_pvi_contrasts = {'Load two (T1)', 'Load two (T2)'};

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
