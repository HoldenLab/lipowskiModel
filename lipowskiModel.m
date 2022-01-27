%Lipowski model
function motorDynamics = lipowskiModel(motorState)

%motorState
eps0 = motorState.eps0;%single motor unbinding rate
pi0 = motorState.pi0; %single motor binding rate
Fdetach = motorState.Fdetach;%detachment force
Fstall = motorState.Fstall; %stall force
Nplus = motorState.Nplus;%total number of plus motors 
Nminus= motorState.Nminus;%total number of bound plus motors 
nPlus = motorState.nPlus;%number of bound plus motors 
nMinus= motorState.nMinus;%number of bound minus motors
vF = motorState.vF;%forward velocity
vB = motorState.vB;%backward velocity

if nPlus>=nMinus
    v1=vF;
    v2=vB;
else
    v1=vB;
    v2=vF;
end

lambda = (1+ (nPlus*v2)/(nMinus*v1))^-1;
Fcargo = (lambda*nPlus + (1-lambda)*nMinus)*Fstall;
vCargo = (nPlus-nMinus)/(nPlus/v1 + nMinus/v2)

epsPlus =nPlus*eps0*exp(Fcargo/(nPlus*Fdetach));
epsMinus=nMinus*eps0*exp(Fcargo/(nMinus*Fdetach));

piPlus = (Nplus - nPlus)*pi0;
piMinus = (Nminus - nMinus)*pi0;

motorDynamics.lambda  =lambda;   
motorDynamics.Fcargo  =Fcargo; 
motorDynamics.vCargo  =vCargo ; 
motorDynamics.epsPlus =epsPlus ; 
motorDynamics.epsMinus=epsMinus;
motorDynamics.piPlus  =piPlus  ;
motorDynamics.piMinus =piMinus ;

