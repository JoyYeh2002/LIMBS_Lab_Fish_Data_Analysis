% Cache 02: SICB data loader
close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
out_dir_figures = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\AAA_playground\';

mBody = load([abs_path, 'all_fish_full_length_data.mat']); % All the raw + cleaned data labels for Bode analyis
mHead = load([abs_path, 'all_fish_head_point_time_freq_data.mat']); % All the raw + cleaned data labels for Bode analyis


% Create the empty merged struct
all_fish = mHead.m.group;

all_fish(1).name = 'Hope';
all_fish(2).name = 'Len';
all_fish(3).name = 'Doris';
all_fish(4).name = 'Finn';
all_fish(5).name = 'Ruby';


all_fish(1).bodyData = mBody.all_fish_data(1).luminance;
all_fish(2).bodyData = mBody.all_fish_data(3).luminance;
all_fish(3).bodyData = mBody.all_fish_data(5).luminance;
all_fish(4).bodyData = mBody.all_fish_data(4).luminance;
all_fish(5).bodyData = mBody.all_fish_data(2).luminance;

hope = all_fish(1).fishData;
hope = rmfield(hope, {'conductivity', 'illumination','cp02', 'allVar', 'meanVar'});
save('hope.mat', 'hope')
% 
% h = {};
% h.luxTixk = hope.luxTick;
% master_struct ----------- [LEGACY CODE 12/02/2023]

% master_struct = load([abs_path, 'fishBodeMasterStruct.mat']); % All the raw + cleaned data labels for Bode analyis
% shuttle_array = load([abs_path, 'shuttle.mat']); % the 500 x 1 double array for the shuttle (head direction = R)
% sigfit_data = load([abs_path, 'sigFitStruct.mat']); % The 4 frequency ranges and their corresponding phase response (52 data points)
% sig_curve_params = load([abs_path, 'sigParams.mat']); % The smooth curve fitted onto the sigmoid fit (A, B, C, D)
% 
% doris_leg = load([abs_path, 'legacy_fish_structs/dorisBigStruct.mat']);
% doris_leg2 = load([abs_path, 'legacy_fish_structs/dorisElevenCleanBode.mat']);
% 
% 
% m = load([abs_path, 'fishBodeMasterStruct.mat']); % All the raw + cleaned data labels for Bode analyis
% for fishIdx = 1 : 5
%     m.group(fishIdx).fishData= rmfield(m.group(fishIdx).fishData, {'fishXClean', 'fishXCleanTr', 'fishXCleanRep', 'fishXMeanClean', ...
%         'fishGainClean', 'fishPhaseClean', 'gainMeanClean', 'phaseMeanClean', 'cpClean', 'cpGain', 'cpPhase', 'rms'});
%     m.group(fishIdx).fishData= rmfield(m.group(fishIdx).fishData, {'xPosValidity', 'numOutliers'});
% end
% 
% save('fishBodeMasterStruct.mat', 'm')