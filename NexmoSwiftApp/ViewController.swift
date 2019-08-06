//
//  ViewController.swift
//  quickstart_swift
//
//  Copyright © 2018 Nexmo. All rights reserved.
//

import UIKit
import AVFoundation
import NexmoClient

class ViewController: UIViewController, UITextFieldDelegate, NXMClientDelegate, NXMCallDelegate {
    
    @IBOutlet weak var aaa: UIButton!
    @IBOutlet weak var first: UILabel!
    @IBOutlet weak var second: UILabel!
    
//    @IBOutlet weak var loginButton: UIButton!
//    @IBOutlet weak var logoutButton: UIButton!
//    @IBOutlet weak var callButton: UIButton!
//    @IBOutlet weak var hangupButton: UIButton!
//    @IBOutlet weak var speakerButton: UIButton!
//    @IBOutlet weak var muteButton: UIButton!
//    @IBOutlet weak var numberInput: UITextField!
//    @IBOutlet weak var statusLabel: UILabel!
    
    public static var nexmoClient:NXMClient  = NXMClient(token: "")! // NXMClient is the SDK entry with token
    var currentCall:NXMCall?    // NXMCall is the SDK call object
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
      //  self.numberInput.delegate = self
        // set the nexmoClient
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    
    // MARK - buttons actions
    
    @IBAction func onLoginPressed(_ sender: Any) {
     //   self.loginButton.isEnabled = false
        
        ViewController.nexmoClient = NXMClient(token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTU2NTAwNzYyMywibmJmIjoxNTY1MDA3NjIzLCJleHAiOjE1NjUwMzc2NTMsImp0aSI6MTU2NTAwNzY1MzUxMiwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiL3YxL3VzZXJzLyoqIjp7fSwiL3YxL2NvbnZlcnNhdGlvbnMvKioiOnt9LCIvdjEvc2Vzc2lvbnMvKioiOnt9LCIvdjEvZGV2aWNlcy8qKiI6e30sIi92MS9pbWFnZS8qKiI6e30sIi92My9tZWRpYS8qKiI6e30sIi92MS9hcHBsaWNhdGlvbnMvKioiOnt9LCIvdjEvcHVzaC8qKiI6e30sIi92MS9rbm9ja2luZy8qKiI6e30sIi92MS9jYWxscy8qKiI6e30sIi9iZXRhMi8qKiI6e30sIi8qKiI6e319fSwic3ViIjoidGVzdHVzZXI0In0.aQ--bpA5ibts9uubqhlcAyJUEf1BvN4h6jktFTcTfTacuTsBOJJV_bho-d1sVyYIDtMhrXgJ8YkY6DeOJZcJu5cm1wDOmgFaS60hN3UyCvokXBqqD5IMME8fgncpTVidrzv8dVynvOKxLyQDi3Jxzp9PthaMGLE86vqCofZasLDXZ_RRKwdkiysXSfPEASyhJ1kmWCrwVhNuGXSpkJBAl9YQgXAuFxIao1K7Yn_kyiTPRtxGWR8jrQz4S6JpJ6qjIvidzJslQN55fHZe0WijItoHU3aK61e-7Av9rAb1pQ_aSav2Yd0L_Wq70CoFbTq2KB7SlLRTQQVSwk4ga3fWqw")!
        ViewController.nexmoClient.setDelegate(self)
        ViewController.nexmoClient.login()
        
        NXMLogger.setLogLevel(NXMLoggerLevel.verbose)
    }
    
    @IBAction func onLogoutPressed(_ sender: Any) {
     //   self.logoutButton.isEnabled = false
        
    }
    
    @IBAction func onCallPressed(_ sender: Any) {
   //     self.callButton.isEnabled = false
        
     //   let number = self.numberInput.text!
        ViewController.nexmoClient.call(["testuser5"], callHandler: .inApp, delegate: self) {
            (error, call) in
            self.currentCall = call // update currentCall with the new call
            
            // update UI
            DispatchQueue.main.async {
                self.updateCallButtons(true);
            }
        }
    }
    
    @IBAction func onHangupPressed(_ sender: Any) {
       // self.hangupButton.isEnabled = false
        
    }
    
    @IBAction func onMutePressed(_ sender: Any) {
        
    }
    
    @IBAction func onSpeakerPressed(_ sender: Any) {
       // if (self.speakerButton.isSelected) {
//            try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.none)
//            self.speakerButton.isSelected = false
//            return
//        }
        try? AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSession.PortOverride.speaker)
    //    self.speakerButton.isSelected = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // This method is being called when there is an incoming call
    func incomingCall(_ call: NXMCall) {
        self.currentCall = call // update currentCall
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Incoming call", message: "", preferredStyle: UIAlertController.Style.alert)
            
            alert.addAction(UIAlertAction(title: "Answer", style: .`default`, handler: { action in
                
                // answer call
                self.currentCall?.answer(self, completionHandler: { (error) in
                    DispatchQueue.main.async {
                        self.updateCallButtons(true);
               //         self.numberInput.text = (call.otherCallMembers[0] as! NXMCallMember).user.name
                    }
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Decline", style: .cancel, handler: { action in
                
                // decline call
                self.currentCall?.reject(completionHandler: { (error) in
                    
                })
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    // This method is being called when the status of the call changed
    func statusChanged(_ participant: NXMCallMember) {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.statusChanged(participant)
            }
            return
        }
        
      //  self.muteButton.isSelected = self.currentCall!.myCallMember.isMuted
        self.updateCallButtons(self.currentCall?.myCallMember.status != NXMCallMemberStatus.completed)
        
        self.first.text = String.init(format: "%@ %@", self.currentCall?.myCallMember.user.name ?? "", self.currentCall?.myCallMember.statusDescription ?? "");
        
        if (self.currentCall?.otherCallMembers.count ?? 0 > 0) {
            self.second.text = String.init(format: "%@ %@", (self.currentCall?.otherCallMembers[0] as! NXMCallMember).user.name , self.currentCall?.myCallMember.statusDescription ?? "");
        }
        
    }
    
    // This method is being called when there is a connectivity change
    func connectionStatusChanged(_ status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        if (!Thread.isMainThread) {
            DispatchQueue.main.async {
                self.connectionStatusChanged(status, reason: reason)
            }
        }
        
        switch status {
        case .connected:
       //     self.statusLabel.text = "connected"
            self.updateLoginButtons(false)
            
            let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
//            // Enable push notifications
//            ViewController.nexmoClient.enablePushNotifications(withDeviceToken: appDelegate.pushKitToken!,
//                                                               isPushKit: true,
//                                                               isSandbox: true) { (error) in
//            }
            
            break;
        case .disconnected:
         //   self.statusLabel.text = "disconnected"
            self.updateLoginButtons(true)
            break;
        case .connecting:
         //   self.statusLabel.text = "connecting"
            break;
        default:
            break;
        //    self.statusLabel.text = "unknown"
        }
    }
    
    // Mark: - update buttons
    
    
    func updateLoginButtons(_ isLoginEnabled:Bool) {
//        self.loginButton.isEnabled = isLoginEnabled
//        self.loginButton.isHidden = !isLoginEnabled
//
//        self.loginButton.isEnabled = !isLoginEnabled
//        self.logoutButton.isHidden = isLoginEnabled
    }
    
    func updateCallButtons(_ isCallStarted:Bool) {
//        self.callButton.isEnabled = !isCallStarted
//        self.callButton.isHidden = isCallStarted
//
//        self.hangupButton.isEnabled = isCallStarted
//        self.hangupButton.isHidden = !isCallStarted
    }
    
    func error(_ message: String?) {
        print(message ?? "")
    }
    
    func warning(_ message: String?) {
        print(message ?? "")
    }
    
    func info(_ message: String?) {
        print(message ?? "")
        
    }
    
    func debug(_ message: String?) {
        print(message ?? "")
        
    }
    
}



