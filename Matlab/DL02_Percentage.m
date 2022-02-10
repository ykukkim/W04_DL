%% Analysis
% 1. Percentage within 16ms
% 2. Averaged time with 95%
clear; close;
%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');
% ifMac = 1;
switch ifMac
    case 0
        TestPath1= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results/excel';
        
        pathCompSep = '/';
    case 1
        %for testing reasons, path is hard-coded
        TestPath1= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Results\excel\';
        pathCompSep = '\';
end

destPath = [TestPath1, pathCompSep, 'Manuscript'];
pctl = [10 95];

% Reading CSV
[FSnum,FSstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],1);
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],4);

%% FS

% FS_FF_temp_Final = NaN(50,10);
% FS_MF_temp_Final = NaN(50,10);
% FS_HF_temp_Final = NaN(50,10);

q = 1;

for i = 1:2:size(FSnum,2)
    
    length_FS_FF = find(FSstr(:,i) == "ForeFoot", 1, 'last')-1;
    length_FS_MF = find(FSstr(:,i) == "MidFoot",  1, 'last')-1;
    length_FS_HF = find(FSstr(:,i) == "Heel",     1, 'last')-1;
    
    FS_FF  =  FSnum(1:length_FS_FF,i);
    FS_MF  =  FSnum(length_FS_FF:length_FS_MF,i);
    FS_HF  =  FSnum(length_FS_MF:length_FS_HF,i);
    
    % Perctange
    pctlv_FF = [];
    pctlv_MF = [];
    pctlv_HF = [];
    
    % FF
    t = 1;
    FS_FF_Batch_size = floor(length(FS_FF)/10);
    for j = 1:FS_FF_Batch_size:(length(FS_FF)-FS_FF_Batch_size)
        
        FS_FF_temp  = FS_FF(j:j+FS_FF_Batch_size);
        FS_FF_temp_Final(1:length(FS_FF_temp),t)  = sort(FS_FF_temp, 'ascend');
        temp = rmoutliers(FS_FF_temp_Final(1:length(FS_FF_temp),t),'median');
        
        % Finds the value at 95% percentile
        pctlv_FF =  prctile(abs(temp),pctl);
        
        % Events within 95% of result
        Indx_FF  = find(temp <= pctlv_FF(2));
        
        FS(q).Time.Average_95.FF(1,t)  = mean(temp(Indx_FF));
        clear Indx_FF
        
        % Percentage within 16ms
        Indx_FF  = find(FS_FF_temp_Final(:,t) <= 2.4);
        FS(q).Percentage.within16.FF(t) = (length((Indx_FF))/length(temp))*100;
        FS(q).Percentage.out16.FF(t) = 100-((length((Indx_FF))/length(temp))*100);
        
        t = t+1;
    end
    % MF
    t = 1;
    FS_MF_Batch_size = floor(length(FS_MF)/10);
    for j = 1:FS_MF_Batch_size:(length(FS_MF)-FS_MF_Batch_size)
        
        FS_MF_temp  = FS_MF(j:j+FS_MF_Batch_size);
        FS_MF_temp_Final(1:length(FS_MF_temp),t)  =  sort(FS_MF_temp, 'ascend');
        temp = rmoutliers(FS_MF_temp_Final(1:length(FS_MF_temp),t),'median');
        
        % Finds the value at 95% percentile
        pctlv_MF =  prctile(abs(temp),pctl);
        
        % Events within 95% of result
        Indx_MF  = find(temp <= pctlv_MF(2));
        
        FS_MF_temp_Final_temp  = FS_MF_temp_Final(:,t);
        FS(q).Time.Average_95.MF(1,t)  = mean(temp(Indx_MF));
        clear Indx_MF
        
        % Percentage within 16ms
        Indx_MF  = find(FS_MF_temp_Final(:,t) <= 2.4);
        FS(q).Percentage.within16.MF(t) = (length((Indx_MF))/length(temp))*100;
        FS(q).Percentage.out16.MF(t) = 100-((length((Indx_MF))/length(temp))*100);
        clear Indx_MF
        t = t+1;
    end
    % HF
    t = 1;
    FS_HF_Batch_size = floor(length(FS_HF)/10);
    for j = 1:FS_HF_Batch_size:(length(FS_HF)-FS_HF_Batch_size)
        
        FS_HF_temp  = FS_HF(j:j+FS_HF_Batch_size);
        FS_HF_temp_Final(1:length(FS_HF_temp),t)  = sort(FS_HF_temp, 'ascend');
        temp = rmoutliers(FS_HF_temp_Final(1:length(FS_HF_temp),t),'median');
        
        % Finds the value at 95% percentile
        pctlv_HF =  prctile(abs(temp),pctl);
        
        % Events within 95% of result
        Indx_HF  = find(temp <= pctlv_HF(2));
        
        FS(q).Time.Average_95.HF(1,t)  = mean(temp(Indx_HF));
        clear Indx_HF
        
        % Percentage within 16ms
        Indx_HF  = find(temp <= 2.4);
        FS(q).Percentage.within16.HF(t) = (length((Indx_HF))/length(temp))*100;
        FS(q).Percentage.out16.HF(t) = 100-((length((Indx_HF))/length(temp))*100);
        t = t+1;
    end
    q = q+1;
    clearvars -except TestPath1 pathCompSep destPath names pctl FOnum FOstr FSnum FSstr FS  i q
end

for i = 1:size(FS,2)
    
    FF(i).std = std(FS(i).Percentage.within16.FF)/sqrt(length(FS(i).Percentage.within16.FF));
    FF(i).mean = mean(FS(i).Percentage.within16.FF);
    FF(i).time_mean = mean(FS(i).Time.Average_95.FF*6.6);
    FF(i).time_std = std(FS(i).Time.Average_95.FF*6.6);
    
    MF(i).std = std(FS(i).Percentage.within16.MF)/sqrt(length(FS(i).Percentage.within16.MF));
    MF(i).mean = mean(FS(i).Percentage.within16.MF);
    MF(i).time_mean = mean(FS(i).Time.Average_95.MF*6.6);
    MF(i).time_std = std(FS(i).Time.Average_95.MF*6.6);
    
    HF(i).std = std(FS(i).Percentage.within16.HF)/sqrt(length(FS(i).Percentage.within16.HF));
    HF(i).mean = mean(FS(i).Percentage.within16.HF);
    HF(i).time_mean = mean(FS(i).Time.Average_95.HF*6.6);
    HF(i).time_std = std(FS(i).Time.Average_95.HF*6.6);
    
    temp = [FS(i).Percentage.within16.FF  FS(i).Percentage.within16.MF FS(i).Percentage.within16.HF];
    temp_time = [FS(i).Time.Average_95.FF  FS(i).Time.Average_95.MF FS(i).Time.Average_95.HF];
    
    Overall(i).std = std(temp)/sqrt(length(temp));
    Overall(i).mean = mean(temp);
    Overall(i).Timestd = std(temp_time*6.6)/sqrt(length(temp));
    Overall(i).Timemean = mean(temp_time)*6.6;
end

clearvars -except TestPath1 pathCompSep destPath names pctl FOnum FOstr FS FF HF MF Overall

% %% FO
% length_FO_FF = find(FOstr == "ForeFoot", 1, 'last')-1;
% length_FO_MF = find(FOstr == "MidFoot",  1, 'last')-1;
% length_FO_HF = find(FOstr == "Heel",     1, 'last')-1;
%
% FO_FF_temp_Final = NaN(50,10);
% FO_MF_temp_Final = NaN(50,10);
% FO_HF_temp_Final = NaN(50,10);
% q = 1;
%
% for i = 1:2:size(FOnum,2)
%     length_FO_FF = find(FOstr(:,i) == "ForeFoot", 1, 'last')-1;
%     length_FO_MF = find(FOstr(:,i) == "MidFoot",  1, 'last')-1;
%     length_FO_HF = find(FOstr(:,i) == "Heel",     1, 'last')-1;
%
%     FO_FF  =  FOnum(1:length_FO_FF,i);
%     FO_MF  =  FOnum(length_FO_FF:length_FO_MF,i);
%     FO_HF  =  FOnum(length_FO_MF:length_FO_HF,i);
%
%     % Perctange
%     pctlv_FF = [];
%     pctlv_MF = [];
%     pctlv_HF = [];
%
%     % FF
%     t = 1;
%     FO_FF_Batch_size = floor(length(FO_FF)/10);
%     for j = 1:FO_FF_Batch_size:(length(FO_FF)-FO_FF_Batch_size)
%         FO_FF_temp  = FO_FF(j:j+FO_FF_Batch_size);
%         Original_length_FF = length(FO_FF_temp);
%
%         FO_FF_temp_Final(1:length(FO_FF_temp),t)  = sort(FO_FF_temp, 'ascend');
%         temp = rmoutliers(FO_FF_temp_Final,'median');
%
%         % Finds the value at 95% percentile
%         pctlv_FF =  prctile(abs(temp(:,t)),pctl);
%
%         % Events within 95% of result
%         Indx_FF  = find(FO_FF_temp_Final(:,t) <= pctlv_FF(2));
%
%         FO_FF_temp_Final_temp  = FO_FF_temp_Final(:,t);
%         FO(q).Time.Average_95.FF(1,t)  = mean(FO_FF_temp_Final_temp(Indx_FF));
%         clear Indx_FF
%         Indx_FF  = find(FO_FF_temp_Final(:,t) <= 2.5);
%         % Percentage within 16ms
%
%         FO(q).Percentage.within16.FF(t) = (length((Indx_FF))/Original_length_FF)*100;
%         FO(q).Percentage.out16.FF(t) = 100-((length((Indx_FF))/Original_length_FF)*100);
%         FO(q).Time.Average_16.FF(1:(length(Indx_FF)),t)  = FO_FF_temp_Final_temp(Indx_FF);
%         FO(q).Time.Average_out16.FF(1:length(FO_FF_temp_Final_temp(Indx_FF(end)+1:end)),t)  = FO_FF_temp_Final_temp(Indx_FF(end)+1:end);
%         clear Indx_FF
%
%         t = t+1;
%     end
%     % MF
%     t = 1;
%     FO_MF_Batch_size = floor(length(FO_MF)/10);
%     for j = 1:FO_MF_Batch_size:(length(FO_MF)-FO_MF_Batch_size)
%         FO_MF_temp  = FO_MF(j:j+FO_MF_Batch_size);
%         Original_length_MF = length(FO_MF_temp);
%
%         FO_MF_temp_Final(1:length(FO_MF_temp),t)  =  sort(FO_MF_temp, 'ascend');
%         temp = rmoutliers(FO_MF_temp_Final,'median');
%
%         pctlv_MF =  prctile(abs(temp(:,t)),pctl);
%         Indx_MF  = find(FO_MF_temp_Final(:,t) <= pctlv_MF(2));
%         FO_MF_temp_Final_temp  = FO_MF_temp_Final(:,t);
%         FO(q).Time.Average_95.MF(1,t)  = mean(FO_MF_temp_Final_temp(Indx_MF));
%         clear Indx_MF
%         Indx_MF  = find(FO_MF_temp_Final(:,t) <= 2.5);
%         FO(q).Percentage.within16.MF(t) = (length((Indx_MF))/Original_length_MF)*100;
%         FO(q).Percentage.out16.MF(t) = 100-((length((Indx_MF))/Original_length_MF)*100);
%         FO(q).Time.Average_16.MF(1:(length(Indx_MF)),t)  = FO_MF_temp_Final_temp(Indx_MF);
%         FO(q).Time.Average_out16.MF(1:length(FO_MF_temp_Final_temp(Indx_MF(end)+1:end)),t)  = FO_MF_temp_Final_temp(Indx_MF(end)+1:end);
%         clear Indx_MF
%         t = t+1;
%     end
%     % HF
%     t = 1;
%     FO_HF_Batch_size = floor(length(FO_HF)/10);
%     for j = 1:FO_HF_Batch_size:(length(FO_HF)-FO_HF_Batch_size)
%         FO_HF_temp  = FO_HF(j:j+FO_HF_Batch_size);
%         Original_length_HF = length(FO_HF_temp);
%
%         FO_HF_temp_Final(1:length(FO_HF_temp),t)  = sort(FO_HF_temp, 'ascend');
%                 temp = rmoutliers(FO_HF_temp_Final,'median');
%
%         pctlv_HF =  prctile(abs(temp),pctl);
%         Indx_HF  = find(FO_HF_temp_Final(:,t) <= pctlv_HF(2));
%         FO_HF_temp_Final_temp  = FO_HF_temp_Final(:,t);
%         FO(q).Time.Average_95.HF(1,t)  = mean(FO_HF_temp_Final_temp(Indx_HF));
%         clear Indx_HF
%         Indx_HF  = find(FO_HF_temp_Final(:,t) <= 2.5);
%         FO(q).Percentage.within16.HF(t) = (length((Indx_HF))/Original_length_HF)*100;
%         FO(q).Percentage.out16.HF(t) = 100-((length((Indx_HF))/Original_length_HF)*100);
%         FO(q).Time.Average_16.HF(1:(length(Indx_HF)),t)  = FO_HF_temp_Final_temp(Indx_HF);
%         FO(q).Time.Average_out16.HF(1:length(FO_HF_temp_Final_temp(Indx_HF(end)+1:end)),t)  = FO_HF_temp_Final_temp(Indx_HF(end)+1:end);
%         clear Indx_HF
%         t = t+1;
%     end
%
%     q = q+1;
%     clearvars -except TestPath1 pathCompSep destPath names pctl FOnum FOstr FSnum FSstr FS FO i q
% end

% clearvars -except FS FO
