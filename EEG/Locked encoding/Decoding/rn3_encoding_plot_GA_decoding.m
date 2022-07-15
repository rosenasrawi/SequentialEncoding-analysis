%% Clear workspace

clc; clear; close all

%% Define parameters

subjectIDs = [1:5,7:19,21:27];
subjects = 1:25;

%% Load data files

for this_subject = subjects
    
    %% Parameters
    sub = subjectIDs(this_subject);
    [param, eegfiles] = rn3_gen_param(sub);
    
    load([param.path, 'Processed/EEG/Locked encoding/decoding/' 'decoding_' param.subjectIDs{sub}], 'decoding');

    fn = fieldnames(decoding);
    fn = fn(~contains(fn, 'time'));
    
    for f = 1:length(fn)
        decoding_all.(fn{f})(this_subject,:) = squeeze(mean(decoding.(fn{f})));
    end

    decoding_all.time = decoding.time;

end

%% Plot variables
decoding_titles = {'Load one - T1', 'Load one - T2', 'Load two'};
linecolors = {[140/255, 69/255, 172/255], [140/255, 69/255, 172/255], [80/255, 172/255, 123/255]};

fn = fieldnames(decoding_all);

motor_correct = fn(contains(fn, 'motor_correct'));
motor_distance = fn(contains(fn, 'motor_distance'));

motor_beta_correct = fn(contains(fn, 'motor_beta_correct'));
motor_beta_distance = fn(contains(fn, 'motor_beta_distance'));

visual_correct = fn(contains(fn, 'visual_correct'));
visual_distance = fn(contains(fn, 'visual_distance'));

visual_alpha_correct = fn(contains(fn, 'visual_alpha_correct'));
visual_alpha_distance = fn(contains(fn, 'visual_alpha_distance'));

%% Plot motor

figure;
sgtitle('Motor selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_correct{i}), linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .8]); xlim([0 3500]); 

end

%% Plot visual

figure;
sgtitle('Visual selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    frevede_errorbarplot(decoding.time, decoding_all.(visual_correct{i}), linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .8]); xlim([0 3500]); 

end

%% Plot motor (beta)

figure;
sgtitle('Motor (beta) selection')

for i = 1:length(decoding_titles)   

    subplot(1,3,i)

    frevede_errorbarplot(decoding_all.time, decoding_all.(motor_beta_correct{i}), linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .8]); xlim([0 3500]); 

end

%% Plot visual (alpha)

figure;
sgtitle('Visual (alpha) selection')

for i = 1:length(decoding_titles)

    subplot(1,3,i)

    frevede_errorbarplot(decoding.time, decoding_all.(visual_alpha_correct{i}), linecolors{i}, 'se');

    title(decoding_titles{i}); 
    xlabel('time (s)'); ylabel('decoding accuracy');   

    xline(0, '--k'); xline(1000, '--k'); yline(0.5, '--k')
    ylim([.4 .8]); xlim([0 3500]); 

end