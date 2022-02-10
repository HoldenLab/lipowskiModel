
motorPar.eps0=10;%single motor unbinding rate s^-1
motorPar.pi0 =1; %single motor binding rate s^-1
motorPar.Fdetach = 1;%detachment force pN nm
motorPar.Fstall = 100; %stall force pN nM
motorPar.Nplus=1;%total number of plus motors 
motorPar.Nminus=0;%total number of bound plus motors 
motorPar.vF=40;%forward velocity nm/s
motorPar.vB=0.1;%backward velocity nm/s

motorState=motorPar;
motorState.nPlus=1;%number of bound plus motors 
motorState.nMinus=0;%number of bound minus motors

simPar.nStep= 100;

%motorDynamics = lipowskiModel(motorState)

[dynamics] = lipowskiSim(motorPar,simPar);
t=dynamics.t;
x=dynamics.x;
nPlus=dynamics.nPlus;
nMinus=dynamics.nMinus;
vCargo=dynamics.vCargo;

figure;
subplot(3,1,1);
plot(t,x);
subplot(3,1,2);
hold all;
plot(t,nPlus);
plot(t,nMinus);
plot(t,nMinus+nMinus);
subplot(3,1,3);
plot(t,vCargo);
