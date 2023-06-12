%% Clear workspace

clc; clear; close all

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

    cfg = [];
    cfg.elec = ft_read_sens('standard_1020.elc');
    
    data = ft_scalpcurrentdensity(cfg, data);
    
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
    
    %% Channels
    
    % Motor
    chan_motor_left     = match_str(tfr.label, param.C3);
    chan_motor_right    = match_str(tfr.label, param.C4);
    
    %% Contrast parameters in structure

    candi_encoding = [];
    
    candi_encoding.label = tfr.label;
    candi_encoding.time = tfr.time;
    candi_encoding.freq = tfr.freq;
    candi_encoding.dimord = 'chan_freq_time';
    
    %% Contra and ipsi (candi)

    % - Load one & T1
    
    % Contra
    cl = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right, chan_motor_left, :, :));
    cr = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left, chan_motor_right, :, :));

    candi_encoding.contra_motor_load_one_T1(1,:,:) = (cl + cr) ./ 2;

    % Ipsi
    il = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_left, chan_motor_left, :, :));
    ir = mean(tfr.powspctrm(trials_load_one_target_T1_reqresp_right, chan_motor_right, :, :));

    candi_encoding.ipsi_motor_load_one_T1(1,:,:) = (il + ir) ./ 2;

    % - Load one & T2
    
    % Contra
    cl = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right, chan_motor_left, :, :));
    cr = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left, chan_motor_right, :, :));

    candi_encoding.contra_motor_load_one_T2(1,:,:) = (cl + cr) ./ 2;

    % Ipsi
    il = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_left, chan_motor_left, :, :));
    ir = mean(tfr.powspctrm(trials_load_one_target_T2_reqresp_right, chan_motor_right, :, :));

    candi_encoding.ipsi_motor_load_one_T2(1,:,:) = (il + ir) ./ 2;

    % - Load two

    % Contra
    cl = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right, chan_motor_left, :, :));
    cr = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left, chan_motor_right, :, :));

    candi_encoding.contra_motor_load_two(1,:,:) = (cl + cr) ./ 2;

    % Ipsi
    il = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_left, chan_motor_left, :, :));
    ir = mean(tfr.powspctrm(trials_load_two_target_T1_reqresp_right, chan_motor_right, :, :));

    candi_encoding.ipsi_motor_load_two(1,:,:) = (il + ir) ./ 2;    

    %% Save 
    
    save([param.path, 'Processed/EEG/Locked encoding/tfr candi/' 'candi_encoding_' param.subjectIDs{this_subject}], 'candi_encoding');

end



