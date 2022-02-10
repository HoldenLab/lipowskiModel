function [motorDynamicsList] = lipowskiSim(motorPar,simPar)

%initialise with one motor
motorState=motorPar;
nStep= simPar.nStep;

t=zeros(nStep,1);
x=t;
nPlus=t;
nMinus=t;
vCargo=t;

%gillespie algorithm
for ii = 2:nStep
    m = lipowskiModel(motorState);
    %calculate overall reaction rate
    k=[m.epsPlus,m.epsMinus,m.piPlus,m.piMinus];
    R = sum(k);
    %calculate time to next reaction
    u1=rand();
    tau=1/R*log(1/u1);

    %store reaction time and position
    t(ii)=t(ii-1)+tau;
    x(ii)=x(ii-1)+m.vCargo*tau;
    nPlus(ii)= motorState.nPlus;
    nMinus(ii)=motorState.nMinus;
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
    end
end
motorDynamicsList.t=t;
motorDynamicsList.x=x;
motorDynamicsList.nPlus=nPlus;
motorDynamicsList.nMinus=nMinus;
motorDynamicsList.vCargo=vCargo;

