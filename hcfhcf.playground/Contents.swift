//: Playground - noun: a place where people can play




import UIKit
import AVFoundation
import Foundation
import MultipeerConnectivity

class FilmingVC: UIViewController, MCSessionDelegate, MCBrowserViewControllerDelegate, AVCaptureVideoDataOutputSampleBufferDelegate{
    
    //Video
    let captureSession = AVCaptureSession()
    var previewLayer : AVCaptureVideoPreviewLayer?
    var captureDevice : AVCaptureDevice?
    var videoDeviceOutput: AVCaptureVideoDataOutput!
    var sessionQueue: dispatch_queue_t!
    
    //Multipeer
    var peerID: MCPeerID!
    var session: MCSession!
    var browser: MCBrowserViewController!
    var assistant: MCAdvertiserAssistant!
    var videoStream: NSOutputStream!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Video
        // Do any additional setup after loading the view, typically from a nib.
        captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        let devices = AVCaptureDevice.devices()
        
        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if (device.hasMediaType(AVMediaTypeVideo)) {
                // Finally check the position and confirm we've got the back camera
                if(device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture device found")
                        beginSession()
                    }
                }
            }
        }
        
        //Multipeer
        self.peerID = MCPeerID(displayName: UIDevice.currentDevice().name)
        print( UIDevice.currentDevice().name )
        //self.session = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .Required)
        self.session = MCSession(peer: self.peerID)
        self.session.delegate = self
        
        // create the browser viewcontroller with a unique service name
        self.browser = MCBrowserViewController(serviceType: "LCOC-Chat", session: self.session)
        self.browser.delegate = self
        
        // tell the assistant to start advertising our fabulous chat
        self.assistant = MCAdvertiserAssistant(serviceType:"LCOC-Chat", discoveryInfo:nil, session:self.session)
        self.assistant.start()
        
    }
    
    /***** Video *****/
    func focusTo(value : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(value, completionHandler: { (time) -> Void in
                })
                device.unlockForConfiguration()
            } catch {
                //error message
                print("Can't change focus of capture device")
            }
        }
    }
    
    func configureDevice() {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.focusMode = .Locked
                device.unlockForConfiguration()
            } catch {
                //error message etc.
                print("Capture device not configurable")
            }
        }
        
    }
    
    func beginSession() {
        
        configureDevice()
        do {
            //try captureSession.addInput(input: captureDevice)
            try captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
            updateDeviceSettings(0.0, isoValue: 0.0)
        } catch {
            //error message etc.
            print("Capture device not initialisable")
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer!)
        previewLayer?.frame = self.view.layer.frame
        self.view.layer.insertSublayer(previewLayer!, atIndex: 0)
        captureSession.startRunning()
    }
    
    func updateDeviceSettings(focusValue : Float, isoValue : Float) {
        if let device = captureDevice {
            do {
                try device.lockForConfiguration()
                device.setFocusModeLockedWithLensPosition(focusValue, completionHandler: { (time) -> Void in
                })
                
                // Adjust the iso to clamp between minIso and maxIso based on the active format
                let minISO = device.activeFormat.minISO
                let maxISO = device.activeFormat.maxISO
                let clampedISO = isoValue * (maxISO - minISO) + minISO
                
                device.setExposureModeCustomWithDuration(AVCaptureExposureDurationCurrent, ISO: clampedISO, completionHandler: { (time) -> Void in
                    //
                })
                
                device.unlockForConfiguration()
            } catch {
                //error message etc.
                print("Can't update device settings")
            }
            
        }
    }
    
    //Initializes SampleBufferDelegate and videoDeviceOutput
    func addVideoOutput() {
        videoDeviceOutput = AVCaptureVideoDataOutput()
        videoDeviceOutput.alwaysDiscardsLateVideoFrames = true
        self.sessionQueue = dispatch_queue_create("Camera Session", DISPATCH_QUEUE_SERIAL)
        videoDeviceOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        if captureSession.canAddOutput(videoDeviceOutput) {
            captureSession.addOutput(videoDeviceOutput)
        }
    }
    
    //Grabbing frames from camera
    func captureOutput (captureOutput: AVCaptureOutput, didOutputSampleBuffer sampleBuffer: CMSampleBufferRef, fromConnection connection: AVCaptureConnection) {
        print("frame received")
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let src_buff = CVPixelBufferGetBaseAddress(imageBuffer)
        let data: NSData = NSData(bytes: src_buff, length: bytesPerRow * height)
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
        videoStream.scheduleInRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        videoStream.open()
        videoStream.write(UnsafePointer<UInt8>(data.bytes), maxLength: data.length)
        
    }
    
    /***** Multipeer *****/
    @IBAction func sendVideo(sender: UIButton) {
        // connected peers
        // initialize NSOutputStream with peers
        if self.session.connectedPeers.count > 0 {
            do {
                videoStream = try self.session.startStreamWithName("video", toPeer: self.session.connectedPeers[0])
                addVideoOutput();
            } catch let error as NSError {
                let ac = UIAlertController(title: "Send error", message: error.localizedDescription, preferredStyle: .Alert)
                ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                presentViewController(ac, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func showBrowser(sender: UIButton) {
        // Show the browser view controller
        self.presentViewController(self.browser, animated: true, completion: nil)
    }
    
    func updateChat(text : String, fromPeer peerID: MCPeerID) {
        
    }
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    func browserViewController(browserViewController: MCBrowserViewController, shouldPresentNearbyPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) -> Bool {
        return true
    }
    
    /****** Session *****/
    func session(session: MCSession, didReceiveData data: NSData, fromPeer peerID: MCPeerID) {
        // Called when a peer sends an NSData to us
        
        // This needs to run on the main queue
        dispatch_async(dispatch_get_main_queue()) {
        }
        print("Did receive data packet")
    }
    func session(session: MCSession, peer peerID: MCPeerID, didChangeState state: MCSessionState) {
        switch state {
        case MCSessionState.Connected:
            print("Connected: \(peerID.displayName)")
            
        case MCSessionState.Connecting:
            print("Connecting: \(peerID.displayName)")
            
        case MCSessionState.NotConnected:
            print("Not Connected: \(peerID.displayName)")
        }
        print("Session Changed State")
    }
    func session(session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, withProgress progress: NSProgress) {
        print("Did start receiving resource")
    }
    func session(session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, atURL localURL: NSURL, withError error: NSError?) {
        print("Did finish receiving resource")
    }
    func session(session: MCSession, didReceiveStream stream: NSInputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        // Assuming a stream of UInt8's
        var buffer = [UInt8](count: 8, repeatedValue: 0)
        
        stream.open()
        print("Are we working")
        // Read a single byte
        if stream.hasBytesAvailable {
            let result: Int = stream.read(&buffer, maxLength: buffer.count)
            print("result: \(result)")
        }
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didDropSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        
        print("frame dropped")
    }
    
}
