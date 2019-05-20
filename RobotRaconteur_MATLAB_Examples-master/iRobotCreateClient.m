function iRobotCreateClient()

%Example iRobot Create client in MATLAB

%Connect to the service
c=RobotRaconteur.ConnectService('rr+tcp://localhost:2354?service=Create');


%Drive a bit
c.Drive(int16(200),int16(1000));
pause(0.5);
c.Drive(int16(0),int16(1000));

%Demonstrate events and callbacks
%Enable events and callbacks.  Only do this if you plan on using them,
%the buffer can overflow if they are not processed...
RobotRaconteur.EnableEvents(c);

%addlistener for the 'Bump' event so that the Bump function is called
addlistener(c,'Bump',@Bump)

%Set the callback for the play_callback
c.play_callback=@play_callback;

%Because MATLAB is single threaded, we need to use the main thread
%to check for events and callbacks.  This is pretty cumbersome but is
%the only way to handle events and callbacks.  We will check for 10 
%seconds looping with 100 ms delay between checks.

%Start streaming. try/catch blocks work to handle exceptions.
try    
c.StartStreaming();
catch e
    disp('StartStreaming error occured')
end

disp('Waiting for events/callbacks')
for i=1:100
    %Process any pending events or callbacks
    RobotRaconteur.ProcessRequests();
    pause(.1); 
end
disp('End waiting for events/callbacks')
%Disable events when you don't need them
RobotRaconteur.DisableEvents(c);


%Demonstrate using a wire

%Connect the wire
packet_wire=c.packets.Connect();

for i=1:10
    try
        %Receive a packet
        packet=packet_wire.InValue;
        %Print out the data
        disp(packet.Data)
    catch e
        %If the error is "Value not set" ignore, otherwise print the error
        if (isempty(strfind(e.message,'Value not set')))
            disp(e.message)
        end
    end
    pause(.1)
end
%Close the wire, we are done
packet_wire.Close();

%Stop the iRobot Create streaming data
c.StopStreaming();

%Disconnect the service
RobotRaconteur.DisconnectService(c)

    %Function for Bump event, called on event
    function Bump()
       disp('Bump!') 
    end

    %Function for play_callback
    function notes=play_callback(distance, angle)
        disp('play_callback!')
        disp(distance)
        disp(angle)
        
        %Return some notes to play (uint8 type)
        notes=uint8([69,16,60,16,69,16])';
    end 

end