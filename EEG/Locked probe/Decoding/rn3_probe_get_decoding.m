%% Clear workspace

clc; clear; close all

%% Analysis settings

laplacian = true;

%% Define parameters

subjects = 1:5;

%% Loop

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked probe/epoched probe/' 'epoched_probe_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
   
    %% Load ICA
    
    load([param.path, 'Processed/EEG/Locked probe/ICA probe/' 'ICA_probe_' param.subjectIDs{this_subject}], 'ica2rem','ica');

    %% Load usable trials

    load([param.path, 'Processed/EEG/Locked probe/usable trials probe/' 'usable_trials_probe_' param.subjectIDs{this_subject}], 'trl2keep');
    
    %% Keep channels of interest

    cfg = [];
    cfg.latency = [-.1 1]; % just keep -100 to +1000 ms -- makes it a bit faster below.
    cfg.channel = {'EEG'};

    data = ft_preprocessing(cfg, data);

    %% Remove bad trials
    
    cfg = [];
    cfg.trials = trl2keep;

    data = ft_selectdata(cfg, data);
    
    clear trl2keep;

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);
    
    clear ica;
    
    %% baseline correction (just like in the ERP & EMG scripts)

    cfg = [];
    cfg.demean = 'yes';
    cfg.baselinewindow = [-.25 0]; % e.g., 250 ms pre-probe baseline window
    
    data = ft_preprocessing(cfg, data);

    %% Separate trial types
    
    % Left & right required response 
    trials_reqresp_left     = ismember(tfr.trialinfo(:,1), param.triggers_reqresp_left);
    trials_reqresp_right    = ismember(tfr.trialinfo(:,1), param.triggers_reqresp_right);

    % Target location
    trials_item_left        = ismember(tfr.trialinfo(:,1), param.triggers_item_left);
    trials_item_right       = ismember(tfr.trialinfo(:,1), param.triggers_item_right);
    
    % Load types
    trials_load_one         = ismember(tfr.trialinfo(:,1), param.triggers_load1);
    trials_load_two         = ismember(tfr.trialinfo(:,1), param.triggers_load2);
    
    % Dial types
    trials_dial_up          = ismember(tfr.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right       = ismember(tfr.trialinfo(:,1), param.triggers_dial_right);
        

    %% Select data

    % separate predictable and unpredictable into two separate time-lock-analysis structures
    trials_pred = ismember(data.trialinfo(:,1), trig_pred); % note: only consider triggers for WM trials.
    trials_unpred = ismember(data.trialinfo(:,1), trig_unpred);

    cfg = [];
    
    cfg.trials = trials_pred;
    cfg.keeptrials = 'yes';
    data_pred = ft_timelockanalysis(cfg, data); % put all trials into a single matrix

    cfg.trials = trials_unpred;
    cfg.keeptrials = 'yes'; 
    data_unpred = ft_timelockanalysis(cfg, data); % put all trials into a single matrix
            