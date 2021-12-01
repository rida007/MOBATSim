classdef I2V < matlab.System & matlab.system.mixin.CustomIcon
    % This block sends the signals of the AIM (Autonomous Intersection Manager) signals to the vehicles approaching or passing crossroads.
    %

    % Pre-computed constants
    properties(Access = private)
        Vehicles = evalin('base','Vehicles');
    end

    methods(Access = protected)

        function stepImpl(obj,Flags)
            
            if ~isempty(Flags)
                % If there are flags for stopping and passing
                for vehicle = obj.Vehicles
                    % If the vehicle's id is in the first column of Flags
                    if ismember(vehicle.id,Flags(:,1))
                        % find which row of the Flags refer to the current vehicle
                        row = vehicle.id==Flags(:,1);
                        % get the braking flag value determined by the infrastructure
                        vehicle.status.brakingFlag = Flags(row,2);
                    end
                end
            end
            
        end

        function icon = getIconImpl(~)
            % Define icon for System block
            icon = matlab.system.display.Icon("MOBATSIM-Icon-Set_3- Flags.png");
        end
    end
end
