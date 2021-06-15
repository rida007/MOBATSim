classdef VehicleCommunication_v2v < matlab.System & handle & matlab.system.mixin.Propagates ...
        & matlab.system.mixin.CustomIcon
    % This module gets the futureData(other vehicles' predictions) which has a V2V connection with this vehicle.
    %

    % Public, tunable properties
    properties
        Vehicle_id
    end

    % Pre-computed constants
    properties(Access = private)
        vehicle
        Vehicles
    end

    methods
        % Constructor
        function obj = VehicleCommunication_v2v(varargin)
            % Support name-value pair arguments when constructing object
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access = protected)
        %% Common functions
        function setupImpl(obj)
            % Perform one-time calculations, such as computing constants
            obj.Vehicles = evalin('base','Vehicles');
            obj.vehicle = obj.Vehicles(obj.Vehicle_id);
        end
        
        function OtherVehiclesFutureData = stepImpl(obj,CommunicationID)
            %This block shouldn't run if the vehicle has reached its
            %destination
            if obj.vehicle.pathInfo.destinationReached
           
                % Output: Collect Future Data
                OtherVehiclesFutureData = -1;
                
            else
                
                % Output: Collect Future Data
                OtherVehiclesFutureData = obj.CollectFutureData(obj.vehicle, obj.Vehicles);
            end
        end
        
        function futureData = CollectFutureData(~,car, Vehicles)
            i = 1:length(Vehicles);
            
            i = i(car.V2VdataLink==1); % Remove the vehicles that don't have V2V connection to the car
            i(car.id)=[]; % Remove the car with the same id

            futureData =cat(1,cat(1,[Vehicles(i).decisionUnit]).futureData);

        end

        
    %% Standard Simulink Output functions
        function s = saveObjectImpl(obj)
            % Set properties in structure s to values in object obj

            % Set public properties and states
            s = saveObjectImpl@matlab.System(obj);

            % Set private and protected properties
            %s.myproperty = obj.myproperty;
        end

        function icon = getIconImpl(~)
            % Define icon for System block
            icon = matlab.system.display.Icon("V2V.png");
        end

        function loadObjectImpl(obj,s,wasLocked)
            % Set properties in object obj to values in structure s

            % Set private and protected properties
            % obj.myproperty = s.myproperty; 

            % Set public properties and states
            loadObjectImpl@matlab.System(obj,s,wasLocked);
        end

    end

    methods(Static, Access = protected)
        function header = getHeaderImpl
            % Define header panel for System block dialog
            header = matlab.system.display.Header(mfilename('class'));
        end


        function group = getPropertyGroupsImpl
            % Define property section(s) for System block dialog
            group = matlab.system.display.Section(mfilename('class'));
        end

        function ds = getDiscreteStateImpl(~)
            % Return structure of properties with DiscreteState attribute
            ds = struct([]);
        end

        function flag = isInputSizeLockedImpl(~,~)
            % Return true if input size is not allowed to change while
            % system is running
            flag = true;
        end

        function out = getOutputSizeImpl(~)
            % Return size for each output port
            out = [8000 6];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function out = getOutputDataTypeImpl(~)
            % Return data type for each output port
            out = 'double';

            % Example: inherit data type from first input port
            % out = propagatedInputDataType(obj,1);
        end

        function out = isOutputComplexImpl(~)
            % Return true for each output port with complex data
            out = false;
            % Example: inherit complexity from first input port
            % out = propagatedInputComplexity(obj,1);
        end

        function out = isOutputFixedSizeImpl(~)
            % Return true for each output port with fixed size
            out = false;

            % Example: inherit fixed-size status from first input port
            % out = propagatedInputFixedSize(obj,1);
        end

        function resetImpl(~)
            % Initialize / reset discrete-state properties
        end
    end
end
