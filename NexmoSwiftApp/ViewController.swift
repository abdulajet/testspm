//
//  ViewController.swift
//  quickstart_swift
//
//  Copyright © 2018 Nexmo. All rights reserved.
//

import UIKit
import AVFoundation
import NexmoClient

class ViewController: UIViewController, UITextFieldDelegate, NXMClientDelegate, NXMCallDelegate, NXMLoggerDelegate {
    
    @IBOutlet weak var aaa: UIButton!
    
//    @IBOutlet weak var loginButton: UIButton!
//    @IBOutlet weak var logoutButton: UIButton!
//    @IBOutlet weak var callButton: UIButton!
//    @IBOutlet weak var hangupButton: UIButton!
//    @IBOutlet weak var speakerButton: UIButton!
//    @IBOutlet weak var muteButton: UIButton!
//    @IBOutlet weak var numberInput: UITextField!
//    @IBOutlet weak var statusLabel: UILabel!
    
    public static var nexmoClient:NXMClient  = NXMClient(token: "") // NXMClient is the SDK entry with token
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
        
        ViewController.nexmoClient = NXMClient(token: "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJJbHR1cyIsImlhdCI6MTU1MDA1OTYwNCwibmJmIjoxNTUwMDU5NjA0LCJleHAiOjE1NTAwODk2MzQsImp0aSI6MTU1MDA1OTYzNDI2MSwiYXBwbGljYXRpb25faWQiOiJmMWE1ZjZmYS03ZDc0LTRiOTctYmRmNC00ZWNhYWU4ZTg1MWUiLCJhY2wiOnsicGF0aHMiOnsiL3YxL3VzZXJzLyoqIjp7fSwiL3YxL2NvbnZlcnNhdGlvbnMvKioiOnt9LCIvdjEvc2Vzc2lvbnMvKioiOnt9LCIvdjEvZGV2aWNlcy8qKiI6e30sIi92MS9pbWFnZS8qKiI6e30sIi92My9tZWRpYS8qKiI6e30sIi92MS9hcHBsaWNhdGlvbnMvKioiOnt9LCIvdjEvcHVzaC8qKiI6e30sIi92MS9rbm9ja2luZy8qKiI6e30sIi92MS9jYWxscy8qKiI6e319fSwic3ViIjoidGVzdHVzZXIzIn0.Eyn4ymERCwahRz_pMeNjFwmNqr_BpBSI9nQo9YdG1kQlb1JBICkq_g94g1xow4oxod7-HFkQfJrRJYOr3A9dAGliMR3JThLM3wPq-VC1l0KiNjB5d2Y24iTeQoQCW8KSwZOJ-aEQGOtaOQ8BtCF70hkly9Oq0ANE3bojJQKxRHf9RBd9_HMohOUGYEdvsc_vXS6wgnX5EjYyLC8RGKO5luXm8GbeXLpRVkm871jt4jwRnt0yNDKGNofcygtuCqTQJI8HIZQpKSsfvwr_dR2tOjDLL3LtFEBeF4j1uEAkdCYHz8W3c8Ya2cOODARD9D6qTXkFpx0ROD-vzIyMJWuF6g")
        ViewController.nexmoClient.setLoggerDelegate(self)
        ViewController.nexmoClient.setDelegate(self)
        ViewController.nexmoClient.login()
    }
    
    @IBAction func onLogoutPressed(_ sender: Any) {
     //   self.logoutButton.isEnabled = false
        
    }
    
    @IBAction func onCallPressed(_ sender: Any) {
   //     self.callButton.isEnabled = false
        
     //   let number = self.numberInput.text!
        ViewController.nexmoClient.call(["972505597827"], callType: NXMCallType.server, delegate: self) {
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
                self.currentCall?.reject({ (error) in
                    
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



