%% Calculates the error-distribution(coverage) and historgram.
clear; close;
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
DeviceColors = {[194/250 150/250 130/250] [98/250 122/250 157/250] [87/250 108/250 67/250] [50/250 200/250 149/250] [187/250 86/250 149/250]};
names = {'HLXHEE', 'TOEHEE','HLXPMT5HEE','TOEPMT5HEE','HLXTOEHEE'};
pctl = [10 95];
%% Reading CSV
[FSnum,FSstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],3);
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],4);
F_Overall_total = NaN(700,5);
X_Overall_total = NaN(300,5);

% FS
length_FS_ForeFoot  = find(FSstr == "ForeFoot",   1, 'last')-1;
length_FS_MidFoot   = find(FSstr == "MidFoot",    1, 'last')-1;
length_FS_Heel      = find(FSstr == "Heel",       1, 'last')-1;

for i = 1:size(FSnum,2)
    
    FS_ForeFoot   =  FSnum(1:length_FS_ForeFoot,i);
    FS_MidFoot    =  FSnum(length_FS_ForeFoot:length_FS_MidFoot,i);
    FS_Heel       =  FSnum(length_FS_MidFoot:length_FS_Heel,i);
    
    FS_ForeFoot(FS_ForeFoot == -1) = [];
    FS_MidFoot(FS_MidFoot == -1)   = [];
    FS_Heel(FS_Heel == -1)         = [];
    
    FS_ForeFoot = sort(FS_ForeFoot,'ascend');
    FS_MidFoot  = sort(FS_MidFoot,'ascend');
    FS_Heel     = sort(FS_Heel,'ascend');
    
    % Removes outliers
    FS_ForeFoot = rmoutliers(FS_ForeFoot,'quartiles')*6.6;
    FS_MidFoot  = rmoutliers(FS_MidFoot,'quartiles')*6.6;
    FS_Heel     = rmoutliers(FS_Heel,'quartiles')*6.6;
    
    FS_Overall  = vertcat(FS_ForeFoot, FS_MidFoot, FS_Heel);
    FS_Overall  = sort(FS_Overall,'ascend');
    
    FS(i).Overall = FS_Overall;
    
    % Plot Percentile
    pctlv_ForeFoot = prctile(abs(FS_ForeFoot),pctl);
    pctlv_MidFoot  = prctile(abs(FS_MidFoot),pctl);
    pctlv_Heel     = prctile(abs(FS_Heel),pctl);
    pctlv_Overall  = prctile(FS_Overall,pctl);
    
    total_pctlv.FS.ForeFoot(i) = pctlv_ForeFoot(2);
    total_pctlv.FS.MidFoot(i)  = pctlv_MidFoot(2);
    total_pctlv.FS.Heel(i)     = pctlv_Heel(2);
    total_pctlv.FS.Overall(i)  = pctlv_Overall(2);
    
    [x_ForeFoot, f_ForeFoot]   = ecdf(FS_ForeFoot);
    [x_MidFoot,f_MidFoot]      = ecdf(FS_MidFoot);
    [x_Heel,f_Heel]            = ecdf(FS_Heel);
    [x_Overall, f_Overall]     = ecdf(FS_Overall);
    f_ForeFoot(1) = 0;f_MidFoot(1) = 0; f_Heel(1) = 0;f_Overall(1)=0;
    
    h = figure;
    plot(f_ForeFoot,x_ForeFoot, 'color',  [98/250 122/250 157/250],'LineWidth',2); hold on
    plot(f_MidFoot,x_MidFoot,'color', [87/250 108/250 67/250] ,'LineWidth',2); hold on
    plot(f_Heel,x_Heel,'color', [187/250 86/250 149/250],'LineWidth',2); hold on
    plot(f_Overall,x_Overall, 'color',  [194/250 150/250 130/250],'LineWidth',2);hold on
    
    hold on
    
    for k = 1:numel(pctl)
        
        if find(pctlv_Overall<0)
            plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
            plot([min(ylim);1*pctlv_Overall(k)],[1;1]*pctl(k)/100,'--k')
        else
            plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
            plot([0;1]*pctlv_Overall(k),[1;1]*pctl(k)/100, '--k')
        end
        
    end
    titlename_error = ['Initial Contact- Error distribution - ' names{i}];
    xlabel('Time(ms)');
    ylabel('Percentile'); grid on;
    title(titlename_error);
    legend('ForeFoot', 'MidFoot','Heel','Overall','location','southeast')
    saveas(h, fullfile(destPath, titlename_error), 'jpg');
    close()
end

%% Error-distribution all in one.
h = figure;
for i = 1:size(FS,2)
    [x_Overall, f_Overall]   = ecdf(FS(i).Overall);
    f_Overall(1) = 0;
    plot(f_Overall,x_Overall,'color', DeviceColors{i},'LineWidth',2);
    hold on
    pctlv_Overall  = prctile(FS(i).Overall,pctl);
    total_pctlv.FS.Overall(i) = pctlv_Overall(2);
    
end
titlename_error = ['Initial Contact - Error distribution'];
xlabel('Time(ms)');
ylabel('Percentile'); grid on;
title(titlename_error);
legend(names,'location','southeast')
saveas(h, fullfile(destPath, titlename_error), 'pdf');
close()
clearvars -except pctl total_pctlv FOnum FOstr FOnum_abs FOstr_abs destPath names F_Overall_total  X_Overall_total DeviceColors FS

%% FO
length_FO_ForeFoot = find(FOstr == "ForeFoot",   1, 'last')-1;
length_FO_MidFoot  = find(FOstr == "MidFoot",    1, 'last')-1;
length_FO_Heel     = find(FOstr == "Heel",       1, 'last')-1;

for i = 1:size(FOnum,2)
    
    FO_ForeFoot  =  FOnum(1:length_FO_ForeFoot,i);
    FO_MidFoot   =  FOnum(length_FO_ForeFoot:length_FO_MidFoot,i);
    FO_Heel      =  FOnum(length_FO_MidFoot:length_FO_Heel,i);
    
    FO_ForeFoot(FO_ForeFoot == -1) = [];
    FO_MidFoot(FO_MidFoot == -1)   = [];
    FO_Heel(FO_Heel == -1)         = [];
    
    FO_ForeFoot  = sort(FO_ForeFoot,'ascend')*6.6;
    FO_MidFoot   = sort(FO_MidFoot,'ascend')*6.6;
    FO_Heel      = sort(FO_Heel,'ascend')*6.6;
    
    % Removes outliers
    FO_ForeFoot = rmoutliers(FO_ForeFoot,'quartiles');
    FO_MidFoot  = rmoutliers(FO_MidFoot,'quartiles');
    FO_Heel     = rmoutliers(FO_Heel,'quartiles');
    
    FO_Overall  = vertcat(FO_ForeFoot, FO_MidFoot, FO_Heel);
    FO_Overall  = sort(FO_Overall,'ascend');
    
    FO(i).Overall = FO_Overall;
    
    % Plot Percentile
    pctlv_ForeFoot  = prctile(FO_ForeFoot,pctl);
    pctlv_MidFoot   = prctile(FO_MidFoot,pctl);
    pctlv_Heel      = prctile(FO_Heel,pctl);
    pctlv_Overall   = prctile(FO_Overall,pctl);
    
    total_pctlv.FO.ForeFoot(i) = pctlv_ForeFoot(2);
    total_pctlv.FO.MidFoot(i)  = pctlv_MidFoot(2);
    total_pctlv.FO.Heel(i)     = pctlv_Heel(2);
    total_pctlv.FO.Overall(i)  = pctlv_Overall(2);
    
    [x_ForeFoot, f_ForeFoot] = ecdf(FO_ForeFoot);
    [x_MidFoot,f_MidFoot]    = ecdf(FO_MidFoot);
    [x_Heel,f_Heel]          = ecdf(FO_Heel);
    [x_Overall, f_Overall]   = ecdf(FO_Overall);
    f_ForeFoot(1) = 0;f_MidFoot(1) = 0; f_Heel(1) = 0;f_Overall(1)=0;
    
    h = figure;
    plot(f_ForeFoot,x_ForeFoot, 'color',  [98/250 122/250 157/250],'LineWidth',2); hold on
    plot(f_MidFoot,x_MidFoot,'color', [87/250 108/250 67/250] ,'LineWidth',2); hold on
    plot(f_Heel,x_Heel,'color', [187/250 86/250 149/250],'LineWidth',2); hold on
    plot(f_Overall,x_Overall, 'color',  [194/250 150/250 130/250],'LineWidth',2);hold on
    
    hold on
    
    for k = 1:numel(pctl)
        
        if find(pctlv_Overall<0)
            plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
            plot([min(ylim);1*pctlv_Overall(k)],[1;1]*pctl(k)/100,'--k')
        else
            plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
            plot([0;1]*pctlv_Overall(k),[1;1]*pctl(k)/100, '--k')
        end
        
    end
    titlename_error = ['Toe Off - Error distribution - ' names{i}];
    xlabel('Time(ms)');
    ylabel('Percentile'); grid on;
    title(titlename_error);
    legend('ForeFoot', 'MidFoot','Heel','Overall','location','southeast')
    
    saveas(h, fullfile(destPath, titlename_error), 'jpg');
    close()
end

h = figure;
for i = 1:size(FO,2)
    [x_Overall, f_Overall]   = ecdf(abs(FO(i).Overall));
    f_Overall(1) = 0;
    
    plot(f_Overall,x_Overall,'color', DeviceColors{i},'LineWidth',2);
    hold on
    pctlv_Overall  = prctile(abs(FO(i).Overall),pctl);
    total_pctlv.FO.Overall(i) = pctlv_Overall(2);
end

titlename_error = ['Toe Off - Error distribution'];
xlabel('Time(ms)');
ylabel('Percentile'); grid on;
title(titlename_error);
legend(names,'location','southeast')
saveas(h, fullfile(destPath, titlename_error), 'pdf');
close()

% writetable(struct2table(total_pctlv.FS), 'Error_distribution_FS.csv')
% writetable(struct2table(total_pctlv.FO), 'Error_distribution_FO.csv')

clearvars -except FO FS


