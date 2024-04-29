%% step01a_head_raw_data_GM_calculate.m
% Updated 04.27.2024
% LIMBS Lab
% Author: Huanying (Joy) Yeh

% Experiment Name: Eigenmannia Virescens Luminance + Locomotion Comparisons
%
% Content:
% - Use the raw data (x and y time-domain values) struct and clean to get
% clean trial and rep names [Mahal distances, lots of pre-cleaning] [TODO]
% - Use functions to calculate and populate GM and CP
% - Output: "data_clean_head.mat"

% [INPUT]
parent_dir = fullfile(pwd, '..', '..');
abs_path = fullfile(parent_dir, 'data_structures\');

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numIls = [14, 9, 11, 9, 9];
numFish = 5;

k = [2, 3, 5, 7, 11, 13, 19, 23, 29, 31, 37, 41];

% get the HALF CLEAN data
% all_fish = load(fullfile(abs_path, 'data_raw_head.mat'), 'all_fish').all_fish;
all_fish = load(fullfile(abs_path, 'data_raw_head.mat'),'h').h;
shuttle = load(fullfile(abs_path, '\helper_structs\helper_shuttle.mat'), 'shuttle').shuttle;

% RE calculate GM and CP

% k is the list of frequency multiples
k = [2, 3, 5, 7, 11, 13, 19, 23, 29, 31, 37, 41];
freq_scalar = 0.05;

% Mean of each case

% Make the new container
S = fftshift(fft(shuttle));

for fish_idx = 1 : numFish
    fish_name = fishNames{fish_idx};
    num_il_levels = numel(all_fish(fish_idx).data);

    for il = 1 : num_il_levels


        num_trials = numel(all_fish(fish_idx).data(il).fishX);

        all_fish(fish_idx).data(il).GM = {};
        all_fish(fish_idx).data(il).gmGain = {};
        all_fish(fish_idx).data(il).gmPhase = {};

        all_fish(fish_idx).data(il).CP = {};
        all_fish(fish_idx).data(il).cpGain = {};
        all_fish(fish_idx).data(il).cpPhase = {};

        for trial_idx = 1 : num_trials

            data = cell2mat(all_fish(fish_idx).data(il).fishX(trial_idx));


            FM = fftshift(fft(data));
            GM = zeros(size(k));
            PM = zeros(size(k));

            for j = 1:length(k) % Calculate the GM of each frequency band with S, the FFT of the shuttle input
                % length()/2 + 1 is for fixing idx offsets from the fftshift() flipping
                % GM = "gain mean"
                GM(1,j) =  FM((length(FM)/2)+1+k(j)) / S((length(FM)/2+1)+k(j));
            end

            % Phase mean in degrees
            PM = rad2deg(unwrap(angle(GM)));
            PM = calibratePhase(PM, GM);

            all_fish(fish_idx).data(il).GM{trial_idx}= GM;
            all_fish(fish_idx).data(il).gmGain{trial_idx}= abs(GM);
            all_fish(fish_idx).data(il).gmPhase{trial_idx} = PM;

            CP = GM ./ (1 - GM);
            all_fish(fish_idx).data(il).CP{trial_idx} = CP;

            CPM = rad2deg(unwrap(angle(CP)));
            all_fish(fish_idx).data(il).cpGain{trial_idx} = abs(CP);
            all_fish(fish_idx).data(il).cpPhase{trial_idx} = CPM;
        end
    end
end

%% 3. Update and save to a new struct
save([abs_path, 'data_raw_head_with_GM.mat'], 'all_fish');
disp("SUCCESS: /data_structures/data_raw_head_with_GM.mat generated with open-loop and closed-loop CP.")


% Helper: calibratePhase
function [M] = calibratePhase(M, G)
for i = 1 : length(G)
    if M(i) > 90
        M(i) = M(i) - 360;
    end

    if M(i) < -270
        M(i) = M(i) + 360;
    end
end
end



