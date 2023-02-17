%% ==================================================================
% Script that plots the time series in each folder
%
% ===================================================================
clear all ; close all; clc
                                 

%% Info for each simulation
iter = 30;                      % iterations allowed in each time step 
                                % NOTE: make sure you know what is output in "logfile" (I think it has mech.+ther. iterations

%% Info for figure in each simulation     
lw = 1;             % line width
fs = 14;            % font size
%% Check each simulation against snap criteria

       
fileconv = ['L_p1fr1']; % convergence information file name
logfile = load(fileconv);    % loads vector "logfile"
                             %     check if step is converged     

indxconv = find(logfile(:,2) <= iter);   % index for all converged steps


fname1=['P_p1fr1a.dis'];  % displacement information file name
disp_a=load(fname1);

fname2=['P_p1fr1b.dis'];
disp_b=load(fname2);

fname3=['P_p1fr1c.dis'];
disp_c=load(fname3);

fname4=['P_p1fr1d.dis'];
disp_d=load(fname4);

fname5=['P_p1fr1e.dis'];
disp_e=load(fname5);

fname6=['P_p1fr1f.dis'];
disp_f=load(fname6);

disp_b = disp_b(:,2:end);
disp_c = disp_c(:,2:end);
disp_d = disp_d(:,2:end);
disp_e = disp_e(:,2:end);
disp_f = disp_f(:,2:end);

disp_all  = [disp_a, disp_b, disp_c, disp_d, disp_e, disp_f];

filedisp = ['O_p1fr1_disp']; % file with displecement at middle node
eval(filedisp);  

%% Plot DISPLACEMENT-TIME for last 50 cycles
figure(1)
grid on; hold on; box on
plot(disp_all(:,1),disp_all(:,52),'b--','LineWidth',lw,'MarkerSize',5)
xlabel('Time [s]','FontSize',fs)
ylabel('Displacement at mid-point [mm]','FontSize',fs)
title({['Pinned-pinned sinusoidal beam'],['Newmark']}, 'FontSize',fs)
%         xlim([xmin xmax])
%         ylim([ymin ymax])
set(gca,'fontsize',fs)
fig_name1 = ['TimeSeriesLast50cycles.eps'];
% saveplot(fig_name1,1,0.5)

%% Plot DISPLACEMENT-TIME for all forcing cycles
figure(2)
grid on; hold on; box on
plot(displacements(:,1),displacements(:,6),'b--','LineWidth',lw,'MarkerSize',5)
xlabel('Time [s]','FontSize',fs)
ylabel('Displacement at mid-point [mm]','FontSize',fs)
title({['Pinned-pinned sinusoidal beam'],['Newmark']}, 'FontSize',fs)
%         xlim([xmin xmax])
%         ylim([ymin ymax])
set(gca,'fontsize',fs)
fig_name1 = ['timeSeries.eps'];
% saveplot(fig_name1,1,0.5)
save('p1fr1')
