%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = [7:19,21:27];
% subjects = 3:5;% Try-out

%% Loop over subjects

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Combined logfile
    
    log = readtable(param.combinedLogfile);
    
    this_sub_logindex = find(contains(log.subjectID, param.subjectIDs{this_subject}));
    this_sub_log = log(this_sub_logindex,:);
    
    if this_subject == 14
        this_sub_log = this_sub_log([1:384,405:end],:);
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

    %% Trials with RT in range
       
    good_RT = contains(this_sub_log.goodBadTrials, 'TRUE');
    
    good_trials = trl2keep & good_RT;
        
    %% Remove bad trials
    
    cfg = [];
    cfg.trials = good_trials;

    data = ft_selectdata(cfg, data);

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);

    %% Surface laplacian

    cfg = [];
    cfg.elec = ft_read_sens('standard_1020.elc'); % Does not read the EMG electrodes!!

    data = ft_scalpcurrentdensity(cfg, data);
    
    %% Baseline correction

    cfg = []; 
    cfg.demean = 'yes';
    cfg.baselinewindow = [-.25 0];

    data = ft_preprocessing(cfg, data);    
        
    %% Get ERP

    cfg = [];
    cfg.keeptrials = 'yes';

    tl = ft_timelockanalysis(cfg, data);

    %% Separate trial types
    
    % Dial types
    trials_dial_up          = ismember(tl.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right       = ismember(tl.trialinfo(:,1), param.triggers_dial_right);
    
    % Target tilt
    trials_tilt_left        = ismember(tl.trialinfo(:,1), param.triggers_reqresp_left);
    trials_tilt_right       = ismember(tl.trialinfo(:,1), param.triggers_reqresp_right);

    % Required response 
    trials_reqresp_left     = trials_tilt_left & trials_dial_up | trials_tilt_right & trials_dial_right;
    trials_reqresp_right    = trials_tilt_right & trials_dial_up | trials_tilt_left & trials_dial_right;

    % Target location
    trials_item_left        = ismember(tl.trialinfo(:,1), param.triggers_item_left);
    trials_item_right       = ismember(tl.trialinfo(:,1), param.triggers_item_right);
    
    % Load types
    trials_load_one         = ismember(tl.trialinfo(:,1), param.triggers_load1);
    trials_load_two         = ismember(tl.trialinfo(:,1), param.triggers_load2);
    
    % Target moment
    trials_target_T1        = ismember(tl.trialinfo(:,1), param.triggers_target_T1);
    trials_target_T2        = ismember(tl.trialinfo(:,1), param.triggers_target_T2);
    
    %% Trial performance

    % Fast versus slow
    trials_fast             = contains(this_sub_log.fastSlow, 'fast');
    trials_fast             = trials_fast(good_trials);
    trials_slow             = contains(this_sub_log.fastSlow, 'slow');
    trials_slow             = trials_slow(good_trials);
        
    % Precise versus imprecise
    trials_prec             = contains(this_sub_log.precImprec, 'prec');
    trials_prec             = trials_prec(good_trials);
    trials_imprec           = contains(this_sub_log.precImprec, 'imprec');
    trials_imprec           = trials_imprec(good_trials);

    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tl.label, param.C3);
    chan_motor_right    = match_str(tl.label, param.C4);
    
    % Visual
    chan_visual_left    = match_str(tl.label, param.PO7);
    chan_visual_right   = match_str(tl.label, param.PO8);

    %% Combined trial types

    %% Motor (response L/R)

    % FAST

    % - Load one & T1    
    trials_load_one_T1_resp_left_fast      = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_fast;
    trials_load_one_T1_resp_right_fast     = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_fast;
    
    % - Load one & T2
    trials_load_one_T2_resp_left_fast      = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_fast;
    trials_load_one_T2_resp_right_fast     = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_fast;    
    
    % - Load two & T1
    trials_load_two_T1_resp_left_fast      = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_fast;
    trials_load_two_T1_resp_right_fast     = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_fast;
    
    % - Load two & T2
    trials_load_two_T2_resp_left_fast      = trials_load_two & trials_target_T2 & trials_reqresp_right & trials_fast;
    trials_load_two_T2_resp_right_fast     = trials_load_two & trials_target_T2 & trials_reqresp_left & trials_fast;
    
    % SLOW

    % - Load one & T1    
    trials_load_one_T1_resp_left_slow      = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_slow;
    trials_load_one_T1_resp_right_slow     = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_slow;
    
    % - Load one & T2
    trials_load_one_T2_resp_left_slow      = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_slow;
    trials_load_one_T2_resp_right_slow     = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_slow;    
    
    % - Load two & T1
    trials_load_two_T1_resp_left_slow      = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_slow;
    trials_load_two_T1_resp_right_slow     = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_slow;
    
    % - Load two & T2
    trials_load_two_T2_resp_left_slow      = trials_load_two & trials_target_T2 & trials_reqresp_right & trials_slow;
    trials_load_two_T2_resp_right_slow     = trials_load_two & trials_target_T2 & trials_reqresp_left & trials_slow;

    % PREC

    % - Load one & T1    
    trials_load_one_T1_resp_left_prec      = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_prec;
    trials_load_one_T1_resp_right_prec     = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_prec;
    
    % - Load one & T2
    trials_load_one_T2_resp_left_prec      = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_prec;
    trials_load_one_T2_resp_right_prec     = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_prec;    
    
    % - Load two & T1
    trials_load_two_T1_resp_left_prec      = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_prec;
    trials_load_two_T1_resp_right_prec     = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_prec;
    
    % - Load two & T2
    trials_load_two_T2_resp_left_prec      = trials_load_two & trials_target_T2 & trials_reqresp_right & trials_prec;
    trials_load_two_T2_resp_right_prec     = trials_load_two & trials_target_T2 & trials_reqresp_left & trials_prec;

    % IMPREC

    % - Load one & T1    
    trials_load_one_T1_resp_left_imprec    = trials_load_one & trials_target_T1 & trials_reqresp_left & trials_imprec;
    trials_load_one_T1_resp_right_imprec   = trials_load_one & trials_target_T1 & trials_reqresp_right & trials_imprec;
    
    % - Load one & T2
    trials_load_one_T2_resp_left_imprec    = trials_load_one & trials_target_T2 & trials_reqresp_left & trials_imprec;
    trials_load_one_T2_resp_right_imprec   = trials_load_one & trials_target_T2 & trials_reqresp_right & trials_imprec;    
    
    % - Load two & T1
    trials_load_two_T1_resp_left_imprec    = trials_load_two & trials_target_T1 & trials_reqresp_left & trials_imprec;
    trials_load_two_T1_resp_right_imprec   = trials_load_two & trials_target_T1 & trials_reqresp_right & trials_imprec;
    
    % - Load two & T2
    trials_load_two_T2_resp_left_imprec    = trials_load_two & trials_target_T2 & trials_reqresp_right & trials_imprec;
    trials_load_two_T2_resp_right_imprec   = trials_load_two & trials_target_T2 & trials_reqresp_left & trials_imprec;
    
    %% Visual (item location L/R)

    % FAST

    % - Load one & T1    
    trials_load_one_T1_item_left_fast      = trials_load_one & trials_target_T1 & trials_item_left & trials_fast;
    trials_load_one_T1_item_right_fast     = trials_load_one & trials_target_T1 & trials_item_right & trials_fast;
    
    % - Load one & T2
    trials_load_one_T2_item_left_fast      = trials_load_one & trials_target_T2 & trials_item_left & trials_fast;
    trials_load_one_T2_item_right_fast     = trials_load_one & trials_target_T2 & trials_item_right & trials_fast;    
    
    % - Load two & T1
    trials_load_two_T1_item_left_fast      = trials_load_two & trials_target_T1 & trials_item_left & trials_fast;
    trials_load_two_T1_item_right_fast     = trials_load_two & trials_target_T1 & trials_item_right & trials_fast;
    
    % - Load two & T2
    trials_load_two_T2_item_left_fast      = trials_load_two & trials_target_T2 & trials_item_right & trials_fast;
    trials_load_two_T2_item_right_fast     = trials_load_two & trials_target_T2 & trials_item_left & trials_fast;
    
    % SLOW

    % - Load one & T1    
    trials_load_one_T1_item_left_slow      = trials_load_one & trials_target_T1 & trials_item_left & trials_slow;
    trials_load_one_T1_item_right_slow     = trials_load_one & trials_target_T1 & trials_item_right & trials_slow;
    
    % - Load one & T2
    trials_load_one_T2_item_left_slow      = trials_load_one & trials_target_T2 & trials_item_left & trials_slow;
    trials_load_one_T2_item_right_slow     = trials_load_one & trials_target_T2 & trials_item_right & trials_slow;    
    
    % - Load two & T1
    trials_load_two_T1_item_left_slow      = trials_load_two & trials_target_T1 & trials_item_left & trials_slow;
    trials_load_two_T1_item_right_slow     = trials_load_two & trials_target_T1 & trials_item_right & trials_slow;
    
    % - Load two & T2
    trials_load_two_T2_item_left_slow      = trials_load_two & trials_target_T2 & trials_item_right & trials_slow;
    trials_load_two_T2_item_right_slow     = trials_load_two & trials_target_T2 & trials_item_left & trials_slow;

    % PREC

    % - Load one & T1    
    trials_load_one_T1_item_left_prec      = trials_load_one & trials_target_T1 & trials_item_left & trials_prec;
    trials_load_one_T1_item_right_prec     = trials_load_one & trials_target_T1 & trials_item_right & trials_prec;
    
    % - Load one & T2
    trials_load_one_T2_item_left_prec      = trials_load_one & trials_target_T2 & trials_item_left & trials_prec;
    trials_load_one_T2_item_right_prec     = trials_load_one & trials_target_T2 & trials_item_right & trials_prec;    
    
    % - Load two & T1
    trials_load_two_T1_item_left_prec      = trials_load_two & trials_target_T1 & trials_item_left & trials_prec;
    trials_load_two_T1_item_right_prec     = trials_load_two & trials_target_T1 & trials_item_right & trials_prec;
    
    % - Load two & T2
    trials_load_two_T2_item_left_prec      = trials_load_two & trials_target_T2 & trials_item_right & trials_prec;
    trials_load_two_T2_item_right_prec     = trials_load_two & trials_target_T2 & trials_item_left & trials_prec;

    % IMPREC

    % - Load one & T1    
    trials_load_one_T1_item_left_imprec    = trials_load_one & trials_target_T1 & trials_item_left & trials_imprec;
    trials_load_one_T1_item_right_imprec   = trials_load_one & trials_target_T1 & trials_item_right & trials_imprec;
    
    % - Load one & T2
    trials_load_one_T2_item_left_imprec    = trials_load_one & trials_target_T2 & trials_item_left & trials_imprec;
    trials_load_one_T2_item_right_imprec   = trials_load_one & trials_target_T2 & trials_item_right & trials_imprec;    
    
    % - Load two & T1
    trials_load_two_T1_item_left_imprec    = trials_load_two & trials_target_T1 & trials_item_left & trials_imprec;
    trials_load_two_T1_item_right_imprec   = trials_load_two & trials_target_T1 & trials_item_right & trials_imprec;
    
    % - Load two & T2
    trials_load_two_T2_item_left_imprec    = trials_load_two & trials_target_T2 & trials_item_right & trials_imprec;
    trials_load_two_T2_item_right_imprec   = trials_load_two & trials_target_T2 & trials_item_left & trials_imprec;

    %% Conta versus ipsilateral performance split

    %% Motor

    % FAST

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_fast, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_fast, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_fast, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_fast, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T1_fast = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_fast, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_fast, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_fast, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_fast, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T2_fast = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_fast, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_fast, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_fast, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_fast, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T1_fast = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_fast, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_fast, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_fast, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_fast, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T2_fast = contra - ipsi;

    % SLOW

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_slow, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_slow, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_slow, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_slow, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T1_slow = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_slow, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_slow, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_slow, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_slow, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T2_slow = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_slow, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_slow, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_slow, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_slow, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T1_slow = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_slow, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_slow, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_slow, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_slow, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T2_slow = contra - ipsi;

    % PRECISE

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_prec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_prec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_prec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_prec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T1_prec = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_prec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_prec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_prec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_prec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T2_prec = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_prec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_prec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_prec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_prec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T1_prec = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_prec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_prec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_prec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_prec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T2_prec = contra - ipsi;

    % IMPRECISE

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_imprec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_imprec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_resp_left_imprec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_resp_right_imprec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T1_imprec = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_imprec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_imprec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_resp_left_imprec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_resp_right_imprec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_one_T2_imprec = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_imprec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_imprec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_resp_left_imprec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_resp_right_imprec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T1_imprec = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_imprec, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_imprec, chan_motor_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_resp_left_imprec, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_resp_right_imprec, chan_motor_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_motor_load_two_T2_imprec = contra - ipsi;

    %% Visual

    % FAST

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_item_right_fast, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_item_left_fast, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_item_left_fast, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_item_right_fast, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T1_fast = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_item_right_fast, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_item_left_fast, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_item_left_fast, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_item_right_fast, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T2_fast = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_item_right_fast, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_item_left_fast, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_item_left_fast, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_item_right_fast, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T1_fast = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_item_right_fast, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_item_left_fast, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_item_left_fast, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_item_right_fast, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T2_fast = contra - ipsi;

    % SLOW

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_item_right_slow, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_item_left_slow, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_item_left_slow, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_item_right_slow, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T1_slow = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_item_right_slow, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_item_left_slow, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_item_left_slow, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_item_right_slow, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T2_slow = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_item_right_slow, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_item_left_slow, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_item_left_slow, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_item_right_slow, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T1_slow = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_item_right_slow, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_item_left_slow, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_item_left_slow, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_item_right_slow, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T2_slow = contra - ipsi;

    % PRECISE

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_item_right_prec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_item_left_prec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_item_left_prec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_item_right_prec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T1_prec = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_item_right_prec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_item_left_prec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_item_left_prec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_item_right_prec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T2_prec = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_item_right_prec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_item_left_prec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_item_left_prec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_item_right_prec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T1_prec = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_item_right_prec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_item_left_prec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_item_left_prec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_item_right_prec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T2_prec = contra - ipsi;

    % IMPRECISE

    % - Load one & T1

    RL = squeeze(mean(tl.trial(trials_load_one_T1_item_right_imprec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T1_item_left_imprec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T1_item_left_imprec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T1_item_right_imprec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T1_imprec = contra - ipsi;
    
    % - Load one & T2

    RL = squeeze(mean(tl.trial(trials_load_one_T2_item_right_imprec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_T2_item_left_imprec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_one_T2_item_left_imprec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_T2_item_right_imprec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_one_T2_imprec = contra - ipsi;

    % - Load two & T1

    RL = squeeze(mean(tl.trial(trials_load_two_T1_item_right_imprec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T1_item_left_imprec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T1_item_left_imprec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T1_item_right_imprec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T1_imprec = contra - ipsi;
    
    % - Load two & T2

    RL = squeeze(mean(tl.trial(trials_load_two_T2_item_right_imprec, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_T2_item_left_imprec, chan_visual_right, :, :)));
    contra = (RL + LR) ./ 2;

    LL = squeeze(mean(tl.trial(trials_load_two_T2_item_left_imprec, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_T2_item_right_imprec, chan_visual_right, :, :)));
    ipsi = (LL + RR) ./ 2;

    cvsi_visual_load_two_T2_imprec = contra - ipsi;

    %% Contrast parameters in structure
    
    erp = [];
    
    erp.label = tl.label;
    erp.time = tl.time;
    erp.dimord = 'chan_time';
    
    %% Motor

    % FAST
    erp.cvsi_motor_load_one_T1_fast     = cvsi_motor_load_one_T1_fast;
    erp.cvsi_motor_load_one_T2_fast     = cvsi_motor_load_one_T2_fast;
    erp.cvsi_motor_load_two_T1_fast     = cvsi_motor_load_two_T1_fast;
    erp.cvsi_motor_load_two_T2_fast     = cvsi_motor_load_two_T2_fast;

    % SLOW
    erp.cvsi_motor_load_one_T1_slow     = cvsi_motor_load_one_T1_slow;
    erp.cvsi_motor_load_one_T2_slow     = cvsi_motor_load_one_T2_slow;
    erp.cvsi_motor_load_two_T1_slow     = cvsi_motor_load_two_T1_slow;
    erp.cvsi_motor_load_two_T2_slow     = cvsi_motor_load_two_T2_slow;

    % PREC
    erp.cvsi_motor_load_one_T1_prec     = cvsi_motor_load_one_T1_prec;
    erp.cvsi_motor_load_one_T2_prec     = cvsi_motor_load_one_T2_prec;
    erp.cvsi_motor_load_two_T1_prec     = cvsi_motor_load_two_T1_prec;
    erp.cvsi_motor_load_two_T2_prec     = cvsi_motor_load_two_T2_prec;

    % IMPREC
    erp.cvsi_motor_load_one_T1_imprec   = cvsi_motor_load_one_T1_imprec;
    erp.cvsi_motor_load_one_T2_imprec   = cvsi_motor_load_one_T2_imprec;
    erp.cvsi_motor_load_two_T1_imprec   = cvsi_motor_load_two_T1_imprec;
    erp.cvsi_motor_load_two_T2_imprec   = cvsi_motor_load_two_T2_imprec;

    %% Visual

    % FAST
    erp.cvsi_visual_load_one_T1_fast     = cvsi_visual_load_one_T1_fast;
    erp.cvsi_visual_load_one_T2_fast     = cvsi_visual_load_one_T2_fast;
    erp.cvsi_visual_load_two_T1_fast     = cvsi_visual_load_two_T1_fast;
    erp.cvsi_visual_load_two_T2_fast     = cvsi_visual_load_two_T2_fast;

    % SLOW
    erp.cvsi_visual_load_one_T1_slow     = cvsi_visual_load_one_T1_slow;
    erp.cvsi_visual_load_one_T2_slow     = cvsi_visual_load_one_T2_slow;
    erp.cvsi_visual_load_two_T1_slow     = cvsi_visual_load_two_T1_slow;
    erp.cvsi_visual_load_two_T2_slow     = cvsi_visual_load_two_T2_slow;

    % PREC
    erp.cvsi_visual_load_one_T1_prec     = cvsi_visual_load_one_T1_prec;
    erp.cvsi_visual_load_one_T2_prec     = cvsi_visual_load_one_T2_prec;
    erp.cvsi_visual_load_two_T1_prec     = cvsi_visual_load_two_T1_prec;
    erp.cvsi_visual_load_two_T2_prec     = cvsi_visual_load_two_T2_prec;

    % IMPREC
    erp.cvsi_visual_load_one_T1_imprec   = cvsi_visual_load_one_T1_imprec;
    erp.cvsi_visual_load_one_T2_imprec   = cvsi_visual_load_one_T2_imprec;
    erp.cvsi_visual_load_two_T1_imprec   = cvsi_visual_load_two_T1_imprec;
    erp.cvsi_visual_load_two_T2_imprec   = cvsi_visual_load_two_T2_imprec;

    %% Save 
        
    save([param.path, 'Processed/EEG/Locked encoding/erp contrasts encoding/' 'erp_encoding_performance_' param.subjectIDs{this_subject}], 'erp');
        
end