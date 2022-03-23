%% Clear workspace

clc; clear; close all

%% Analysis settings

laplacian = true;

%% Define parameters

subjects = 6:12;

%%
for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);

    %% Combined logfile
    log = readtable(param.combinedLogfile);
    
    this_sub_logindex = find(contains(log.subjectID, param.subjectIDs{this_subject}));
    remove_RT = log.goodBadTrials(this_sub_logindex);
    good_RT = contains(remove_RT, 'TRUE');
    
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked response/epoched response/' 'epoched_response_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
   
    %% Load ICA
    
    load([param.path, 'Processed/EEG/Locked response/ICA response/' 'ICA_response_' param.subjectIDs{this_subject}], 'ica2rem','ica');

    %% Load usable trials

    load([param.path, 'Processed/EEG/Locked response/usable trials response/' 'usable_trials_response_' param.subjectIDs{this_subject}], 'trl2keep');
    
    %% Keep channels of interest

    cfg = [];
    cfg.channel = {'EEG'};

    data = ft_preprocessing(cfg, data);

    %% Remove bad trials
    
    cfg = [];
    cfg.trials = trl2keep & good_RT;

    data = ft_selectdata(cfg, data);
    
    clear trl2keep;

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);
    
    clear ica;

    %% Surface laplacian if specified

    % compare with & without

    if laplacian
        cfg = [];
        cfg.elec = ft_read_sens('standard_1020.elc');

        data = ft_scalpcurrentdensity(cfg, data);
    end
    
    %% Get time-frequency response
    taperstyle = 'hanning'; 
    windowsize = 0.3;

    cfg = [];

    cfg.method = 'mtmconvol';
    cfg.keeptrials = 'yes';
    cfg.taper = taperstyle;
    cfg.foi = 3:1:40; % frequency's of interest
    cfg.pad = 10; % 
    cfg.toi = data.time{1}(1) + (windowsize / 2) : .05 : data.time{1}(end) - (windowsize / 2); % steps of 50 ms always. 
    cfg.t_ftimwin = ones(1,length(cfg.foi)) * windowsize;

    tfr = ft_freqanalysis(cfg, data);

    clear data;
    
    %% Separate trial types
    
    % Left & right resp
    trials_resp_left    = ismember(tfr.trialinfo(:,1), param.triggers_resp_left);
    trials_resp_right   = ismember(tfr.trialinfo(:,1), param.triggers_resp_right);

    % Dial types
    trials_dial_up      = ismember(tfr.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right   = ismember(tfr.trialinfo(:,1), param.triggers_dial_right);
    
    %% Combined
    
    trials_resp_left_dial_up        = trials_resp_left & trials_dial_up;
    trials_resp_right_dial_up       = trials_resp_right & trials_dial_up;
    
    trials_resp_left_dial_right     = trials_resp_left & trials_dial_right;
    trials_resp_right_dial_right    = trials_resp_right & trials_dial_right;
    
    trials_resp_left                = trials_resp_left_dial_up | trials_resp_left_dial_right;
    trials_resp_right               = trials_resp_right_dial_up | trials_resp_right_dial_right;
    
    %% Channels
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);
    
    %% Contrasts
    
    % ---- Both dials
        
    % Left channels
    a = mean(tfr.powspctrm(trials_resp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_resp_left, chan_motor_left, :, :)); % ipsi
    cvsi_right = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_resp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_resp_right, chan_motor_right, :, :)); % ipsi
    cvsi_left = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_both_dials(1,:,:) = (cvsi_right + cvsi_left) ./ 2;    
    
    % ---- Dial up
        
    % Left channels
    a = mean(tfr.powspctrm(trials_resp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_resp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_right = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_resp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_resp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_left = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_dial_up(1,:,:) = (cvsi_right + cvsi_left) ./ 2;
    
    % ---- Dial right
    
    % Left channels
    a = mean(tfr.powspctrm(trials_resp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_resp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_right = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_resp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_resp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_left = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_dial_right(1,:,:) = (cvsi_right + cvsi_left) ./ 2;

    
    %% Contrast parameters in structure

    cvsi_response = [];
    
    cvsi_response.label = tfr.label;
    cvsi_response.time = tfr.time;
    cvsi_response.freq = tfr.freq;
    cvsi_response.dimord = 'chan_freq_time';
    
    cvsi_response.cvsi_motor_dial_up      = cvsi_motor_dial_up;
    cvsi_response.cvsi_motor_dial_right   = cvsi_motor_dial_right;
    cvsi_response.cvsi_motor_both_dials   = cvsi_motor_both_dials;
    
    %% Save 
    
    save([param.path, 'Processed/EEG/Locked response/tfr contrasts response/' 'cvsi_response_' param.subjectIDs{this_subject}], 'cvsi_response');
    
end    