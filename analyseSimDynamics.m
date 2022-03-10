function [simResult, chgpt, tFr,xFr] = analyseSimDynamics(t,x,frameInterval,zeroSpeedThresh, switchTooCloseThresh, runID)
% function [simResult, chgpt, tFr,xFr] = analyseSimDynamics(t,x,frameInterval,zeroSpeedThresh, switchTooCloseThresh)
%INPUTS
% frame interval: units: t (typically s): exposure time for a single image frame in comparable experimental system. For MreB dynamics, we usually use 6 s
% zeroSpeedThresh - units: x/t (typically nm/s): speed below which speed cannot be accurately differentiated from stationary molecule
% switchTooCloseThresh - units: frames, number of frames below which a switching event is too close to be detected in the comparable experimental analysis. Typically 4 frames based on things like MSD analysis

if ~exist('runID','var')
    runID=1;
end

frameInterval=frameInterval;
vThresh=zeroSpeedThresh;
frameThresh = switchTooCloseThresh;

tFr = 0:frameInterval:max(t);
xFr = interp1(t,x,tFr);

dxFr= diff(xFr);
v=dxFr/frameInterval;

%filter out near zero speed
v2= v;
v2(abs(v2)<=vThresh)=0;

%loop through and find sign changes or pauses
%need to identify states(beginning and end)
%measure type of state (motile, paused), length of state, average speed, and next state
%(motile paused)
%exclude states that are too close to last one
vSign = v2;
vSign(vSign>0) =1;
vSign(vSign<0) =-1;

%plot(tFr(1:end-1),vSign);
chgpt=find(diff(vSign)~=0);
%add the first and last frames as states
chgpt=[1,chgpt,numel(tFr)-1];
hold all;
tChgPt=tFr(chgpt);
%plot(tChgPt,vSign(chgpt),'x')
%Filter out short trajectories
frameThresh=4;
chgptFilt=chgpt;
ii = 2;
while ii <= numel(chgptFilt)
    %try
    
    if ii > 1 & (chgptFilt(ii)-chgptFilt(ii-1))<frameThresh
        if chgptFilt(ii)+1>numel(vSign) %if last change point out of bounds
            %delete last chgptFilt
            chgptFilt(ii)=[];
        elseif vSign(chgptFilt(ii-1))==vSign(chgptFilt(ii)+1)%previous state same as current state
            %delete both chgptFilt
            chgptFilt(ii-1:ii)=[];
            ii=ii-1;
        else
            %dlete only previous chgptFilt
            chgptFilt(ii-1)=[];
        end
    else
        ii=ii+1;
    end
%     catch ME
%         keyboard
%     end
end
tChgPtFilt=tFr(chgptFilt);
%plot(tChgPtFilt,vSign(chgptFilt),'o')

%record states in output table
simResult = table;
nState = numel(chgptFilt)-2;%have to discard the last state as dont know what it transitioned to
simResult.runID = ones(nState,1)*runID;
%loop through and measure state properties
for ii=1:nState
    startIdx = chgptFilt(ii);
    endIdx  = chgptFilt(ii+1);
    nextStateIdx=chgptFilt(ii+2);
    simResult.duration(ii)= tFr(endIdx)-tFr(startIdx);
    simResult.processivity(ii)=abs(xFr(endIdx)-xFr(startIdx));
    simResult.speed(ii)=simResult.processivity(ii)/simResult.duration(ii);
    simResult.isMotile(ii)=vSign(endIdx)~=0;
    simResult.isNextStateMotile(ii)=vSign(nextStateIdx)~=0;    
end

chgpt = chgptFilt;

