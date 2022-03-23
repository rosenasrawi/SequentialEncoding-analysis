%% Clear workspace

clc; clear; close all

%% Analysis settings

laplacian = true;

%% Define parameters

subjects = [2:5,7:19,21:27];

%% Loop

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

    %% Surface laplacian if specified

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

    % Absolute response
    trials_reqresp_left_abs = trials_reqresp_left & trials_dial_up | trials_reqresp_right & trials_dial_right;
    trials_reqresp_right_abs = trials_reqresp_right & trials_dial_up | trials_reqresp_left & trials_dial_right;
    
    % Fast versus slow
    trials_fast             = contains(this_sub_log.fastSlow, 'fast');
    trials_fast             = trials_fast(good_trials);
    trials_slow             = contains(this_sub_log.fastSlow, 'slow');
    trials_slow             = trials_slow(good_trials);
    
    % Fast versus slow (including extra variables)
    trials_fast_xvar             = contains(this_sub_log.fastSlow_dial_tloc_hand, 'fast');
    trials_fast_xvar             = trials_fast_xvar(good_trials);
    trials_slow_xvar             = contains(this_sub_log.fastSlow_dial_tloc_hand, 'slow');
    trials_slow_xvar             = trials_slow_xvar(good_trials);
        
    % Precise versus imprecise
    trials_prec             = contains(this_sub_log.precImprec, 'prec');
    trials_prec             = trials_prec(good_trials);
    trials_imprec           = contains(this_sub_log.precImprec, 'imprec');
    trials_imprec           = trials_imprec(good_trials);

    %% TRIALS MOTOR
    
    %% load x moment x fastvsslow

    % FAST

    % Load one - T1
    trials_load_one_T1_resp_left_fast     = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_fast;
    trials_load_one_T1_resp_right_fast    = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_fast;
    
    % Load one - T2
    trials_load_one_T2_resp_left_fast     = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_fast;
    trials_load_one_T2_resp_right_fast    = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_fast;
    
    % Load two - T1
    trials_load_two_T1_resp_left_fast     = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_fast;
    trials_load_two_T1_resp_right_fast    = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_fast;
    
    % Load two - T2
    trials_load_two_T2_resp_left_fast     = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_fast; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_fast    = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_fast;
    
    % SLOW
    
    % Load one - T1
    trials_load_one_T1_resp_left_slow     = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_slow;
    trials_load_one_T1_resp_right_slow    = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_slow;
    
    % Load one - T2
    trials_load_one_T2_resp_left_slow     = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_slow;
    trials_load_one_T2_resp_right_slow    = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_slow;
    
    % Load two - T1
    trials_load_two_T1_resp_left_slow     = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_slow;
    trials_load_two_T1_resp_right_slow    = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_slow;
    
    % Load two - T2
    trials_load_two_T2_resp_left_slow     = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_slow; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_slow    = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_slow;

    %% load x moment x fastvsslow (including extra variables)

    % FAST

    % Load one - T1
    trials_load_one_T1_resp_left_fast_xvar     = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_fast_xvar;
    trials_load_one_T1_resp_right_fast_xvar    = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_fast_xvar;
    
    % Load one - T2
    trials_load_one_T2_resp_left_fast_xvar     = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_fast_xvar;
    trials_load_one_T2_resp_right_fast_xvar    = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_fast_xvar;
    
    % Load two - T1
    trials_load_two_T1_resp_left_fast_xvar     = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_fast_xvar;
    trials_load_two_T1_resp_right_fast_xvar    = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_fast_xvar;
    
    % Load two - T2
    trials_load_two_T2_resp_left_fast_xvar     = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_fast_xvar; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_fast_xvar    = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_fast_xvar;
    
    % SLOW
    
    % Load one - T1
    trials_load_one_T1_resp_left_slow_xvar     = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_slow_xvar;
    trials_load_one_T1_resp_right_slow_xvar    = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_slow_xvar;
    
    % Load one - T2
    trials_load_one_T2_resp_left_slow_xvar     = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_slow_xvar;
    trials_load_one_T2_resp_right_slow_xvar    = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_slow_xvar;
    
    % Load two - T1
    trials_load_two_T1_resp_left_slow_xvar     = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_slow_xvar;
    trials_load_two_T1_resp_right_slow_xvar    = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_slow_xvar;
    
    % Load two - T2
    trials_load_two_T2_resp_left_slow_xvar     = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_slow_xvar; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_slow_xvar    = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_slow_xvar;
    
    
    %% load x moment x precvsimprec

    % PRECISE
    
    % Load one - T1
    trials_load_one_T1_resp_left_prec     = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_prec;
    trials_load_one_T1_resp_right_prec    = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_prec;
    
    % Load one - T2
    trials_load_one_T2_resp_left_prec     = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_prec;
    trials_load_one_T2_resp_right_prec    = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_prec;
    
    % Load two - T1
    trials_load_two_T1_resp_left_prec     = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_prec;
    trials_load_two_T1_resp_right_prec    = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_prec;
    
    % Load two - T2
    trials_load_two_T2_resp_left_prec     = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_prec; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_prec    = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_prec;
    
    % IMPRECISE
    
    % Load one - T1
    trials_load_one_T1_resp_left_imprec   = trials_load_one & trials_target_T1 & trials_reqresp_left_abs & trials_imprec;
    trials_load_one_T1_resp_right_imprec  = trials_load_one & trials_target_T1 & trials_reqresp_right_abs & trials_imprec;
    
    % Load one - T2
    trials_load_one_T2_resp_left_imprec   = trials_load_one & trials_target_T2 & trials_reqresp_left_abs & trials_imprec;
    trials_load_one_T2_resp_right_imprec  = trials_load_one & trials_target_T2 & trials_reqresp_right_abs & trials_imprec;
    
    % Load two - T1
    trials_load_two_T1_resp_left_imprec   = trials_load_two & trials_target_T1 & trials_reqresp_left_abs & trials_imprec;
    trials_load_two_T1_resp_right_imprec  = trials_load_two & trials_target_T1 & trials_reqresp_right_abs & trials_imprec;
    
    % Load two - T2
    trials_load_two_T2_resp_left_imprec   = trials_load_two & trials_target_T2 & trials_reqresp_right_abs & trials_imprec; % Req resp swaps here, becasue based on T1
    trials_load_two_T2_resp_right_imprec  = trials_load_two & trials_target_T2 & trials_reqresp_left_abs & trials_imprec;

    %% TRIALS VISUAL     

    %% load x moment x fastvsslow

    % FAST

    % Load one - T1      
    trials_load_one_T1_item_left_fast      = trials_load_one & trials_target_T1 & trials_item_left & trials_fast;
    trials_load_one_T1_item_right_fast     = trials_load_one & trials_target_T1 & trials_item_right & trials_fast;
    
    % Load one - T2      
    trials_load_one_T2_item_left_fast      = trials_load_one & trials_target_T2 & trials_item_left & trials_fast;
    trials_load_one_T2_item_right_fast     = trials_load_one & trials_target_T2 & trials_item_right & trials_fast;
    
    % Load two - T1      
    trials_load_two_T1_item_left_fast      = trials_load_two & trials_target_T1 & trials_item_left & trials_fast;
    trials_load_two_T1_item_right_fast     = trials_load_two & trials_target_T1 & trials_item_right & trials_fast;
    
    % Load two - T2      
    trials_load_two_T2_item_left_fast      = trials_load_two & trials_target_T2 & trials_item_right & trials_fast; % Item side swaps here, because based on T1
    trials_load_two_T2_item_right_fast     = trials_load_two & trials_target_T2 & trials_item_left & trials_fast;
       
    % SLOW

    % Load one - T1      
    trials_load_one_T1_item_left_slow      = trials_load_one & trials_target_T1 & trials_item_left & trials_slow;
    trials_load_one_T1_item_right_slow     = trials_load_one & trials_target_T1 & trials_item_right & trials_slow;
    
    % Load one - T2      
    trials_load_one_T2_item_left_slow      = trials_load_one & trials_target_T2 & trials_item_left & trials_slow;
    trials_load_one_T2_item_right_slow     = trials_load_one & trials_target_T2 & trials_item_right & trials_slow;
    
    % Load two - T1      
    trials_load_two_T1_item_left_slow      = trials_load_two & trials_target_T1 & trials_item_left & trials_slow;
    trials_load_two_T1_item_right_slow     = trials_load_two & trials_target_T1 & trials_item_right & trials_slow;
    
    % Load two - T2      
    trials_load_two_T2_item_left_slow      = trials_load_two & trials_target_T2 & trials_item_right & trials_slow; % Item side swaps here, because based on T1
    trials_load_two_T2_item_right_slow     = trials_load_two & trials_target_T2 & trials_item_left & trials_slow;

    %% load x moment x precvimprec

    % PRECISE

    % Load one - T1      
    trials_load_one_T1_item_left_prec      = trials_load_one & trials_target_T1 & trials_item_left & trials_prec;
    trials_load_one_T1_item_right_prec     = trials_load_one & trials_target_T1 & trials_item_right & trials_prec;
    
    % Load one - T2      
    trials_load_one_T2_item_left_prec      = trials_load_one & trials_target_T2 & trials_item_left & trials_prec;
    trials_load_one_T2_item_right_prec     = trials_load_one & trials_target_T2 & trials_item_right & trials_prec;
    
    % Load two - T1      
    trials_load_two_T1_item_left_prec      = trials_load_two & trials_target_T1 & trials_item_left & trials_prec;
    trials_load_two_T1_item_right_prec     = trials_load_two & trials_target_T1 & trials_item_right & trials_prec;
    
    % Load two - T2      
    trials_load_two_T2_item_left_prec      = trials_load_two & trials_target_T2 & trials_item_right & trials_prec; % Item side swaps here, because based on T1
    trials_load_two_T2_item_right_prec     = trials_load_two & trials_target_T2 & trials_item_left & trials_prec;

    % IMPRECISE

    % Load one - T1      
    trials_load_one_T1_item_left_imprec      = trials_load_one & trials_target_T1 & trials_item_left & trials_imprec;
    trials_load_one_T1_item_right_imprec     = trials_load_one & trials_target_T1 & trials_item_right & trials_imprec;
    
    % Load one - T2      
    trials_load_one_T2_item_left_imprec      = trials_load_one & trials_target_T2 & trials_item_left & trials_imprec;
    trials_load_one_T2_item_right_imprec     = trials_load_one & trials_target_T2 & trials_item_right & trials_imprec;
    
    % Load two - T1      
    trials_load_two_T1_item_left_imprec      = trials_load_two & trials_target_T1 & trials_item_left & trials_imprec;
    trials_load_two_T1_item_right_imprec     = trials_load_two & trials_target_T1 & trials_item_right & trials_imprec;
    
    % Load two - T2      
    trials_load_two_T2_item_left_imprec      = trials_load_two & trials_target_T2 & trials_item_right & trials_imprec; % Item side swaps here, because based on T1
    trials_load_two_T2_item_right_imprec     = trials_load_two & trials_target_T2 & trials_item_left & trials_imprec;
         
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);

    % Visual
    chan_visual_left    = match_str(tfr.label, param.PO7);
    chan_visual_right   = match_str(tfr.label, param.PO8);
        
    %% CVSI motor: load x moment x fastvsslow
    
    % ---- FAST

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_fast, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_fast, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_fast, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_fast, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_fast, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_fast, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_fast, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_fast, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_fast, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_fast, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_fast, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_fast, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_fast, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_fast, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_fast, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_fast, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % ---- SLOW

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_slow, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_slow, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_slow, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_slow, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_slow, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_slow, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_slow, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_slow, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_slow, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_slow, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_slow, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_slow, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_slow, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_slow, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_slow, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_slow, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;

    %% CVSI motor: load x moment x fastvsslow (including extra variables)
    
    % ---- FAST

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_fast_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_fast_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_fast_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_fast_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_fast_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_fast_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_fast_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_fast_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_fast_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_fast_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_fast_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_fast_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_fast_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_fast_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_fast_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_fast_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_fast_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_fast_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_fast_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_fast_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % ---- SLOW

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_slow_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_slow_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_slow_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_slow_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_slow_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_slow_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_slow_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_slow_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_slow_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_slow_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_slow_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_slow_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_slow_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_slow_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_slow_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_slow_xvar, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_slow_xvar, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_slow_xvar, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_slow_xvar, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_slow_xvar(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    %% CVSI motor: load x moment x precvsimprec
    
    % ---- PRECISE

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_prec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_prec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_prec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_prec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_prec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_prec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_prec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_prec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_prec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_prec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_prec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_prec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_prec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_prec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_prec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_prec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % ---- IMPRECISE

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_resp_right_imprec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_resp_left_imprec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_resp_left_imprec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_resp_right_imprec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T1_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_resp_right_imprec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_resp_left_imprec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_resp_left_imprec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_resp_right_imprec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_one_T2_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
 
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_resp_right_imprec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_resp_left_imprec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_resp_left_imprec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_resp_right_imprec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T1_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
   
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_resp_right_imprec, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_resp_left_imprec, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_resp_left_imprec, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_resp_right_imprec, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    motor_load_two_T2_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
       
    %% CVSI visual: load x moment x fastvsslow
    
    % ---- FAST

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_item_right_fast, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_item_left_fast, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_item_left_fast, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_item_right_fast, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T1_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_item_right_fast, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_item_left_fast, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_item_left_fast, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_item_right_fast, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T2_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_item_right_fast, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_item_left_fast, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_item_left_fast, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_item_right_fast, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T1_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_item_right_fast, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_item_left_fast, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_item_left_fast, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_item_right_fast, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T2_fast(1,:,:) = (cvsi_left + cvsi_right) ./ 2;      
    
    % ---- SLOW

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_item_right_slow, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_item_left_slow, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_item_left_slow, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_item_right_slow, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T1_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_item_right_slow, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_item_left_slow, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_item_left_slow, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_item_right_slow, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T2_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_item_right_slow, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_item_left_slow, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_item_left_slow, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_item_right_slow, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T1_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_item_right_slow, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_item_left_slow, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_item_left_slow, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_item_right_slow, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T2_slow(1,:,:) = (cvsi_left + cvsi_right) ./ 2;      

    %% CVSI visual: load x moment x precvsimprec
    
    % ---- PRECISE

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_item_right_prec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_item_left_prec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_item_left_prec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_item_right_prec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T1_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_item_right_prec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_item_left_prec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_item_left_prec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_item_right_prec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T2_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_item_right_prec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_item_left_prec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_item_left_prec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_item_right_prec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T1_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_item_right_prec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_item_left_prec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_item_left_prec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_item_right_prec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T2_prec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;        

    % ---- IMPRECISE

    % -- Load one & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T1_item_right_imprec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T1_item_left_imprec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T1_item_left_imprec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T1_item_right_imprec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T1_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load one & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_T2_item_right_imprec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_T2_item_left_imprec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_T2_item_left_imprec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_T2_item_right_imprec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_one_T2_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % -- Load two & T1
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T1_item_right_imprec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T1_item_left_imprec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T1_item_left_imprec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T1_item_right_imprec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T1_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
       
    % -- Load two & T2
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_T2_item_right_imprec, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_T2_item_left_imprec, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_T2_item_left_imprec, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_T2_item_right_imprec, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    visual_load_two_T2_imprec(1,:,:) = (cvsi_left + cvsi_right) ./ 2;       
    
    %% Contrast parameters in structure

    cvsi_perf = [];
    
    cvsi_perf.label = tfr.label;
    cvsi_perf.time = tfr.time;
    cvsi_perf.freq = tfr.freq;
    cvsi_perf.dimord = 'chan_freq_time';
    
    % MOTOR
    
    % Fast
    cvsi_perf.motor_load_one_T1_fast     = motor_load_one_T1_fast;
    cvsi_perf.motor_load_one_T2_fast     = motor_load_one_T2_fast;
    cvsi_perf.motor_load_two_T1_fast     = motor_load_two_T1_fast;
    cvsi_perf.motor_load_two_T2_fast     = motor_load_two_T2_fast;     
    
    % Slow
    cvsi_perf.motor_load_one_T1_slow     = motor_load_one_T1_slow;
    cvsi_perf.motor_load_one_T2_slow     = motor_load_one_T2_slow;
    cvsi_perf.motor_load_two_T1_slow     = motor_load_two_T1_slow;
    cvsi_perf.motor_load_two_T2_slow     = motor_load_two_T2_slow;   
    
    % Fast (xvar)
    cvsi_perf.motor_load_one_T1_fast_xvar     = motor_load_one_T1_fast_xvar;
    cvsi_perf.motor_load_one_T2_fast_xvar     = motor_load_one_T2_fast_xvar;
    cvsi_perf.motor_load_two_T1_fast_xvar     = motor_load_two_T1_fast_xvar;
    cvsi_perf.motor_load_two_T2_fast_xvar     = motor_load_two_T2_fast_xvar;     
    
    % Slow (xvar)
    cvsi_perf.motor_load_one_T1_slow_xvar     = motor_load_one_T1_slow_xvar;
    cvsi_perf.motor_load_one_T2_slow_xvar     = motor_load_one_T2_slow_xvar;
    cvsi_perf.motor_load_two_T1_slow_xvar     = motor_load_two_T1_slow_xvar;
    cvsi_perf.motor_load_two_T2_slow_xvar     = motor_load_two_T2_slow_xvar;     
    
    % Precise
    cvsi_perf.motor_load_one_T1_prec     = motor_load_one_T1_prec;
    cvsi_perf.motor_load_one_T2_prec     = motor_load_one_T2_prec;
    cvsi_perf.motor_load_two_T1_prec     = motor_load_two_T1_prec;
    cvsi_perf.motor_load_two_T2_prec     = motor_load_two_T2_prec;     
    
    % Imprecise
    cvsi_perf.motor_load_one_T1_imprec   = motor_load_one_T1_imprec;
    cvsi_perf.motor_load_one_T2_imprec   = motor_load_one_T2_imprec;
    cvsi_perf.motor_load_two_T1_imprec   = motor_load_two_T1_imprec;
    cvsi_perf.motor_load_two_T2_imprec   = motor_load_two_T2_imprec;   

    % VISUAL
    
    % Fast
    cvsi_perf.visual_load_one_T1_fast    = visual_load_one_T1_fast;
    cvsi_perf.visual_load_one_T2_fast    = visual_load_one_T2_fast;
    cvsi_perf.visual_load_two_T1_fast    = visual_load_two_T1_fast;
    cvsi_perf.visual_load_two_T2_fast    = visual_load_two_T2_fast;     
    
    % Slow
    cvsi_perf.visual_load_one_T1_slow    = visual_load_one_T1_slow;
    cvsi_perf.visual_load_one_T2_slow    = visual_load_one_T2_slow;
    cvsi_perf.visual_load_two_T1_slow    = visual_load_two_T1_slow;
    cvsi_perf.visual_load_two_T2_slow    = visual_load_two_T2_slow;    
    
    % Precise
    cvsi_perf.visual_load_one_T1_prec    = visual_load_one_T1_prec;
    cvsi_perf.visual_load_one_T2_prec    = visual_load_one_T2_prec;
    cvsi_perf.visual_load_two_T1_prec    = visual_load_two_T1_prec;
    cvsi_perf.visual_load_two_T2_prec    = visual_load_two_T2_prec;     
    
    % Imprecise
    cvsi_perf.visual_load_one_T1_imprec  = visual_load_one_T1_imprec;
    cvsi_perf.visual_load_one_T2_imprec  = visual_load_one_T2_imprec;
    cvsi_perf.visual_load_two_T1_imprec  = visual_load_two_T1_imprec;
    cvsi_perf.visual_load_two_T2_imprec  = visual_load_two_T2_imprec;  
    
    %% Save 
    
    save([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'cvsi_encoding_perf_' param.subjectIDs{this_subject}], 'cvsi_perf');
    
end    