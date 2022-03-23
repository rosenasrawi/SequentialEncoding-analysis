%% Parameters

% Function to specify general parameters of study rn3 (sequential encoding).
% Input: subject ID as a number
% Output: param and filenames for subjects

function [param, eegfiles] = rn3_gen_param(this_subject)

    % Paths
    param.EEGpath           = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn3 - Sequential encoding/Data/Lab data/eegdata/';
    param.path              = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn3 - Sequential encoding/Data/';
    param.combinedLogfile   = '/Users/rosenasrawi/Documents/VU PhD/Projects/rn3 - Sequential encoding/Data/Processed/Behavior/logfiles_combined_rn3.csv';
    
    % Subjects and sessions
    param.subjectIDs    = {'s01', 's02', 's03', 's04', 's05', 's06', 's07', 's08', 's09', 's10', 's11', 's12', 's13', 's14', 's15', 's16', 's17', 's18', 's19', 's20', 's21', 's22', 's23', 's24', 's25', 's26', 's27'};
    
    eegfiles = {strcat('rn3_', param.subjectIDs{this_subject}, 'a', '.bdf'); 
                strcat('rn3_', param.subjectIDs{this_subject}, 'b', '.bdf')};
    
    % Frequency bands
    param.betaband           = [10 25];
    param.alphaband          = [ 8 12];
    param.mubetaband         = [13 30];
    
    % Electrodes
    param.C3                 = 'C3';
    param.C4                 = 'C4';
    param.chan_motor_left    = {'C3','C1','CP3','FC3'};
    param.chan_motor_right   = {'C4','C2','CP4','FC4'};
    
    param.PO7                = 'PO7';
    param.PO8                = 'PO8';
    param.chan_visual_left   = {'O1', 'P03', 'P07'};
    param.chan_visual_left   = {'O2', 'P04', 'P08'};
    
    % Times
    param.T_enc1_window      = [1 4];
    param.T_probe_window     = [1 3];
    param.T_resp_window      = [1.5 2.5];
    param.T_delay            = [0 3]; 
    
    % Time selection plotting
    param.T1                 = [-0.5 2];
    param.T2                 = [0.5 3];
    
    param.T1_enc             = [0.5 0.9];
    param.T2_enc             = [1.5 1.9];
    
    % Triggers
    
    % Moments
    param.triggers_enc1             = [1:8, 51:58, 101:108, 151:158];                                     % Encoding 1
    param.triggers_enc2             = [11:18, 61:68, 111:118, 161:168];                                   % Encoding 2
    param.triggers_probe            = [21:28, 71:78, 121:128, 171:178];                                   % Probe
    param.triggers_resp             = [31:38, 41:48, 81:88, 91:98, 131:138, 141:148, 181:188, 191:198];   % Response
    param.triggers_resp_left        = [31:38, 81:88, 131:138, 181:188];
    param.triggers_resp_right       = [41:48, 91:98, 141:148, 191:198];
        
    % Conditions
    param.triggers_load1            = [1:8, 11:18, 21:28, 31:38, 41:48, 101:108, 111:118, 121:128, 131:138, 141:148];
    param.triggers_load2            = [51:58, 61:68, 71:78, 81:88, 91:98, 151:158, 161:168, 171:178, 181:188, 191:198];
    
    param.triggers_dial_up          = [1:8, 11:18, 21:28, 31:38, 41:48, 51:58, 61:68, 71:78, 81:88, 91:98];
    param.triggers_dial_right       = [101:108, 111:118, 121:128, 131:138, 141:148, 151:158, 161:168, 171:178, 181:188, 191:198];

    param.triggers_item_left        = [[1,2,5,6,[1,2,5,6]+10,[1,2,5,6]+20,[1,2,5,6]+30,[1,2,5,6]+40,[1,2,5,6]+50,[1,2,5,6]+60,[1,2,5,6]+70,[1,2,5,6]+80,[1,2,5,6]+90], [1,2,5,6,[1,2,5,6]+10,[1,2,5,6]+20,[1,2,5,6]+30,[1,2,5,6]+40,[1,2,5,6]+50,[1,2,5,6]+60,[1,2,5,6]+70,[1,2,5,6]+80,[1,2,5,6]+90]+100];
    param.triggers_item_right       = [[3,4,7,8,[3,4,7,8]+10,[3,4,7,8]+20,[3,4,7,8]+30,[3,4,7,8]+40,[3,4,7,8]+50,[3,4,7,8]+60,[3,4,7,8]+70,[3,4,7,8]+80,[3,4,7,8]+90], [3,4,7,8,[3,4,7,8]+10,[3,4,7,8]+20,[3,4,7,8]+30,[3,4,7,8]+40,[3,4,7,8]+50,[3,4,7,8]+60,[3,4,7,8]+70,[3,4,7,8]+80,[3,4,7,8]+90]+100];
    
    param.triggers_target_T1        = [1:4, 11:14, 21:24, 31:34, 41:44, 51:54, 61:64, 71:74, 81:84, 91:94, 101:104, 111:114, 121:124, 131:134, 141:144, 151:154, 161:164, 171:174, 181:184, 191:194];
    param.triggers_target_T2        = [5:8, 15:18, 25:28, 35:38, 45:48, 55:58, 65:68, 75:78, 85:88, 95:98, 105:108, 115:118, 125:128, 135:138, 145:148, 155:158, 165:168, 175:178, 185:188, 195:198];
    
    param.triggers_reqresp_left     = [[1,3,5,7,[1,3,5,7]+10,[1,3,5,7]+20,[1,3,5,7]+30,[1,3,5,7]+40,[1,3,5,7]+50,[1,3,5,7]+60,[1,3,5,7]+70,[1,3,5,7]+80,[1,3,5,7]+90], [1,3,5,7,[1,3,5,7]+10,[1,3,5,7]+20,[1,3,5,7]+30,[1,3,5,7]+40,[1,3,5,7]+50,[1,3,5,7]+60,[1,3,5,7]+70,[1,3,5,7]+80,[1,3,5,7]+90]+100];
    param.triggers_reqresp_right    = [[2,4,6,8,[2,4,6,8]+10,[2,4,6,8]+20,[2,4,6,8]+30,[2,4,6,8]+40,[2,4,6,8]+50,[2,4,6,8]+60,[2,4,6,8]+70,[2,4,6,8]+80,[2,4,6,8]+90], [2,4,6,8,[2,4,6,8]+10,[2,4,6,8]+20,[2,4,6,8]+30,[2,4,6,8]+40,[2,4,6,8]+50,[2,4,6,8]+60,[2,4,6,8]+70,[2,4,6,8]+80,[2,4,6,8]+90]+100];

    % Bad channels in order of subject
    
    % sub                     [1]                                                [2]                                                [3]        [4]  [5]  [6]  [7]  [8]  [9]  [10] [11]  [12]           [13] [14] [15] [16] [17]  [18]           [19] [20] [21] [22] [23] [24] [25] [26] [27]        
    param.badchan      = {  {'B14',         'A26',          'A29'},            {'B31',         'B15',        'A15'},               'B8',       ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ',  'A30',         ' ', ' ', ' ', ' ', ' ',  'A29',         ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', 'B25'}; 
    param.replacechan  = { {{'B15','B13'}, {'A25', 'A27'}, {'A30', 'A28'} }, { {'A30','B30'}, {'B16','B6'}, {'A16','A8','A14'} }, {'B7','B9'}, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', {'A29', 'A31'}, ' ', ' ', ' ', ' ', ' ', {'A28', 'A30'}, ' ', ' ', ' ', ' ', ' ', ' ', ' ', ' ', {'A31', 'B26'}};
    
end