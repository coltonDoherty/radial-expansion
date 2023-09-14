function constantsMatrix=getConstants(inputStrokeLength,inputHalfCyleTime)
%getConstants
%   inputs=[strokeLength (cm), halfCycleTime (sec)]
%   outputs= [b (m), m (m/rads), theta1Start (rads), theta1End (rads), 
%   innerRaduis (m), outerRaduis (m), dTheta_dTime (rads/s), RPM]

%% Intitialization

%%Inputs 
strokeLength= inputStrokeLength; %[cm]
halfCycleTime= inputHalfCyleTime; %[seconds (s)]
bList=[5, 10, 15, 20, 25, 30]; %[mm] 10 to 30, list of length 4 values do not have to have equal step sizes


%%Angle and Raduis Constants
theta1Start=0; %% Do not need to change this since changing b has similar effect as changing this 
theta1Range= 160*pi/180; %% 160 Degrees was chosen to allow for wiggle room with servo motors and avoid path overlap, larger angle range results in more favorbale resolution for motor and torque conditions

%%Create Empty Lists
constantsMatrix=zeros(4,8); % Each row is assoicatyed with a value of b, for each b value a row reads: [b, m, theta1Start, theta1End, innerRaduis, outerRaduis, dTheta_dTime, RPM]

%% Intitial Calculations

%%Angle and Raduis
theta1End=0 + theta1Range;
radiusDifference= strokeLength/100; %[m]


%%M and B
m=radiusDifference/theta1Range; %(m/rads)
bList=bList/1000; %[m]

%% Iteration of b for Loop

for i=1:length(bList)
    inputHalfCyleTime=bList(i);

    %%Radii
    outerRaduis=inputHalfCyleTime+radiusDifference;
    innerRaduis=inputHalfCyleTime;

    %%Solve for RPM
    dTheta_dTime=((radiusDifference/halfCycleTime)/m);
    RPM=dTheta_dTime*60/(2*pi);

    %Create row in constantsMatrix
    constantsMatrix(i,:)=[inputHalfCyleTime, m, theta1Start, theta1End, innerRaduis, outerRaduis, dTheta_dTime, RPM];
end