%% Clean workspace

clc; clear; close all

%% Define parameters

subjectIDs = [1:5,7:19,21:27];
subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    %% load 
    load([param.path, 'Processed/EEG/Locked encoding/tfr contrasts encoding/' 'full_perf_encoding_' param.subjectIDs{sub}], 'full_perf');

    if this_subject == 1 % Copy structure once for only label, time, freq, dimord
        full_perf_all = selectfields(full_perf,{'label', 'time', 'freq', 'dimord'});
    end
    
    full_perf_all.load_two_T1_fast_slow(this_subject,:,:,:)         = full_perf.load_two_T1_fast_slow;
    full_perf_all.load_two_T2_fast_slow(this_subject,:,:,:)         = full_perf.load_two_T2_fast_slow;
    full_perf_all.load_two_T1_T2_fast_slow(this_subject,:,:,:)      = full_perf.load_two_T1_fast_slow - full_perf.load_two_T2_fast_slow;

    
    full_perf_all.load_two_T1_prec_imprec(this_subject,:,:,:)       = full_perf.load_two_T1_prec_imprec .* -1; % Temporarily * -1, can remove after having rerun get-TFR
    full_perf_all.load_two_T2_prec_imprec(this_subject,:,:,:)       = full_perf.load_two_T2_prec_imprec .* -1;
    full_perf_all.load_two_T1_T2_prec_imprec(this_subject,:,:,:)    = full_perf.load_two_T1_prec_imprec .* -1 - full_perf.load_two_T2_prec_imprec  .* -1;

end

%% Average

mean_full_perf_all = selectfields(full_perf_all, {'label', 'time', 'freq', 'dimord'});

mean_full_perf_all.load_two_T1_fast_slow         = squeeze(mean(full_perf_all.load_two_T1_fast_slow));
mean_full_perf_all.load_two_T2_fast_slow         = squeeze(mean(full_perf_all.load_two_T2_fast_slow));
mean_full_perf_all.load_two_T1_T2_fast_slow      = squeeze(mean(full_perf_all.load_two_T1_T2_fast_slow));

mean_full_perf_all.load_two_T1_prec_imprec       = squeeze(mean(full_perf_all.load_two_T1_prec_imprec));
mean_full_perf_all.load_two_T2_prec_imprec       = squeeze(mean(full_perf_all.load_two_T2_prec_imprec));
mean_full_perf_all.load_two_T1_T2_prec_imprec    = squeeze(mean(full_perf_all.load_two_T1_T2_prec_imprec));

%% Save

save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/full_perf_all'], 'full_perf_all');
save ([param.path, '/Processed/EEG/Locked encoding/tfr contrasts encoding/mean_full_perf_all'], 'mean_full_perf_all');
