#The service definition of this service.
drive_servicedef="""
#Service to provide sample interface to the iRobot Create
service experimental.create

option version 0.5

struct WheelsCmd
    field double v_r_cmd
    field double v_l_cmd
end struct

object Drive
    option constant int16 LEFT_MOTOR_MIN_PWM = 60
    option constant int16 LEFT_MOTOR_MAX_PWM = 255
    option constant int16 RIGHT_MOTOR_MIN_PWM = 60
    option constant int16 RIGHT_MOTOR_MAX_PWM = 255
    option constant double SPEED_TOLERANCE = 1.e-2

    function void setWheelsSpeed(double v_left, double v_right)

    function void StartStreaming()
    function void StopStreaming()

    wire WheelsCmd commands

end object
"""



class Create_impl(object):
    def __init__(self):
        self._packets=None
        self._connected_wires=dict()
   
        

    def StartStreaming(self):
        with self._lock:
            if (self._streaming):
                raise Exception("Already streaming")

            self._ep=RR.ServerEndpoint.GetCurrentEndpoint()
            #Start the thread that receives data
            self._streaming=True
            t=threading.Thread(target=self._recv_thread)
            t.start()
    
    @property
    def packets(self):
        return self._packets
    @packets.setter
    def packets(self,value):
        self._packets=value
        #Set the wire connect callback for the wire server
        self._packets.WireConnectCallback=self._packet_wire_connected

    #Add connected wire to list.  You can also request an event when InValue
    #changes here
    def _packet_wire_connected(self,wire):
        self._connected_wires[wire.Endpoint]=wire
        #If you also want value changed event updates:
        #wire.WireValueChanged+=self.value_changed_callback
        #See client for usage example


    #Thread function that runs receive loop
    def _recv_thread(self):
        try:
            while self._streaming:
                if (not self._streaming): return
                self._ReceiveSensorPackets()
        except:
            #Exception will be thrown when the port is closed
            #just ignore it
            if (self._streaming):

                traceback.print_exc()
            pass

    #Receive the packets and execute the right commands
    def _ReceiveSensorPackets(self):
        while self._serial.inWaiting() > 0:
            seed=struct.unpack('>B',self._serial.read(1))[0]

            if (seed!=19):
                continue
            nbytes=struct.unpack('>B',self._serial.read(1))[0]

            if nbytes==0:
                continue

            packets=self._serial.read(nbytes)

            checksum=self._serial.read(1)

            #Send packet to the client through wire.  If there is a large backlog
            #of packets don't send
            if (self._serial.inWaiting() < 20):

                self._SendSensorPackets(seed,packets)

            readpos=0
            while (readpos < nbytes):
                id=struct.unpack('B',packets[readpos])[0]
                readpos+=1

                #Handle distance packets
                elif (id==19):
                    try:
                        distbytes=packets[readpos:(readpos+2)]
                        self._DistanceTraveled+=struct.unpack(">h",distbytes)[0]
                        readpos+=2
                    except:
                        print struct.unpack("%sB" % len(packets),packets)
                        raise

                #Handle angle packets
                elif (id==20):
                    distbytes=packets[readpos:(readpos+2)]
                    self._DistanceTraveled+=struct.unpack(">h",distbytes)[0]
                    readpos+=2


    def _SendSensorPackets(self,seed,packets):
        #Pack the data into the structure to send to the lient
        data=numpy.frombuffer(packets,dtype='u1')
        #Create the new structure using the "NewStructure" function
        strt=RRN.NewStructure('experimental.create.SensorPacket')
        #Set the data
        strt.ID=seed
        strt.Data=data

        #Iterate over all connected wires and set the OutValue
        eps=self._connected_wires.keys()
        for ep in eps:
            try:
                wire=self._connected_wires[ep]
                wire.OutValue=strt
            except:
                #If there is an error assume the wire has disconnected
                del(self._connected_wires[ep])
