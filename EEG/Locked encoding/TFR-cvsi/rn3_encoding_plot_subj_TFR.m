%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1:18;

%% Plot motor

figure;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_' param.subjectIDs{this_subject}], 'cvsi_encoding');
    
    %% Plot TFR motor - both dials
    
    titles_enc_contrasts = {'cvsi motor - load1-T1', 'cvsi motor - load1-T2', 'cvsi motor - load2'};
    enc_contrasts = {cvsi_encoding.cvsi_motor_load_one_T1, cvsi_encoding.cvsi_motor_load_one_T2, cvsi_encoding.cvsi_motor_load_two};
    
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim = [-20,20];
    
    this_sub_title = join(['subject ', string(this_subject)]);
    
    for contrast = 1:length(enc_contrasts)
        subplot(length(subjects), length(enc_contrasts), (this_subject-1)*length(enc_contrasts)+contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

        colormap(flipud(brewermap(100,'RdBu')));

        data2plot = squeeze(enc_contrasts{contrast}); % select data
        contourf(cvsi_encoding.time, cvsi_encoding.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
        xline(0)
        xline(1)
        xline(3)

        title([titles_enc_contrasts{contrast}, this_sub_title])

        caxis(cfg.zlim)
        colorbar
    end    
    
%     %% Plot TFR motor - up vs. right
%     
%     titles_enc_contrasts = {'cvsi motor - load1-T1 - dial up', 'cvsi motor - load1-T2 - dial up', 'cvsi motor - load2 - dial up', 'cvsi motor - load1-T1 - dial right', 'cvsi motor - load1-T2 - dial right', 'cvsi motor - load2 - dial right'};
%     enc_contrasts = {cvsi_encoding.cvsi_motor_load_one_T1_dial_up, cvsi_encoding.cvsi_motor_load_one_T2_dial_up, cvsi_encoding.cvsi_motor_load_two_dial_up, cvsi_encoding.cvsi_motor_load_one_T1_dial_right, cvsi_encoding.cvsi_motor_load_one_T2_dial_right, cvsi_encoding.cvsi_motor_load_two_dial_right};
%     
%     cfg = [];
%     cfg.colorbar = 'no';
%     cfg.zlim = [-20,20];
%     
%     this_sub_title = join(['subject ', string(this_subject)]);
%     
%     for contrast = 1:length(enc_contrasts)
%         subplot(length(subjects), length(enc_contrasts), (this_subject-1)*length(enc_contrasts)+contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)
% 
%         colormap(flipud(brewermap(100,'RdBu')));
% 
%         data2plot = squeeze(enc_contrasts{contrast}); % select data
%         contourf(cvsi_encoding.time, cvsi_encoding.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
%         xline(0)
%         xline(1)
%         xline(3)
% 
%         title([titles_enc_contrasts{contrast}, this_sub_title])
% 
%         caxis(cfg.zlim)
%         colorbar
%     end

end

%% Plot visual

figure;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_' param.subjectIDs{this_subject}], 'cvsi_encoding');

    %% Plot TFR visual - both dials
    
    titles_enc_contrasts = {'cvsi visual - load1-T1', 'cvsi visual - load1-T2', 'cvsi visual - load2'};
    enc_contrasts = {cvsi_encoding.cvsi_visual_load_one_T1, cvsi_encoding.cvsi_visual_load_one_T2, cvsi_encoding.cvsi_visual_load_two};
    
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim = [-20,20];
    
    this_sub_title = join(['subject ', string(this_subject)]);
    
    for contrast = 1:length(enc_contrasts)
        subplot(length(subjects), length(enc_contrasts), (this_subject-1)*length(enc_contrasts)+contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

        colormap(flipud(brewermap(100,'RdBu')));

        data2plot = squeeze(enc_contrasts{contrast}); % select data
        contourf(cvsi_encoding.time, cvsi_encoding.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
        xline(0)
        xline(1)
        xline(3)

        title([titles_enc_contrasts{contrast}, this_sub_title])

        caxis(cfg.zlim)
        colorbar
    end             
end   

