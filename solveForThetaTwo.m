function [theta2,track]=solveForThetaTwo(m, b, theta1)
%solveForThetaTwo
%   inputs=(m "slope" (m/rad), b (m), theta1 (rads))
%   outputs= theta2 (rads)

derx= (m*cos(theta1))+(m*theta1+b)*-sin(theta1);
dery= (m*sin(theta1))+((m*theta1+b)*(cos(theta1)));

norm=[-dery, derx];
xprime=[cos(theta1),sin(theta1)];

theta2=pi/2-(pi-acos(dot(norm,xprime)/sqrt(dery^2+derx^2)));

