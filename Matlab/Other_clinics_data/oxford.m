clear; clc;
% patientFolder = 'C:\Users\ykuk0\Desktop\Data_c3d';
% ExportFolder  = 'C:\Users\ykuk0\Desktop\Data_csv';
patientFolder ='C:\Users\ykuk0\Desktop\C3Ds';
ExportFolder  ='C:\Users\ykuk0\Desktop\C3Ds\csv';
c3dList = dir([patientFolder,'\*.c3d']);
addpath('C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Codes\Matlab\');
addpath('C:\Users\ykuk0\Documents\Deep_learning\Deep Learning\Codes\Matlab\btk\');
cd(pwd)

for i= 2: length(c3dList)
    
    btkData=btkReadAcquisition([c3dList(i).folder,'\',(c3dList(i).name)]);
    
    ff=btkGetFirstFrame(btkData);
    Markers = btkGetMarkers(btkData);
    f=btkGetPointFrequency(btkData);
    n = btkGetPointFrameNumber(btkData);
    n1=n+ff-1;
    
    %% Correct walking direction 
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
    low_ltoe=filtfilt(B, A, Markers_Corrected.LTOE);
    ltoe_y=low_ltoe(:,2);
    ltoe_x=low_ltoe(:,1);
    ltoe_z=low_ltoe(:,3);
    v_ltoe_sagittal=[];
    v_ltoe_horizontal=[];
    v_ltoe_vertical=[];
    for t = 1:n-1
        v_ltoe_sagittal(t,1) = sqrt((low_ltoe(t+1,gaitAxis)- low_ltoe(t,gaitAxis))^2+(low_ltoe(t+1,verticalAxis)- low_ltoe(t,verticalAxis))^2)/(1/f);
        v_ltoe_horizontal(t,1)=(low_ltoe(t+1,gaitAxis)-low_ltoe(t,gaitAxis))/(1/f);
        v_ltoe_vertical(t,1)=(low_ltoe(t+1,verticalAxis)-low_ltoe(t,verticalAxis))/(1/f);
    end
    v_ltoe_sagittal2=v_ltoe_sagittal(:);
    v_ltoe_horizontal2=v_ltoe_horizontal(:);
    v_ltoe_vertical2=v_ltoe_vertical(:);
    
    rtoe=filtfilt(B2, A2, Markers_Corrected.RTOE);
    low_rtoe=filtfilt(B, A, Markers_Corrected.RTOE);
    rtoe_y=low_rtoe(:,2);
    rtoe_x=low_rtoe(:,1);
    rtoe_z=low_rtoe(:,3);
    v_rtoe_sagittal=[];
    v_rtoe_horizontal=[];
    v_rtoe_vertical=[];
    for t = 1:n-1
        v_rtoe_sagittal(t,1) = sqrt((low_rtoe(t+1,gaitAxis)- low_rtoe(t,gaitAxis))^2+(low_rtoe(t+1,verticalAxis)- low_rtoe(t,verticalAxis))^2)/(1/f);
        v_rtoe_horizontal(t,1)=(low_rtoe(t+1,gaitAxis)-low_rtoe(t,gaitAxis))/(1/f);
        v_rtoe_vertical(t,1)=(low_rtoe(t+1,verticalAxis)-low_rtoe(t,verticalAxis))/(1/f);
    end
    v_rtoe_sagittal2=v_rtoe_sagittal(:);
    v_rtoe_horizontal2=v_rtoe_horizontal(:);
    v_rtoe_vertical2=v_rtoe_vertical(:);
    
    lhee=filtfilt(B2, A2, Markers_Corrected.LHEE);
    low_lhee=filtfilt(B, A, Markers_Corrected.LHEE);
    lhee_y=low_lhee(:,2);
    lhee_x=low_lhee(:,1);
    lhee_z=low_lhee(:,3);
    v_lhee_sagittal=[];
    v_lhee_horizontal=[];
    v_lhee_vertical=[];
    for t = 1:n-1
        v_lhee_sagittal(t,1) = sqrt((low_lhee(t+1,gaitAxis)- low_lhee(t,gaitAxis))^2+(low_lhee(t+1,verticalAxis)- low_lhee(t,verticalAxis))^2)/(1/f);
        v_lhee_horizontal(t,1)=(low_lhee(t+1,gaitAxis)-low_lhee(t,gaitAxis))/(1/f);
        v_lhee_vertical(t,1)=(low_lhee(t+1,verticalAxis)-low_lhee(t,verticalAxis))/(1/f);
    end
    v_lhee_sagittal2=v_lhee_sagittal(:);
    v_lhee_horizontal2=v_lhee_horizontal(:);
    v_lhee_vertical2=v_lhee_vertical(:);
    
    rhee=filtfilt(B2, A2, Markers_Corrected.RHEE);
    low_rhee=filtfilt(B, A, Markers_Corrected.RHEE);
    rhee_y=low_rhee(:,2);
    rhee_x=low_rhee(:,1);
    rhee_z=low_rhee(:,3);
    v_rhee_sagittal=[];
    v_rhee_horizontal=[];
    v_rhee_vertical=[];
    for t = 1:n-1
        v_rhee_sagittal(t,1) = sqrt((low_rhee(t+1,gaitAxis)- low_rhee(t,gaitAxis))^2+(low_rhee(t+1,verticalAxis)- low_rhee(t,verticalAxis))^2)/(1/f);
        v_rhee_horizontal(t,1)=(low_rhee(t+1,gaitAxis)-low_rhee(t,gaitAxis))/(1/f);
        v_rhee_vertical(t,1)=(low_rhee(t+1,verticalAxis)-low_rhee(t,verticalAxis))/(1/f);
    end
    v_rhee_sagittal2=v_rhee_sagittal(:);
    v_rhee_horizontal2=v_rhee_horizontal(:);
    v_rhee_vertical2=v_rhee_vertical(:);
    
    LP5M=filtfilt(B2, A2, Markers_Corrected.LP5M);
    low_LP5M=filtfilt(B, A, Markers_Corrected.LP5M);
    LP5M_y=low_LP5M(:,2);
    LP5M_x=low_LP5M(:,1);
    LP5M_z=low_LP5M(:,3);
    v_LP5M_sagittal=[];
    v_LP5M_horizontal=[];
    v_LP5M_vertical=[];
    for t = 1:n-1
        v_LP5M_sagittal(t,1) = sqrt((low_LP5M(t+1,gaitAxis)- low_LP5M(t,gaitAxis))^2+(low_LP5M(t+1,verticalAxis)- low_LP5M(t,verticalAxis))^2)/(1/f);
        v_LP5M_horizontal(t,1)=(low_LP5M(t+1,gaitAxis)-low_LP5M(t,gaitAxis))/(1/f);
        v_LP5M_vertical(t,1)=(low_LP5M(t+1,verticalAxis)-low_LP5M(t,verticalAxis))/(1/f);
    end
    v_LP5M_sagittal2=v_LP5M_sagittal(:);
    v_LP5M_horizontal2=v_LP5M_horizontal(:);
    v_LP5M_vertical2=v_LP5M_vertical(:);
    
    RP5M=filtfilt(B2, A2, Markers_Corrected.RP5M);
    low_RP5M=filtfilt(B, A, Markers_Corrected.RP5M);
    RP5M_y=low_RP5M(:,2);
    RP5M_x=low_RP5M(:,1);
    RP5M_z=low_RP5M(:,3);
    v_RP5M_sagittal=[];
    v_RP5M_horizontal=[];
    v_RP5M_vertical=[];
    for t = 1:n-1
        v_RP5M_sagittal(t,1) = sqrt((low_RP5M(t+1,gaitAxis)- low_RP5M(t,gaitAxis))^2+(low_RP5M(t+1,verticalAxis)- low_RP5M(t,verticalAxis))^2)/(1/f);
        v_RP5M_horizontal(t,1)=(low_RP5M(t+1,gaitAxis)-low_RP5M(t,gaitAxis))/(1/f);
        v_RP5M_vertical(t,1)=(low_RP5M(t+1,verticalAxis)-low_RP5M(t,verticalAxis))/(1/f);
    end
    v_RP5M_sagittal2=v_RP5M_sagittal(:);
    v_RP5M_horizontal2=v_RP5M_horizontal(:);
    v_RP5M_vertical2=v_RP5M_vertical(:);
    
    lhlx=filtfilt(B2, A2, Markers_Corrected.LHLX);
    low_lhlx=filtfilt(B, A, Markers_Corrected.LHLX);
    lhlx_y=low_lhlx(:,2);
    lhlx_x=low_lhlx(:,1);
    lhlx_z=low_lhlx(:,3);
    v_lhlx_sagittal=[];
    v_lhlx_horizontal=[];
    v_lhlx_vertical=[];
    for t = 1:n-1
        v_lhlx_sagittal(t,1) = sqrt((low_lhlx(t+1,gaitAxis)- low_lhlx(t,gaitAxis))^2+(low_lhlx(t+1,verticalAxis)- low_lhlx(t,verticalAxis))^2)/(1/f);
        v_lhlx_horizontal(t,1)=(low_lhlx(t+1,gaitAxis)-low_lhlx(t,gaitAxis))/(1/f);
        v_lhlx_vertical(t,1)=(low_lhlx(t+1,verticalAxis)-low_lhlx(t,verticalAxis))/(1/f);
    end
    v_lhlx_sagittal2=v_lhlx_sagittal(:);
    v_lhlx_horizontal2=v_lhlx_horizontal(:);
    v_lhlx_vertical2=v_lhlx_vertical(:);
    
    rhlx=filtfilt(B2, A2, Markers_Corrected.RHLX);
    low_rhlx=filtfilt(B, A, Markers_Corrected.RHLX);
    rhlx_y=low_rhlx(:,2);
    rhlx_x=low_rhlx(:,1);
    rhlx_z=low_rhlx(:,3);
    v_rhlx_sagittal=[];
    v_rhlx_horizontal=[];
    v_rhlx_vertical=[];
    for t = 1:n-1
        v_rhlx_sagittal(t,1) = sqrt((low_rhlx(t+1,gaitAxis)- low_rhlx(t,gaitAxis))^2+(low_rhlx(t+1,verticalAxis)- low_rhlx(t,verticalAxis))^2)/(1/f);
        v_rhlx_horizontal(t,1)=(low_rhlx(t+1,gaitAxis)-low_rhlx(t,gaitAxis))/(1/f);
        v_rhlx_vertical(t,1)=(low_rhlx(t+1,verticalAxis)-low_rhlx(t,verticalAxis))/(1/f);
    end
    v_rhlx_sagittal2=v_rhlx_sagittal(:);
    v_rhlx_horizontal2=v_rhlx_horizontal(:);
    v_rhlx_vertical2=v_rhlx_vertical(:);
    d = (ff:1:n1-1)';
    
    left=cat(2,d,...
        ltoe_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),ltoe_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),ltoe_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_ltoe_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_ltoe_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_ltoe_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        lhlx_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhlx_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhlx_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_lhlx_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhlx_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhlx_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        lhee_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhee_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhee_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_lhee_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhee_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhee_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        LP5M_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),LP5M_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),LP5M_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_LP5M_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_LP5M_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_LP5M_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rtoe_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rtoe_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rtoe_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rtoe_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rtoe_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rtoe_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rhlx_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhlx_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhlx_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rhlx_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhlx_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhlx_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rhee_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhee_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhee_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rhee_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhee_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhee_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        RP5M_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),RP5M_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),RP5M_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_RP5M_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_RP5M_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_RP5M_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))));
    
    right=cat(2,d,...
        ltoe_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),ltoe_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),ltoe_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_ltoe_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_ltoe_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_ltoe_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        lhlx_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhlx_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhlx_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_lhlx_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhlx_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhlx_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        lhee_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhee_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),lhee_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_lhee_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhee_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_lhee_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        LP5M_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),LP5M_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),LP5M_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_LP5M_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_LP5M_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_LP5M_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rtoe_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rtoe_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rtoe_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rtoe_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rtoe_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rtoe_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rhlx_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhlx_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhlx_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rhlx_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhlx_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhlx_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        rhee_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhee_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),rhee_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_rhee_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhee_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_rhee_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        RP5M_x(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),RP5M_y(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),RP5M_z(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),...
        v_RP5M_horizontal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_RP5M_sagittal2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))),v_RP5M_vertical2(1:min(length(ltoe_x),length(v_ltoe_horizontal2))));
    
    leftable = array2table(left,'VariableNames',{'Frame',...
        'LTOE_X','LTOE_Y','LTOE_Z','V_LTOE_X','V_LTOE_Y','V_LTOE_Z',...
        'LHLX_X','LHLX_Y','LHLX_Z','V_LHLX_X','V_LHLX_Y','V_LHLX_Z',...
        'LHEE_X','LHEE_Y','LHEE_Z','V_LHEE_X','V_LHEE_Y','V_LHEE_Z',...
        'LP5M_X','LP5M_Y','LP5M_Z','V_LP5M_X','V_LP5M_Y','V_LP5M_Z'...
        'RTOE_X','RTOE_Y','RTOE_Z','V_RTOE_X','V_RTOE_Y','V_RTOE_Z',...
        'RHLX_X','RHLX_Y','RHLX_Z','V_RHLX_X','V_RHLX_Y','V_RHLX_Z',...
        'RHEE_X','RHEE_Y','RHEE_Z','V_RHEE_X','V_RHEE_Y','V_RHEE_Z',...
        'RP5M_X','RP5M_Y','RP5M_Z','V_RP5M_X','V_RP5M_Y','V_RP5M_Z'});
    
    rightable = array2table(right,'VariableNames',{'Frame',...
        'LTOE_X','LTOE_Y','LTOE_Z','V_LTOE_X','V_LTOE_Y','V_LTOE_Z',...
        'LHLX_X','LHLX_Y','LHLX_Z','V_LHLX_X','V_LHLX_Y','V_LHLX_Z',...
        'LHEE_X','LHEE_Y','LHEE_Z','V_LHEE_X','V_LHEE_Y','V_LHEE_Z',...
        'LP5M_X','LP5M_Y','LP5M_Z','V_LP5M_X','V_LP5M_Y','V_LP5M_Z'...
        'RTOE_X','RTOE_Y','RTOE_Z','V_RTOE_X','V_RTOE_Y','V_RTOE_Z',...
        'RHLX_X','RHLX_Y','RHLX_Z','V_RHLX_X','V_RHLX_Y','V_RHLX_Z',...
        'RHEE_X','RHEE_Y','RHEE_Z','V_RHEE_X','V_RHEE_Y','V_RHEE_Z',...
        'RP5M_X','RP5M_Y','RP5M_Z','V_RP5M_X','V_RP5M_Y','V_RP5M_Z'});
    
    namefile=c3dList(i).name(1:8);
    writetable(leftable, [ExportFolder,'\','LT_',namefile,'.csv']);
    writetable(rightable,[ExportFolder,'\','RT_',namefile,'.csv']);
end