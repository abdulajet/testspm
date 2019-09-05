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
    func client(_ client: NXMClient, didChange status: NXMConnectionStatus, reason: NXMConnectionStatusReason) {
        
    }
    
    func client(_ client: NXMClient, didReceiveError error: Error) {
        
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, with status: NXMCallMemberStatus) {
        
    }
    
    func call(_ call: NXMCall, didUpdate callMember: NXMCallMember, isMuted muted: Bool) {
        
    }
    
    func call(_ call: NXMCall, didReceive error: Error) {
        
    }
    
    
    
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
    
  //  public static var nexmoClient:NXMClient// NXMClient is the SDK entry with token
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

        NXMClient.shared.setDelegate(self)
        NXMClient.shared.login(withAuthToken: "")
        
        NXMLogger.setLogLevel(NXMLoggerLevel.verbose)
    }
    
    @IBAction func onLogoutPressed(_ sender: Any) {
     //   self.logoutButton.isEnabled = false
        
    }
    
    @IBAction func onCallPressed(_ sender: Any) {
   //     self.callButton.isEnabled = false
        
     //   let number = self.numberInput.text!
        NXMClient.shared.call("testuser5", callHandler: .inApp) {
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
                
                
                self.currentCall?.setDelegate(self);
                // answer call
                self.currentCall?.answer({ (error) in
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
            
        //    let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
            
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



