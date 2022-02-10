%% Figure_GaitEvenHSetection_Yong
% load("Saliency_yong.mat")

%% plot outcomes saliency for IC per group for TOEPMT5HEE marker combi
% with edit figure proterties adapt bar width velocity from 0.8 to 0.4
% for TO data is in diMFerent sub-structs IC.FF/IC.MF/IC.HS
% for IC data is in IC.FF in diMFerent rows, row 1 is toe-walker, row 2
% flat foot, row 3 heel strike groups

% tiledlayout('flow');

tiledlayout(5,3);
%% TO
% HLXHEE

% figure;
nexttile
bar(TO.FF.HLXHEE.position(1,:))
hold on
bar(TO.FF.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-FF-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf','landscape');
% flat foot
% figure
nexttile
bar(TO.MF.HLXHEE.position(1,:))
hold on
bar(TO.MF.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-MF-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf');
% heel strike
% figure
nexttile
bar(TO.HS.HLXHEE.position(1,:))
hold on
bar(TO.HS.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-HS-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf');

% TOEHEE
% figure;
nexttile
bar(TO.FF.TOEHEE.position(1,:))
hold on
bar(TO.FF.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-FF-TOEHEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(TO.MF.TOEHEE.position(1,:))
hold on
bar(TO.MF.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-MF-TOEHEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(TO.HS.TOEHEE.position(1,:))
hold on
bar(TO.HS.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-HS-TOEHEE"];
title(name);
% print(name,'-dpdf');

% HLXPMT5HEE
% figure;
nexttile
bar(TO.FF.HLXPMT5HEE.position(1,:))
hold on
bar(TO.FF.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-FF-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(TO.MF.HLXPMT5HEE.position(1,:))
hold on
bar(TO.MF.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-MF-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(TO.HS.HLXPMT5HEE.position(1,:))
hold on
bar(TO.HS.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-HS-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');

% TOEPMT5HEE
% figure;
nexttile
bar(TO.FF.TOEPMT5HEE.position(1,:))
hold on
bar(TO.FF.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-FF-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(TO.MF.TOEPMT5HEE.position(1,:))
hold on
bar(TO.MF.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-MF-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(TO.HS.TOEPMT5HEE.position(1,:))
hold on
bar(TO.HS.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-HS-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');

% HLXTOEHEE
% figure;
nexttile
bar(TO.FF.HLXTOEHEE.position(1,:))
hold on
bar(TO.FF.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-FF-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(TO.MF.HLXTOEHEE.position(1,:))
hold on
bar(TO.MF.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-MF-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(TO.HS.HLXTOEHEE.position(1,:))
hold on
bar(TO.HS.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["TO-HS-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
orient('landscape');
print('TO-ALL','-bestfit','-dpdf');

close;

tiledlayout(5,3);

%% IC
% HLXHEE

% figure;
nexttile
bar(IC.FF.HLXHEE.position(1,:))
hold on
bar(IC.FF.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-FF-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf','landscape');
% flat foot
% figure
nexttile
bar(IC.MF.HLXHEE.position(1,:))
hold on
bar(IC.MF.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-MF-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf');
% heel strike
% figure
nexttile
bar(IC.HS.HLXHEE.position(1,:))
hold on
bar(IC.HS.HLXHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-HS-HLXHEE"];
title(name);
% print(name,'-bestfit','-dpdf');

% TOEHEE
% figure;
nexttile
bar(IC.FF.TOEHEE.position(1,:))
hold on
bar(IC.FF.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-FF-TOEHEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(IC.MF.TOEHEE.position(1,:))
hold on
bar(IC.MF.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-MF-TOEHEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(IC.HS.TOEHEE.position(1,:))
hold on
bar(IC.HS.TOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-HS-TOEHEE"];
title(name);
% print(name,'-dpdf');

% HLXPMT5HEE
% figure;
nexttile
bar(IC.FF.HLXPMT5HEE.position(1,:))
hold on
bar(IC.FF.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-FF-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(IC.MF.HLXPMT5HEE.position(1,:))
hold on
bar(IC.MF.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-MF-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(IC.HS.HLXPMT5HEE.position(1,:))
hold on
bar(IC.HS.HLXPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-HS-HLXPMT5HEE"];
title(name);
% print(name,'-dpdf');

% TOEPMT5HEE
% figure;
nexttile
bar(IC.FF.TOEPMT5HEE.position(1,:))
hold on
bar(IC.FF.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-FF-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(IC.MF.TOEPMT5HEE.position(1,:))
hold on
bar(IC.MF.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-MF-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(IC.HS.TOEPMT5HEE.position(1,:))
hold on
bar(IC.HS.TOEPMT5HEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-HS-TOEPMT5HEE"];
title(name);
% print(name,'-dpdf');

% HLXTOEHEE
% figure;
nexttile
bar(IC.FF.HLXTOEHEE.position(1,:))
hold on
bar(IC.FF.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-FF-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
% flat foot
% figure
nexttile
bar(IC.MF.HLXTOEHEE.position(1,:))
hold on
bar(IC.MF.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-MF-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
% heel strike
% figure
nexttile
bar(IC.HS.HLXTOEHEE.position(1,:))
hold on
bar(IC.HS.HLXTOEHEE.velocity(1,:),0.4);
ylim([0 1])
name = ["IC-HS-HLXTOEHEE"];
title(name);
% print(name,'-dpdf');
orient('landscape');
print('IC-ALL','-bestfit','-dpdf');

close;