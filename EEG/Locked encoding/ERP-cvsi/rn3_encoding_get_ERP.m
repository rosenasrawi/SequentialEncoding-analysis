%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = [3:5,7:19,21:27];
% subjects = 2;% Try-out

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
 
    load([param.path, 'Processed/EEG/Locked encoding/usable trials encoding/' 'usable_trials_encoding_' param.subjectIDs{this_subject}], 'trl2keep'); trl2keep_EEG = trl2keep;
    load([param.path, 'Processed/EEG/Locked encoding/usable trials encoding/' 'usable_trials_EMG_encoding_' param.subjectIDs{this_subject}], 'trl2keep'); trl2keep_EMG = trl2keep;

    clear trl2keep
    %% Keep channels of interest

    cfg = [];
    cfg.channel = {'EEG', 'emgLrect', 'emgRrect'};

    data = ft_preprocessing(cfg, data);

    %% Trials with RT in range
       
    good_RT = contains(this_sub_log.goodBadTrials, 'TRUE');
    
    good_trials = trl2keep_EEG & trl2keep_EMG & good_RT;
        
    %% Remove bad trials
    
    cfg = [];
    cfg.trials = good_trials;

    data = ft_selectdata(cfg, data);

    %% Remove bad ICA components

    cfg = [];
    cfg.component = ica2rem;

    data = ft_rejectcomponent(cfg, ica, data);

    %% Keep EMG info

    complete_label = data.label;
    complete_trial = data.trial;
    emg_index = contains(complete_label, {'emgLrect','emgRrect'});

    %% Surface laplacian

    cfg = [];
    cfg.elec = ft_read_sens('standard_1020.elc'); % Does not read the EMG electrodes!!

    data = ft_scalpcurrentdensity(cfg, data);

    %% Add EMG info
    
    data.label = complete_label;

    for time = 1:length(data.trial)
        data.trial{time} = [data.trial{time}; complete_trial{time}(emg_index,:)];
    end
    
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
    
    %% Combined trial types

    %% Motor (response L/R)

    % - Load one & T1    
    trials_load_one_target_T1_reqresp_left      = trials_load_one & trials_target_T1 & trials_reqresp_left;
    trials_load_one_target_T1_reqresp_right     = trials_load_one & trials_target_T1 & trials_reqresp_right;
    
    % - Load one & T2
    trials_load_one_target_T2_reqresp_left      = trials_load_one & trials_target_T2 & trials_reqresp_left;
    trials_load_one_target_T2_reqresp_right     = trials_load_one & trials_target_T2 & trials_reqresp_right;    
    
    % - Load two 
    trials_load_two_target_T1_reqresp_left      = trials_load_two & trials_target_T1 & trials_reqresp_left | trials_load_two & trials_target_T2 & trials_reqresp_right;
    trials_load_two_target_T1_reqresp_right     = trials_load_two & trials_target_T1 & trials_reqresp_right | trials_load_two & trials_target_T2 & trials_reqresp_left;
    
    %% Visual (item location L/R)

    % - Load one & T1    
    trials_load_one_target_T1_item_left      = trials_load_one & trials_target_T1 & trials_item_left;
    trials_load_one_target_T1_item_right     = trials_load_one & trials_target_T1 & trials_item_right;
    
    % - Load one & T2
    trials_load_one_target_T2_item_left      = trials_load_one & trials_target_T2 & trials_item_left;
    trials_load_one_target_T2_item_right     = trials_load_one & trials_target_T2 & trials_item_right;    
    
    % - Load two 
    trials_load_two_target_T1_item_left      = trials_load_two & trials_target_T1 & trials_item_left | trials_load_two & trials_target_T2 & trials_item_right;
    trials_load_two_target_T1_item_right     = trials_load_two & trials_target_T1 & trials_item_right | trials_load_two & trials_target_T2 & trials_item_left;
    
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tl.label, param.C3);
    chan_motor_right    = match_str(tl.label, param.C4);
    
    % Visual
    chan_visual_left    = match_str(tl.label, param.PO7);
    chan_visual_right   = match_str(tl.label, param.PO8);

    % EMG
    chan_EMG_left     = match_str(tl.label, param.emgLrect);
    chan_EMG_right    = match_str(tl.label, param.emgRrect);

    %% Contra, ipsi, contra-ipsi

    %% Load one - T1

    %% Motor

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_right, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_left, chan_motor_right, :, :)));

    contra_motor_load_one_T1 = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_left, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_right, chan_motor_right, :, :)));

    ipsi_motor_load_one_T1 = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_motor_load_one_T1 = contra_motor_load_one_T1 - ipsi_motor_load_one_T1;
    
    %% Visual

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T1_item_right, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T1_item_left, chan_visual_right, :, :)));

    contra_visual_load_one_T1 = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T1_item_left, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T1_item_right, chan_visual_right, :, :)));

    ipsi_visual_load_one_T1 = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_visual_load_one_T1 = contra_visual_load_one_T1 - ipsi_visual_load_one_T1;

    %% EMG (motor)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_left, chan_EMG_right, :, :)));

    contra_EMG_mot_load_one_T1 = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T1_reqresp_right, chan_EMG_right, :, :)));

    ipsi_EMG_mot_load_one_T1 = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_mot_load_one_T1 = contra_EMG_mot_load_one_T1 - ipsi_EMG_mot_load_one_T1;
    
    %% EMG (visual)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T1_item_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T1_item_left, chan_EMG_right, :, :)));

    contra_EMG_vis_load_one_T1 = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T1_item_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T1_item_right, chan_EMG_right, :, :)));

    ipsi_EMG_vis_load_one_T1 = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_vis_load_one_T1 = contra_EMG_vis_load_one_T1 - ipsi_EMG_vis_load_one_T1;

    %% Load one - T2
    
    %% Motor

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_right, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_left, chan_motor_right, :, :)));

    contra_motor_load_one_T2 = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_left, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_right, chan_motor_right, :, :)));

    ipsi_motor_load_one_T2 = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_motor_load_one_T2 = contra_motor_load_one_T2 - ipsi_motor_load_one_T2;
    
    %% Visual

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T2_item_right, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T2_item_left, chan_visual_right, :, :)));

    contra_visual_load_one_T2 = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T2_item_left, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T2_item_right, chan_visual_right, :, :)));

    ipsi_visual_load_one_T2 = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_visual_load_one_T2 = contra_visual_load_one_T2 - ipsi_visual_load_one_T2;

    %% EMG (motor)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_left, chan_EMG_right, :, :)));

    contra_EMG_mot_load_one_T2 = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T2_reqresp_right, chan_EMG_right, :, :)));

    ipsi_EMG_mot_load_one_T2 = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_mot_load_one_T2 = contra_EMG_mot_load_one_T2 - ipsi_EMG_mot_load_one_T2;
    
    %% EMG (visual)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_one_target_T2_item_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_one_target_T2_item_left, chan_EMG_right, :, :)));

    contra_EMG_vis_load_one_T2 = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_one_target_T2_item_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_one_target_T2_item_right, chan_EMG_right, :, :)));

    ipsi_EMG_vis_load_one_T2 = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_vis_load_one_T2 = contra_EMG_vis_load_one_T2 - ipsi_EMG_vis_load_one_T2;

    %% Load two

    %% Motor

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_right, chan_motor_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_left, chan_motor_right, :, :)));

    contra_motor_load_two = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_left, chan_motor_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_right, chan_motor_right, :, :)));

    ipsi_motor_load_two = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_motor_load_two = contra_motor_load_two - ipsi_motor_load_two;
    
    %% Visual

    % Contra
    RL = squeeze(mean(tl.trial(trials_load_two_target_T1_item_right, chan_visual_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_target_T1_item_left, chan_visual_right, :, :)));

    contra_visual_load_two = (RL + LR) ./ 2;

    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_two_target_T1_item_left, chan_visual_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_target_T1_item_right, chan_visual_right, :, :)));

    ipsi_visual_load_two = (LL + RR) ./ 2;

    % Contra versus ipsi
    cvsi_visual_load_two = contra_visual_load_two - ipsi_visual_load_two;

    %% EMG (motor)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_left, chan_EMG_right, :, :)));

    contra_EMG_mot_load_two = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_target_T1_reqresp_right, chan_EMG_right, :, :)));

    ipsi_EMG_mot_load_two = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_mot_load_two = contra_EMG_mot_load_two - ipsi_EMG_mot_load_two;
    
    %% EMG (visual)
    
    % Contra
    RL = squeeze(mean(tl.trial(trials_load_two_target_T1_item_right, chan_EMG_left, :, :)));
    LR = squeeze(mean(tl.trial(trials_load_two_target_T1_item_left, chan_EMG_right, :, :)));

    contra_EMG_vis_load_two = (RL + LR) ./ 2;
    
    % Ispi
    LL = squeeze(mean(tl.trial(trials_load_two_target_T1_item_left, chan_EMG_left, :, :)));
    RR = squeeze(mean(tl.trial(trials_load_two_target_T1_item_right, chan_EMG_right, :, :)));

    ipsi_EMG_vis_load_two = (LL + RR) ./ 2;
    
    % Contra versus ipsi
    cvsi_EMG_vis_load_two = contra_EMG_vis_load_two - ipsi_EMG_vis_load_two;
    
    %% Contrast parameters in structure
    
    erp = [];
    
    erp.label = tl.label;
    erp.time = tl.time;
    erp.dimord = 'chan_time';
    
    % Load one-T1
    erp.contra_motor_load_one_T1        = contra_motor_load_one_T1;
    erp.ipsi_motor_load_one_T1          = ipsi_motor_load_one_T1;
    erp.cvsi_motor_load_one_T1          = cvsi_motor_load_one_T1;
    
    erp.contra_visual_load_one_T1       = contra_visual_load_one_T1;
    erp.ipsi_visual_load_one_T1         = ipsi_visual_load_one_T1;
    erp.cvsi_visual_load_one_T1         = cvsi_visual_load_one_T1;
    
    erp.contra_EMG_mot_load_one_T1      = contra_EMG_mot_load_one_T1;
    erp.ipsi_EMG_mot_load_one_T1        = ipsi_EMG_mot_load_one_T1;
    erp.cvsi_EMG_mot_load_one_T1        = cvsi_EMG_mot_load_one_T1;

    erp.contra_EMG_vis_load_one_T1      = contra_EMG_vis_load_one_T1;
    erp.ipsi_EMG_vis_load_one_T1        = ipsi_EMG_vis_load_one_T1;
    erp.cvsi_EMG_vis_load_one_T1        = cvsi_EMG_vis_load_one_T1;

    % Load one-T2
    erp.contra_motor_load_one_T2        = contra_motor_load_one_T2;
    erp.ipsi_motor_load_one_T2          = ipsi_motor_load_one_T2;
    erp.cvsi_motor_load_one_T2          = cvsi_motor_load_one_T2;
    
    erp.contra_visual_load_one_T2       = contra_visual_load_one_T2;
    erp.ipsi_visual_load_one_T2         = ipsi_visual_load_one_T2;
    erp.cvsi_visual_load_one_T2         = cvsi_visual_load_one_T2;
    
    erp.contra_EMG_mot_load_one_T2      = contra_EMG_mot_load_one_T2;
    erp.ipsi_EMG_mot_load_one_T2        = ipsi_EMG_mot_load_one_T2;
    erp.cvsi_EMG_mot_load_one_T2        = cvsi_EMG_mot_load_one_T2;

    erp.contra_EMG_vis_load_one_T2      = contra_EMG_vis_load_one_T2;
    erp.ipsi_EMG_vis_load_one_T2        = ipsi_EMG_vis_load_one_T2;
    erp.cvsi_EMG_vis_load_one_T2        = cvsi_EMG_vis_load_one_T2;
    
    % Load two
    erp.contra_motor_load_two           = contra_motor_load_two;
    erp.ipsi_motor_load_two             = ipsi_motor_load_two;
    erp.cvsi_motor_load_two             = cvsi_motor_load_two;
    
    erp.contra_visual_load_two          = contra_visual_load_two;
    erp.ipsi_visual_load_two            = ipsi_visual_load_two;
    erp.cvsi_visual_load_two            = cvsi_visual_load_two;
    
    erp.contra_EMG_mot_load_two         = contra_EMG_mot_load_two;
    erp.ipsi_EMG_mot_load_two           = ipsi_EMG_mot_load_two;
    erp.cvsi_EMG_mot_load_two           = cvsi_EMG_mot_load_two;

    erp.contra_EMG_vis_load_two         = contra_EMG_vis_load_two;
    erp.ipsi_EMG_vis_load_two           = ipsi_EMG_vis_load_two;
    erp.cvsi_EMG_vis_load_two           = cvsi_EMG_vis_load_two;

    %% Save 
        
    save([param.path, 'Processed/EEG/Locked encoding/erp contrasts encoding/' 'erp_encoding_' param.subjectIDs{this_subject}], 'erp');
        
end   
