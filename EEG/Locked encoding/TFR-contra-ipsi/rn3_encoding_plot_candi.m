%% Clean workspace

clc; clear; close all

%% Parameters

sids = [1:5,7:19,21:27];

for s = 1:25

    sid = sids(s);

    % Parameters
    [param, eegfiles] = rn3_gen_param(sid);
    
    % Load
    load([param.path, 'Processed/EEG/Locked encoding/tfr candi/' 'candi_encoding_' param.subjectIDs{sid}], 'candi_encoding');

    if sid == 1 % Copy structure once for only label, time, freq, dimord
        candi_all = selectfields(candi_encoding, {'label', 'time', 'freq', 'dimord'});
        candi_all.label = {'C3'}; % CVSI, so only one channel per contrast
    end
    
    fn = fieldnames(candi_encoding);
    fn_TFR = fn(contains(fn, 'motor'));

    for f = 1:length(fn_TFR)
        candi_all.(fn_TFR{f})(s,:,:,:) = candi_encoding.(fn_TFR{f}); 
    end

end

%% Time-courses

beta = candi_all.freq >= 13 & candi_all.freq <= 30;

for f = 1:length(fn_TFR)
    field = fn_TFR{f};
    candi_all.(append(field, '_beta')) = squeeze(mean(squeeze(candi_all.(field)(:,:,beta,:)),2));
end

%% Plot variables

fn = fieldnames(candi_all);
fn_TC = fn(contains(fn, 'beta'));

fn_contra = fn_TC(contains(fn_TC, 'contra'));
fn_ipsi = fn_TC(contains(fn_TC, 'ipsi'));

load = {'One-T1', 'One-T2', 'Two'};
time = candi_all.time;

linecolors = {[140/255, 69/255, 172/255],[80/255, 172/255, 123/255]};

%% Plot TC

t_bl = time >= -0.5 & time <= -0.15;

figure;

for i = 1:length(load)
    
    subplot(1,3,i)

    contra = candi_all.(fn_contra{i});
    contra_bl = mean(contra(:,t_bl),2);
    contra = contra - contra_bl;

    ipsi = candi_all.(fn_ipsi{i});
    ipsi_bl = mean(ipsi(:,t_bl),2);
    ipsi = ipsi - ipsi_bl;

    frevede_errorbarplot(time, contra, linecolors{1}, 'se');
    frevede_errorbarplot(time, ipsi, linecolors{2}, 'se');

    xline(0); xline(1); xline(3); yline(0)
    xlim([-0.5 3]); ylim([-3*10^-8 1*10^-8])

end

set(gcf, "renderer", "Painters");
set(gcf, "Position", [500 500 1500 300]);

%% Save fig

saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-candi'], 'epsc');
saveas(gcf, [param.figpath 'TFR-cvsi/new/TC-candi'], 'png');
