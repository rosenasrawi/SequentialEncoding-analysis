%% Clear workspace

clc; clear; close all

%% Define parameters

subjects = 1:12;

%% Loop

for this_subject = subjects
    %% Parameters
    
    [param, eegfiles] = rn3_gen_param(this_subject);
    
    %% load 
    
    load([param.path, 'Processed/EEG/Locked response/tfr contrasts response/' 'cvsi_response_' param.subjectIDs{this_subject}], 'cvsi_response');
    
    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        cvsi_response_all = selectfields(cvsi_response,{'label', 'time', 'freq', 'dimord'});
    end
    
    %% add to all sub structure
    
    cvsi_response_all.cvsi_motor_dial_up(this_subject,:,:,:)        = cvsi_response.cvsi_motor_dial_up;
    cvsi_response_all.cvsi_motor_dial_right(this_subject,:,:,:)     = cvsi_response.cvsi_motor_dial_right;
    cvsi_response_all.cvsi_motor_both_dials(this_subject,:,:,:)     = cvsi_response.cvsi_motor_both_dials;

end

%% Average

mean_cvsi_response_all = selectfields(cvsi_response_all,{'label', 'time', 'freq', 'dimord'});

mean_cvsi_response_all.cvsi_motor_dial_up       = squeeze(mean(cvsi_response_all.cvsi_motor_dial_up));
mean_cvsi_response_all.cvsi_motor_dial_right    = squeeze(mean(cvsi_response_all.cvsi_motor_dial_right));
mean_cvsi_response_all.cvsi_motor_both_dials    = squeeze(mean(cvsi_response_all.cvsi_motor_both_dials));

%% Plot TFR motor - up, right, both dials

titles_resp_contrasts = {'cvsi motor - dial up', 'cvsi motor - dial right', 'cvsi motor - both dials'};
resp_contrasts = {mean_cvsi_response_all.cvsi_motor_dial_up, mean_cvsi_response_all.cvsi_motor_dial_right, mean_cvsi_response_all.cvsi_motor_both_dials};

cfg = [];
cfg.colorbar = 'no';
cfg.zlim = [-10,10];

figure;

for contrast = 1:length(resp_contrasts)
    subplot(1, length(resp_contrasts), contrast);   %(this_subject-1)*length(enc_contrasts)+contrast  % subplot_add(this_subject)+contrast)

    colormap(flipud(brewermap(100,'RdBu')));

    data2plot = squeeze(resp_contrasts{contrast}); % select data
    contourf(mean_cvsi_response_all.time, mean_cvsi_response_all.freq, data2plot, 500, 'linecolor', 'none'); % this instead of ft_singleplotTFR
    xline(0)

    title(titles_resp_contrasts{contrast})

    caxis(cfg.zlim)
    colorbar
end    

%% Plot timecourses motor - up, right, both dials

beta_index = mean_cvsi_response_all.freq >= param.betaband(1) & mean_cvsi_response_all.freq <= param.betaband(2);

cvsi_motor_dial_up      = squeeze(mean(mean_cvsi_response_all.cvsi_motor_dial_up(beta_index,:)));
cvsi_motor_dial_right   = squeeze(mean(mean_cvsi_response_all.cvsi_motor_dial_right(beta_index,:)));
cvsi_motor_both_dials   = squeeze(mean(mean_cvsi_response_all.cvsi_motor_both_dials(beta_index,:)));

plot(mean_cvsi_response_all.time, cvsi_motor_dial_up, 'blue');
hold on;
plot(mean_cvsi_response_all.time, cvsi_motor_dial_right, 'red');
plot(mean_cvsi_response_all.time, cvsi_motor_both_dials, 'green');

yline(0); xline(0)
