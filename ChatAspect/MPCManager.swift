//
//  MPCManager.swift
//  ChatAspect
//
//  Created by Pasquale Spisto on 27/04/2018.
//  Copyright © 2018 pasp_development. All rights reserved.
//

import UIKit
import MultipeerConnectivity

protocol MPCManagerDelegate {
   func mpcManager(_ connectedPeers: [MCPeerID], didDisconnected peer: MCPeerID)
   func mpcManager(_ connectedPeers: [MCPeerID], didConnected peer: MCPeerID)
}

public struct ChatMessage: Codable {
   public var message: [String: String]
   public var sendTime: Date
}


class MPCManager: NSObject {
   
   
   public static let shared = MPCManager()
   
   var delegate: MPCManagerDelegate?
   
   public let notificatioName = NSNotification.Name("receiverDataFromPeer")
   /* MARK: - Service Type Name
    *
    * Follow 2 essential rules:
    *   1. It mustn't be longer than 15 characters;
    *   2. It can only contain lowercase ASCII characters, numbers and hyphen.
    */
   public let serviceName: String = "chat-thesis"
   
   
   public var myPeer: MCPeerID!
   public var mcSession: MCSession!
   public var advertiser: MCAdvertiserAssistant!
   public var browserSession: MCBrowserViewController!
   
   public var timeConnectionPeers: [String: Date] = [:]
   
   
   
   override private init() {
      super.init()
      
      setupConnectivity()
   }
   
   deinit {
      mcSession.disconnect()
   }
   
   
   private func setupConnectivity() -> Void {
      myPeer = MCPeerID(displayName: UIDevice.current.name)
      
      
      
      /* When we initialize a session we can chose di type of encryption.
       * PAY ATTENSTION: Some problems of this framewors come from the encryptio, so use it
       *                 only if you really need.
       */
      //        mcSession = MCSession(peer: myPeer, securityIdentity: nil, encryptionPreference: .none)
      mcSession = MCSession(peer: myPeer)
      mcSession.delegate = self
      
      
      
      // MARK: - Initialization of default browser for this session
      browserSession = MCBrowserViewController(serviceType: serviceName, session: mcSession)
      browserSession.delegate = self
      
      advertiser = MCAdvertiserAssistant(serviceType: serviceName, discoveryInfo: nil, session: mcSession)
   }
   
   public func startAdvertising() -> Void {
      advertiser.start()
   }
   
   public func stopAdvertising() -> Void {
      advertiser.start()
   }
   
   public func joinChat(current viewController: UIViewController) -> Void {
      viewController.present(browserSession, animated: true, completion: nil)
   }
   
   public func sendMessage(sendObj: ChatMessage) {
      if mcSession.connectedPeers.count > 0 {
         
         do {
            let jsonToSend = try JSONEncoder().encode(sendObj)
            try mcSession.send(jsonToSend, toPeers: mcSession.connectedPeers, with: .reliable)
         } catch {
            print(error.localizedDescription)
         }
      } else {
         print("There aren't any peers connected!")
      }
   }
   
   public func closeConnection() {
      mcSession.disconnect()
   }
}



extension MPCManager: MCSessionDelegate {
   
   // MARK: - MC Session Delegate Function
   
   func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
      
      switch state {
      case .connected:
         delegate?.mpcManager(session.connectedPeers, didConnected: peerID)
         print("\(peerID) is connected")
         break
      case .connecting:
         print("\(peerID) is connecting")
         break
      case .notConnected:
         delegate?.mpcManager(session.connectedPeers, didDisconnected: peerID)
         print("\(peerID) is not connected")
         break
      default:
         fatalError()
      }
   }
   
   func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
      let dictionaryMessage: [String : AnyObject] = ["data" : data as AnyObject, "fromPeer" : peerID]
      
      /* MARK: - Message Recieved Notification
       *
       * After receiced data from an other peer it must be notified that in order to call the right metod of
       * that the chat viewController that will show the message in the chat.
       */
      NotificationCenter.default.post(name: notificatioName, object: dictionaryMessage)
   }
   
   func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
      
   }
   
   func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
      
   }
   
   func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
      
   }
}



extension MPCManager: MCBrowserViewControllerDelegate {
   
   // MARK: - MC Browser Delegate Function
   
   func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {
      browserViewController.dismiss(animated: true, completion: nil)
   }
   
   func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {
      browserViewController.dismiss(animated: true, completion: nil)
   }
}

















