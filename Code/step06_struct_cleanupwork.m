% step07: fish head struct clean up intermediate step
% Re-name the variables in the head big struct (for Hope) 
% updated 12/22/2023

% load the struct
load('hope.mat');

close all;
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\';
mBody = load([abs_path, 'all_fish_full_length_data.mat']); % All the raw + cleaned data labels for Bode analyis

% Grab fish #1, Hope
hb = mBody.all_fish_data(1).luminance;

h = {};

for il = 1 : size(hope, 2)
    h(il).luxTick = hope(il).luxTick;
    h(il).luxTickActual = hope(il).luxTickActual;
    h(il).testID_all = hope(il).testID;
    h(il).repID_all = hope(il).repID;

    % Get the trial numbers grouping by il
    % h(il).expIdx_all = unique(cell2mat(h(il).testID_all));
    h(il).expIdx_all = hb(il).trial_indices;

    h(il).shuttleX_all = hope(il).shuttleX;
    % Get the raw x-data of the head (head doesn't have y?)
    h(il).headX_all = hope(il).fishX;
    % [TODO: STILL MISSING Y VALUES. ADD THEM HERE]

    body = hb(il).data;
    h(il).bodyX_all = {};

    for tr_idx = 1 : size(body, 2)
        h(il).bodyX_all = [h(il).bodyX_all, body(tr_idx).x_rep1, body(tr_idx).x_rep2, body(tr_idx).x_rep3];
    end
    
    
    % Time domain tags and clean head data
    h(il).xTr = hope(il).xClean02Tr;
    h(il).xRep = hope(il).xClean02Rep;

    h(il).x = hope(il).xClean02;
    h(il).xMean = hope(il).xClean02Mean;

    % [TODO] Populate head y and head y mean (clean)

    % CP fields renamed
    h(il).cp = hope(il).cpClean02;
    h(il).cpGain = hope(il).cpGain02;
    h(il).cpPhase = hope(il).cpPhase02;

    % GM fields renamed
    h(il).gm = hope(il).GM02;
    h(il).gmGain= hope(il).gainMean02;
    h(il).gmPhase = hope(il).phaseMean02;

end

save('h.mat', 'h')
save('hb.mat', 'hb')


