function [processivity, speed, lifetime, rate, fractionMotile, simResult, Nmotor] = quantifySimDynamics(motorState, simPar,analysisPar,nSimRepeat)

frameInterval   = analysisPar.frameInterval;
zeroSpeedThresh = analysisPar.zeroSpeedThresh;
switchTooCloseThresh = analysisPar.switchTooCloseThresh;

simResult=table;
for ii=1:nSimRepeat
    [dynamics] = lipowskiWithUnbindingSim(motorState,simPar);
    t=dynamics.t;
    x=dynamics.x;
    runID=ii;
    [simResultCur] = analyseSimDynamics(t,x,frameInterval,zeroSpeedThresh, switchTooCloseThresh, runID,dynamics);
    if size(simResultCur,1)>0
        simResult=[simResult;simResultCur];
    end
end

%implement rate calculations as functions so can do bootstrap CIs
nBoot = 1000;

pause_processive_rateFcn= @(simResult) sum(simResult.isMotile==1 & simResult.isNextStateMotile==0)/ sum(simResult.duration(simResult.isMotile==1));
pause_processive_rate=pause_processive_rateFcn(simResult);
if ~isnan(pause_processive_rate)
    pause_processive_rate_ci = bootci(nBoot,pause_processive_rateFcn,simResult);
    rate.pause_processive = [pause_processive_rate, pause_processive_rate_ci'];
else
    rate.pause_processive = [NaN,NaN,NaN];
end


reversal_processive_rateFcn= @(simResult) sum(simResult.isMotile==1 & simResult.isNextStateMotile==1)/ sum(simResult.duration(simResult.isMotile==1));
reversal_processive_rate=reversal_processive_rateFcn(simResult);
if ~isnan(reversal_processive_rate)
    reversal_processive_rate_ci=bootci(nBoot,reversal_processive_rateFcn,simResult);
    rate.reversal_processive = [reversal_processive_rate,reversal_processive_rate_ci'];
else
    rate.reversal_processive = [NaN,NaN,NaN];
end

staticToMotile_rateFcn = @(simResult) sum(simResult.isMotile==0)/sum(simResult.duration(simResult.isMotile==0));
staticToMotile_rate = staticToMotile_rateFcn(simResult);
if ~isnan(staticToMotile_rate)
    staticToMotile_rate_ci=bootci(nBoot,staticToMotile_rateFcn,simResult);
    rate.staticToMotile = [staticToMotile_rate,staticToMotile_rate_ci'];
else
    rate.staticToMotile = [NaN,NaN,NaN];
end

fractionMotileFcn = @(simResult) sum(simResult.duration(simResult.isMotile==1))/sum(simResult.duration);
fractionMotile = fractionMotileFcn(simResult);
if ~isnan(fractionMotile)
    fractionMotile_ci=bootci(nBoot,fractionMotileFcn,simResult);
    fractionMotile = [fractionMotile, fractionMotile_ci'];
else
    fractionMotile = [NaN,NaN,NaN];
end

lifetime.All= simResult.duration;
lifetime.Processive = simResult.duration(simResult.isMotile==1);
lifetime.Static = simResult.duration(simResult.isMotile==0);

processivity = simResult.processivity(simResult.isMotile==1);
speed = simResult.speed;
Nmotor = simResult.Nmotor;
