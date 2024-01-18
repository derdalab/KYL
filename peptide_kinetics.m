clear all; % clear all variables from the workplace
close all; % close all opened windows
indir = ''; % define the directory which holds the file (present dir)
name = 'KY-VII-102.xlsx'; % define the file name
%name = 'pH8 area percentage.xls';
path = fullfile(indir,name); % define a full path: directory/name
raw = xlsread(path); % read the raw data from Excel file
rows = 1:7; % define in which rows your data is stored
%rows = 36:39;
delay = 0; % introduce a fixed delay to improve the fit
x = raw(rows,1) - delay; % extract the time
x = x*60;
column = [6 8]; % define in which columns the product and reactants are
% define two types of 1st order equations for product and reactant
equation = {'A*(1-exp(-k*x))', 'A*(exp(-k*x))'};
% definethe concentration of excess reagent in Molar units
conc = 0.0024;
%%%%% make your best guess about k and A parameters %%%%%%%%%%%%%%%%%%%%
A = 2500;
k = 0.0;
% run the same fit twice, plot the results in two subplots
for i = 1:2
y = raw(rows,column(i)); % extract the adsorbance from a current column
%%%%% define the fit options %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
s = fitoptions('Method','NonlinearLeastSquares',...
'Lower',[0, 0],...
'Upper',[5000, 20],...
'Startpoint',[A k],...
'TolFun', 1e-10 );
%%%%% define the fit equation and options %%%%%%%%%%%%%%%%%%%%%%%%%
ft = fittype( equation{i},'options',s );
%%%%% fit the data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[c2,gof2,output] = fit(x,y,ft);
%%%%% find the 95% confidence bounds and confidence interval %%%%%%%%%%%%
CON = confint(c2); % confidence interval
x2=0:0.1:max(x);
p22 = predint(c2,x2,0.95,'functional','on');
%%%%% plot the raw data as black diamonds %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
subplot(1,2,i);
plot(x,y,'dk',...
'MarkerEdgeColor','k',...
'MarkerFaceColor','k',...
'MarkerSize',5);
hold on;
%%%%% plot the fit data as red line and 95% confidence bounds as dash %%
plot( c2,'r');
plot(x2,p22,'k:');
legend off;
drawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%% define the axis, re-scale them, label them %%%%%%%%%%%%%
xmax = max(x)*1.05;
ymax = max(max(p22))*1.05;
xlim([0 xmax])
ylim([0 ymax])
xlabel('time(s)');
ylabel('absorbance');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display the results of the fit on the plot
% extract the fit value of k, divide it by concentration to yield real k
FIRSTorderk = c2.k / conc;
% calculate the % standard deviations for k and A
STD(1) = 100*abs(CON(1,1) - CON(2,1))/2 / c2.A;
STD(2) = 100*abs(CON(1,2) - CON(2,2))/2 / c2.k;
% create a 3-line text string that will be displayed on the chart
TL{1} = [' k =' num2str(FIRSTorderk,'%0.2f') ...
' [' num2str(STD(2),'%0.2f') '% ]'];
TL{2} = [' A =' num2str(c2.A,'%0.2f') ...
' [' num2str(STD(1),'%0.2f') '% ]'];
TL{3} = [' R^2=' num2str(gof2.rsquare,'%0.4f') ];
% plate the text string on the chart into a predefined location
text(0.15*xmax,0.75*ymax, char(TL));
end