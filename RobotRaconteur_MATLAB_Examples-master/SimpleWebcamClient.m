function SimpleWebcamClient()

%Simple example Robot Raconteur webcam client

%Connect to the service
c_host=RobotRaconteur.ConnectService('rr+tcp://duckiepark:2355?service=Webcam');

%Use objref's to pull out the cameras. c_host is a "WebcamHost" type
%and is used to find the webcams
c1=c_host.get_Webcams(0);
% c2=c_host.get_Webcams(1);

%Pull a frame from each camera, c1 and c2
frame1=WebcamImageToIM(c1.CaptureFrame());
%frame2=WebcamImageToIM(c2.CaptureFrame());

%Show the images
figure
imshow(frame1);
title(c1.Name)
%figure
%imshow(frame2);
%title(c2.Name)

RobotRaconteur.DisconnectService(c_host)

    %Helper function to convert raw images to "MATLAB" format
    function im=WebcamImageToIM(wim)
        b=reshape(wim.data(1:3:end),wim.width,wim.height)';
        g=reshape(wim.data(2:3:end),wim.width,wim.height)';
        r=reshape(wim.data(3:3:end),wim.width,wim.height)';
        
        im=cat(3,r,g,b);
        
        
    end

end
