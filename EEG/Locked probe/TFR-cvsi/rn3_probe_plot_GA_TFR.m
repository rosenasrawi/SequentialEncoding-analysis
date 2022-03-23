%% Clear workspace
clc; clear; close all

%% Define parameters
subjectIDs = [1:5,7:19,21:27];
subjects = 1:25;

%% Load all files
for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked probe/tfr contrasts probe/' 'cvsi_probe_' param.subjectIDs{this_subject}], 'cvsi_probe');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_probe_all = selectfields(cvsi_probe,{'label', 'time', 'freq', 'dimord'});
    end
    
    %% add to all sub structure
    
    cvsi_probe_all.cvsi_motor_load_one_dial_up(this_subject,:,:,:)        = cvsi_probe.cvsi_motor_load_one_dial_up;
    cvsi_probe_all.cvsi_motor_load_two_dial_up(this_subject,:,:,:)        = cvsi_probe.cvsi_motor_load_two_dial_up;
    cvsi_probe_all.cvsi_motor_load_one_dial_right(this_subject,:,:,:)     = cvsi_probe.cvsi_motor_load_one_dial_right;
    cvsi_probe_all.cvsi_motor_load_two_dial_right(this_subject,:,:,:)     = cvsi_probe.cvsi_motor_load_two_dial_right;
    cvsi_probe_all.cvsi_motor_load_one(this_subject,:,:,:)                = cvsi_probe.cvsi_motor_load_one;
    cvsi_probe_all.cvsi_motor_load_two(this_subject,:,:,:)                = cvsi_probe.cvsi_motor_load_two;
    
    cvsi_probe_all.cvsi_visual_load_one_dial_up(this_subject,:,:,:)       = cvsi_probe.cvsi_visual_load_one_dial_up;
    cvsi_probe_all.cvsi_visual_load_two_dial_up(this_subject,:,:,:)       = cvsi_probe.cvsi_visual_load_two_dial_up;
    cvsi_probe_all.cvsi_visual_load_one_dial_right(this_subject,:,:,:)    = cvsi_probe.cvsi_visual_load_one_dial_right;
    cvsi_probe_all.cvsi_visual_load_two_dial_right(this_subject,:,:,:)    = cvsi_probe.cvsi_visual_load_two_dial_right;
    cvsi_probe_all.cvsi_visual_load_one(this_subject,:,:,:)               = cvsi_probe.cvsi_visual_load_one;
    cvsi_probe_all.cvsi_visual_load_two(this_subject,:,:,:)               = cvsi_probe.cvsi_visual_load_two;

end  
 
% Average

mean_cvsi_probe_all = selectfields(cvsi_probe_all,{'label', 'time', 'freq', 'dimord'});

mean_cvsi_probe_all.cvsi_motor_load_one_dial_up        = squeeze(mean(cvsi_probe_all.cvsi_motor_load_one_dial_up));
mean_cvsi_probe_all.cvsi_motor_load_two_dial_up        = squeeze(mean(cvsi_probe_all.cvsi_motor_load_two_dial_up));
mean_cvsi_probe_all.cvsi_motor_load_one_dial_right     = squeeze(mean(cvsi_probe_all.cvsi_motor_load_one_dial_right));
mean_cvsi_probe_all.cvsi_motor_load_two_dial_right     = squeeze(mean(cvsi_probe_all.cvsi_motor_load_two_dial_right));
mean_cvsi_probe_all.cvsi_motor_load_one                = squeeze(mean(cvsi_probe_all.cvsi_motor_load_one));
mean_cvsi_probe_all.cvsi_motor_load_two                = squeeze(mean(cvsi_probe_all.cvsi_motor_load_two));

mean_cvsi_probe_all.cvsi_visual_load_one_dial_up       = squeeze(mean(cvsi_probe_all.cvsi_visual_load_one_dial_up));
mean_cvsi_probe_all.cvsi_visual_load_two_dial_up       = squeeze(mean(cvsi_probe_all.cvsi_visual_load_two_dial_up));
mean_cvsi_probe_all.cvsi_visual_load_one_dial_right    = squeeze(mean(cvsi_probe_all.cvsi_visual_load_one_dial_right));
mean_cvsi_probe_all.cvsi_visual_load_two_dial_right    = squeeze(mean(cvsi_probe_all.cvsi_visual_load_two_dial_right));
mean_cvsi_probe_all.cvsi_visual_load_one               = squeeze(mean(cvsi_probe_all.cvsi_visual_load_one));
mean_cvsi_probe_all.cvsi_visual_load_two               = squeeze(mean(cvsi_probe_all.cvsi_visual_load_two));
 
%% Plot TFR motor - both dials

% % Load one:
[h,~,~,t]                                        = ttest(cvsi_probe_all.cvsi_motor_load_one);
mean_cvsi_probe_all.cvsi_motor_load_one_Masked   = mean_cvsi_probe_all.cvsi_motor_load_one .* squeeze(h); % values with significant t-test preserved, rest 0.

% % Load two:
[h,~,~,t]                                        = ttest(cvsi_probe_all.cvsi_motor_load_two);
mean_cvsi_probe_all.cvsi_motor_load_two_Masked   = mean_cvsi_probe_all.cvsi_motor_load_two .* squeeze(h); % values with significant t-test preserved, rest 0.

titles_probe_contrasts = {'cvsi motor - load1', 'cvsi motor - load2'};
% probe_contrasts = {mean_cvsi_probe_all.cvsi_motor_load_one, mean_cvsi_probe_all.cvsi_motor_load_two};
probe_contrasts = {mean_cvsi_probe_all.cvsi_motor_load_one_Masked, mean_cvsi_probe_all.cvsi_motor_load_two_Masked};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(probe_contrasts)
    subplot(1, length(probe_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(probe_contrasts{contrast}); % select data
    contourf(mean_cvsi_probe_all.time, mean_cvsi_probe_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_probe_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot TFR visual - both dials

% % Load one:
[h,~,~,t]                                           = ttest(cvsi_probe_all.cvsi_visual_load_one);
mean_cvsi_probe_all.cvsi_visual_load_one_Masked     = mean_cvsi_probe_all.cvsi_visual_load_one .* squeeze(h); % values with significant t-test preserved, rest 0.

% % Load two:
[h,~,~,t]                                           = ttest(cvsi_probe_all.cvsi_visual_load_two);
mean_cvsi_probe_all.cvsi_visual_load_two_Masked     = mean_cvsi_probe_all.cvsi_visual_load_two .* squeeze(h); % values with significant t-test preserved, rest 0.

titles_probe_contrasts = {'cvsi visual - load1', 'cvsi visual - load2'};
% probe_contrasts = {mean_cvsi_probe_all.cvsi_visual_load_one, mean_cvsi_probe_all.cvsi_visual_load_two};
probe_contrasts = {mean_cvsi_probe_all.cvsi_visual_load_one_Masked, mean_cvsi_probe_all.cvsi_visual_load_two_Masked};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-5,5];

figure;

for contrast = 1:length(probe_contrasts)
    subplot(1, length(probe_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(probe_contrasts{contrast}); % select data
    contourf(mean_cvsi_probe_all.time, mean_cvsi_probe_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_probe_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot TFR motor - up vs right

% % Load one:
% Up
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_motor_load_one_dial_up);
mean_cvsi_probe_all.cvsi_motor_load_one_dial_up_Masked      = mean_cvsi_probe_all.cvsi_motor_load_one_dial_up .* squeeze(h); % values with significant t-test preserved, rest 0.
% Right
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_motor_load_one_dial_right);
mean_cvsi_probe_all.cvsi_motor_load_one_dial_right_Masked   = mean_cvsi_probe_all.cvsi_motor_load_one_dial_right .* squeeze(h); % values with significant t-test preserved, rest 0.

% % Load two:
% Up
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_motor_load_two_dial_up);
mean_cvsi_probe_all.cvsi_motor_load_two_dial_up_Masked      = mean_cvsi_probe_all.cvsi_motor_load_two_dial_up .* squeeze(h); % values with significant t-test preserved, rest 0.
% Right
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_motor_load_two_dial_right);
mean_cvsi_probe_all.cvsi_motor_load_two_dial_right_Masked   = mean_cvsi_probe_all.cvsi_motor_load_two_dial_right .* squeeze(h); % values with significant t-test preserved, rest 0.

titles_probe_contrasts = {'cvsi motor - load1 - dial up', 'cvsi motor - load2 - dial up', 'cvsi motor - load1 - dial right', 'cvsi motor - load2 - dial right'};
% probe_contrasts = {mean_cvsi_probe_all.cvsi_motor_load_one_dial_up, mean_cvsi_probe_all.cvsi_motor_load_two_dial_up, mean_cvsi_probe_all.cvsi_motor_load_one_dial_right, mean_cvsi_probe_all.cvsi_motor_load_two_dial_right};
probe_contrasts = {mean_cvsi_probe_all.cvsi_motor_load_one_dial_up_Masked, mean_cvsi_probe_all.cvsi_motor_load_two_dial_up_Masked, mean_cvsi_probe_all.cvsi_motor_load_one_dial_right_Masked, mean_cvsi_probe_all.cvsi_motor_load_two_dial_right_Masked};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-20,20];

figure;

for contrast = 1:length(probe_contrasts)
    subplot(1, length(probe_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(probe_contrasts{contrast}); % select data
    contourf(mean_cvsi_probe_all.time, mean_cvsi_probe_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_probe_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot TFR visual - up vs right

% % Load one:
% Up
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_visual_load_one_dial_up);
mean_cvsi_probe_all.cvsi_visual_load_one_dial_up_Masked     = mean_cvsi_probe_all.cvsi_visual_load_one_dial_up .* squeeze(h); % values with significant t-test preserved, rest 0.
% Right
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_visual_load_one_dial_right);
mean_cvsi_probe_all.cvsi_visual_load_one_dial_right_Masked  = mean_cvsi_probe_all.cvsi_visual_load_one_dial_right .* squeeze(h); % values with significant t-test preserved, rest 0.

% % Load two:
% Up
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_visual_load_two_dial_up);
mean_cvsi_probe_all.cvsi_visual_load_two_dial_up_Masked     = mean_cvsi_probe_all.cvsi_visual_load_two_dial_up .* squeeze(h); % values with significant t-test preserved, rest 0.
% Right
[h,~,~,t]                                                   = ttest(cvsi_probe_all.cvsi_visual_load_two_dial_right);
mean_cvsi_probe_all.cvsi_visual_load_two_dial_right_Masked  = mean_cvsi_probe_all.cvsi_visual_load_two_dial_right .* squeeze(h); % values with significant t-test preserved, rest 0.

titles_probe_contrasts = {'cvsi visual - load1 - dial up',  'cvsi visual - load2 - dial up', 'cvsi visual - load1 - dial right', 'cvsi visual - load2 - dial right'};
% probe_contrasts = {mean_cvsi_probe_all.cvsi_visual_load_one_dial_up, mean_cvsi_probe_all.cvsi_visual_load_two_dial_up, mean_cvsi_probe_all.cvsi_visual_load_one_dial_right, mean_cvsi_probe_all.cvsi_visual_load_two_dial_right};
probe_contrasts = {mean_cvsi_probe_all.cvsi_visual_load_one_dial_up_Masked, mean_cvsi_probe_all.cvsi_visual_load_two_dial_up_Masked, mean_cvsi_probe_all.cvsi_visual_load_one_dial_right_Masked, mean_cvsi_probe_all.cvsi_visual_load_two_dial_right_Masked};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(probe_contrasts)
    subplot(1, length(probe_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(probe_contrasts{contrast}); % select data
    contourf(mean_cvsi_probe_all.time, mean_cvsi_probe_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_probe_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot timecourses motor - both dials

beta_index = mean_cvsi_probe_all.freq >= param.betaband(1) & mean_cvsi_probe_all.freq <= param.betaband(2);

cvsi_motor_load_one_beta      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_one(:,:,beta_index,:)),2));
cvsi_motor_load_two_beta      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_two(:,:,beta_index,:)),2));

figure; sgtitle("motor-beta post-probe")
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_one_beta, 'blue', 'se');
hold on;
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_two_beta, 'red', 'se');
xlim([-0.5 2.5]); ylim([-10 15])
yline(0); xline(0)

%% Plot timecourses visual - both dials
alpha_index = mean_cvsi_probe_all.freq >= param.alphaband(1) & mean_cvsi_probe_all.freq <= param.alphaband(2);

cvsi_visual_load_one_alpha      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_one(:,:,alpha_index,:)),2));
cvsi_visual_load_two_alpha      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_two(:,:,alpha_index,:)),2));

figure; sgtitle("visual-alpha post-probe")
frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_load_one_alpha, 'blue', 'se');
hold on;
frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_load_two_alpha, 'red', 'se');
xlim([-0.5 2.5]); ylim([-5 5])
yline(0); xline(0)

%% Plot timecourse vis & mot load one

figure;
sgtitle("visual-motor load-two post-probe")
frevede_errorbarplot(cvsi_probe_all.time, cvsi_motor_load_one_beta, 'blue', 'se');
hold on;
frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_load_one_alpha, 'red', 'se');
xlim([-0.5 2.5]); ylim([-10 10])
yline(0); xline(0)

%% Plot timecourse vis & mot load two

figure;
sgtitle("visual-motor load-two post-probe")
frevede_errorbarplot(cvsi_probe_all.time, cvsi_motor_load_two_beta, 'blue', 'se');
hold on;
frevede_errorbarplot(cvsi_probe_all.time, cvsi_visual_load_two_alpha, 'red', 'se');
xlim([-0.5 2.5]); ylim([-10 10])
yline(0); xline(0)

%% Plot timecourses - up vs right dial

cvsi_motor_load_one_beta_dial_up         = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_one_dial_up(:,:,beta_index,:)),2));
cvsi_motor_load_one_beta_dial_right      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_one_dial_right(:,:,beta_index,:)),2));
cvsi_motor_load_two_beta_dial_up         = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_two_dial_up(:,:,beta_index,:)),2));
cvsi_motor_load_two_beta_dial_right      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_motor_load_two_dial_right(:,:,beta_index,:)),2));

cvsi_visual_load_one_beta_dial_up         = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_one_dial_up(:,:,alpha_index,:)),2));
cvsi_visual_load_one_beta_dial_right      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_one_dial_right(:,:,alpha_index,:)),2));
cvsi_visual_load_two_beta_dial_up         = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_two_dial_up(:,:,alpha_index,:)),2));
cvsi_visual_load_two_beta_dial_right      = squeeze(mean(squeeze(cvsi_probe_all.cvsi_visual_load_two_dial_right(:,:,alpha_index,:)),2));

figure;
% One & up
subplot(2,2,1)
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_one_beta_dial_up, 'blue', 'se');
hold on;
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_visual_load_one_beta_dial_up, 'red', 'se');
title('Load one - dial up')
yline(0); xline(0)

% One & right
subplot(2,2,2)
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_one_beta_dial_right, 'blue', 'se');
hold on;
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_visual_load_one_beta_dial_right, 'red', 'se');
title('Load one - dial right')
yline(0); xline(0)

% Two & up
subplot(2,2,3)
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_two_beta_dial_up, 'blue', 'se');
hold on;
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_visual_load_two_beta_dial_up, 'red', 'se');
title('Load two - dial up')
yline(0); xline(0)

% Two & right
subplot(2,2,4)
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_motor_load_two_beta_dial_right, 'blue', 'se');
hold on;
frevede_errorbarplot(mean_cvsi_probe_all.time, cvsi_visual_load_two_beta_dial_right, 'red', 'se');
title('Load two - dial right')
yline(0); xline(0)
