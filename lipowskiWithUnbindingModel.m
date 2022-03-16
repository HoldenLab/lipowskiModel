%Lipowski model
function motorDynamics = lipowskiWithUnbindingModel(motorState)

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
motorConcentration = motorState.motorConcentration;
kOn0 = motorState.kOn0; %rate of single motor (synthase) binding to cargo (mreB)
kOff0 = motorState.kOff0; %rate of single motor (synthase) unbinding from cargo (mreB)
if isfield(motorState,'Nmax')%optional field to define max occupancy of +/- sites
    Nmax = motorState.Nmax;
else
    Nmax = inf;
end
if isfield(motorState,'speedDependsOnNmotor')
    speedDependsOnNmotor = motorState.speedDependsOnNmotor;
else
    speedDependsOnNmotor = false;
end
if speedDependsOnNmotor
    Nmotor = Nplus+Nminus;
    if Nmotor>0 %otherwise we divide by zero
        vF = vF/(Nplus+Nminus); %model where local depletion of lipid II reduces synthase speed
    end
end

if nPlus>Nplus 
    error('Number of attached plus motors cannot be greater than total number of plus motors')
elseif nMinus>Nminus 
    error('Number of attached minus motors cannot be greater than total number of minus motors')
end


if nPlus>=nMinus
    v1=vF;
    v2=vB;
else
    v1=vB;
    v2=vF;
end

lambda = (1+ (nPlus*v2)/(nMinus*v1))^-1;
if (nPlus + nMinus)>0
    Fcargo = (lambda*nPlus + (1-lambda)*nMinus)*Fstall;
    vCargo = (nPlus-nMinus)/(nPlus/v1 + nMinus/v2);
else
    Fcargo=0;
    vCargo = 0;
end

if nPlus>0
    epsPlus =nPlus*eps0*exp(Fcargo/(nPlus*Fdetach));
else 
    epsPlus=0;
end
if nMinus>0
    epsMinus=nMinus*eps0*exp(Fcargo/(nMinus*Fdetach));
else
    epsMinus=0;
end

piPlus = (Nplus - nPlus)*pi0;
piMinus = (Nminus - nMinus)*pi0;

%binding unbinding rates
%cargo unbinding occurs only from inactive motors
kOffPlus = (Nplus - nPlus)*kOff0;
if Nplus<Nmax
    kOnPlus = kOn0*motorConcentration;
else
    kOnPlus = 0;
end
kOffMinus = (Nminus - nMinus)*kOff0;
if Nminus<Nmax
    kOnMinus = kOn0*motorConcentration;
else
    kOnMinus = 0;
end

motorDynamics.lambda  =lambda;   
motorDynamics.Fcargo  =Fcargo; 
motorDynamics.vCargo  =vCargo ; 
motorDynamics.epsPlus =epsPlus ; 
motorDynamics.epsMinus=epsMinus;
motorDynamics.piPlus  =piPlus  ;
motorDynamics.piMinus =piMinus ;
motorDynamics.kOffPlus=kOffPlus;
motorDynamics.kOnPlus = kOnPlus;
motorDynamics.kOffMinus=kOffMinus;
motorDynamics.kOnMinus = kOnMinus;
