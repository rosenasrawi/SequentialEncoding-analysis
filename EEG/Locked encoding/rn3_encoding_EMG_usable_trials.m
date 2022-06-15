%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = [1:5,7:19,21:27];
% subjects = 1; % Try-out

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked encoding/epoched encoding/' 'epoched_encoding_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
   
    %% Load ICA
    
    load([param.path, 'Processed/EEG/Locked encoding/ICA encoding/' 'ICA_encoding_' param.subjectIDs{this_subject}], 'ica2rem','ica');

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);
    
    %% Find bad trials

    data.trialinfo(:,end+1) = 1:length(data.trial);
    trials_old = data.trialinfo(:,end);

    %% Chan selections

    cfg.keepchannel = 'yes';
    cfg.channel = {'emgLrect','emgRrect'};
 
    data = ft_rejectvisual(cfg, data);    

    %% Trials to keep

    trials_new = data.trialinfo(:,end);

    trl2keep = ismember(trials_old, trials_new);

    propkeep(this_subject) = mean(trl2keep) % how many removed?

    %% Save

    save([param.path, 'Processed/EEG/Locked encoding/usable trials encoding/' 'usable_trials_EMG_encoding_' param.subjectIDs{this_subject}], 'trl2keep');

end