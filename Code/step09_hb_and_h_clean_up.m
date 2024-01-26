% Step08: Extract clean stuff from hb, then place into the "h.mat"
load('h.mat', 'h');
load('hb.mat', 'hb');

for il = 1 
    clean_trials = cell2mat(h(il).xTr);
    clean_reps = cell2mat(h(il).xRep);

    for idx = 1 %: size(clean_trials, 2)
        t = clean_trials(idx);
        r = clean_reps(idx);

        % Use logical indexing to find elements with the specified value
        

        % Display the matching elements

        rep_field_name = ['x_rep', num2str(r)]

        elem = hb(il).data([hb(1).data.trial_idx] == t).(rep_field_name);

     
    end

end


