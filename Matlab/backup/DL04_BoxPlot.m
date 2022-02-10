% clear; close;
%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        TestPath1= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results/excel';
        
        pathCompSep = '/';
    case 1
        TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\excel\';
        pathCompSep = '\';
end

destPath = [TestPath1,pathCompSep,'Error-distribution'];

%% Figure Settings
Markers =  {'HLXHEE','TOEHEE','HLXPMT5HEE','TOEPMT5HEE','HLXTOEHEE'};
Group =  {'ForeFoot', 'MidFoot','Heel','Overall'};
DeviceColors = {[194/250 150/250 130/250] [98/250 122/250 157/250] [87/250 108/250 67/250] [50/250 200/250 149/250] [187/250 86/250 149/250]};

%% Reading CSV
[FSnum,FSstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],3);
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],4);

% FS
length_FS_ForeFoot  = find(FSstr == "ForeFoot",   1, 'last')-1;
length_FS_MidFoot   = find(FSstr == "MidFoot",    1, 'last')-1;
length_FS_Heel      = find(FSstr == "Heel",       1, 'last')-1;

FS_ForeFoot   =  FSnum(1:length_FS_ForeFoot,1:5);
FS_MidFoot    =  FSnum(length_FS_ForeFoot:length_FS_MidFoot,1:5);
FS_Heel       =  FSnum(length_FS_MidFoot:length_FS_Heel,1:5);

for i = 1:size(FSnum,2)
    
    idx_ForeFoot = find(FS_ForeFoot(:,i) == -1);
    idx_MidFoot  = find(FS_MidFoot(:,i) == -1);
    idx_Heel     = find(FS_Heel(:,i) == -1);
    
    FS_ForeFoot(idx_ForeFoot,i) = NaN;
    FS_MidFoot(idx_MidFoot,i) = NaN;
    FS_Heel(idx_Heel,i) = NaN;
    
end

FS_ForeFoot  = rmoutliers(FS_ForeFoot,'median');
FS_MidFoot   = rmoutliers(FS_MidFoot,'median');
FS_Heel      = rmoutliers(FS_Heel,'median');

FS_Overall    = vertcat(FS_ForeFoot, FS_MidFoot, FS_Heel);

GroupedData = {FS_ForeFoot FS_MidFoot FS_Heel FS_Overall};

N = numel(GroupedData);
delta = linspace(-.4,.4,N);% define offsets to distinguish plots
width = .1; %// small width to avoid overlap
cmap = hsv(N); %// colormap
legWidth = 1.8; %// make room for legend

figure;
hold on;

for ii=1:N %// better not to shadow i (imaginary unit)
    labels = Markers; %// center plot: use real labels

    boxplot(GroupedData{ii},'Color', DeviceColors{ii}, 'boxstyle','filled', ...
        'position',(1:numel(labels))+delta(ii), 'widths',width,'labels',labels,'symbol','')

    %// plot filled boxes with specified positions, widths, labels
    plot(NaN,1,'color',DeviceColors{ii}); %// dummy plot for legend
end
title("Initial Contact");xlabel('Input Markers'); ylabel('Difference from to the ground truth (Frames)');grid on;
xlim([1+2*delta(1) numel(labels)+legWidth+2*delta(N)])
ylim([0 4]) %// adjust x limits, with room for legend%// adjust x limits, with room for legend
legend(Group);

clearvars -except FOstr FOnum Markers Group DeviceColors

%% FO
length_FO_ForeFoot  = find(FOstr == "ForeFoot",   1, 'last')-1;
length_FO_MidFoot   = find(FOstr == "MidFoot",    1, 'last')-1;
length_FO_Heel      = find(FOstr == "Heel",       1, 'last')-1;

FO_ForeFoot   =  FOnum(1:length_FO_ForeFoot,1:5);
FO_MidFoot    =  FOnum(length_FO_ForeFoot:length_FO_MidFoot,1:5);
FO_Heel       =  FOnum(length_FO_MidFoot:length_FO_Heel,1:5);

for i = 1:size(FOnum,2)
    
    idx_ForeFoot = find(FO_ForeFoot(:,i) == -1);
    idx_MidFoot  = find(FO_MidFoot(:,i) == -1);
    idx_Heel     = find(FO_Heel(:,i) == -1);
    
    FO_ForeFoot(idx_ForeFoot,i) = NaN;
    FO_MidFoot(idx_MidFoot,i) = NaN;
    FO_Heel(idx_Heel,i) = NaN;
    
end

FO_ForeFoot  = rmoutliers(FO_ForeFoot,'median');
FO_MidFoot   = rmoutliers(FO_MidFoot,'median');
FO_Heel      = rmoutliers(FO_Heel,'median');

FO_Overall    = vertcat(FO_ForeFoot, FO_MidFoot, FO_Heel);

GroupedData = {FO_ForeFoot FO_MidFoot FO_Heel FO_Overall};

N = numel(GroupedData);
delta = linspace(-.4,.4,N);% define offsets to distinguish plots
width = .2; %// small width to avoid overlap
cmap = hsv(N); %// colormap
legWidth = 1.8; %// make room for legend

figure;
hold on;

for ii=1:N %// better not to shadow i (imaginary unit)
    labels = Markers; %// center plot: use real labels

    boxplot(GroupedData{ii},'Color', DeviceColors{ii}, 'boxstyle','filled', ...
        'position',(1:numel(labels))+delta(ii), 'widths',width,'labels',labels,'symbol','')

    %// plot filled boxes with specified positions, widths, labels
    plot(NaN,1,'color',DeviceColors{ii}); %// dummy plot for legend
end
title("Toe-Off");xlabel('Input Markers'); ylabel('Difference from to the ground truth (Frames)'); grid on;
xlim([1+2*delta(1) numel(labels)+legWidth+2*delta(N)])
ylim([5 15]) %// adjust x limits, with room for legend%// adjust x limits, with room for legend
legend(Group,'FontSize',14);
