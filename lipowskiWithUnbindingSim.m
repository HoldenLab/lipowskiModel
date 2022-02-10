function [motorDynamicsList] = lipowskiWithUnbindingSim(motorPar,simPar)

%initialise with one motor
motorState=motorPar;
nStep= simPar.nStep;

t=zeros(nStep,1);
x=t;
nPlus=t;
nMinus=t;
Nplus=t;
Nminus=t;
vCargo=t;

%gillespie algorithm
for ii = 2:nStep
    m = lipowskiWithUnbindingModel(motorState);
    %calculate overall reaction rate
    k=[m.epsPlus,m.epsMinus,m.piPlus,m.piMinus,m.kOffPlus,m.kOnPlus,m.kOffMinus,m.kOnMinus];
    R = sum(k);
    %calculate time to next reaction
    u1=rand();
    tau=1/R*log(1/u1);

    %store reaction time and position
    t(ii)=t(ii-1)+tau;
    x(ii)=x(ii-1)+m.vCargo*tau;
    nPlus(ii)= motorState.nPlus;
    nMinus(ii)=motorState.nMinus;
    Nplus(ii)= motorState.Nplus;
    Nminus(ii)=motorState.Nminus;
    vCargo(ii)=m.vCargo;

    %select reaction to occur
    propensity = cumsum(k)/sum(k);
    u2=rand();
    %find the first propensity > u2
    rateIdx = find((u2-propensity)>0==0,1,'first');
    switch rateIdx
        case 1 %epsPlus unbinding
            if motorState.nPlus>0 %these if statements should not be necessary as rate should just go to zero if you run out of motors in the model but belt and braces
                motorState.nPlus=motorState.nPlus-1;
            end
        case 2 %epsMinus
            if motorState.nMinus>0
                motorState.nMinus=motorState.nMinus-1;
            end
        case 3 %piPlus
            if motorState.nPlus<motorState.Nplus
                motorState.nPlus=motorState.nPlus+1;
            end
        case 4 %piMinus
            if motorState.nMinus<motorState.Nminus
                motorState.nMinus=motorState.nMinus+1;
            end
        case 5 %kOffPlus
            if motorState.Nplus>0
                motorState.Nplus=motorState.Nplus-1;
            end
        case 6 %kOnPlus
            motorState.Nplus=motorState.Nplus+1;
        case 7 %kOffMinus
            if motorState.Nminus>0
                motorState.Nminus=motorState.Nminus-1;
            end
        case 8 %kOnMinus
            motorState.Nminus=motorState.Nminus+1;
    end
end

%apparently some transitions happen so fast as to be approximately instantaneous
%In this case only record the second event (although the first event still happens
%so effectively equivalent to appearance of eg 2 motors could bind at once
idx=find(diff(t)==0);
t(idx+1)=[];
x(idx+1)=[];
nPlus(idx+1)  =[];
nMinus(idx+1) =[];
Nplus(idx+1)  =[];
Nminus(idx+1) =[];
vCargo(idx+1) =[];

motorDynamicsList.t=t;
motorDynamicsList.x=x;
motorDynamicsList.nPlus=nPlus;
motorDynamicsList.nMinus=nMinus;
motorDynamicsList.Nplus=Nplus;
motorDynamicsList.Nminus=Nminus;
motorDynamicsList.vCargo=vCargo;
