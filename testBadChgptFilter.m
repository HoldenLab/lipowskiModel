load('xt_chgptFilterNotWorkingExample.mat');
frameInterval=6;
zeroSpeedThresh = 5;
switchTooCloseThresh = 4;
 [simResult, chgpt, tFr,xFr] = analyseSimDynamics(t,x,frameInterval,zeroSpeedThresh, switchTooCloseThresh);
