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
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],3);
F_Overall_total = NaN(700,5);
X_Overall_total = NaN(300,5);

% FS
q = 1;
for i = 1:2:size(FSnum,2)
 
    length_FS_FF = find(FSstr(:,i) == "ForeFoot", 1, 'last')-1;
    length_FS_MF = find(FSstr(:,i) == "MidFoot",  1, 'last')-1;
    length_FS_HF = find(FSstr(:,i) == "Heel",     1, 'last')-1;
    
    FS_FF   =  FSnum(1:length_FS_FF,i);
    FS_MF   =  FSnum(length_FS_FF:length_FS_MF,i);
    FS_HF   =  FSnum(length_FS_MF:length_FS_HF,i);
    
    FS_FF(FS_FF == -1) = [];
    FS_MF(FS_MF == -1) = [];
    FS_HF(FS_HF == -1) = [];
    
    FS_FF = sort(FS_FF,'ascend');
    FS_MF = sort(FS_MF,'ascend');
    FS_HF = sort(FS_HF,'ascend');
    
    % Removes outliers
    FS_FF = rmoutliers(FS_FF,'quartiles')*6.6;
    FS_MF = rmoutliers(FS_MF,'quartiles')*6.6;
    FS_HF = rmoutliers(FS_HF,'quartiles')*6.6;
    
    FS_Overall  = vertcat(FS_FF, FS_MF, FS_HF);
    FS_Overall  = sort(FS_Overall,'ascend');
    
    FS(q).Overall = FS_Overall;
    
    % Plot Percentile
    pctlv_ForeFoot = prctile(abs(FS_FF),pctl);
    pctlv_MidFoot  = prctile(abs(FS_MF),pctl);
    pctlv_Heel     = prctile(abs(FS_HF),pctl);
    pctlv_Overall  = prctile(FS_Overall,pctl);
    
    total_pctlv.FS.ForeFoot(q) = pctlv_ForeFoot(2);
    total_pctlv.FS.MidFoot(q)  = pctlv_MidFoot(2);
    total_pctlv.FS.Heel(q)     = pctlv_Heel(2);
    total_pctlv.FS.Overall(q)  = pctlv_Overall(2);
    
    [x_ForeFoot, f_ForeFoot]   = ecdf(FS_FF);
    [x_MidFoot,f_MidFoot]      = ecdf(FS_MF);
    [x_Heel,f_Heel]            = ecdf(FS_HF);
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
    titlename_error = ['Toe Off- Error distribution - ' names{q}];
    xlabel('Time(ms)');
    ylabel('Percentile'); grid on;
    title(titlename_error);
    legend('ForeFoot', 'MidFoot','Heel','Overall','location','southeast')
    saveas(h, fullfile(destPath, titlename_error), 'pdf');
    close()
    q = q + 1;
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
titlename_error = ['Toe Off - Error distribution'];
xlabel('Time(ms)');
ylabel('Percentile'); grid on;
title(titlename_error);
legend(names,'location','southeast')
saveas(h, fullfile(destPath, titlename_error), 'pdf');
close()
clearvars -except pctl total_pctlv FOnum FOstr FOnum_abs FOstr_abs destPath names F_Overall_total  X_Overall_total DeviceColors FS

% % FO
% q = 1;
% for i = 9
%  
%     length_FO_FF = find(FOstr(:,i) == "ForeFoot", 1, 'last')-1;
%     length_FO_MF = find(FOstr(:,i) == "MidFoot",  1, 'last')-1;
%     length_FO_HF = find(FOstr(:,i) == "Heel",     1, 'last')-1;
%     
%     FO_FF   =  FOnum(1:length_FO_FF,i);
%     FO_MF   =  FOnum(length_FO_FF:length_FO_MF,i);
%     FO_HF   =  FOnum(length_FO_MF:length_FO_HF,i);
%     
%     FO_FF(FO_FF == -1) = [];
%     FO_MF(FO_MF == -1) = [];
%     FO_HF(FO_HF == -1) = [];
%     
%     FO_FF = sort(FO_FF,'ascend');
%     FO_MF = sort(FO_MF,'ascend');
%     FO_HF = sort(FO_HF,'ascend');
%     
%     % Removes outliers
%     FO_FF = rmoutliers(FO_FF,'median')*6.6;
%     FO_MF = rmoutliers(FO_MF,'quartiles')*6.6;
%     FO_HF = rmoutliers(FO_HF,'quartiles')*6.6;
%     
%     FO_Overall  = vertcat(FO_FF, FO_MF, FO_HF);
%     FO_Overall  = sort(FO_Overall,'ascend');
%     
%     FO(q).Overall = FO_Overall;
%     
%     % Plot Percentile
%     pctlv_ForeFoot = prctile(abs(FO_FF),pctl);
%     pctlv_MidFoot  = prctile(abs(FO_MF),pctl);
%     pctlv_Heel     = prctile(abs(FO_HF),pctl);
%     pctlv_Overall  = prctile(FO_Overall,pctl);
%     
%     total_pctlv.FO.ForeFoot(q) = pctlv_ForeFoot(2);
%     total_pctlv.FO.MidFoot(q)  = pctlv_MidFoot(2);
%     total_pctlv.FO.Heel(q)     = pctlv_Heel(2);
%     total_pctlv.FO.Overall(q)  = pctlv_Overall(2);
%     
%     [x_ForeFoot, f_ForeFoot]   = ecdf(FO_FF);
%     [x_MidFoot,f_MidFoot]      = ecdf(FO_MF);
%     [x_Heel,f_Heel]            = ecdf(FO_HF);
%     [x_Overall, f_Overall]     = ecdf(FO_Overall);
%     f_ForeFoot(1) = 0;f_MidFoot(1) = 0; f_Heel(1) = 0;f_Overall(1)=0;
%     
%     h = figure;
%     plot(f_ForeFoot,x_ForeFoot, 'color',  [98/250 122/250 157/250],'LineWidth',2); hold on
%     plot(f_MidFoot,x_MidFoot,'color', [87/250 108/250 67/250] ,'LineWidth',2); hold on
%     plot(f_Heel,x_Heel,'color', [187/250 86/250 149/250],'LineWidth',2); hold on
%     plot(f_Overall,x_Overall, 'color',  [194/250 150/250 130/250],'LineWidth',2);hold on
%     
%     hold on
%     
%     for k = 1:numel(pctl)
%         
%         if find(pctlv_Overall<0)
%             plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
%             plot([min(ylim);1*pctlv_Overall(k)],[1;1]*pctl(k)/100,'--k')
%         else
%             plot([1;1]*pctlv_Overall(k),[0;1]*pctl(k)/100, '--k')
%             plot([0;1]*pctlv_Overall(k),[1;1]*pctl(k)/100, '--k')
%         end
%         
%     end
%     titlename_error = ['Toe Off- Error distribution - ' names{q}];
%     xlabel('Time(ms)');
%     ylabel('Percentile'); grid on;
%     title(titlename_error);
%     legend('ForeFoot', 'MidFoot','Heel','Overall','location','southeast')
%     saveas(h, fullfile(destPath, titlename_error), 'pdf');
%     close()
%     q = q + 1;
% end
% 
% %% Error-distribution all in one.
% h = figure;
% for i = 1:size(FO,2)
%     [x_Overall, f_Overall]   = ecdf(FO(i).Overall);
%     f_Overall(1) = 0;
%     plot(f_Overall,x_Overall,'color', DeviceColors{i},'LineWidth',2);
%     hold on
%     pctlv_Overall  = prctile(FO(i).Overall,pctl);
%     total_pctlv.FO.Overall(i) = pctlv_Overall(2);
%     
% end
% titlename_error = ['Toe Off - Error distribution'];
% xlabel('Time(ms)');
% ylabel('Percentile'); grid on;
% title(titlename_error);
% legend(names,'location','southeast')
% saveas(h, fullfile(destPath, titlename_error), 'pdf');
% close()
% 
% % writetable(struct2table(total_pctlv.FS), 'Error_distribution_FS.csv')
% % writetable(struct2table(total_pctlv.FO), 'Error_distribution_FO.csv')
% 
% clearvars -except FO FS
% 
% 
% 
% 
