function DuckiebotDriveClient()

%Simple example Robot Raconteur Drive client for Duckiebot

%Connect to the service
c=RobotRaconteur.ConnectService('rr+tcp://duckiepark:2356?service=Drive');


%Drive a bit
c.setWheelsSpeed(0.5,0.5)
pause(1);
c.setWheelsSpeed(0,0)
pause(1);

RobotRaconteur.DisconnectService(c)

end
