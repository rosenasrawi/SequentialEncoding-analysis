%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 13:20;

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked response/epoched response/' 'epoched_response_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
   
    %% run fast ICA and check eog component detectability (+ topography check)

    cfg = [];
    cfg.keeptrials = 'yes';
    cfg.channel = {'EEG'};
    
    d_eeg = ft_timelockanalysis(cfg, data);
    
    %% ica
    cfg = [];
    cfg.method = 'fastica';
    ica = ft_componentanalysis(cfg, d_eeg);

%     %% look at components
%     cfg           = [];
%     cfg.component = 1:63;
%     cfg.layout    = 'biosemi64.lay';
%     cfg.comment   = 'no';
%     figure; ft_topoplotIC(cfg, ica)
%     colormap('jet')

    %% correlate ica timecourses with measured eog

    cfg = [];
    cfg.keeptrials = 'yes';
    d_ica = ft_timelockanalysis(cfg, ica);
    
    cfg.channel = {'eog'};
    d_eog = ft_timelockanalysis(cfg, data);

    %% Plot (visual inspection of components)
    y = [];

    x = d_eog.trial(:,1,:); % eog
    for c = 1:size(d_ica.trial,2)
        y = d_ica.trial(:,c,:); % components
        correlations(c) = corr(y(:), x(:));
    end

    figure; 
    bar(1:c, abs(correlations),'r'); title('correlations with component timecourses');   
    xlabel('comp #');

    %% Find the max abs cor

    find(abs(correlations) > 0.2)
    ica2rem = input('bad components are [__,__,__]: ');
    
    %% Save
    
    save([param.path, 'Processed/EEG/Locked response/ICA response/' 'ICA_response_' param.subjectIDs{this_subject}], 'ica2rem','ica');

end