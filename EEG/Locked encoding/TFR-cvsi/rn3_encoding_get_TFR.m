%% Clear workspace

clc; clear; close all

%% Analysis settings

laplacian = true;

%% Define parameters

subjects = [1:5,7:19,21:27];

%% Loop

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Combined logfile
    log = readtable(param.combinedLogfile);
    
    this_sub_logindex = find(contains(log.subjectID, param.subjectIDs{this_subject}));
    remove_RT = log.goodBadTrials(this_sub_logindex);
    good_RT = contains(remove_RT, 'TRUE');
    
    if this_subject == 14
        good_RT = good_RT([1:384,405:end]);
    end
    
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked encoding/epoched encoding/' 'epoched_encoding_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
    
    %% Load ICA
    
    load([param.path, 'Processed/EEG/Locked encoding/ICA encoding/' 'ICA_encoding_' param.subjectIDs{this_subject}], 'ica2rem','ica');

    %% Load usable trials
 
    load([param.path, 'Processed/EEG/Locked encoding/usable trials encoding/' 'usable_trials_encoding_' param.subjectIDs{this_subject}], 'trl2keep');
    
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
    
    % Left & right required response 
    trials_reqresp_left     = ismember(tfr.trialinfo(:,1), param.triggers_reqresp_left);
    trials_reqresp_right    = ismember(tfr.trialinfo(:,1), param.triggers_reqresp_right);

    % Target location
    trials_item_left        = ismember(tfr.trialinfo(:,1), param.triggers_item_left);
    trials_item_right       = ismember(tfr.trialinfo(:,1), param.triggers_item_right);
    
    % Load types
    trials_load_one         = ismember(tfr.trialinfo(:,1), param.triggers_load1);
    trials_load_two         = ismember(tfr.trialinfo(:,1), param.triggers_load2);
    
    % Target moment
    trials_target_T1        = ismember(tfr.trialinfo(:,1), param.triggers_target_T1);
    trials_target_T2        = ismember(tfr.trialinfo(:,1), param.triggers_target_T2);
    
    % Dial types
    trials_dial_up          = ismember(tfr.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right       = ismember(tfr.trialinfo(:,1), param.triggers_dial_right);
    
    %% Combined motor  
    
    % ---- Dial up
    
    % - Load one & T1    
    trials_load_one_target_T1_reqresp_left_dial_up      = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_dial_up;
    trials_load_one_target_T1_reqresp_right_dial_up     = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_dial_up;
    
    % - Load one & T2
    trials_load_one_target_T2_reqresp_left_dial_up      = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_dial_up;
    trials_load_one_target_T2_reqresp_right_dial_up     = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_dial_up;    
    
    % - Load two 
    trials_load_two_target_T1_reqresp_left_dial_up      = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_dial_up | trials_load_two & trials_target_T2 & trials_reqresp_right & trials_dial_up;
    trials_load_two_target_T1_reqresp_right_dial_up     = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_dial_up | trials_load_two & trials_target_T2 & trials_reqresp_left & trials_dial_up;
    
    % ---- Dial right
    
    % - Load one & T1    
    trials_load_one_target_T1_reqresp_left_dial_right   = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_dial_right;
    trials_load_one_target_T1_reqresp_right_dial_right  = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_dial_right;
    
    % - Load one & T2
    trials_load_one_target_T2_reqresp_left_dial_right   = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_dial_right;
    trials_load_one_target_T2_reqresp_right_dial_right  = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_dial_right;    
    
    % - Load two 
    trials_load_two_target_T1_reqresp_left_dial_right   = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_dial_right | trials_load_two & trials_target_T2 & trials_reqresp_left & trials_dial_right;
    trials_load_two_target_T1_reqresp_right_dial_right  = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_dial_right | trials_load_two & trials_target_T2 & trials_reqresp_right & trials_dial_right;
    
    % ---- Both dials
    
    % - Load one & T1    
    trials_load_one_target_T1_reqresp_left      = trials_load_one_target_T1_reqresp_left_dial_up | trials_load_one_target_T1_reqresp_left_dial_right;
    trials_load_one_target_T1_reqresp_right     = trials_load_one_target_T1_reqresp_right_dial_up | trials_load_one_target_T1_reqresp_right_dial_right;
    
    % - Load one & T2
    trials_load_one_target_T2_reqresp_left      = trials_load_one_target_T2_reqresp_left_dial_up | trials_load_one_target_T2_reqresp_left_dial_right;
    trials_load_one_target_T2_reqresp_right     = trials_load_one_target_T2_reqresp_right_dial_up | trials_load_one_target_T2_reqresp_right_dial_right;   
    
    % - Load two 
    trials_load_two_target_T1_reqresp_left      = trials_load_two_target_T1_reqresp_left_dial_up | trials_load_two_target_T1_reqresp_left_dial_right;
    trials_load_two_target_T1_reqresp_right     = trials_load_two_target_T1_reqresp_right_dial_up | trials_load_two_target_T1_reqresp_right_dial_right;

    %% Combined visual     

    % ---- Both dials
    
    % - Load one & T1    
    trials_load_one_target_T1_item_left      = trials_load_one & trials_target_T1 & trials_item_left;
    trials_load_one_target_T1_item_right     = trials_load_one & trials_target_T1 & trials_item_right;
    
    % - Load one & T2
    trials_load_one_target_T2_item_left      = trials_load_one & trials_target_T2 & trials_item_left;
    trials_load_one_target_T2_item_right     = trials_load_one & trials_target_T2 & trials_item_right;    
    
    % - Load two 
    trials_load_two_target_T1_item_left      = trials_load_two & trials_target_T1 & trials_item_left | trials_load_two & trials_target_T2 & trials_item_right;
    trials_load_two_target_T1_item_right     = trials_load_two & trials_target_T1 & trials_item_right | trials_load_two & trials_target_T2 & trials_item_left;
    
    % ---- Dial up
    
    % - Load one & T1    
    trials_load_one_target_T1_item_left_dial_up      = trials_load_one_target_T1_item_left & trials_dial_up;
    trials_load_one_target_T1_item_right_dial_up     = trials_load_one_target_T1_item_right & trials_dial_up;
    
    % - Load one & T2
    trials_load_one_target_T2_item_left_dial_up      = trials_load_one_target_T2_item_left & trials_dial_up;
    trials_load_one_target_T2_item_right_dial_up     = trials_load_one_target_T2_item_right & trials_dial_up;    
    
    % - Load two 
    trials_load_two_target_T1_item_left_dial_up      = trials_load_two_target_T1_item_left & trials_dial_up;
    trials_load_two_target_T1_item_right_dial_up     = trials_load_two_target_T1_item_right & trials_dial_up;
    
    % ---- Dial right
    
    % - Load one & T1    
    trials_load_one_target_T1_item_left_dial_right      = trials_load_one_target_T1_item_left & trials_dial_right;
    trials_load_one_target_T1_item_right_dial_right     = trials_load_one_target_T1_item_right & trials_dial_right;
    
    % - Load one & T2
    trials_load_one_target_T2_item_left_dial_right      = trials_load_one_target_T2_item_left & trials_dial_right;
    trials_load_one_target_T2_item_right_dial_right     = trials_load_one_target_T2_item_right & trials_dial_right;    
    
    % - Load two 
    trials_load_two_target_T1_item_left_dial_right      = trials_load_two_target_T1_item_left & trials_dial_right;
    trials_load_two_target_T1_item_right_dial_right     = trials_load_two_target_T1_item_right & trials_dial_right;        
    
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);
    
    % Visual
    chan_visual_left    = match_str(tfr.label, param.PO7);
    chan_visual_right   = match_str(tfr.label, param.PO8);
     
    %% Contra vs ipsi motor
    
    % ---- Both dials

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T1(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T2(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two(1,:,:) = (cvsi_left + cvsi_right) ./ 2;        
    
    % ---- Dial up

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T1_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T2_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    

    % ---- Dial Right

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T1_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_T2_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    

    %% Contra vs ipsi visual
    
    % ---- Both dials

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_item_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_item_left, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_item_left, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_item_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T1(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_item_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_item_left, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_item_left, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_item_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T2(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_item_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_item_left, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_item_left, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_item_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % ---- Dial up

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_item_right_dial_up, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_item_left_dial_up, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_item_left_dial_up, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_item_right_dial_up, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T1_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_item_right_dial_up, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_item_left_dial_up, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_item_left_dial_up, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_item_right_dial_up, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T2_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_item_right_dial_up, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_item_left_dial_up, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_item_left_dial_up, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_item_right_dial_up, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;       

    % ---- Dial right

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T1_item_right_dial_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T1_item_left_dial_right, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T1_item_left_dial_right, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T1_item_right_dial_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T1_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_target_T2_item_right_dial_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_target_T2_item_left_dial_right, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_target_T2_item_left_dial_right, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_target_T2_item_right_dial_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_T2_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_target_T1_item_right_dial_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_target_T1_item_left_dial_right, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_target_T1_item_left_dial_right, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_target_T1_item_right_dial_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;       
    
    %% Right vs left response (topography)

    % -- Load one & T1
    
    a = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left, :, :, :)); % left
    rvsl_resp_load_one_T1 = squeeze(((a-b) ./ (a+b)) * 100);

    % -- Load one & T2
    
    a = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left, :, :, :)); % left
    rvsl_resp_load_one_T2 = squeeze(((a-b) ./ (a+b)) * 100);
    
    % -- Load two
    
    a = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left, :, :, :)); % left
    rvsl_resp_load_two = squeeze(((a-b) ./ (a+b)) * 100);
    
    %% Right vs left item location (topography)
    
    % -- Load one & T1
    
    a = mean(tfr.powspctrm(trials_load_one_target_T1_item_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_one_target_T1_item_left, :, :, :)); % left
    rvsl_item_load_one_T1 = squeeze(((a-b) ./ (a+b)) * 100);

    % -- Load one & T2
    
    a = mean(tfr.powspctrm(trials_load_one_target_T2_item_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_one_target_T2_item_left, :, :, :)); % left
    rvsl_item_load_one_T2 = squeeze(((a-b) ./ (a+b)) * 100);
    
    % -- Load two
    
    a = mean(tfr.powspctrm(trials_load_two_target_T1_item_right, :, :, :)); % right
    b = mean(tfr.powspctrm(trials_load_two_target_T1_item_left, :, :, :)); % left
    rvsl_item_load_two = squeeze(((a-b) ./ (a+b)) * 100);
        
    %% Contrast parameters in structure

    cvsi_encoding = [];
    
    cvsi_encoding.label = tfr.label;
    cvsi_encoding.time = tfr.time;
    cvsi_encoding.freq = tfr.freq;
    cvsi_encoding.dimord = 'chan_freq_time';
    
    % Motor
    
    % --- Both dials
    cvsi_encoding.cvsi_motor_load_one_T1              = cvsi_motor_load_one_T1;
    cvsi_encoding.cvsi_motor_load_one_T2              = cvsi_motor_load_one_T2;
    cvsi_encoding.cvsi_motor_load_two                 = cvsi_motor_load_two;    
    
    % - right vs left (topo)
    cvsi_encoding.rvsl_resp_load_one_T1               = rvsl_resp_load_one_T1;
    cvsi_encoding.rvsl_resp_load_one_T2               = rvsl_resp_load_one_T2;
    cvsi_encoding.rvsl_resp_load_two                  = rvsl_resp_load_two;
    
    % --- Dial up
    cvsi_encoding.cvsi_motor_load_one_T1_dial_up      = cvsi_motor_load_one_T1_dial_up;
    cvsi_encoding.cvsi_motor_load_one_T2_dial_up      = cvsi_motor_load_one_T2_dial_up;
    cvsi_encoding.cvsi_motor_load_two_dial_up         = cvsi_motor_load_two_dial_up;
    
    % --- Dial right
    cvsi_encoding.cvsi_motor_load_one_T1_dial_right   = cvsi_motor_load_one_T1_dial_right;
    cvsi_encoding.cvsi_motor_load_one_T2_dial_right   = cvsi_motor_load_one_T2_dial_right;
    cvsi_encoding.cvsi_motor_load_two_dial_right      = cvsi_motor_load_two_dial_right;
    
    % Visual

    % --- Both dials
    cvsi_encoding.cvsi_visual_load_one_T1             = cvsi_visual_load_one_T1;
    cvsi_encoding.cvsi_visual_load_one_T2             = cvsi_visual_load_one_T2;
    cvsi_encoding.cvsi_visual_load_two                = cvsi_visual_load_two;  
    
    % - right vs left (topo)
    cvsi_encoding.rvsl_item_load_one_T1               = rvsl_item_load_one_T1;
    cvsi_encoding.rvsl_item_load_one_T2               = rvsl_item_load_one_T2;
    cvsi_encoding.rvsl_item_load_two                  = rvsl_item_load_two;
    
    % --- Dial up
    cvsi_encoding.cvsi_visual_load_one_T1_dial_up     = cvsi_visual_load_one_T1_dial_up;
    cvsi_encoding.cvsi_visual_load_one_T2_dial_up     = cvsi_visual_load_one_T2_dial_up;
    cvsi_encoding.cvsi_visual_load_two_dial_up        = cvsi_visual_load_two_dial_up;
    
    % --- Dial right
    cvsi_encoding.cvsi_visual_load_one_T1_dial_right  = cvsi_visual_load_one_T1_dial_right;
    cvsi_encoding.cvsi_visual_load_one_T2_dial_right  = cvsi_visual_load_one_T2_dial_right;
    cvsi_encoding.cvsi_visual_load_two_dial_right     = cvsi_visual_load_two_dial_right;
 
    %% Save 
    
    save([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_' param.subjectIDs{this_subject}], 'cvsi_encoding');
    
end    