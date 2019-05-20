function SimpleWebcamClient_stream()

%Simple example Robot Raconteur webcam client

%Connect to the service
c_host=RobotRaconteur.ConnectService('rr+tcp://duckiepark:2355?service=Webcam');

%Use objref's to pull out the cameras. c_host is a "WebcamHost" type
%and is used to find the webcams
c1=c_host.get_Webcams(0);

%Connect to the stream pipe
p=c1.FrameStream.Connect(-1);

%Start the streaming, ignore if there is an error
try
   c1.StartStreaming();
catch
end

%Loop through and show 20 seconds of the live feed
%Note: the framerate may be very low for this example...
figure

for i=1:100
   %If there is a packet available, receive and show
   while (p.Available > 0)
       im=WebcamImageToIM(p.ReceivePacket());
       clf
       imshow(im)
   end
   pause(.2)
end

%You can also "SendPacket" on a pipe, but we do not in this example

%Close the pipe
p.Close();

%Stop the camera streaming
c1.StopStreaming();

%Disconnect from the service
RobotRaconteur.DisconnectService(c_host);

    %Helper function to convert raw images to "MATLAB" format
    function im=WebcamImageToIM(wim)
        b=reshape(wim.data(1:3:end),wim.width,wim.height)';
        g=reshape(wim.data(2:3:end),wim.width,wim.height)';
        r=reshape(wim.data(3:3:end),wim.width,wim.height)';
        
        im=cat(3,r,g,b);        
    end

end