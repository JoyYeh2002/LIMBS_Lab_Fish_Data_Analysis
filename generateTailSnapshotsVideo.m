% Joy Yeh Eigen Luminance Tail Motion Analysis
% generateTailSnapshotsVideo.m
%
% With the saved .mat file of all tracked data, create snapshots in a jet()
% color map in a video
% [05/18]

function generateTailSnapshotsVideo(dir, frame_gaps)
    close all;

    tic;

    dataDir = [dir, '\']; % [NEW] Use this for population analysis
    
    load([dataDir, 'tracked_data.mat']);
    x = x_tracked;
    y = y_tracked;

    n = size(x, 2);

    % Create a video writer object
    vidFilename = [dataDir, 'tail_snapshots.avi'];
    vOut = VideoWriter(vidFilename);
    vOut.FrameRate = 30;
    open(vOut);

    % Set the dimension limits
    figure;

    % Set the figure size to 640 by 190 pixels
    set(gcf, 'Position', [400, 400, 640, 190]);
    ylim([1, 190]);
    set(gca, 'YDir', 'reverse');
    xlim([1, 640]);

    seq = 1:frame_gaps:1776;
    numElem = numel(seq);
    cp = jet(numElem);

    hold on;
    for i = seq
        plot(x(i, :), y(i, :), 'color', cp((i-1)/20 + 1, :), 'linewidth', 3);

        % Update the title
        % String to subtract
        subtractString = '..\data\hope_population_analysis\';
        
        % Subtract the string from the directory name
        remainingText = strrep(dir, subtractString, ''); 
        fixed_str = strrep(strrep(remainingText, '\', ' '), '_', ' ');
        title(sprintf('%s: Frame %d', fixed_str, i));

        % Write the current frame to the video
        frame = getframe(gcf);
        writeVideo(vOut, frame);
    end

    close(vOut);
    disp(['SUCCESS: ', dir, 'tail_snapshots.avi is saved.']);

    toc;
end
