%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = [5,7:19,21:27];

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

    %% Baseline correction

    cfg = []; 
    cfg.demean = 'yes';
    cfg.baselinewindow = [-.25 0];

    data = ft_preprocessing(cfg, data);   

    %% Betaband selection

    selectBetaband = false;

    if selectBetaband
        cfg = [];
        cfg.bpfilter = 'yes';
        cfg.hilbert = 'yes';
        cfg.bpfreq = [13 30];
        data = ft_preprocessing(cfg, data);
    end

    %% Temporal smoothing (removing the higher frequencies)

    cfg = [];
    cfg.boxcar = 0.05; % smooth with 50 ms boxcar window
    
    data = ft_preprocessing(cfg, data);

    %% Select data 
    
    cfg = [];
    cfg.latency = [-.1 4]; % encoding window
    cfg.channel = 'EEG'; % only keep EEG electrodes
    
    data = ft_selectdata(cfg, data);
    
    %% Trialtypes

    % Load types
    trials_load_one         = ismember(data.trialinfo(:,1), param.triggers_load1);
    trials_load_two         = ismember(data.trialinfo(:,1), param.triggers_load2);
    
    % Target moment
    trials_target_T1        = ismember(data.trialinfo(:,1), param.triggers_target_T1);
    trials_target_T2        = ismember(data.trialinfo(:,1), param.triggers_target_T2);

    % Dial types
    trials_dial_up          = ismember(data.trialinfo(:,1), param.triggers_dial_up);
    trials_dial_right       = ismember(data.trialinfo(:,1), param.triggers_dial_right);
    
    % Target tilt
    trials_tilt_left        = ismember(data.trialinfo(:,1), param.triggers_reqresp_left);
    trials_tilt_right       = ismember(data.trialinfo(:,1), param.triggers_reqresp_right);

    % Target location
    trials_item_left        = ismember(data.trialinfo(:,1), param.triggers_item_left);
    trials_item_right       = ismember(data.trialinfo(:,1), param.triggers_item_right);

    % Required response 
    trials_reqresp_left     = trials_tilt_left & trials_dial_up | trials_tilt_right & trials_dial_right;
    trials_reqresp_right    = trials_tilt_right & trials_dial_up | trials_tilt_left & trials_dial_right;

    %% Data into single matrix, split by condition
    
    % Load one - T1
    cfg = [];

    cfg.trials = trials_load_one & trials_target_T1;
    cfg.keeptrials = 'yes';
    
    data_one_T1 = ft_timelockanalysis(cfg, data); % put all trials into a single matrix

    % Load one - T2
    cfg = [];

    cfg.trials = trials_load_one & trials_target_T2;
    cfg.keeptrials = 'yes';
    
    data_one_T2 = ft_timelockanalysis(cfg, data); % put all trials into a single matrix

    % Load two
    cfg = [];

    cfg.trials = trials_load_two;
    cfg.keeptrials = 'yes';
    
    data_two = ft_timelockanalysis(cfg, data); % put all trials into a single matrix

    %% Decoding - motor
    
    %% Load one-T1    

    % Data
    d = data_one_T1.trial;
    allTrials = 1:size(data_one_T1.trial, 1);

    % Class
    motorClass = trials_reqresp_right(trials_load_one & trials_target_T1); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisMotor   = motorClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (motorClass == thisMotor);
        otherNonMatch   = otherTrials' & (motorClass ~= thisMotor);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.motor_correct_one_T1(thisTrial, time)      = distMatch < distNonMatch;
            decoding.motor_distance_one_T1(thisTrial, time)     = distNonMatch - distMatch;
        end

    end

    %% Load one-T2    

    % Data
    d = data_one_T2.trial;
    allTrials = 1:size(data_one_T2.trial, 1);

    % Class
    motorClass = trials_reqresp_right(trials_load_one & trials_target_T2); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisMotor   = motorClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (motorClass == thisMotor);
        otherNonMatch   = otherTrials' & (motorClass ~= thisMotor);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.motor_correct_one_T2(thisTrial, time)      = distMatch < distNonMatch;
            decoding.motor_distance_one_T2(thisTrial, time)     = distNonMatch - distMatch;
        end

    end

    %% Load two    

    % Data
    d = data_two.trial;
    allTrials = 1:size(data_two.trial, 1);

    % Class
    motorClass = trials_reqresp_right(trials_load_two); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisMotor   = motorClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (motorClass == thisMotor);
        otherNonMatch   = otherTrials' & (motorClass ~= thisMotor);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.motor_correct_two(thisTrial, time)      = distMatch < distNonMatch;
            decoding.motor_distance_two(thisTrial, time)     = distNonMatch - distMatch;
        end

    end

    %% Decoding - visual
    
    %% Load one-T1    

    % Data
    d = data_one_T1.trial;
    allTrials = 1:size(data_one_T1.trial, 1);

    % Class
    visualClass = trials_item_right(trials_load_one & trials_target_T1); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisVisual   = visualClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (visualClass == thisVisual);
        otherNonMatch   = otherTrials' & (visualClass ~= thisVisual);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.visual_correct_one_T1(thisTrial, time)      = distMatch < distNonMatch;
            decoding.visual_distance_one_T1(thisTrial, time)     = distNonMatch - distMatch;
        end

    end

    %% Load one-T2    

    % Data
    d = data_one_T2.trial;
    allTrials = 1:size(data_one_T2.trial, 1);

    % Class
    visualClass = trials_item_right(trials_load_one & trials_target_T2); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisVisual   = visualClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (visualClass == thisVisual);
        otherNonMatch   = otherTrials' & (visualClass ~= thisVisual);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.visual_correct_one_T2(thisTrial, time)      = distMatch < distNonMatch;
            decoding.visual_distance_one_T2(thisTrial, time)     = distNonMatch - distMatch;
        end

    end

    %% Load two   

    % Data
    d = data_two.trial;
    allTrials = 1:size(data_two.trial, 1);

    % Class
    visualClass = trials_item_right(trials_load_two); % 0 if left, 1 if right

    for thisTrial = allTrials

        disp(['decoding trial ', num2str(thisTrial), ' out of ', num2str(length(allTrials))]);
        
        % Test data
        testData    = squeeze(d(thisTrial,:,:)); % Trial data
        thisVisual   = visualClass(thisTrial); % Required response hand this trial
        
        % Training data
        otherTrials     = ~ismember(allTrials, thisTrial);
        
        otherMatch      = otherTrials' & (visualClass == thisVisual);
        otherNonMatch   = otherTrials' & (visualClass ~= thisVisual);
        trainMatch      = squeeze(mean(d(otherMatch,:,:)));
        trainNonMatch   = squeeze(mean(d(otherNonMatch,:,:)));

        % Loop over timepoints
        for time = 1:length(data.time{thisTrial})
            covar = covdiag(squeeze(d(otherTrials,:,time))); % covariance over all others trials

            distMatch         = pdist([testData(:,time)'; trainMatch(:,time)'], 'mahalanobis', covar);
            distNonMatch      = pdist([testData(:,time)'; trainNonMatch(:,time)'], 'mahalanobis', covar);
            
            decoding.visual_correct_two(thisTrial, time)      = distMatch < distNonMatch;
            decoding.visual_distance_two(thisTrial, time)     = distNonMatch - distMatch;
        end

    end
    %% Save

    save([param.path, 'Processed/EEG/Locked encoding/decoding/' 'decoding_' param.subjectIDs{this_subject}], 'decoding');
    
end

%% Plot decoding accuracy

time = data.time{1}*1000;

decoding_titles = {'Load one - T1', 'Load one - T2', 'Load two'};

motor_correct   = {decoding.motor_correct_one_T1, decoding.motor_correct_one_T2, decoding.motor_correct_two};
motor_distance  = {decoding.motor_distance_one_T1, decoding.motor_distance_one_T2, decoding.motor_distance_two}; 

visual_correct   = {decoding.visual_correct_one_T1, decoding.visual_correct_one_T2, decoding.motor_correct_two};
visual_distance  = {decoding.visual_distance_one_T1, decoding.visual_distance_one_T2, decoding.motor_distance_two}; 

figure;
sgtitle('Motor selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    plot(time, squeeze(mean(motor_correct{i}))); 

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.25 1]); xlim([0 3500]); 

end

figure;
sgtitle('Visual selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    plot(time, squeeze(mean(visual_correct{i}))); 

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.25 1]); xlim([0 3500]); 

end
