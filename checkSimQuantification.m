simResult=table;
nState=200;
simResult.isMotile = ones(nState,1);
simResult.isNextStateMotile=zeros(nState,1);
simResult.duration = 1*ones(nState,1)+randn(nState,1);


pause_processive_rateFcn= @(simResult) sum(simResult.isMotile==1 & simResult.isNextStateMotile==0)/ sum(simResult.duration(simResult.isMotile==1));

pause_processive_rate=pause_processive_rateFcn(simResult)
