%% Analysis
% 1. Percentage within 16ms
% 2. Averaged time within 16ms
% 4. Averaged time outside of 16ms
% 3. Averaged time with 95%
clear; close;
%% Initializing the data folder
% ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');
ifMac = 1;
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

% Reading CSV1
[FSnum,FSstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],3);
[FOnum,FOstr]            = xlsread([TestPath1,pathCompSep,'Result.xlsx'],4);

%% FS
length_FS_FF = find(FSstr == "ForeFoot", 1, 'last')-1;
length_FS_MF = find(FSstr == "MidFoot",  1, 'last')-1;
length_FS_HF = find(FSstr == "Heel",     1, 'last')-1;

FS_FF_temp_Final = NaN(35,10);
FS_MF_temp_Final = NaN(35,10);
FS_HF_temp_Final = NaN(35,10);


for i = 1:size(FSnum,2)
    
    FS_FF  =  FSnum(1:length_FS_FF,i);
    FS_MF  =  FSnum(length_FS_FF:length_FS_MF,i);
    FS_HF  =  FSnum(length_FS_MF:length_FS_HF,i);
    
    % Perctange
    pctlv_FF = [];
    pctlv_MF = [];
    pctlv_HF = [];
    
    FS_Batch_size = 32;
    
    % ForeFoot
    t = 1;
    for j = 1:FS_Batch_size:(length(FS_FF)-FS_Batch_size)
        
        FS_FF_temp  = FS_FF(j:j+FS_Batch_size);
        FS_MF_temp  = FS_MF(j:j+FS_Batch_size);
        FS_HF_temp  = FS_HF(j:j+FS_Batch_size);
        
        Original_length_FF = length(FS_FF_temp);
        Original_length_MF = length(FS_MF_temp);
        Original_length_HF = length(FS_HF_temp);
        
        FS_FF_temp(FS_FF_temp == -1) = [];
        FS_MF_temp(FS_MF_temp == -1) = [];
        FS_HF_temp(FS_HF_temp == -1) = [];
        
        FS_FF_temp = rmoutliers(FS_FF_temp,'median');
        FS_MF_temp = rmoutliers(FS_MF_temp,'median');
        FS_HF_temp = rmoutliers(FS_HF_temp,'median');
        
        % Sort from lowest to highest
        FS_FF_temp_Final(1:length(FS_FF_temp),t)  = sort(FS_FF_temp,'ascend');
        FS_MF_temp_Final(1:length(FS_MF_temp),t)  = sort(FS_MF_temp,'ascend');
        FS_HF_temp_Final(1:length(FS_HF_temp),t)  = sort(FS_HF_temp,'ascend');
        
        % Finds the value at 95% percentile
        pctlv_FF =  prctile(abs(FS_FF_temp_Final(:,t)),pctl);
        pctlv_MF =  prctile(abs(FS_MF_temp_Final(:,t)),pctl);
        pctlv_HF =  prctile(abs(FS_HF_temp_Final(:,t)),pctl);
        
        % Events within 95% of result
        Indx_FF  = find(FS_FF_temp_Final(:,t) <= pctlv_FF(2));
        Indx_MF  = find(FS_MF_temp_Final(:,t) <= pctlv_MF(2));
        Indx_HF  = find(FS_HF_temp_Final(:,t) <= pctlv_HF(2));
        
        % Creating temp variable
        FS_FF_temp_Final_temp  = FS_FF_temp_Final(:,t);
        FS_MF_temp_Final_temp  = FS_MF_temp_Final(:,t);
        FS_HF_temp_Final_temp  = FS_HF_temp_Final(:,t);
        
        % Time within 95%
%         FS(i).Time.Average_95.FF(1:(length(Indx_FF)),t)  = mean(FS_FF_temp_Final_temp(Indx_FF));
%         FS(i).Time.Average_95.MF(1:(length(Indx_MF)),t)  = mean(FS_MF_temp_Final_temp(Indx_MF));
%         FS(i).Time.Average_95.HF(1:(length(Indx_HF)),t)  = mean(FS_HF_temp_Final_temp(Indx_HF));
        
        FS(i).Time.Average_95.FF(1,t)  = mean(FS_FF_temp_Final_temp(Indx_FF));
        FS(i).Time.Average_95.MF(1,t)  = mean(FS_MF_temp_Final_temp(Indx_MF));
        FS(i).Time.Average_95.HF(1,t)  = mean(FS_HF_temp_Final_temp(Indx_HF));
        
        clearvars Indx_FF Indx_MF Indx_HF
        
        % Events detected within 16ms.
        Indx_FF  = find(FS_FF_temp_Final(:,t) <= 2.5);
        Indx_MF  = find(FS_MF_temp_Final(:,t) <= 2.5);
        Indx_HF  = find(FS_HF_temp_Final(:,t) <= 2.5);
        
        % Percentage within 16ms
        FS(i).Percentage.within16.FF(t) = (length((Indx_FF))/Original_length_FF)*100;
        FS(i).Percentage.within16.MF(t) = (length((Indx_MF))/Original_length_MF)*100;
        FS(i).Percentage.within16.HF(t) = (length((Indx_HF))/Original_length_HF)*100;
        
        % Averaged time witin 16ms
        
        FS(i).Time.Average_16.FF(1:(length(Indx_FF)),t)  = FS_FF_temp_Final_temp(Indx_FF);
        FS(i).Time.Average_16.MF(1:(length(Indx_MF)),t)  = FS_MF_temp_Final_temp(Indx_MF);
        FS(i).Time.Average_16.HF(1:(length(Indx_HF)),t)  = FS_HF_temp_Final_temp(Indx_HF);
        
        % Percentage outside 16ms
        FS(i).Percentage.out16.FF(t) = 100-((length((Indx_FF))/Original_length_FF)*100);
        FS(i).Percentage.out16.MF(t) = 100-((length((Indx_MF))/Original_length_MF)*100);
        FS(i).Percentage.out16.HF(t) = 100-((length((Indx_HF))/Original_length_HF)*100);
        
        % Averaged time outside 16ms
        
        FS(i).Time.Average_out16.FF(1:length(FS_FF_temp_Final_temp(Indx_FF(end)+1:end)),t)  = FS_FF_temp_Final_temp(Indx_FF(end)+1:end);
        FS(i).Time.Average_out16.MF(1:length(FS_MF_temp_Final_temp(Indx_MF(end)+1:end)),t)  = FS_MF_temp_Final_temp(Indx_MF(end)+1:end);
        FS(i).Time.Average_out16.HF(1:length(FS_HF_temp_Final_temp(Indx_HF(end)+1:end)),t)  = FS_HF_temp_Final_temp(Indx_HF(end)+1:end);
        
        clearvars Indx_FF Indx_MF Indx_HF
        
        t = t + 1;
    end
    FS(i).Time.Average_95_2.FF(1)  = mean(FS(i).Time.Average_95.FF(1,:))*6.6;
    FS(i).Time.Average_95_2.MF(1)  = mean(FS(i).Time.Average_95.MF(1,:))*6.6;
    FS(i).Time.Average_95_2.HF(1)  = mean(FS(i).Time.Average_95.HF(1,:))*6.6;
        
    % Mean and standard deviation of averaged seconds
    %     [FS(i).Average.FFTime, FS(i).Std.FFTime]               = deal(mean(FS(i).Time.Average.FF), std(FS(i).Time.Average.FF));
    %     [FS(i).Average.FFPercentage,FS(i).Std.FFPercentage]    = deal(mean(FS(i).Percentage.Average.FF), std(FS(i).Percentage.Average.FF));
    %     [FS(i).Average.MFTime, FS(i).Std.MFTime]               = deal(mean(FS(i).Time.Average.MF), std(FS(i).Time.Average.MF));
    %     [FS(i).Average.MFPercentage,FS(i).Std.MFPercentage]    = deal(mean(FS(i).Percentage.Average.MF), std(FS(i).Percentage.Average.MF));
    %     [FS(i).Average.HFTime, FS(i).Std.HFTime]               = deal(mean(FS(i).Time.Average.HF), std(FS(i).Time.Average.HF));
    %     [FS(i).Average.HFPercentage,FS(i).Std.HFPercentage]    = deal(mean(FS(i).Percentage.Average.HF), std(FS(i).Percentage.Average.HF));
    
end

clearvars -except TestPath1 pathCompSep destPath names pctl FOnum FOstr FS

%% FO
length_FO_FF = find(FOstr == "ForeFoot", 1, 'last')-1;
length_FO_MF = find(FOstr == "MidFoot",  1, 'last')-1;
length_FO_HF = find(FOstr == "Heel",     1, 'last')-1;

FO_FF_temp_Final = NaN(35,10);
FO_MF_temp_Final = NaN(35,10);
FO_HF_temp_Final = NaN(35,10);


for i = 1:size(FOnum,2)
    % for i = 5
    FO_FF  =  FOnum(1:length_FO_FF,i);
    FO_MF  =  FOnum(length_FO_FF:length_FO_MF,i);
    FO_HF  =  FOnum(length_FO_MF:length_FO_HF,i);
    
    % Perctange
    pctlv_FF = [];
    pctlv_MF = [];
    pctlv_HF = [];
    
    FO_Batch_size = 32;
    
    % ForeFoot
    t = 1;
    for j = 1:FO_Batch_size:(length(FO_FF)-FO_Batch_size)
        
        FO_FF_temp  = FO_FF(j:j+FO_Batch_size);
        FO_MF_temp  = FO_MF(j:j+FO_Batch_size);
        FO_HF_temp  = FO_HF(j:j+FO_Batch_size);
        
        Original_length_FF = length(FO_FF_temp);
        Original_length_MF = length(FO_MF_temp);
        Original_length_HF = length(FO_HF_temp);
        
        FO_FF_temp(FO_FF_temp == -1) = [];
        FO_MF_temp(FO_MF_temp == -1) = [];
        FO_HF_temp(FO_HF_temp == -1) = [];
        
        FO_FF_temp = rmoutliers(FO_FF_temp,'median');
        FO_MF_temp = rmoutliers(FO_MF_temp,'median');
        FO_HF_temp = rmoutliers(FO_HF_temp,'median');
        
        % Sort from lowest to highest
        FO_FF_temp_Final(1:length(FO_FF_temp),t)  = sort(FO_FF_temp,'ascend');
        FO_MF_temp_Final(1:length(FO_MF_temp),t)  = sort(FO_MF_temp,'ascend');
        FO_HF_temp_Final(1:length(FO_HF_temp),t)  = sort(FO_HF_temp,'ascend');
        
        % Finds the value at 95% percentile
        pctlv_FF =  prctile(abs(FO_FF_temp_Final(:,t)),pctl);
        pctlv_MF =  prctile(abs(FO_MF_temp_Final(:,t)),pctl);
        pctlv_HF =  prctile(abs(FO_HF_temp_Final(:,t)),pctl);
        
        % Events within 95% of result
        Indx_FF  = find(FO_FF_temp_Final(:,t) <= pctlv_FF(2));
        Indx_MF  = find(FO_MF_temp_Final(:,t) <= pctlv_MF(2));
        Indx_HF  = find(FO_HF_temp_Final(:,t) <= pctlv_HF(2));
        
        % Creating temp variable
        FO_FF_temp_Final_temp  = FO_FF_temp_Final(:,t);
        FO_MF_temp_Final_temp  = FO_MF_temp_Final(:,t);
        FO_HF_temp_Final_temp  = FO_HF_temp_Final(:,t);
        
        % Time within 95%
%         FO(i).Time.Average_95.FF(1:(length(Indx_FF)),t)  = FO_FF_temp_Final_temp(Indx_FF);
%         FO(i).Time.Average_95.MF(1:(length(Indx_MF)),t)  = FO_MF_temp_Final_temp(Indx_MF);
%         FO(i).Time.Average_95.HF(1:(length(Indx_HF)),t)  = FO_HF_temp_Final_temp(Indx_HF);
        FO(i).Time.Average_95.FF(1,t)  = mean(FO_FF_temp_Final_temp(Indx_FF));
        FO(i).Time.Average_95.MF(1,t)  = mean(FO_MF_temp_Final_temp(Indx_MF));
        FO(i).Time.Average_95.HF(1,t)  = mean(FO_HF_temp_Final_temp(Indx_HF));
        
        clearvars Indx_FF Indx_MF Indx_HF
        
        % Events detected within 16ms.
        Indx_FF  = find(FO_FF_temp_Final(:,t) <= 2.5);
        Indx_MF  = find(FO_MF_temp_Final(:,t) <= 2.5);
        Indx_HF  = find(FO_HF_temp_Final(:,t) <= 2.5);
        
        % Percentage within 16ms
        FO(i).Percentage.within16.FF(t) = (length((Indx_FF))/Original_length_FF)*100;
        FO(i).Percentage.within16.MF(t) = (length((Indx_MF))/Original_length_MF)*100;
        FO(i).Percentage.within16.HF(t) = (length((Indx_HF))/Original_length_HF)*100;
        
        % Averaged time witin 16ms
        
        FO(i).Time.Average_16.FF(1:(length(Indx_FF)),t)  = FO_FF_temp_Final_temp(Indx_FF);
        FO(i).Time.Average_16.MF(1:(length(Indx_MF)),t)  = FO_MF_temp_Final_temp(Indx_MF);
        FO(i).Time.Average_16.HF(1:(length(Indx_HF)),t)  = FO_HF_temp_Final_temp(Indx_HF);
        
        % Percentage outside 16ms
        FO(i).Percentage.out16.FF(t) = 100-((length((Indx_FF))/Original_length_FF)*100);
        FO(i).Percentage.out16.MF(t) = 100-((length((Indx_MF))/Original_length_MF)*100);
        FO(i).Percentage.out16.HF(t) = 100-((length((Indx_HF))/Original_length_HF)*100);
        
        % Averaged time outside 16ms
        
        FO(i).Time.Average_out16.FF(1:length(FO_FF_temp_Final_temp(Indx_FF(end)+1:end)),t)  = FO_FF_temp_Final_temp(Indx_FF(end)+1:end);
        FO(i).Time.Average_out16.MF(1:length(FO_MF_temp_Final_temp(Indx_MF(end)+1:end)),t)  = FO_MF_temp_Final_temp(Indx_MF(end)+1:end);
        FO(i).Time.Average_out16.HF(1:length(FO_HF_temp_Final_temp(Indx_HF(end)+1:end)),t)  = FO_HF_temp_Final_temp(Indx_HF(end)+1:end);
        
        
        clearvars Indx_FF Indx_MF Indx_HF
        
        t = t + 1;
    end
    FO(i).Time.Average_95_2.FF(1)  = mean(FO(i).Time.Average_95.FF(1,:))*6.6;
    FO(i).Time.Average_95_2.MF(1)  = mean(FO(i).Time.Average_95.MF(1,:))*6.6;
    FO(i).Time.Average_95_2.HF(1)  = mean(FO(i).Time.Average_95.HF(1,:))*6.6;
    % Mean and standard deviation of averaged seconds
    %     [FO(i).Average.FFTime, FO(i).Std.FFTime]               = deal(mean(FO(i).Time.Average.FF), std(FO(i).Time.Average.FF));
    %     [FO(i).Average.FFPercentage,FO(i).Std.FFPercentage]    = deal(mean(FO(i).Percentage.Average.FF), std(FO(i).Percentage.Average.FF));
    %     [FO(i).Average.MFTime, FO(i).Std.MFTime]               = deal(mean(FO(i).Time.Average.MF), std(FO(i).Time.Average.MF));
    %     [FO(i).Average.MFPercentage,FO(i).Std.MFPercentage]    = deal(mean(FO(i).Percentage.Average.MF), std(FO(i).Percentage.Average.MF));
    %     [FO(i).Average.HFTime, FO(i).Std.HFTime]               = deal(mean(FO(i).Time.Average.HF), std(FO(i).Time.Average.HF));
    %     [FO(i).Average.HFPercentage,FO(i).Std.HFPercentage]    = deal(mean(FO(i).Percentage.Average.HF), std(FO(i).Percentage.Average.HF));
    
end

clearvars -except FS FO
