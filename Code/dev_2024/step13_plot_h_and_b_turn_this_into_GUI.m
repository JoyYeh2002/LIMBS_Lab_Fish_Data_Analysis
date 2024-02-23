%% STEP 13: h and b both plot

close all;

%% 1. Load head and body.m
abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\data\fish_structs_2024\';
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';

load([abs_path, 'clean_data_head_point_with_freq.mat']) % head struct: "h"
b = load([abs_path, 'raw_data_full_body.mat']); % body struct: "b"
b = b.all_fish;
load([abs_path, 'shuttle.mat']); % "shuttle" is 500x1 double

fishNames = {'Hope', 'Len', 'Doris', 'Finn', 'Ruby'}; % consistent with SICB
numFish = 5;
num_body_pts = 12;

target_fish_idx = 4;
il = 2;
trID = 1;
target_rep_IDs = 3;


%% 3. Initial calculations
k = [2, 3, 5, 7, 11, 13, 19, 23, 29, 31, 37, 41]; % freq peak multipliers
FREQ_AMPLITUDE_SCALAR = 0.05;
freq_datapoints = k * FREQ_AMPLITUDE_SCALAR;
gray = [0.7, 0.7, 0.7];


%% Loop through all fish

plot_stuff = 1;




data_to_plot = 'gm';

if plot_stuff == 1
    for fish_idx = target_fish_idx
        fishName = fishNames{fish_idx};
        data = h(fish_idx).data(il);
        num_il_levels = numel(data);

        IDs = [cell2mat(data.trID); cell2mat(data.repID)];

        for repID = target_rep_IDs
        target_idx = find(IDs(1, :) == trID & IDs(2, :) == repID);

        % Display the column number
     
        if strcmp(data_to_plot, 'gm')
            gainField = 'gmGainAll';
            phaseField = 'gmPhaseAll';
            c = copper(num_il_levels);
            plotname_suffix = [' GM: IL = ', ...
                num2str(il), '. Tr = ', num2str(trID), ', Rep = ', num2str(repID), '(Trial #', num2str(target_idx), ')'];
            yLimG = [0 1.2];
            yLimP = [-210 20];
        else
            gainField = 'cpComplex';
            phaseField = 'cpPhase';
            c = summer(num_il_levels);
            plotname_suffix = ' Closed-Loop GM Frequency Responses';
            yLimG = [0 10];
            yLimP = [-240 0];
        end

        %% CLOSED LOOP BODE HERE
        f = figure();
        f.Position = [100 100 900 550];

        % colorMap = {'#000000', '#112d80', '#234099', '#2d50b4', '#5070c7', ...
        %     '#91a6e2', '#acc0fa', '#cbd0ee', '#ececec'};
        plotName = [fishName, plotname_suffix];

        lineWidth = 1.9;
        axisFontSize = 12;
        labelFontSize = 9;

        %% Gain
        h1 = axes('position',[0.07 0.56 0.82 0.4]);
        hold on

        for p = 1 : num_il_levels
            semilogx(freq_datapoints, smooth(data(p).(gainField){target_idx}), ...
                'color',c(p, :),'LineWidth', lineWidth);
        end

        set(h1,'xScale','log');
        set(h1,'yScale','log');

        h1.XGrid = 'on';
        h1.XLim = [0 2.1];
        set(h1,'XTick', freq_datapoints);
        set(h1,'XTick', [freq_datapoints(1:8), freq_datapoints(10:12)]);
        h1.XAxis.FontSize = labelFontSize;

        h1.YGrid = 'on';
        h1.YLim = yLimG;
        set(h1,'YTick',[0, 0.1, 1, 10]);
        set(h1,'YTickLabel',["0", "10^{-1}", "10^0","10^1"]);
        h1.YAxis.FontSize = labelFontSize;
        ylabel('Gain', 'FontSize', axisFontSize)

        title(plotName);

        %% Phase
        h2 = axes('position',[0.07 0.1 0.82 0.4]);

        hold on
        for j = 1: num_il_levels
            semilogx(freq_datapoints, smooth(data(j).(phaseField){target_idx}), ...
                'color', c(j, :),'LineWidth', lineWidth);
        end

        h2.XGrid = 'on';
        h2.XLim = [0 2.1];
        set(h2,'xScale','log');
        set(h2,'XTick', freq_datapoints);
        set(h2,'XTick', [freq_datapoints(1:8), freq_datapoints(10:12)]);
        h2.XAxis.FontSize = labelFontSize;
        xlabel('Freq in Hz', 'FontSize', axisFontSize);

        h2.YGrid = 'on';
        h2.YLim = yLimP;
        set(h2,'YTick',[-200 -150 -100 -50 0 50]);
        h2.YAxis.FontSize = labelFontSize;
        ylabel('Phase(deg)', 'FontSize', axisFontSize);

        % Add color bar
        cb = colorbar;
        colormap(c);
        cb.Ticks = linspace(1/(2*num_il_levels), 1-1/(2*num_il_levels), num_il_levels);
        cb.TickLabels = 1:num_il_levels;
        cb.Label.String = 'Luminance levels';
        cb.Position = [0.9 0.1 0.02 0.8]; % Adjust position as needed

        % Save the closed loop bode plots
        saveas(gcf, [out_path, fishName, '_', gainField, '_IL_', num2str(il), ...
            '_TR_', num2str(trID), '_REP_', num2str(repID),'_bode.png']);
        disp(['SUCCESS: ', fishName, ' bode plot for ', gainField, '_IL_', num2str(il), ...
            '_TR_', num2str(trID), '_REP_', num2str(repID), 'bode.png', ...
            'is saved.']);
    end
    end
end
