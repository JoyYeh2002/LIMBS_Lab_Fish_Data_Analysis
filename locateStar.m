 function target_y = locateStar(strip_input, num_sections)
    % Determine the number of sections to split the image into
    img = strip_input;
   
    
    % Compute the height of each section
    section_height = size(img, 1) / num_sections;
    % Iterate over each section
    for i = 1:num_sections
        
        % Compute the row indices of the current section
        start_row = round((i-1)*section_height) + 1;
        end_row = round(i*section_height);
        
        % Extract the current section
        section = img(start_row:end_row, :);
        
        % Compute the mean intensity of the current section
        mean_intensities(i) = mean(section(:));
        
    end
    
    % Find the index of the section with the highest mean intensity
    [~, brightest_idx] = max(mean_intensities);
    
    % Compute the row indices of the brightest section
    brightest_start_row = round((brightest_idx-1)*section_height) + 1;
    brightest_end_row = round(brightest_idx*section_height);
    
    % Compute the target y-coordinate as the average of the two brightest sections
    target_y = floor(mean([brightest_start_row, brightest_end_row]));
 end
    