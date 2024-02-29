%% step 18: DB joy_data04.m
%% function joy_data4

clear
close all
clc
format short 

%--------------------------------------------------------------------------
% data = load("Fish_1_data.mat");
% fish_name = 'Hope';

fish_name = 'Hope';
file_name = strcat(fish_name,'_TEST_HEAT_MAP.mat');
% file_name = strcat(fish_name,'_bodycurve_data_rotated_clean.mat');
out_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Outputs\';
y_limits = [0 0.5];
num_interp_pts = 23;

% fig_out_path = [out_path, 'Curvature\'];
fig_out_path = out_path;
if ~exist(fig_out_path, 'dir')
    mkdir(fig_out_path);
end


data = load(file_name);

p2m = 2 * 0.0002;

%--------------------------------------------------------------------------
X_data = data.X_corrected;
Y_data = data.Y_corrected;
%--------------------------------------------------------------------------
    scaling_factor = 1;
    Fs = 25*scaling_factor ; % sampling frequency
    time = 0:1/Fs:20-1/Fs;
    L = length(time);

    Fc = 5; % cutoff frequencyin Hz
    Wn = Fc/(Fs/2); % Cut-off frequency for discrete-time filter
    [b,a]=butter(2,Wn); % butterworth filter parameters
%--------------------------------------------------------------------------

for k = 1:1:size(X_data,1)

    tmp_x = squeeze(X_data(k,:,:));
    tmp_y = squeeze(Y_data(k,:,:));

    counter = 1;
    for i = 1:size(tmp_x,1)
        for j = 1:3%:size(tmp_x,2)
            tmp2_x = cell2mat(tmp_x(i,j));
            tmp2_y = cell2mat(tmp_y(i,j));


            if ~isempty(tmp2_y)
            
                for ii = 1:12
                    tmp3_y = interp(tmp2_y(:,ii),scaling_factor)*p2m*100;
                    tmp3_y_filt(:,ii) = filtfilt(b,a,tmp3_y);


                end

                
            for ii = 1:500
                xq = linspace(tmp2_x(ii,1),tmp2_x(ii,end),2*12-1);
                xq = [xq(1)-mean(diff(xq))/5,xq, xq(end)+mean(diff(xq))/5];
                yq = (interp1(tmp2_x(ii,:),tmp2_y(ii,:),xq,'makima'));

                % to check the intepolation result
                % figure; 
                % hold on
                % plot(tmp2_x(ii,:),tmp2_y(ii,:),'r.','MarkerSize',15)
                % plot(xq,yq,'b.-')
                % return
                [~,R,~] = curvature([xq(:)*p2m*100,yq(:)*p2m*100]);
%                 [~,R,~] = curvature([tmp2_x(ii,:)',tmp2_y(ii,:)']*p2m*100);
                Curv{i,j}(:,ii) = 1./R(2:end-1);

            end

            % to check the curvature plot
            figure;
            surf(smoothdata(Curv{i,j}),'EdgeColor','none')
            shading interp
            view(2)
            colorbar
return

                Y_filt = tmp3_y_filt';
                Y_filt_vel = smoothdata([zeros(12,1),diff(Y_filt,[],2)]*Fs,2,"movmean",1);
            
                for jj = 1:12
                    Y_filt_comb{k,jj}(counter,:) = Y_filt(jj,:);
                    Y_filt_vel_comb{k,jj}(counter,:) = Y_filt_vel(jj,:);

                    [f,P1] = single_sided_spectra(Y_filt(jj,:),Fs);
                    [f,P1_vel] = single_sided_spectra(Y_filt_vel(jj,:),Fs);

                    P1_comb{k,jj}(counter,:) = P1;
                    P1_vel_comb{k,jj}(counter,:) = P1_vel;
                end

                counter = counter + 1;
            % figure;
            % plot(Y_filt_vel')
            end
        end
        

        
    end
%--------------------------------------------------------------------------

    colors = jet(12);
    figure('Color','white')
    subplot(211)
    set(gca,'LineWidth',1.5,'FontSize',14)
    hold on
    for i = 1:12
        plot(f,smooth(mean(P1_comb{k,i},1),3),'LineWidth',2,'Color',colors(i,:))
        xlim([0 10])
    end
    ylim(y_limits)
    ylabel('FFT Position','FontSize',14)

    subplot(212)
    set(gca,'LineWidth',1.5,'FontSize',14)
    hold on
    for i = 1:12
        plot(f,smooth(mean(P1_vel_comb{k,i},1),3),'LineWidth',2,'Color',colors(i,:))
        xlim([0 10])
    end
   ylim([0 2.5])
   xlabel('Frequency in Hz','FontSize',14)
   ylabel('FFT Velocity','FontSize',14)
   sgtitle(['Fish:',fish_name,', IL = ', num2str(k), ', Diff  Colors: Diff Body Points'],'fontsize',14)

   % Updated 12/01/2023
   abs_path = 'C:\Users\joy20\Folder\FA_2023\LIMBS Presentations\Data\';
   
   fig_out_filename = [fish_name, '_IL_', num2str(k), '_rainbow_body.png'];
   saveas(gcf, [fig_out_path, fig_out_filename]);
   %--------------------------------------------------------------------------

%    counter2 = 0;
%    S = 0;
%    for i = 1:size(Curv,1)
%         for j = 1:3
%             if ~isempty(Curv{i,j})
%                 counter2 = counter2+1;
%                 S = S + Curv{i,j};
%             end
%         end
%    end
%    S = S/counter2;

    tail_curvature{k} = [];
    for i = 1:size(Curv,1)
        for j = 1:3
            if ~isempty(Curv{i,j})
                tail_curvature{k} = [tail_curvature{k},Curv{i,j}(num_interp_pts,:)];
               
            end
        end
   end

%%





%%
   %%
%     figure('Color','white')
%     set(gca,'LineWidth',1.5,'FontSize',14)
%     hold on
%     surf(time,1:1:size(S,1),smoothdata(S))
%     shading interp
%     view(2)
%     
%     mycolormap = magma(size(X_data,1));
%     
%     ylim([0.99 23])
%     yticks([1.5 22.7])
%     yticklabels({'Head','Tail'})
%     ax = gca;
%     ax.YAxis.FontSize = 16;
%     xlabel('Time (s)')
%     c = colorbar;
%     colormap(mycolormap)
%     clim([0 0.25])
%     c.Label.String = 'Curvature (units TBD)';
%     c.Label.FontSize = 14;
%     sgtitle(['Fish:',fish_name,', IL =  = ', num2str(k), ', Averaged across all trials'],'fontsize',18)



end
%%

body_point_idx = 12;
colors = magma(14);
figure('Color','white')

subplot(211)
set(gca,'LineWidth',1.5,'FontSize',14)
hold on 
for k = 1:1:size(X_data,1)
    plot(f,smooth(mean(P1_comb{k,body_point_idx},1),3),'LineWidth',2,'Color',colors(k,:))
    xlim([0 10])

end
ylabel('FFT Position','FontSize',14)
subplot(212)
set(gca,'LineWidth',1.5,'FontSize',14)
hold on 
for k = 1:1:size(X_data,1)
    plot(f,smooth(mean(P1_vel_comb{k,12},1),3),'LineWidth',2,'Color',colors(k,:))
    xlim([0 10])

end
ylim([0 2.4])
xlabel('Frequency in Hz','FontSize',14)
ylabel('FFT Velocity','FontSize',14)
sgtitle(['Fish:',fish_name,'Body point = ', num2str(body_point_idx), '(Tail), Diff  Colors: Diff IL, Averaged across all trials'],'fontsize',14)

avg_fig_out_filename = [fish_name, '_AVG_FFT.png'];
saveas(gcf, [fig_out_path, avg_fig_out_filename]);

%%
clear Z
figure('Color','white')
set(gca,'LineWidth',1.5,'FontSize',14)
hold on 
edges = linspace(0,0.3,100);
for k  = 1:size(tail_curvature,2)
    h = histogram(tail_curvature{k},edges,'Normalization','probability');
    Z(k,:) = h.Values;
end

%%
[X,Y] = meshgrid(edges(1:end-1), 1:1:9);

figure('Color','white')
set(gca,'LineWidth',1.5,'FontSize',14)
hold on 


% ------------------------------------------------------
p = waterfall(X,Y,smoothdata((Z),2,"movmean",3));

p.FaceAlpha = 0.3;
p.EdgeColor = 'interp';
p.LineWidth = 2;
view([17 30])
xlabel('Curvature')
ylabel('Illumination Levels','Rotation',55)
zlabel('Probability')
sgtitle(['Fish:',fish_name,', Tail Point Curvature, Combined data across all trials'],'fontsize',16)
waterfall_fig_out_filename = [fish_name, '_WATERFALL.png'];
saveas(gcf, [fig_out_path, waterfall_fig_out_filename]);

%%
function [f,P1] = single_sided_spectra(X,Fs)
% input 
% X = time series signal
%  Fs  = sampling frequency   

    X(isnan(X))=[];
    X = X - mean(X);

    
    Y = fft(X);
    L = length(X);
% Compute the two-sided spectrum P2. Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
    P2 = abs(Y/L);
    P1 = P2(1:round(L/2)+1);
    P1(2:end-1) = 2*P1(2:end-1);
% Define the frequency domain f and plot the single-sided amplitude spectrum P1. The amplitudes are not exactly at 0.7 and 1, as expected, because of the added noise. On average, longer signals produce better frequency approximations.
    f = Fs*(0:round(L/2))/L;

end
