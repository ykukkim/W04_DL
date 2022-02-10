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

%% Reading CSV
[FSnum,FSstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],4);
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],6);

%% FS
length_FS_FF = find(FSstr == "ForeFoot", 1, 'last')-1;
length_FS_MF = find(FSstr == "MidFoot",  1, 'last')-1;
length_FS_HF = find(FSstr == "Heel",     1, 'last')-1;

k = 1;
for i = 1:2:size(FSnum,2)
    
    FS_FF_FPR  =  FSnum(1:length_FS_FF,i);
    FS_FF_TPR  =  FSnum(1:length_FS_FF,i+1);
    FS_MF_FPR  =  FSnum(length_FS_FF:length_FS_MF,i);
    FS_MF_TPR  =  FSnum(length_FS_FF:length_FS_MF,i+1);
    FS_HF_FPR  =  FSnum(length_FS_MF:length_FS_HF,i);
    FS_HF_TPR  =  FSnum(length_FS_MF:length_FS_HF,i+1);
    
    FS_Batch_size = 32;
    t = 1;
    
    for j = 1:FS_Batch_size:(length(FS_FF_TPR))
        
        FS_FF_temp_FPR = FS_FF_FPR(j:j+FS_Batch_size-1);
        FS_MF_temp_FPR = FS_MF_FPR(j:j+FS_Batch_size-1);
        FS_HF_temp_FPR  = FS_HF_FPR(j:j+FS_Batch_size-1);
        
        FS_FF_temp_TPR  = FS_FF_TPR(j:j+FS_Batch_size-1);
        FS_MF_temp_TPR  = FS_MF_TPR(j:j+FS_Batch_size-1);
        FS_HF_temp_TPR = FS_HF_TPR(j:j+FS_Batch_size-1);
        
        FS_FF_temp_FPR(FS_FF_temp_FPR == -1) = [];
        FS_MF_temp_FPR(FS_MF_temp_FPR == -1) = [];
        FS_HF_temp_FPR(FS_HF_temp_FPR == -1) = [];
        
        FS_FF_temp_TPR(FS_FF_temp_TPR == -1) = [];
        FS_MF_temp_TPR(FS_MF_temp_TPR == -1) = [];
        FS_HF_temp_TPR(FS_HF_temp_TPR == -1) = [];
        
        IC(k).FF_FPRRaw(1:length(FS_FF_temp_TPR),t) = FS_FF_temp_TPR;
        IC(k).MF_FPRRaw(1:length(FS_MF_temp_TPR),t) = FS_MF_temp_TPR;
        IC(k).HF_FPRRaw(1:length(FS_HF_temp_TPR),t) = FS_HF_temp_TPR;
        
        IC(k).FF_TPRRaw(1:length(FS_FF_temp_TPR),t) = FS_FF_temp_TPR;
        IC(k).MF_TPRRaw(1:length(FS_MF_temp_TPR),t) = FS_MF_temp_TPR;
        IC(k).HF_TPRRaw(1:length(FS_HF_temp_TPR),t) = FS_HF_temp_TPR;
        
        IC(k).FF_Total(:,t) = sum([FS_FF_temp_FPR; FS_FF_temp_TPR]);
        IC(k).MF_Total(:,t) = sum([FS_MF_temp_FPR; FS_MF_temp_TPR]);
        IC(k).HF_Total(:,t) = sum([FS_HF_temp_FPR; FS_HF_temp_TPR]);
        
        IC(k).FF_FPRTotal(:,t) = sum(FS_FF_temp_FPR);
        IC(k).MF_FPRTotal(:,t) = sum(FS_MF_temp_FPR);
        IC(k).HF_FPRTotal(:,t) = sum(FS_HF_temp_FPR);
        
        IC(k).FF_TPRTotal(:,t) = sum(FS_FF_temp_TPR);
        IC(k).MF_TPRTotal(:,t) = sum(FS_MF_temp_TPR);
        IC(k).HF_TPRTotal(:,t) = sum(FS_HF_temp_TPR);
        
        IC(k).FF_FPRPercentage(:,t) = IC(k).FF_FPRTotal(:,t)/IC(k).FF_Total(:,t);
        IC(k).MF_FPRPercentage(:,t) = IC(k).MF_FPRTotal(:,t)/IC(k).MF_Total(:,t);
        IC(k).HF_FPRPercentage(:,t) = IC(k).HF_FPRTotal(:,t)/IC(k).HF_Total(:,t);
        
        IC(k).FF_TPRPercentage(:,t) = IC(k).FF_TPRTotal(:,t)/IC(k).FF_Total(:,t);
        IC(k).MF_TPRPercentage(:,t) = IC(k).MF_TPRTotal(:,t)/IC(k).MF_Total(:,t);
        IC(k).HF_TPRPercentage(:,t) = IC(k).HF_TPRTotal(:,t)/IC(k).HF_Total(:,t);      
        
        t = t+ 1;
    end
    k = k +1;
end

for k = 1:size(IC,2)

    FF(k).IC.FPR_sum = mean(IC(k).FF_FPRPercentage)*100;
    FF(k).IC.FPR_std = (std(IC(k).FF_FPRPercentage)/sqrt(length(IC(k).FF_FPRPercentage)))*100;
    MF(k).IC.FPR_sum = mean(IC(k).MF_FPRPercentage)*100;
    MF(k).IC.FPR_std = (std(IC(k).MF_FPRPercentage)/sqrt(length(IC(k).MF_FPRPercentage)))*100;
    HF(k).IC.FPR_sum = mean(IC(k).HF_FPRPercentage)*100;
    HF(k).IC.FPR_std = (std(IC(k).HF_FPRPercentage)/sqrt(length(IC(k).HF_FPRPercentage)))*100;
    FF(k).IC.TPR_sum = mean(IC(k).FF_TPRPercentage)*100;
    FF(k).IC.TPR_std = (std(IC(k).FF_TPRPercentage)/sqrt(length(IC(k).FF_TPRPercentage)))*100;
    MF(k).IC.TPR_sum = mean(IC(k).MF_TPRPercentage)*100;
    MF(k).IC.TPR_std = (std(IC(k).MF_TPRPercentage)/sqrt(length(IC(k).MF_TPRPercentage)))*100;
    HF(k).IC.TPR_sum = mean(IC(k).HF_TPRPercentage)*100;
    HF(k).IC.TPR_std = (std(IC(k).HF_TPRPercentage)/sqrt(length(IC(k).HF_TPRPercentage)))*100;
    
    temp_tpr = [IC(k).HF_TPRPercentage IC(k).MF_TPRPercentage IC(k).FF_TPRPercentage];
    temp_fpr = [IC(k).HF_FPRPercentage IC(k).MF_FPRPercentage IC(k).FF_FPRPercentage];

    Overall(k).IC.TPR_sum = mean(temp_tpr)*100;
    Overall(k).IC.TPR_std = std(temp_tpr)/sqrt(length(temp_tpr))*100;
    Overall(k).IC.FPR_sum = mean(temp_fpr)*100;
    Overall(k).IC.FPR_std = std(temp_fpr)/sqrt(length(temp_fpr))*100;
    k = k + 1;
    
end

clearvars -except  pathCompSep destPath FOnum FOstr FS IC FF MF HF Overall

% %% FO
% length_FO_FF = find(FOstr == "ForeFoot", 1, 'last')-1;
% length_FO_MF = find(FOstr == "MidFoot",  1, 'last')-1;
% length_FO_HF = find(FOstr == "Heel",     1, 'last')-1;
% 
% k = 1;
% for i = 1:2:size(FOnum,2)
%     
%     FO_FF_FPR  =  FOnum(1:length_FO_FF,i);
%     FO_FF_TPR  =  FOnum(1:length_FO_FF,i+1);
%     FO_MF_FPR  =  FOnum(length_FO_FF:length_FO_MF,i);
%     FO_MF_TPR  =  FOnum(length_FO_FF:length_FO_MF,i+1);
%     FO_HF_FPR  =  FOnum(length_FO_MF:length_FO_HF,i);
%     FO_HF_TPR  =  FOnum(length_FO_MF:length_FO_HF,i+1);
%     
%     FO_Batch_size = 32;
%     t = 1;
%     
%     for j = 1:FO_Batch_size:(length(FO_FF_TPR))
%         
%         FO_FF_temp_FPR(1:length(FO_FF_FPR(j:j+FO_Batch_size-1)),t)  = FO_FF_FPR(j:j+FO_Batch_size-1);
%         FO_MF_temp_FPR(1:length(FO_MF_FPR(j:j+FO_Batch_size-1)),t)  = FO_MF_FPR(j:j+FO_Batch_size-1);
%         FO_HF_temp_FPR(1:length(FO_HF_FPR(j:j+FO_Batch_size-1)),t)  = FO_HF_FPR(j:j+FO_Batch_size-1);
%         
%         FO_FF_temp_TPR(1:length(FO_FF_TPR(j:j+FO_Batch_size-1)),t)  = FO_FF_TPR(j:j+FO_Batch_size-1);
%         FO_MF_temp_TPR(1:length(FO_MF_TPR(j:j+FO_Batch_size-1)),t)  = FO_MF_TPR(j:j+FO_Batch_size-1);
%         FO_HF_temp_TPR(1:length(FO_HF_TPR(j:j+FO_Batch_size-1)),t)  = FO_HF_TPR(j:j+FO_Batch_size-1);
%         
%         temp_FO_FF_temp_FPR=FO_FF_temp_FPR(:,t);
%         temp_FO_MF_temp_FPR=FO_MF_temp_FPR(:,t);
%         temp_FO_HF_temp_FPR=FO_HF_temp_FPR(:,t);
%         
%         temp_FO_FF_temp_TPR=FO_FF_temp_TPR(:,t);
%         temp_FO_MF_temp_TPR=FO_MF_temp_TPR(:,t);
%         temp_FO_HF_temp_TPR=FO_HF_temp_TPR(:,t);
%         
%         temp_FO_FF_temp_FPR(temp_FO_FF_temp_FPR == -1) = [];
%         temp_FO_MF_temp_FPR(temp_FO_MF_temp_FPR == -1) = [];
%         temp_FO_HF_temp_FPR(temp_FO_HF_temp_FPR == -1) = [];
%         
%         temp_FO_FF_temp_TPR(temp_FO_FF_temp_TPR == -1) = [];
%         temp_FO_MF_temp_TPR(temp_FO_MF_temp_TPR == -1) = [];
%         temp_FO_HF_temp_TPR(temp_FO_HF_temp_TPR == -1) = [];
%         
%         TO(k).FF_Total(:,t) = sum(temp_FO_FF_temp_FPR) + sum(temp_FO_FF_temp_TPR);
%         TO(k).MF_Total(:,t) = sum(temp_FO_MF_temp_FPR) + sum(temp_FO_MF_temp_TPR);
%         TO(k).HF_Total(:,t) = sum(temp_FO_HF_temp_FPR) + sum(temp_FO_HF_temp_TPR);
%         
%         TO(k).FF_FPRTotal(:,t) = sum(temp_FO_FF_temp_FPR);
%         TO(k).MF_FPRTotal(:,t) = sum(temp_FO_MF_temp_FPR);
%         TO(k).HF_FPRTotal(:,t) = sum(temp_FO_HF_temp_FPR);
%         
%         TO(k).FF_TPRTotal(:,t) = sum(temp_FO_FF_temp_TPR);
%         TO(k).MF_TPRTotal(:,t) = sum(temp_FO_MF_temp_TPR);
%         TO(k).HF_TPRTotal(:,t) = sum(temp_FO_HF_temp_TPR);
%         
%         TO(k).FF_FPR(:,t) = sum(temp_FO_FF_temp_FPR)/TO(k).FF_Total(:,t);
%         TO(k).MF_FPR(:,t) = sum(temp_FO_MF_temp_FPR)/TO(k).MF_Total(:,t);
%         TO(k).HF_FPR(:,t) = sum(temp_FO_HF_temp_FPR)/TO(k).HF_Total(:,t);
%         
%         TO(k).FF_TPR(:,t) = sum(temp_FO_FF_temp_TPR)/TO(k).FF_Total(:,t);
%         TO(k).MF_TPR(:,t) = sum(temp_FO_MF_temp_TPR)/TO(k).MF_Total(:,t);
%         TO(k).HF_TPR(:,t) = sum(temp_FO_HF_temp_TPR)/TO(k).HF_Total(:,t);
%         
%         TO(k).FF_FPRRaw(1:length(temp_FO_FF_temp_FPR),t) = temp_FO_FF_temp_FPR;
%         TO(k).MF_FPRRaw(1:length(temp_FO_MF_temp_FPR),t) = temp_FO_MF_temp_FPR;
%         TO(k).HF_FPRRaw(1:length(temp_FO_HF_temp_FPR),t) = temp_FO_HF_temp_FPR;
%         
%         TO(k).FF_TPRRaw(1:length(temp_FO_FF_temp_TPR),t) = temp_FO_FF_temp_TPR;
%         TO(k).MF_TPRRaw(1:length(temp_FO_MF_temp_TPR),t) = temp_FO_MF_temp_TPR;
%         TO(k).HF_TPRRaw(1:length(temp_FO_HF_temp_TPR),t) = temp_FO_HF_temp_TPR;
%         
%         t = t+ 1;
%         
%     end
%     FF(k).TO.FPR_sum = mean(TO(k).FF_FPR)*100;
%     FF(k).TO.FPR_std = (std(TO(k).FF_FPR)/sqrt(length(TO(k).FF_FPR)))*100;
%     MF(k).TO.FPR_sum = mean(TO(k).MF_FPR)*100;
%     MF(k).TO.FPR_std = (std(TO(k).MF_FPR)/sqrt(length(TO(k).MF_FPR)))*100;
%     HF(k).TO.FPR_sum = mean(TO(k).HF_FPR)*100;
%     HF(k).TO.FPR_std = (std(TO(k).HF_FPR)/sqrt(length(TO(k).HF_FPR)))*100;
%     FF(k).TO.TPR_sum = mean(TO(k).FF_TPR)*100;
%     FF(k).TO.TPR_std = (std(TO(k).FF_TPR)/sqrt(length(TO(k).FF_TPR)))*100;
%     MF(k).TO.TPR_sum = mean(TO(k).MF_TPR)*100;
%     MF(k).TO.TPR_std = (std(TO(k).MF_TPR)/sqrt(length(TO(k).MF_TPR)))*100;
%     HF(k).TO.TPR_sum = mean(TO(k).HF_TPR)*100;
%     HF(k).TO.TPR_std = (std(TO(k).HF_TPR)/sqrt(length(TO(k).HF_TPR)))*100;
%     temp_tpr = [TO(k).HF_TPR TO(k).MF_TPR TO(k).FF_TPR];
%     temp_fpr = [TO(k).HF_FPR TO(k).MF_FPR TO(k).FF_FPR];
%     Overall(k).TO.TPR_sum = mean(temp_tpr)*100;
%     Overall(k).TO.TPR_std = std(temp_tpr)/sqrt(length(temp_tpr))*100;
%     Overall(k).TO.FPR_sum = mean(temp_fpr)*100;
%     Overall(k).TO.FPR_std = std(temp_fpr)/sqrt(length(temp_fpr))*100;
%     k = k + 1;
%     
% end
% 
% clearvars -except IC TO FF MF HF Overall
