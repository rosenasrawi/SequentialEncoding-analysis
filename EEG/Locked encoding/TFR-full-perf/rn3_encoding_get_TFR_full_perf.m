%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = [1:5,7:19,21:27];
%subjects = 1; % Try-out

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
    
    %% Separate trial types

    % Load types
    trials_load_two         = ismember(tfr.trialinfo(:,1), param.triggers_load2);
    
    % Target moment
    trials_target_T1        = ismember(tfr.trialinfo(:,1), param.triggers_target_T1);
    trials_target_T2        = ismember(tfr.trialinfo(:,1), param.triggers_target_T2);

    % Fast versus slow
    trials_fast             = contains(this_sub_log.fastSlow, 'fast'); trials_fast = trials_fast(good_trials);
    trials_slow             = contains(this_sub_log.fastSlow, 'slow'); trials_slow = trials_slow(good_trials);
        
    % Precise versus imprecise
    trials_prec             = contains(this_sub_log.precImprec, 'prec'); trials_prec = trials_prec(good_trials);
    trials_imprec           = contains(this_sub_log.precImprec, 'imprec'); trials_imprec = trials_imprec(good_trials);

    %% Combined trial types

    %% Fast versus slow

    % Load two-T1
    trials_load_two_T1_fast     = trials_load_two & trials_target_T1 & trials_fast;
    trials_load_two_T1_slow     = trials_load_two & trials_target_T1 & trials_slow;
    
    % Load two-T2
    trials_load_two_T2_fast     = trials_load_two & trials_target_T2 & trials_fast;
    trials_load_two_T2_slow     = trials_load_two & trials_target_T2 & trials_slow;

    %% Precise versus imprecise

    % Load two-T1
    trials_load_two_T1_prec     = trials_load_two & trials_target_T1 & trials_prec;
    trials_load_two_T1_imprec   = trials_load_two & trials_target_T1 & trials_imprec;
    
    % Load two-T2
    trials_load_two_T2_prec     = trials_load_two & trials_target_T2 & trials_prec;
    trials_load_two_T2_imprec   = trials_load_two & trials_target_T2 & trials_imprec;

    %% Calculate contrasts

    %% Fast versus slow

    % Load two-T1
    a = mean(tfr.powspctrm(trials_load_two_T1_fast,:,:,:));
    b = mean(tfr.powspctrm(trials_load_two_T1_slow,:,:,:));

    load_two_T1_fast_slow = squeeze(((a-b) ./ (a+b))) * 100;  

    % Load two-T2
    a = mean(tfr.powspctrm(trials_load_two_T2_fast,:,:,:));
    b = mean(tfr.powspctrm(trials_load_two_T2_slow,:,:,:));

    load_two_T2_fast_slow = squeeze(((a-b) ./ (a+b))) * 100;  

    %% Precise versus imprecise   

    % Load two-T1
    a = mean(tfr.powspctrm(trials_load_two_T1_prec,:,:,:));
    b = mean(tfr.powspctrm(trials_load_two_T1_imprec,:,:,:));

    load_two_T1_prec_imprec = squeeze(((a-b) ./ (a+b))) * 100;  

    % Load two-T2
    a = mean(tfr.powspctrm(trials_load_two_T2_prec,:,:,:));
    b = mean(tfr.powspctrm(trials_load_two_T2_imprec,:,:,:));

    load_two_T2_prec_imprec = squeeze(((a-b) ./ (a+b))) * 100; 

    %% Contrast parameters in structure

    full_perf = [];
    
    full_perf.label = tfr.label;
    full_perf.time = tfr.time;
    full_perf.freq = tfr.freq;
    full_perf.dimord = 'chan_freq_time';

    % Fast versus slow
    full_perf.load_two_T1_fast_slow     = load_two_T1_fast_slow;
    full_perf.load_two_T2_fast_slow     = load_two_T2_fast_slow;

    % Precise versus imprecise
    full_perf.load_two_T1_prec_imprec   = load_two_T1_prec_imprec;
    full_perf.load_two_T2_prec_imprec   = load_two_T2_prec_imprec;

    %% Save 
    
    save([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'full_perf_encoding_' param.subjectIDs{this_subject}], 'full_perf');
    
end
