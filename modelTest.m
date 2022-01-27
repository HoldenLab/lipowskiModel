
motorState.eps0=1;%single motor unbinding rate s^-1
motorState.pi0 =1; %single motor binding rate s^-1
motorState.Fdetach = 2;%detachment force pN nm
motorState.Fstall = 4 ; %stall force pN nM
motorState.Nplus=2;%total number of plus motors 
motorState.Nminus=2;%total number of bound plus motors 
motorState.nPlus=0;%number of bound plus motors 
motorState.nMinus=1;%number of bound minus motors
motorState.vF=40;%forward velocity nm/s
motorState.vB=0.1;%backward velocity nm/s

motorDynamics = lipowskiModel(motorState)


