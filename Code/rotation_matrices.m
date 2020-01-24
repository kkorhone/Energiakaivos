clc

clear all
close all

% A point on the x axis.

r = [1, 0, 0];

% The rotation angles.

azimuth = 0:5:360;
tilt = -30:5:-10;

% Rotates the point.

plot3(0, 0, 0, 'ko');

hold on

for i = 1:length(azimuth)
    for j = 1:length(tilt)
        
        phi = pi * azimuth(i) / 180;
        theta = pi * tilt(j) / 180;
        
        % Ry = [cos(theta) 0 -sin(theta); 0 1 0; sin(theta) 0 cos(theta)];
        % Rz = [cos(phi) -sin(phi) 0; sin(phi) cos(phi) 0; 0 0 1];

        % R = Rz * Ry;
        
        R = [cos(phi)*cos(theta) -sin(phi) -sin(theta)*cos(phi);
             sin(phi)*cos(theta)  cos(phi) -sin(phi)*sin(theta);
                      sin(theta)         0           cos(theta)];

        % Rotates the point.

        r_ = R * r';

        % Plots the result.

        plot3([0 r_(1)], [0 r_(2)], [0 r_(3)], 'r-')
        
    end
end

% -1 -1 -1
% -1 -1 +1
% -1 +1 -1
% -1 +1 +1
% +1 -1 -1
% +1 -1 +1
% +1 +1 -1
% +1 +1 +1

plot3([-1 -1 -1 -1 +1 +1 +1 +1], [-1 -1 +1 +1 -1 -1 +1 +1], [-1 +1 -1 +1 -1 +1 -1 +1], 'b.')

hold off
