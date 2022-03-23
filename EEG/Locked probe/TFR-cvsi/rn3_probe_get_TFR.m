%% Clear workspace

clc; clear; close all

%% Analysis settings

laplacian = true;

%% Define parameters

subjects = [4,12,14,15,16];

%% Loop

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% Combined logfile
    log = readtable(param.combinedLogfile);
    
    this_sub_logindex = find(contains(log.subjectID, param.subjectIDs{this_subject}));
    remove_RT = log.goodBadTrials(this_sub_logindex);
    good_RT = contains(remove_RT, 'TRUE');
    
%     x = log.triggerProbe(this_sub_logindex);
    
    if this_subject == 14
        good_RT = good_RT([1:384,405:end]);
    end

    if this_subject == 4
        good_RT = good_RT([1:760,762:end]);
    end
    
    if this_subject == 12
        good_RT = good_RT([1:532,534:end]);
    end
    
    if this_subject == 15
        good_RT = good_RT([1:742,744:end]);
    end
         
    if this_subject == 16
        good_RT = good_RT([1:610,612:end]);
    end
             
    %% Load epoched data

    load([param.path, 'Processed/EEG/Locked probe/epoched probe/' 'epoched_probe_' param.subjectIDs{this_subject}], 'data'); % make sure to create the folder "saved_data" in the directory specified by your "path" above
   
%     y = data.trialinfo;
    %% Load ICA
    
    load([param.path, 'Processed/EEG/Locked probe/ICA probe/' 'ICA_probe_' param.subjectIDs{this_subject}], 'ica2rem','ica');

    %% Load usable trials

    load([param.path, 'Processed/EEG/Locked probe/usable trials probe/' 'usable_trials_probe_' param.subjectIDs{this_subject}], 'trl2keep');
    
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
    
    % Dial types
    trials_dial_up          = ismember(tfr.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right       = ismember(tfr.trialinfo(:,1), param.triggers_dial_right);
    
    %% Combined motor  
    
    % ---- Dial up
    
    % - Load one   
    trials_load_one_reqresp_left_dial_up      = trials_load_one & trials_reqresp_left & trials_dial_up;
    trials_load_one_reqresp_right_dial_up     = trials_load_one & trials_reqresp_right & trials_dial_up;

    % - Load two 
    trials_load_two_reqresp_left_dial_up      = trials_load_two & trials_reqresp_left & trials_dial_up;
    trials_load_two_reqresp_right_dial_up     = trials_load_two & trials_reqresp_right & trials_dial_up;
    
    % ---- Dial right
    
    % - Load one 
    trials_load_one_reqresp_left_dial_right   = trials_load_one & trials_reqresp_right & trials_dial_right;
    trials_load_one_reqresp_right_dial_right  = trials_load_one & trials_reqresp_left & trials_dial_right;
    
    % - Load two 
    trials_load_two_reqresp_left_dial_right   = trials_load_two & trials_reqresp_right & trials_dial_right;
    trials_load_two_reqresp_right_dial_right  = trials_load_two & trials_reqresp_left & trials_dial_right;
    
    % ---- Both dials
    
    % - Load one  
    trials_load_one_reqresp_left      = trials_load_one_reqresp_left_dial_up | trials_load_one_reqresp_left_dial_right;
    trials_load_one_reqresp_right     = trials_load_one_reqresp_right_dial_up | trials_load_one_reqresp_right_dial_right;
    
    % - Load two 
    trials_load_two_reqresp_left      = trials_load_two_reqresp_left_dial_up | trials_load_two_reqresp_left_dial_right;
    trials_load_two_reqresp_right     = trials_load_two_reqresp_right_dial_up | trials_load_two_reqresp_right_dial_right;

    %% Combined visual     

    % ---- Both dials
    
    % - Load one   
    trials_load_one_item_left      = trials_load_one & trials_item_left;
    trials_load_one_item_right     = trials_load_one & trials_item_right;
    
    % - Load two 
    trials_load_two_item_left      = trials_load_two & trials_item_left;
    trials_load_two_item_right     = trials_load_two & trials_item_right;
    
    % ---- Dial up
    
    % - Load one   
    trials_load_one_item_left_dial_up      = trials_load_one_item_left & trials_dial_up;
    trials_load_one_item_right_dial_up     = trials_load_one_item_right & trials_dial_up;
    
    % - Load two 
    trials_load_two_item_left_dial_up      = trials_load_two_item_left & trials_dial_up;
    trials_load_two_item_right_dial_up     = trials_load_two_item_right & trials_dial_up;
    
    % ---- Dial right
    
    % - Load one    
    trials_load_one_item_left_dial_right   = trials_load_one_item_left & trials_dial_right;
    trials_load_one_item_right_dial_right  = trials_load_one_item_right & trials_dial_right;
    
    % - Load two 
    trials_load_two_item_left_dial_right   = trials_load_two_item_left & trials_dial_right;
    trials_load_two_item_right_dial_right  = trials_load_two_item_right & trials_dial_right;        
    
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);
    
    % Visual
    chan_visual_left    = match_str(tfr.label, param.PO7);
    chan_visual_right   = match_str(tfr.label, param.PO8);
    
    %% Contra vs ipsi motor
    
    % ---- Both dials

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_reqresp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_reqresp_left, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_reqresp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_reqresp_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_reqresp_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_reqresp_left, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_reqresp_left, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_reqresp_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two(1,:,:) = (cvsi_left + cvsi_right) ./ 2;        
    
    % ---- Dial up

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_reqresp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_reqresp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_reqresp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_reqresp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_reqresp_right_dial_up, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_reqresp_left_dial_up, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_reqresp_left_dial_up, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_reqresp_right_dial_up, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    

    % ---- Dial Right

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_reqresp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_reqresp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_reqresp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_reqresp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_one_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_reqresp_right_dial_right, chan_motor_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_reqresp_left_dial_right, chan_motor_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_reqresp_left_dial_right, chan_motor_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_reqresp_right_dial_right, chan_motor_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_motor_load_two_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    

    %% Contra vs ipsi visual
    
    % ---- Both dials

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_item_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_item_left, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_item_left, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_item_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one(1,:,:) = (cvsi_left + cvsi_right) ./ 2;
    
    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_item_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_item_left, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_item_left, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_item_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two(1,:,:) = (cvsi_left + cvsi_right) ./ 2;    
    
    % ---- Dial up

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_item_right_dial_up, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_item_left_dial_up, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_item_left_dial_up, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_item_right_dial_up, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;

    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_item_right_dial_up, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_item_left_dial_up, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_item_left_dial_up, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_item_right_dial_up, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two_dial_up(1,:,:) = (cvsi_left + cvsi_right) ./ 2;       

    % ---- Dial right

    % -- Load one
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_one_item_right_dial_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_one_item_left_dial_right, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_one_item_left_dial_right, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_one_item_right_dial_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_one_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;

    % -- Load two
    
    % Left channels
    a = mean(tfr.powspctrm(trials_load_two_item_right_dial_right, chan_visual_left, :, :)); % contra
    b = mean(tfr.powspctrm(trials_load_two_item_left_dial_right, chan_visual_left, :, :)); % ipsi
    cvsi_left = squeeze(((a-b) ./ (a+b)) * 100);

    % Right channels
    c = mean(tfr.powspctrm(trials_load_two_item_left_dial_right, chan_visual_right, :, :)); % contra
    d = mean(tfr.powspctrm(trials_load_two_item_right_dial_right, chan_visual_right, :, :)); % ipsi
    cvsi_right = squeeze(((c-d) ./ (c+d)) * 100);

    cvsi_visual_load_two_dial_right(1,:,:) = (cvsi_left + cvsi_right) ./ 2;       
    
    %% Contrast parameters in structure

    cvsi_probe = [];
    
    cvsi_probe.label = tfr.label;
    cvsi_probe.time = tfr.time;
    cvsi_probe.freq = tfr.freq;
    cvsi_probe.dimord = 'chan_freq_time';
    
    cvsi_probe.cvsi_motor_load_one_dial_up       = cvsi_motor_load_one_dial_up;
    cvsi_probe.cvsi_motor_load_two_dial_up       = cvsi_motor_load_two_dial_up;
    cvsi_probe.cvsi_motor_load_one_dial_right    = cvsi_motor_load_one_dial_right;
    cvsi_probe.cvsi_motor_load_two_dial_right    = cvsi_motor_load_two_dial_right;
    cvsi_probe.cvsi_motor_load_one               = cvsi_motor_load_one;
    cvsi_probe.cvsi_motor_load_two               = cvsi_motor_load_two;    

    cvsi_probe.cvsi_visual_load_one_dial_up      = cvsi_visual_load_one_dial_up;
    cvsi_probe.cvsi_visual_load_two_dial_up      = cvsi_visual_load_two_dial_up;
    cvsi_probe.cvsi_visual_load_one_dial_right   = cvsi_visual_load_one_dial_right;
    cvsi_probe.cvsi_visual_load_two_dial_right   = cvsi_visual_load_two_dial_right;
    cvsi_probe.cvsi_visual_load_one              = cvsi_visual_load_one;
    cvsi_probe.cvsi_visual_load_two              = cvsi_visual_load_two;   
    
    %% Save 
    
    save([param.path, 'Processed/EEG/Locked probe/tfr contrasts probe/' 'cvsi_probe_' param.subjectIDs{this_subject}], 'cvsi_probe');
    
end    