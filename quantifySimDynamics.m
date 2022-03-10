function [processivity, speed, lifetime, rate, fractionMotile, simResult] = quantifySimDynamics(motorState, simPar,analysisPar,nSimRepeat)

frameInterval   = analysisPar.frameInterval;
zeroSpeedThresh = analysisPar.zeroSpeedThresh;
switchTooCloseThresh = analysisPar.switchTooCloseThresh;

simResult=table;
for ii=1:nSimRepeat
    [dynamics] = lipowskiWithUnbindingSim(motorState,simPar);
    t=dynamics.t;
    x=dynamics.x;
    runID=ii;
    [simResultCur] = analyseSimDynamics(t,x,frameInterval,zeroSpeedThresh, switchTooCloseThresh, runID);
try
    simResult=[simResult;simResultCur];
catch ME
    keyboard
end
end

%implement rate calculations as functions so can do bootstrap CIs
nBoot = 1000;
pause_processive_rateFcn= @(simResult) sum(simResult.isMotile==1 & simResult.isNextStateMotile==0)/ sum(simResult.duration(simResult.isMotile==1));
pause_processive_rate=pause_processive_rateFcn(simResult);
pause_processive_rate_ci = bootci(nBoot,pause_processive_rateFcn,simResult);
rate.pause_processive = [pause_processive_rate, pause_processive_rate_ci'];

reversal_processive_rateFcn= @(simResult) sum(simResult.isMotile==1 & simResult.isNextStateMotile==1)/ sum(simResult.duration(simResult.isMotile==1));
reversal_processive_rate=reversal_processive_rateFcn(simResult);
reversal_processive_rate_ci=bootci(nBoot,reversal_processive_rateFcn,simResult);
rate.reversal_processive = [reversal_processive_rate,reversal_processive_rate_ci'];

staticToMotile_rateFcn = @(simResult) sum(simResult.isMotile==0)/sum(simResult.duration(simResult.isMotile==0));
staticToMotile_rate = staticToMotile_rateFcn(simResult);
staticToMotile_rate_ci=bootci(nBoot,staticToMotile_rateFcn,simResult);
rate.staticToMotile = [staticToMotile_rate,staticToMotile_rate_ci'];

fractionMotileFcn = @(simResult) sum(simResult.duration(simResult.isMotile==1))/sum(simResult.duration);
fractionMotile = fractionMotileFcn(simResult);
fractionMotile_ci=bootci(nBoot,fractionMotileFcn,simResult);
rate.fractionMotile = [fractionMotile, fractionMotile_ci'];

lifetime.Total = simResult.duration;
lifetime.Processive = simResult.duration(simResult.isMotile==1);
lifetime.Static = simResult.duration(simResult.isMotile==0);

processivity = simResult.processivity(simResult.isMotile==1);
speed = simResult.speed;
