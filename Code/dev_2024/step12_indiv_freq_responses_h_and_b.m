%% Step12_indiv_freq_responses_h_and_b.m
% [Updated 02.19.2024]
% Content:
% - Re-format from SICB data
% - Re-caculate the frequency responses from "head_point.mat" and append to
% - Then, refer to the body "clean tags" and "tail point FFT" to try to
% classify them into categories

close all;

%% 1. Load head and body.m
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

load([abs_path, 'clean_data_head_point.mat']) % head struct: "h"
b = load([abs_path, 'raw_data_full_body.mat']); % body struct: "b"
b = b.all_fish;
load([abs_path, 'shuttle.mat']); % "shuttle" is 500x1 double

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

%% 2. Loop through all fish
for i = 1 : numFish
    fish_name = fishNames{i};
    num_il_levels = numel(h(i).data);
    data = h(i).data;

    for il = 1 : num_il_levels
        num_trials = numel(data(il).fishX);
        this_il_gain = cell(1, num_trials);
        this_il_phase = cell(1, num_trials);
        this_il_cp = cell(1, num_trials);

        % Loop through every trial
        for idx = 1 : num_trials
            currFish = data(il).fishX{idx}; % 500x1 double
            currFish = fillmissing(currFish,'spline'); 
            F = fftshift(fft(currFish)); % 500x1 complex
            S = fftshift(fft(shuttle));  % 500x1 complex

            % GM gain
            G = zeros(size(k));
            for p = 1:length(k)
                G(p) =  F((length(F)/2)+1+k(p)) / S((length(F)/2+1)+k(p));
            end
            
            % GM phase
            P = rad2deg(unwrap(angle(G))); % 1 * 12 double in degrees for 1 trial
            P = calibratePhase(P, G); 
        
            % The gain and phase cell matrix of this trial
            this_il_gain{idx} = abs(G); % 1x17 cell
            this_il_phase{idx} = P;     % 1x17 cell
            this_il_cp{idx} = G ./ (1 - G);
        end

        % we already have all the mean values. This is ALL TRIALS
        h(i).data(il).gmGainAll = this_il_gain;
        h(i).data(il).gmPhaseAll = this_il_phase;
        h(i).data(il).gmComplexAll = this_il_phase;
        h(i).data(il).cpComplexAll = this_il_cp;

    end
end

% Finished TD and frequency-domain processing. Save the raw fish struct.
save([abs_path, 'clean_data_head_point_with_freq.mat'], 'h');
disp("SUCCESS: new freq head point struct is saved.")

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
