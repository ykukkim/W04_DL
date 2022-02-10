%% c3d file to mat.
% Extracts the kinematic and kinetic data from VICON
% Following parameters are extracted:
% 1. Frame number
% 2. Sampling frequency
% 3. Annotated Events
% 4. Classification of patient --> group 1,2 or 3?
clear; clc; close;

%% Initializing the data folder
ifMac = input('Please choose computer is being used for analysis? \n Enter 0 for Mac or 1 for Windows \n');

switch ifMac
    case 0
        patientFolder= '/Users/YKK/Google Drive/Deep_learning/Deep Learning/Results/excel';
        pathCompSep = '/';
        
    case 1
        patientFolder= 'C:\Users\ykuk0\Documents\Deep_learning\Deep Learning';
        pathCompSep = '\';
end
addpath([pwd,pathCompSep,'btk']);
PatientList = readtable([patientFolder, pathCompSep,'Documents',pathCompSep,'PatientList.xlsx'],'Sheet','Final','Range','A:D');
c3dList = dir([patientFolder,pathCompSep,'Data',pathCompSep,'Data_c3d',pathCompSep,'*.c3d']);
for i=1: length(c3dList)
    
    btkData=btkReadAcquisition([c3dList(i).folder,pathCompSep,(c3dList(i).name)]);
    try
        % Finds the corresponding patient's information.
        indx_find   = find(ismember(PatientList.PatientNumber, c3dList(i).name(1:6)));
        
        if (c3dList(i).name(1:6)) == (PatientList.PatientNumber{indx_find})
            % Extracts the data from c3d
            ff=btkGetFirstFrame(btkData);
            Markers = btkGetMarkers(btkData);
            f=btkGetPointFrequency(btkData);
            n = btkGetPointFrameNumber(btkData);
            [events,eventsinfo]=btkGetEvents(btkData);
            n1=n+ff-1;
            % Events have different format of name
            if string(PatientList.ID{indx_find}) == 'v6931a' || string(PatientList.ID{indx_find}) == 'v6425c' || string(PatientList.ID{indx_find}) == 'v6939a' ||...
                    string(PatientList.ID{indx_find}) == 'v5480c' || string(PatientList.ID{indx_find}) == 'v6943a' || string(PatientList.ID{indx_find}) == 'v5882f' ||...
                    string(PatientList.ID{indx_find}) == 'v6942'
                
                temp_left_FS  = append(string(PatientList.ID{indx_find}),'_Left_Foot_Strike');
                temp_right_FS = append(string(PatientList.ID{indx_find}),'_Right_Foot_Strike');
                temp_left_FO  = append(string(PatientList.ID{indx_find}),'_Left_Foot_Off');
                temp_right_FO = append(string(PatientList.ID{indx_find}),'_Right_Foot_Off');
                events.Left_Foot_Strike  = events.(temp_left_FS);
                events.Left_Foot_Off     = events.(temp_left_FO);
                events.Right_Foot_Strike = events.(temp_right_FS);
                events.Right_Foot_Off    = events.(temp_left_FO);
            end
            
            events.Left_Foot_Strike  = ((events.Left_Foot_Strike)*f);
            events.Left_Foot_Off     = ((events.Left_Foot_Off)*f);
            events.Right_Foot_Strike = ((events.Right_Foot_Strike)*f);
            events.Right_Foot_Off    = ((events.Right_Foot_Off)*f);
            events.left_class        = PatientList.L(indx_find);
            events.right_class       = PatientList.R(indx_find);
            
            a1=round(events.Left_Foot_Strike);
            b1=round(events.Left_Foot_Off);
            c1=round(events.Right_Foot_Strike);
            d1=round(events.Right_Foot_Off);
            
            e1=[a1 b1 c1 d1];
            min1=min(e1);
            min1=min1-10;
            if(min1<1)
                min1=1;
            end
            max1=max(e1);
            max1=max1+10;
            
            if(n1-1<max1)
                max1=n1-1;
            end
            
            %% Correct walking direction
            sacralMarkerName={'SACR'};
            SACR = Markers.SACR;
            % delete zeros at the beginning or end of an trial
            dir_i = abs(SACR(end, 1) - SACR(1, 1));
            dir_j = abs(SACR(end, 2) - SACR(1, 2));
            walkdir = 1;  % x is walkdir
            if (dir_i < dir_j)
                walkdir = 2;  % y is walkdir
            end
            % pos. or neg. direktion on axis
            sgn = sign(SACR(end, walkdir) - SACR(1, walkdir));
            walkdir = walkdir * sgn;
            [Markers_Corrected]=f_rotCoordinateSystem(Markers, walkdir, 1);
            gaitAxis=1;
            verticalAxis=3;
            [B,A] = butter(4,6/(f/2),'low');% low pass
            [B2,A2] = butter(4,(7/(f/2)));
            
            [z,p,k] = butter(4,0.5/(f/2),'high');
            [sos,g] = zp2sos(z,p,k);
            
            %% Marker extraction
            ltoe=filtfilt(B2, A2, Markers_Corrected.LTOE);
            high_ltoe= filtfilt(sos,g,ltoe);
            high_ltoe_x(ff:n1)=high_ltoe(1:end,1);
            low_ltoe=filtfilt(B, A, Markers_Corrected.LTOE);
            ltoe_y(ff:n1)=low_ltoe(1:end,2);
            ltoe_x(ff:n1)=low_ltoe(1:end,1);
            ltoe_z(ff:n1)=low_ltoe(1:end,3);
            v_ltoe_sagittal=[];
            v_ltoe_horizontal=[];
            v_ltoe_vertical=[];
            for t = 1:n-1
                v_ltoe_sagittal(t,1) = sqrt((low_ltoe(t+1,gaitAxis)- low_ltoe(t,gaitAxis))^2+(low_ltoe(t+1,verticalAxis)- low_ltoe(t,verticalAxis))^2)/(1/f);
                v_ltoe_horizontal(t,1)=(low_ltoe(t+1,gaitAxis)-low_ltoe(t,gaitAxis))/(1/f);
                v_ltoe_vertical(t,1)=(low_ltoe(t+1,verticalAxis)-low_ltoe(t,verticalAxis))/(1/f);
            end
            v_ltoe_sagittal2(ff:n1-1)=v_ltoe_sagittal(1:end);
            v_ltoe_horizontal2(ff:n1-1)=v_ltoe_horizontal(1:end);
            v_ltoe_vertical2(ff:n1-1)=v_ltoe_vertical(1:end);
            
            rtoe=filtfilt(B2, A2, Markers_Corrected.RTOE);
            high_rtoe= filtfilt(sos,g,rtoe);
            high_rtoe_x(ff:n1)=high_rtoe(1:end,1);
            low_rtoe=filtfilt(B, A, Markers_Corrected.RTOE);
            rtoe_y(ff:n1)=low_rtoe(1:end,2);
            rtoe_x(ff:n1)=low_rtoe(1:end,1);
            rtoe_z(ff:n1)=low_rtoe(1:end,3);
            v_rtoe_sagittal=[];
            v_rtoe_horizontal=[];
            v_rtoe_vertical=[];
            for t = 1:n-1
                v_rtoe_sagittal(t,1) = sqrt((low_rtoe(t+1,gaitAxis)- low_rtoe(t,gaitAxis))^2+(low_rtoe(t+1,verticalAxis)- low_rtoe(t,verticalAxis))^2)/(1/f);
                v_rtoe_horizontal(t,1)=(low_rtoe(t+1,gaitAxis)-low_rtoe(t,gaitAxis))/(1/f);
                v_rtoe_vertical(t,1)=(low_rtoe(t+1,verticalAxis)-low_rtoe(t,verticalAxis))/(1/f);
            end
            v_rtoe_sagittal2(ff:n1-1)=v_rtoe_sagittal(1:end);
            v_rtoe_horizontal2(ff:n1-1)=v_rtoe_horizontal(1:end);
            v_rtoe_vertical2(ff:n1-1)=v_rtoe_vertical(1:end);
            
            lhee=filtfilt(B2, A2, Markers_Corrected.LHEE);
            high_lhee= filtfilt(sos,g,lhee);
            high_lhee_x(ff:n1)=high_lhee(1:end,1);
            low_lhee=filtfilt(B, A, Markers_Corrected.LHEE);
            lhee_y(ff:n1)=low_lhee(1:end,2);
            lhee_x(ff:n1)=low_lhee(1:end,1);
            lhee_z(ff:n1)=low_lhee(1:end,3);
            v_lhee_sagittal=[];
            v_lhee_horizontal=[];
            v_lhee_vertical=[];
            for t = 1:n-1
                v_lhee_sagittal(t,1) = sqrt((low_lhee(t+1,gaitAxis)- low_lhee(t,gaitAxis))^2+(low_lhee(t+1,verticalAxis)- low_lhee(t,verticalAxis))^2)/(1/f);
                v_lhee_horizontal(t,1)=(low_lhee(t+1,gaitAxis)-low_lhee(t,gaitAxis))/(1/f);
                v_lhee_vertical(t,1)=(low_lhee(t+1,verticalAxis)-low_lhee(t,verticalAxis))/(1/f);
            end
            v_lhee_sagittal2(ff:n1-1)=v_lhee_sagittal(1:end);
            v_lhee_horizontal2(ff:n1-1)=v_lhee_horizontal(1:end);
            v_lhee_vertical2(ff:n1-1)=v_lhee_vertical(1:end);
            
            rhee=filtfilt(B2, A2, Markers_Corrected.RHEE);
            high_rhee= filtfilt(sos,g,rhee);
            high_rhee_x(ff:n1)=high_rhee(1:end,1);
            low_rhee=filtfilt(B, A, Markers_Corrected.RHEE);
            rhee_y(ff:n1)=low_rhee(1:end,2);
            rhee_x(ff:n1)=low_rhee(1:end,1);
            rhee_z(ff:n1)=low_rhee(1:end,3);
            v_rhee_sagittal=[];
            v_rhee_horizontal=[];
            v_rhee_vertical=[];
            for t = 1:n-1
                v_rhee_sagittal(t,1) = sqrt((low_rhee(t+1,gaitAxis)- low_rhee(t,gaitAxis))^2+(low_rhee(t+1,verticalAxis)- low_rhee(t,verticalAxis))^2)/(1/f);
                v_rhee_horizontal(t,1)=(low_rhee(t+1,gaitAxis)-low_rhee(t,gaitAxis))/(1/f);
                v_rhee_vertical(t,1)=(low_rhee(t+1,verticalAxis)-low_rhee(t,verticalAxis))/(1/f);
            end
            v_rhee_sagittal2(ff:n1-1)=v_rhee_sagittal(1:end);
            v_rhee_horizontal2(ff:n1-1)=v_rhee_horizontal(1:end);
            v_rhee_vertical2(ff:n1-1)=v_rhee_vertical(1:end);
            
            lpmt5=filtfilt(B2, A2, Markers_Corrected.LPMT5);
            high_lpmt5= filtfilt(sos,g,lpmt5);
            high_lpmt5_x(ff:n1)=high_lpmt5(1:end,1);
            low_lpmt5=filtfilt(B, A, Markers_Corrected.LPMT5);
            lpmt5_y(ff:n1)=low_lpmt5(1:end,2);
            lpmt5_x(ff:n1)=low_lpmt5(1:end,1);
            lpmt5_z(ff:n1)=low_lpmt5(1:end,3);
            v_lpmt5_sagittal=[];
            v_lpmt5_horizontal=[];
            v_lpmt5_vertical=[];
            for t = 1:n-1
                v_lpmt5_sagittal(t,1) = sqrt((low_lpmt5(t+1,gaitAxis)- low_lpmt5(t,gaitAxis))^2+(low_lpmt5(t+1,verticalAxis)- low_lpmt5(t,verticalAxis))^2)/(1/f);
                v_lpmt5_horizontal(t,1)=(low_lpmt5(t+1,gaitAxis)-low_lpmt5(t,gaitAxis))/(1/f);
                v_lpmt5_vertical(t,1)=(low_lpmt5(t+1,verticalAxis)-low_lpmt5(t,verticalAxis))/(1/f);
            end
            v_lpmt5_sagittal2(ff:n1-1)=v_lpmt5_sagittal(1:end);
            v_lpmt5_horizontal2(ff:n1-1)=v_lpmt5_horizontal(1:end);
            v_lpmt5_vertical2(ff:n1-1)=v_lpmt5_vertical(1:end);
            
            rpmt5=filtfilt(B2, A2, Markers_Corrected.RPMT5);
            high_rpmt5= filtfilt(sos,g,rpmt5);
            high_rpmt5_x(ff:n1)=high_rpmt5(1:end,1);
            low_rpmt5=filtfilt(B, A, Markers_Corrected.RPMT5);
            rpmt5_y(ff:n1)=low_rpmt5(1:end,2);
            rpmt5_x(ff:n1)=low_rpmt5(1:end,1);
            rpmt5_z(ff:n1)=low_rpmt5(1:end,3);
            v_rpmt5_sagittal=[];
            v_rpmt5_horizontal=[];
            v_rpmt5_vertical=[];
            
            for t = 1:n-1
                v_rpmt5_sagittal(t,1) = sqrt((low_rpmt5(t+1,gaitAxis)- low_rpmt5(t,gaitAxis))^2+(low_rpmt5(t+1,verticalAxis)- low_rpmt5(t,verticalAxis))^2)/(1/f);
                v_rpmt5_horizontal(t,1)=(low_rpmt5(t+1,gaitAxis)-low_rpmt5(t,gaitAxis))/(1/f);
                v_rpmt5_vertical(t,1)=(low_rpmt5(t+1,verticalAxis)-low_rpmt5(t,verticalAxis))/(1/f);
            end
            v_rpmt5_sagittal2(ff:n1-1)=v_rpmt5_sagittal(1:end);
            v_rpmt5_horizontal2(ff:n1-1)=v_rpmt5_horizontal(1:end);
            v_rpmt5_vertical2(ff:n1-1)=v_rpmt5_vertical(1:end);
            
            lhlx=filtfilt(B2, A2, Markers_Corrected.LHLX);
            high_lhlx= filtfilt(sos,g,lhlx);
            high_lhlx_x(ff:n1)=high_lhlx(1:end,1);
            low_lhlx=filtfilt(B, A, Markers_Corrected.LHLX);
            lhlx_y(ff:n1)=low_lhlx(1:end,2);
            lhlx_x(ff:n1)=low_lhlx(1:end,1);
            lhlx_z(ff:n1)=low_lhlx(1:end,3);
            v_lhlx_sagittal=[];
            v_lhlx_horizontal=[];
            v_lhlx_vertical=[];
            for t = 1:n-1
                v_lhlx_sagittal(t,1) = sqrt((low_lhlx(t+1,gaitAxis)- low_lhlx(t,gaitAxis))^2+(low_lhlx(t+1,verticalAxis)- low_lhlx(t,verticalAxis))^2)/(1/f);
                v_lhlx_horizontal(t,1)=(low_lhlx(t+1,gaitAxis)-low_lhlx(t,gaitAxis))/(1/f);
                v_lhlx_vertical(t,1)=(low_lhlx(t+1,verticalAxis)-low_lhlx(t,verticalAxis))/(1/f);
            end
            v_lhlx_sagittal2(ff:n1-1)=v_lhlx_sagittal(1:end);
            v_lhlx_horizontal2(ff:n1-1)=v_lhlx_horizontal(1:end);
            v_lhlx_vertical2(ff:n1-1)=v_lhlx_vertical(1:end);
            
            rhlx=filtfilt(B2, A2, Markers_Corrected.RHLX);
            high_rhlx= filtfilt(sos,g,rhlx);
            high_rhlx_x(ff:n1)=high_rhlx(1:end,1);
            low_rhlx=filtfilt(B, A, Markers_Corrected.RHLX);
            rhlx_y(ff:n1)=low_rhlx(1:end,2);
            rhlx_x(ff:n1)=low_rhlx(1:end,1);
            rhlx_z(ff:n1)=low_rhlx(1:end,3);
            v_rhlx_sagittal=[];
            v_rhlx_horizontal=[];
            v_rhlx_vertical=[];
            for t = 1:n-1
                v_rhlx_sagittal(t,1) = sqrt((low_rhlx(t+1,gaitAxis)- low_rhlx(t,gaitAxis))^2+(low_rhlx(t+1,verticalAxis)- low_rhlx(t,verticalAxis))^2)/(1/f);
                v_rhlx_horizontal(t,1)=(low_rhlx(t+1,gaitAxis)-low_rhlx(t,gaitAxis))/(1/f);
                v_rhlx_vertical(t,1)=(low_rhlx(t+1,verticalAxis)-low_rhlx(t,verticalAxis))/(1/f);
            end
            v_rhlx_sagittal2(ff:n1-1)=v_rhlx_sagittal(1:end);
            v_rhlx_horizontal2(ff:n1-1)=v_rhlx_horizontal(1:end);
            v_rhlx_vertical2(ff:n1-1)=v_rhlx_vertical(1:end);
            
            max1=max1-1;
            d=min1:1:max1;
            d=d.';
            
            lhs=[];
            for g=1:n1
                lhs(g,1)=0;
            end
            for g2=1:n1
                for j=1:length(events.Left_Foot_Strike)
                    if round(events.Left_Foot_Strike(j))==g2
                        lhs(g2,1)=1;
                    end
                end
            end
            
            rhs=[];
            for g=1:n1
                rhs(g,1)=0;
            end
            for g2=1:n1
                for j=1:length(events.Right_Foot_Strike)
                    if round(events.Right_Foot_Strike(j))==g2
                        rhs(g2,1)=1;
                    end
                end
            end
            lto=[];
            for g=1:n1
                lto(g,1)=0;
            end
            for g2=1:n1
                for j=1:length(events.Left_Foot_Off)
                    if round(events.Left_Foot_Off(j))==g2
                        lto(g2,1)=1;
                    end
                end
            end
            rto=[];
            for g=1:n1
                rto(g,1)=0;
            end
            
            for g2=1:n1
                for j=1:length(events.Right_Foot_Off)
                    if round(events.Right_Foot_Off(j))==g2
                        rto(g2,1)=1;
                    end
                end
            end
            
            lhs2(ff:n1)= lhs(ff:n1);
            lhs3=lhs2.';
            
            rhs2(ff:n1)= rhs(ff:n1);
            rhs3=rhs2.';
            
            lto2(ff:n1)= lto(ff:n1);
            lto3=lto2.';
            
            rto2(ff:n1)= rto(ff:n1);
            rto3=rto2.';
            
            events.left_class        = repelem(PatientList.L(indx_find),length(d))';
            events.right_class       = repelem(PatientList.R(indx_find),length(d))';
            
            left=cat(2,d,events.left_class,...
                ltoe_x(min1:max1).',ltoe_y(min1:max1).',ltoe_z(min1:max1).',...
                v_ltoe_horizontal2(min1:max1).',v_ltoe_sagittal2(min1:max1).',v_ltoe_vertical2(min1:max1).',...
                lhlx_x(min1:max1).',lhlx_y(min1:max1).',lhlx_z(min1:max1).',...
                v_lhlx_horizontal2(min1:max1).',v_lhlx_sagittal2(min1:max1).',v_lhlx_vertical2(min1:max1).',...
                lhee_x(min1:max1).',lhee_y(min1:max1).',lhee_z(min1:max1).',...
                v_lhee_horizontal2(min1:max1).',v_lhee_sagittal2(min1:max1).',v_lhee_vertical2(min1:max1).',...
                lpmt5_x(min1:max1).',lpmt5_y(min1:max1).',lpmt5_z(min1:max1).',...
                v_lpmt5_horizontal2(min1:max1).',v_lpmt5_sagittal2(min1:max1).',v_lpmt5_vertical2(min1:max1).',...
                lhs3(min1:max1),lto3(min1:max1));
            
            right=cat(2,d,events.right_class,...
                rtoe_x(min1:max1).',rtoe_y(min1:max1).',rtoe_z(min1:max1).',...
                v_rtoe_horizontal2(min1:max1).',v_rtoe_sagittal2(min1:max1).',v_rtoe_vertical2(min1:max1).',...
                rhlx_x(min1:max1).',rhlx_y(min1:max1).',rhlx_z(min1:max1).',...
                v_rhlx_horizontal2(min1:max1).',v_rhlx_sagittal2(min1:max1).',v_rhlx_vertical2(min1:max1).',...
                rhee_x(min1:max1).',rhee_y(min1:max1).',rhee_z(min1:max1).',...
                v_rhee_horizontal2(min1:max1).',v_rhee_sagittal2(min1:max1).',v_rhee_vertical2(min1:max1).',...
                rpmt5_x(min1:max1).',rpmt5_y(min1:max1).',rpmt5_z(min1:max1).',...
                v_rpmt5_horizontal2(min1:max1).',v_rpmt5_sagittal2(min1:max1).',v_rpmt5_vertical2(min1:max1).',...
                rhs3(min1:max1),rto3(min1:max1));
            
            leftable = array2table(left,'VariableNames',{'ID','class'...
                'LTOE_X','LTOE_Y','LTOE_Z','V_LTOE_X','V_LTOE_Y','V_LTOE_Z',...
                'LHLX_X','LHLX_Y','LHLX_Z','V_LHLX_X','V_LHLX_Y','V_LHLX_Z',...
                'LHEE_X','LHEE_Y','LHEE_Z','V_LHEE_X','V_LHEE_Y','V_LHEE_Z',...
                'LPMT5_X','LPMT5_Y','LPMT5_Z','V_LPMT5_X','V_LPMT5_Y','V_LPMT5_Z'...
                'FS','FO'});
            
            rightable = array2table(right,'VariableNames',{'ID','class'...
                'RTOE_X','RTOE_Y','RTOE_Z','V_RTOE_X','V_RTOE_Y','V_RTOE_Z',...
                'RHLX_X','RHLX_Y','RHLX_Z','V_RHLX_X','V_RHLX_Y','V_RHLX_Z',...
                'RHEE_X','RHEE_Y','RHEE_Z','V_RHEE_X','V_RHEE_Y','V_RHEE_Z',...
                'RPMT5_X','RPMT5_Y','RPMT5_Z','V_RPMT5_X','V_RPMT5_Y','V_RPMT5_Z',...
                'FS','FO'});
            
            namefile=c3dList(i).name(1:9);
            if (rightable.class(1) == 1) && (leftable.class(1) == 1)
                ExportFoldr = [patientFolder,pathCompSep,'Data', pathCompSep,'iteration4',pathCompSep,'Heel'];
            elseif (rightable.class(1) == 2) && (leftable.class(1) == 2)
                ExportFoldr = [patientFolder,pathCompSep,'Data', pathCompSep,'iteration4',pathCompSep,'Midfoot'];
            elseif (rightable.class(1) == 3) && (leftable.class(1) == 3)
                ExportFoldr = [patientFolder,pathCompSep,'Data', pathCompSep,'iteration4',pathCompSep,'Forefoot'];
            else
                ExportFoldr = [patientFolder,pathCompSep,'Data', pathCompSep,'iteration4',pathCompSep,'Others'];
            end
            if ~exist(ExportFoldr, 'dir')
                mkdir(ExportFoldr)
            end
            
            writetable(leftable, [ExportFoldr,pathCompSep,'LT_',namefile,'.csv']);
            writetable(rightable,[ExportFoldr,pathCompSep,'RT_',namefile,'.csv']);
        end
    catch
        fprintf('%s does not exist\n',(c3dList(i).name))
    end
end