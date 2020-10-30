function pathPlot = plotPath(map,path,carID)
    %This is helper function that plots the current position and path of all Vehicles on the map
    %Input: map is the XML map object,
    %displayInGridCoordinates is a boolean: true = display grid, false = display normal plot
    
    %% prepare Path colors
    persistent colourMatrix
    persistent waypoints
    persistent circles
    persistent trans
    persistent xOff
    persistent yOff
    
    if isempty(colourMatrix)
            colourMatrix = [1 0 0;                      %1  red
                    1 1 0 ;                     %2	yellow
                    0 1 1 ;                     %3  light blue
                    0 0.2470 0.5410;            %4  dark blue
                    0.8500 0.3250 0.0980;       %5  orange
                    1 0 1;                      %6  magenta
                    0 0.4470 0.7410;            %7  blue
                    0.6350 0.0780 0.1840;       %8  dark red
                    0.3 0.3 0.3;                %9  grey
                    0.4940 0.1840 0.5560;       %10 violet
                    ];
    end
    
    if isempty(waypoints)
        waypoints = map.waypoints;
        waypoints(:,3) = -1.*waypoints(:,3);
        circles = map.connections.circle;
        circles(:,6) = -1.*circles(:,6);
        trans = map.connections.translation;
        
        %use offset if you need it
        xOff = 0;
        yOff = 0;
    end
    %% prepare everything
    hold on      

    %% plot path for every vehicle
    pathPlot = [];
    bogPath = [];%list of points to plot
    %determine if circle or not
    for k = 2 : size(path,2)
        p1 = path(k-1);
        p2 = path(k);
        straight = ~isempty(trans(trans(:,1) == p1 & trans(:,2) == p2,:));
        if straight
            %just draw a line
            if isempty(bogPath)
                bogPath = [[map.Vehicles(carID).dynamics.position(1)-xOff,-map.Vehicles(carID).dynamics.position(3)-yOff]; [waypoints(p2,1)-xOff,waypoints(p2,3)-yOff]];
            else
                bogPath = [bogPath;[waypoints(p1,1)-xOff,waypoints(p1,3)-yOff]; [waypoints(p2,1)-xOff,waypoints(p2,3)-yOff]];
            end
        else
            %gather points on the circle
            curvedRoute = circles( circles(:,1)==p1 & circles(:,2) == p2,:);
            if isempty(bogPath)
                x1 = map.Vehicles(carID).dynamics.position(1)-xOff;
                y1 = -map.Vehicles(carID).dynamics.position(3)-yOff;
            else
                x1 = waypoints(curvedRoute(1),1)-xOff; %start
                y1 = waypoints(curvedRoute(1),3)-yOff;
            end
            x2 = waypoints(curvedRoute(2),1)-xOff; %goal
            y2 = waypoints(curvedRoute(2),3)-yOff;
            x0W = curvedRoute(4)-xOff; %central point
            y0W = curvedRoute(6)-yOff;
            radius = norm( [x2,y2]-[x0W,y0W] );
            phiStart = angle(complex((x1-x0W) , (y1-y0W)));
            phiGoal = angle(complex((x2-x0W) , (y2-y0W)));
            direction = sign(curvedRoute(3));
            if phiStart <0
                phiStart = phiStart + 2*pi;
            end
            if phiGoal <0
                phiGoal = phiGoal + 2*pi;
            end
            %make turns through 0° possible
            if (direction == -1 && phiStart < phiGoal)
                phiStart = phiStart + 2*pi;
            end
            if (direction == 1 && phiStart > phiGoal)
                phiGoal = phiGoal + 2*pi;
            end
            phi1 = phiStart : direction*0.1 : phiGoal;
            phi1(1) = phiStart;
            phi1(end) = phiGoal;
            points = [(radius .* cos(phi1)+x0W)',(radius .* sin(phi1))'+y0W];
            bogPath = [bogPath;points];
        end

    end

    if ~isempty(bogPath)
        pathPlot = plot(bogPath(:,1),bogPath(:,2),'color',colourMatrix(carID,:),'LineWidth',2);
    end
    hold off
end