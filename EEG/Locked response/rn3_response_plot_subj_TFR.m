%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1:5;

%% Loop

figure;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked response/tfr contrasts response/' 'cvsi_response_' param.subjectIDs{this_subject}], 'cvsi_response');
    
    %% Plot TFR motor - up, right, both dials
    
    titles_resp_contrasts = {'cvsi motor - upper dial', 'cvsi motor - right dial', 'cvsi motor - both dials'};
    resp_contrasts = {cvsi_response.cvsi_motor_dial_up, cvsi_response.cvsi_motor_dial_right, cvsi_response.cvsi_motor_both_dials};
    
    cfg = [];
    cfg.colorbar = 'no';
    cfg.zlim = [-20,20];
    
    this_sub_title = join(['subject ', string(this_subject)]);
    
    for contrast = 1:length(resp_contrasts)
        subplot(length(subjects),length(resp_contrasts),(this_subject-1)*length(resp_contrasts)+contrast); 

        colormap(flipud(brewermap(100,'RdBu')));

        data2plot = squeeze(resp_contrasts{contrast}); % select data
        contourf(cvsi_response.time, cvsi_response.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
        xline(0)
        title([titles_resp_contrasts{contrast}, this_sub_title])

        caxis(cfg.zlim)
        colorbar
    end
        
end   



