function FPS = SimpleWebcamClient_stream()

%Simple example Robot Raconteur webcam client

%Connect to the service
c_host=RobotRaconteur.ConnectService('rr+tcp://duckiepark:2355?service=Webcam');

%Use objref's to pull out the cameras. c_host is a "WebcamHost" type
%and is used to find the webcams
c1=c_host.get_Webcams(0);

figure
finish_time = 0;
itr = 100;
FPS = zeros(1,itr);
i = 1;
while (i <= itr)
    start_time = now* 24 * 60 * 60;
    im=WebcamImageToIM(c1.CaptureFrame()); 
    clf
    imshow(im)
    FPS(1,i) = 1/((start_time - finish_time));
    finish_time = now* 24 * 60 * 60;
    i = i+1;
end

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
