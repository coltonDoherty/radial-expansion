
%% Clear
close all

%% Define Constants
numOfSteps=51; % Used to create plots
Fs=2:-.03:.5; %N
mu1=0.27;
mu2=0.27;
userInputStrokeLength= input('What would you like the radial stroke length distance to be in (cm)?  ');
userInputHalfCycleTime= input('How long would you like half a cycle (one dircetion) to take in (seconds)?  ')  ;
parameters= getConstants(userInputStrokeLength,userInputHalfCycleTime);
bLength=size(parameters,1);

%% theta1 Parameters
theta1Start= parameters(1,3) ; 
theta1End= parameters(1,4);
theta1Step= (theta1End-theta1Start)/(numOfSteps-1);
theta1Vec= theta1Start:theta1Step:theta1End;
fprintf('Theta 1 will run from %3.2f (deg) to %3.2f (deg) by steps of size %3.2f (deg)\n', theta1Start*180/pi, theta1End*180/pi, theta1Step*180/pi)
theta1DegVec= theta1Vec.*180/pi;

%% Intizialize Vectors
xCordMatrix=zeros(bLength,numOfSteps);
yCordMatrix=zeros(bLength,numOfSteps);
theta2Matrix=zeros(bLength,numOfSteps);
Fn1Matrix=zeros(bLength,numOfSteps);
Fn2Matrix=zeros(bLength,numOfSteps);
torqueMatrix=zeros(bLength,numOfSteps);
theta2DegMatrix=theta2Matrix*180/pi;

%% Calcuations

    for i=1:bLength
        %%% Parse b and m
        b=parameters(i,1);
        m=parameters(i,2);

        %%% rectangular Cordiantes (uesd to draw path) 
        x=(m.*theta1Vec+b).*cos(theta1Vec);
        y=(m.*theta1Vec+b).*sin(theta1Vec);
        xCordMatrix(i,:)=x;
        yCordMatrix(i,:)=y;

            %Iterate by values of theta 1
            for j=1:numOfSteps
                theta1=theta1Vec(j);
                
                %%%theta2
                theta2=solveForThetaTwo(m,b,theta1);
                theta2Matrix(i,j)=theta2;
                theta2DegMatrix(i,j)=theta2*180/pi;
                %%%Forces and Torques
                r=m*theta1+b;
                Fn1=Fs(j)/((sin(theta2))-(mu1*cos(theta2)+mu2*cos(theta2)+mu1*mu2*sin(theta2)));
                Fn2=Fn1*cos(theta2)+mu1*Fn1*sin(theta2);
                T= r*(cos(theta2)*Fn1+sin(theta2)*Fn1*mu1);  
                
                Fn1Matrix(i,j)=Fn1;
                Fn2Matrix(i,j)=Fn2;
                torqueMatrix(i,j)=T;
            end
    end

%% Print Statements

   for i=1:bLength
        b1=round(parameters(i,1)*1000); %mm
        m1=parameters(i,2)*1000; %mm/rads
        ir1=parameters(i,5)*1000; %mm
        or1=parameters(i,6)*1000; %mm
        dTdt1=parameters(i,7)*180/pi; %deg/sec
        RPM1=parameters(i,8);
        fprintf('when b is %d (mm): m=%3.2f (mm/rads), inner raduis=%3.2f (mm), outer raduis is=%3.2f (mm), required change in theta1 per second=%3.2f (deg/second), RPM is=%3.2f\n', b1,m1,ir1,or1,dTdt1,RPM1)
   end


%% Plotting
    %Iterate rows of parameters maxtrix (values of b)
    for i=1:bLength
        figure(i)
        subplot(1,4,1)
        plot(xCordMatrix(i,:)*1000, yCordMatrix(i,:)*1000, 'LineWidth',2)
        title('Curve Path')
        xlabel('$x (mm)$', Interpreter='latex')
        ylabel('$y (mm)$', Interpreter='latex')  
        xlim([-55,50])
        ylim([-50,50])
        xticks([-50 -25 0 25 50])
        yticks([-50 -25 0 25 50])
        axis square
        grid on
        set(gca,'FontSize', 17, 'FontName', 'Times')
        
        
        subplot(1,4,2)
        plot(theta1DegVec,Fn1Matrix(i,:), 'LineWidth',2)
        title('Normal Force 1')
        xlabel('$Angle (^\circ)$', Interpreter='latex')
        ylabel('$Force (N)$', Interpreter='latex')
        ylim([0.1,20]);
        yticks([0 5 10 15 20])
        axis square
        grid on
        set(gca,'FontSize', 17, 'FontName', 'Times')
        
        subplot(1,4,3)
        plot(theta1DegVec,Fn2Matrix(i,:), 'LineWidth',2)
        title('Normal Force 2')
        xlabel('$Angle (^\circ)$', Interpreter='latex')
        ylabel('$Force (N)$', Interpreter='latex')
        ylim([0,20]);
        yticks([0 5 10 15 20])
        axis square
        grid on
        set(gca,'FontSize', 17, 'FontName', 'Times')
        
        subplot(1,4,4)
        plot(theta1DegVec,torqueMatrix(i,:)*1000*6, 'LineWidth',2) %times 1,000 to make Nmm and times 6 because there are six tactors
        title('Motor Torque')    
        xlabel('$Angle (^\circ)$', Interpreter='latex')
        ylabel('$Torque (N \cdot mm)$', Interpreter='latex')
        ylim([0,1000])
        yticks([0 100 200 300 400 500 600 700 800 900 1000])
        axis square
        grid on
        set(gca,'FontSize', 17, 'FontName', 'Times')

        figure(10+i)

        plot(theta1DegVec,torqueMatrix(i,:)*1000*6, 'LineWidth',2) %times 1,000 to make Nmm and times 6 because there are six tactors
        title('Motor Torque Retract')    
        xlabel('$Angle (^\circ)$', Interpreter='latex')
        ylabel('$Torque (N \cdot mm)$', Interpreter='latex')
        ylim([0,1000])
        yticks([0 100 200 300 400 500 600 700 800 900 1000])
        axis square
        grid on
        set(gca,'FontSize', 12, 'FontName', 'Times')
        hold on
        Array=csvread('TEST.csv',2);
        col1 = Array(:, 1);
        col2 = Array(:, 2);
        scatter(col1, col2, 30)
        hold on
        fplot(@(x) 457.47*exp(-0.009*x), [0 160], "LineWidth", 2, "LineStyle", "--", "Color", "red")
       
        figure(100+i)

        plot(theta1DegVec,torqueMatrix(i,:)*1000*6, 'LineWidth',2) %times 1,000 to make Nmm and times 6 because there are six tactors
        title('Motor Torque Expand')    
        xlabel('$Angle (^\circ)$', Interpreter='latex')
        ylabel('$Torque (N \cdot mm)$', Interpreter='latex')
        ylim([0,1000])
        yticks([0 100 200 300 400 500 600 700 800 900 1000])
        axis square
        grid on
        set(gca,'FontSize', 12, 'FontName', 'Times')
        hold on
        Array=csvread('TEST.csv',2);
        col1 = Array(:, 3);
        col2 = Array(:, 4);
        scatter(col1, col2, 30)


    end
%% End





