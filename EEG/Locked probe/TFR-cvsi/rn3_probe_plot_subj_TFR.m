%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1:12;

%% Plot motor

figure;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked probe/tfr contrasts probe/' 'cvsi_probe_' param.subjectIDs{this_subject}], 'cvsi_probe');
    
    %% Plot TFR motor - up, right, both dials
    
    titles_probe_contrasts = {'cvsi motor - load1 - dial up', 'cvsi motor - load2 - dial up', 'cvsi motor - load1 - dial right', 'cvsi motor - load2 - dial right','cvsi motor - load1', 'cvsi motor - load2'};
    probe_contrasts = {cvsi_probe.cvsi_motor_load_one_dial_up, cvsi_probe.cvsi_motor_load_two_dial_up, cvsi_probe.cvsi_motor_load_one_dial_right, cvsi_probe.cvsi_motor_load_two_dial_right, cvsi_probe.cvsi_motor_load_one, cvsi_probe.cvsi_motor_load_two};
    
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim = [-20,20];
    
    this_sub_title = join(['subject ', string(this_subject)]);
    
    for contrast = 1:length(probe_contrasts)
        subplot(length(subjects), length(probe_contrasts), (this_subject-1)*length(probe_contrasts)+contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

        colormap(flipud(brewermap(100,'RdBu')));

        data2plot = squeeze(probe_contrasts{contrast}); % select data
        contourf(cvsi_probe.time, cvsi_probe.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
        xline(0)

        title([titles_probe_contrasts{contrast}, this_sub_title])

        caxis(cfg.zlim)
        colorbar
    end

end

%% Plot visual

figure;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked probe/tfr contrasts probe/' 'cvsi_probe_' param.subjectIDs{this_subject}], 'cvsi_probe');
    
    %% Plot TFR visual - both dials
    
    titles_probe_contrasts = {'cvsi visual - load1 - dial up', 'cvsi visual - load2 - dial up', 'cvsi visual - load1 - dial right', 'cvsi visual - load2 - dial right','cvsi visual - load1', 'cvsi visual - load2'};
    probe_contrasts = {cvsi_probe.cvsi_visual_load_one_dial_up, cvsi_probe.cvsi_visual_load_two_dial_up, cvsi_probe.cvsi_visual_load_one_dial_right, cvsi_probe.cvsi_visual_load_two_dial_right, cvsi_probe.cvsi_visual_load_one, cvsi_probe.cvsi_visual_load_two};
    
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim = [-20,20];
    
    this_sub_title = join(['subject ', string(this_subject)]);
    
    for contrast = 1:length(probe_contrasts)
        subplot(length(subjects), length(probe_contrasts), (this_subject-1)*length(probe_contrasts)+contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

        colormap(flipud(brewermap(100,'RdBu')));

        data2plot = squeeze(probe_contrasts{contrast}); % select data
        contourf(cvsi_probe.time, cvsi_probe.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
        xline(0)

        title([titles_probe_contrasts{contrast}, this_sub_title])

        caxis(cfg.zlim)
        colorbar
    end    
            
end   

