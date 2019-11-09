//
//  ViewController.swift
//  ChatAspect
//
//  Created by Pasquale Spisto on 27/04/2018.
//  Copyright © 2018 pasp_development. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
   
   private let mcManager = MPCManager.shared
   
   private var messagesArray: [Dictionary<String, String>] = []
   
   private var isVisible = false
   
   
   @IBOutlet weak var barItem: UINavigationItem!
   @IBOutlet weak var chatCollectionView: UICollectionView!
   @IBOutlet weak var stopButton: UIBarButtonItem!
   
   
   private let inputTextContainer: UIView = {
      let view = UIView()
      view.backgroundColor = .lightGray
      return view
   }()
   
   private let backTFView: UIView = {
      let view = UIView()
      view.backgroundColor = .white
      view.layer.cornerRadius = 16
      return view
   }()
   
   private let chatTextView: UITextView = {
      let textView = UITextView()
      textView.font = UIFont.systemFont(ofSize: 16)
      textView.backgroundColor = .clear
      return textView
   }()
   
   private var previousRect = CGRect.zero
   
   private let sendButton: UIButton = {
      let button = UIButton()
      let image = UIImage(named: "SendBtn")
      let imageView = UIImageView(image: image)
      
      button.backgroundColor = .black
      button.setImage(image, for: .normal)
      button.imageView?.contentMode = .scaleAspectFit
      button.layer.cornerRadius = 16
      
      return button
   }()
   
   private var bottomConstraint: NSLayoutConstraint!
   private var heightCostraint: NSLayoutConstraint!
   
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      chatCollectionView.delegate = self
      chatCollectionView.dataSource = self
      
      chatTextView.delegate = self
      
      mcManager.delegate = self
      
      stopButton.isEnabled = false
      
      setTopBar()
      setupContainer()
      heightCostraint = NSLayoutConstraint(item: inputTextContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 48)
      inputTextContainer.addConstraint(heightCostraint)
      
      
      setupContainerComponents()
      bottomConstraint = NSLayoutConstraint(item: inputTextContainer, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
      view.addConstraint(bottomConstraint!)
      
      // MARK: - Set Observer for the slide up of the keybord
      NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
      
      NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
      
      NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedData), name: mcManager.notificatioName, object: nil)
      
      let tapGest = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
      view.addGestureRecognizer(tapGest)
   }
   
   private func setTopBar() {
      let logoBarImage = UIImage(named: "Logo")
      let logoImgView = UIImageView(image: logoBarImage)
      logoImgView.frame = CGRect(x: .zero, y: .zero, width: 34.0, height: 34.0)
      logoImgView.contentMode = .scaleAspectFit
      
      self.barItem.titleView = logoImgView
      self.navigationController?.navigationBar.barTintColor = .black
   }
   
   private func setupContainer() {
      view.addSubview(inputTextContainer)
      inputTextContainer.translatesAutoresizingMaskIntoConstraints = false
      inputTextContainer.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
   }
   
   /// Todo: Improve conteiner layout and make it adaptable to iOS/iPadOS devices
   
   private func setupContainerComponents() {
      inputTextContainer.addSubview(backTFView)
      
      backTFView.translatesAutoresizingMaskIntoConstraints = false
      
      backTFView.topAnchor.constraint(equalTo: inputTextContainer.topAnchor, constant: 8).isActive = true
      backTFView.bottomAnchor.constraint(equalTo: inputTextContainer.bottomAnchor, constant: -8).isActive = true
      backTFView.leftAnchor.constraint(equalTo: inputTextContainer.leftAnchor, constant: 10).isActive = true
      backTFView.rightAnchor.constraint(equalTo: inputTextContainer.rightAnchor, constant: -60).isActive = true // avevo -100
      
      backTFView.addSubview(chatTextView)
      
      chatTextView.translatesAutoresizingMaskIntoConstraints = false
      
      chatTextView.topAnchor.constraint(equalTo: backTFView.topAnchor).isActive = true
      chatTextView.bottomAnchor.constraint(equalTo: backTFView.bottomAnchor).isActive = true
      chatTextView.leftAnchor.constraint(equalTo: backTFView.leftAnchor, constant: 8).isActive = true
      chatTextView.rightAnchor.constraint(equalTo: backTFView.rightAnchor, constant: -8).isActive = true
      
      
      inputTextContainer.addSubview(sendButton)
      
      sendButton.translatesAutoresizingMaskIntoConstraints = false
      
      sendButton.topAnchor.constraint(equalTo: inputTextContainer.topAnchor, constant: 8).isActive = true
      sendButton.bottomAnchor.constraint(equalTo: inputTextContainer.bottomAnchor, constant: -8).isActive = true
      sendButton.leftAnchor.constraint(equalTo: backTFView.rightAnchor, constant: 10).isActive = true
      sendButton.rightAnchor.constraint(equalTo: inputTextContainer.rightAnchor, constant: -15).isActive = true
      
      
      sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
   }
   
   @objc private func handleKeyboardNotification(notification: NSNotification) {
      
      if let userInfo = notification.userInfo {
         let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
         
         let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
         
         bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame.height : 0
         
         chatCollectionView.contentInset = isKeyboardShowing ? UIEdgeInsets(top: 8, left: 0, bottom: keyboardFrame.height + inputTextContainer.frame.height + 8, right: 0) : UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
         //      chatCollectionView.contentInset = isKeyboardShowing ? UIEdgeInsets(top: 8, left: 0, bottom: 1000, right: 0) : UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
         
         UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
            self.view.layoutIfNeeded()
         }, completion: { (completed) in
            if isKeyboardShowing {
               if self.messagesArray.count > 0 {
                  let indexPath = IndexPath(item: self.messagesArray.count - 1, section: 0)
                  //            let indexPath = self.chatCollectionView.indexPathsForVisibleItems.last
                  print(self.messagesArray.count)
                  self.chatCollectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
               }
            }
         })
      }
   }
   
   @objc private func handleReceivedData(notification: NSNotification) {
      let receivedData = notification.object as! Dictionary<String, Any>
      
      let data = receivedData["data"] as! Data
      let fromPeer = receivedData["fromPeer"] as! MCPeerID
      
      var jsonData: ChatMessage? = nil
      
      do {
         jsonData = try JSONDecoder().decode(ChatMessage.self, from: data)
      }catch {
         print(error.localizedDescription)
      }
      
      let message = jsonData?.message
      let messageDictionary: [String: String] = ["sender": fromPeer.displayName, "message": message!["message"]!]
      
      messagesArray.append(messageDictionary)
      
      
      let messageDelay = Date().timeIntervalSince((jsonData?.sendTime)!)
      
      print("Message Delay in millisecon: ------------------> \(messageDelay)")
      
      
      DispatchQueue.main.async {
         self.updateChatCollectionView()
      }
   }
   
   
   private func updateChatCollectionView() {
      chatCollectionView.insertItems(at: [IndexPath(item: messagesArray.count - 1, section: 0)])
      
      if chatCollectionView.contentSize.height > chatCollectionView.frame.size.height {
         chatCollectionView.scrollToItem(at: IndexPath(index: messagesArray.count - 1) , at: .bottom, animated: true)
      }
   }
   
   @objc private func sendMessage(_ sender: UIButton) {
      
      if chatTextView.text != "" {
         let message: [String: String] = ["message": chatTextView.text!]
         let chatMessage = ChatMessage(message: message, sendTime: Date())
         
         mcManager.sendMessage(sendObj: chatMessage)
         
         let dictionary: [String: String] = ["sender": "self", "message": chatTextView.text!]
         messagesArray.append(dictionary)
         
         updateChatCollectionView()
         
         chatTextView.text = ""
      }
   }
   
   private func extimateBubbleTextSize(text: String, fontSize: CGFloat) -> CGRect {
      let size = CGSize(width: 280, height: 1000)
      let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      
      let frame = NSString(string: text).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)], context: nil)
      
      return frame
   }
   
   
   @IBAction func shareConnectivity(_ sender: UIBarButtonItem) {
      let actionSheet = UIAlertController(title: "Chat P2P", message: "Change your vibility status or invite your friends to join the chat!", preferredStyle: .actionSheet)
      
      actionSheet.addAction(UIAlertAction(title: self.isVisible ? "Invisible" : "Visible", style: .default, handler: { (action: UIAlertAction) in
         if self.isVisible {
            self.mcManager.stopAdvertising()
            self.isVisible = false
         } else {
            self.mcManager.startAdvertising()
            self.isVisible = true
         }
      }))
      
      actionSheet.addAction(UIAlertAction(title: "Invite Peer", style: .default, handler: { (action: UIAlertAction) in
         self.mcManager.joinChat(current: self)
      }))
      
      actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
      self.present(actionSheet, animated: true, completion: nil)
   }
   
   @IBAction func stopChat(_ sender: UIBarButtonItem) {
      mcManager.closeConnection()
      
      messagesArray = []
      chatCollectionView.reloadData()
      
      DispatchQueue.main.async {
         self.stopButton.isEnabled = false
      }
   }
}



extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return messagesArray.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "messageCell", for: indexPath) as! MessagesCell
      
      let currentMessage = messagesArray[indexPath.row]
      
      cell.textView.text = currentMessage["message"]
      
      let size = CGSize(width: 280, height: 1000)
      let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      
      let extimatedFrame = NSString(string: currentMessage["message"]!).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
      
      if currentMessage["sender"] == "self" {
         cell.bubbleView.frame = CGRect(x: view.frame.width - extimatedFrame.width - 16 - 8, y: 0, width: extimatedFrame.width + 16 + 8, height: extimatedFrame.height + 20)
         cell.bubbleView.backgroundColor = .blue
         cell.textView.frame = CGRect(x: (view.frame.width - extimatedFrame.width) - 16, y: 0, width: extimatedFrame.width + 16, height: extimatedFrame.height + 20)
         cell.textView.textColor = .white
         
      } else {
         cell.nameLabel.text = currentMessage["sender"]
         
         let labelFrame = extimateBubbleTextSize(text: currentMessage["sender"]!, fontSize: 14)
         
         cell.bubbleView.frame = CGRect(x: 0, y: 0, width: max(extimatedFrame.width, labelFrame.width) + 16 + 8, height: extimatedFrame.height + 20 + labelFrame.height + 5)
         cell.nameLabel.frame = CGRect(x: 8, y: 5, width: min(labelFrame.width, 280) + 16 + 8, height: labelFrame.height)
         cell.textView.frame = CGRect(x: 8, y: cell.nameLabel.frame.height, width: extimatedFrame.width + 16, height: extimatedFrame.height + 15)
      }
      
      return cell
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
      return UIEdgeInsets(top: 8, left: 0, bottom: 0, right: 0)
   }
   
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      
      let message = messagesArray[indexPath.row]
      let size = CGSize(width: 280, height: 1000)
      let option = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
      
      let extimatedFrame = NSString(string: message["message"]!).boundingRect(with: size, options: option, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)], context: nil)
      
      if message["sender"] == "self" {
         return CGSize(width: view.frame.width, height: extimatedFrame.height + 20)
      }
      
      let nameFrame = extimateBubbleTextSize(text: message["sender"]!, fontSize: 14)
      
      return CGSize(width: view.frame.width, height: extimatedFrame.height + 22 + nameFrame.height + 4)
   }
   
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      closeKeyboard()
   }
   
   @objc private func closeKeyboard() {
      chatTextView.endEditing(false)
   }
}



extension ViewController: MPCManagerDelegate {
   func mpcManager(_ connectedPeers: [MCPeerID], didDisconnected peer: MCPeerID) {
      
      if connectedPeers.count == 0 {
         DispatchQueue.main.async{
            self.stopButton.isEnabled = false
         }
      }
      
      DispatchQueue.main.async {
         let peerStatusLabel = self.setNewStatusLabel()
         
         self.view.addSubview(peerStatusLabel)
         
         peerStatusLabel.text = "\(peer.displayName) is disconnected"
         peerStatusLabel.frame.origin = CGPoint(x: self.view.center.x - (peerStatusLabel.frame.width / 2), y: 0)
         
         UIView.animate(withDuration: 1, animations: {
            peerStatusLabel.frame.origin.y = self.navigationController!.navigationBar.frame.maxY + 4
         }) { (completed) in
            UIView.animate(withDuration: 1, delay: 2.0, animations: {
               peerStatusLabel.frame.origin.y = 0
            })
         }
      }
   }
   
   func mpcManager(_ connectedPeers: [MCPeerID], didConnected peer: MCPeerID) {
      
      
      if connectedPeers.count > 0 {
         DispatchQueue.main.async{
            self.stopButton.isEnabled = true
         }
      }
      
      DispatchQueue.main.async {
         let peerStatusLabel = self.setNewStatusLabel()
         
         self.view.addSubview(peerStatusLabel)
         
         peerStatusLabel.text = "\(peer.displayName) is connected"
         peerStatusLabel.frame.origin = CGPoint(x: self.view.center.x - (peerStatusLabel.frame.width / 2), y: 0)
         
         UIView.animate(withDuration: 1, animations: {
            peerStatusLabel.frame.origin.y = self.navigationController!.navigationBar.frame.maxY + 4
         }) { (completed) in
            UIView.animate(withDuration: 1, delay: 2.0, animations: {
               peerStatusLabel.frame.origin.y = 0
            })
         }
      }
      
   }
   
   private func setNewStatusLabel() -> UILabel {
      let label = UILabel()
      label.textAlignment = .center
      label.font = UIFont.systemFont(ofSize: 11)
      label.backgroundColor = UIColor(white: 0.8, alpha: 1)
      label.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
      return label
   }
}


extension ViewController: UITextViewDelegate {
   func textViewDidChange(_ textView: UITextView) {
      let endPosition = textView.endOfDocument
      let currentRect = textView.caretRect(for: endPosition)
      
      if currentRect.origin.y > previousRect.origin.y {
         print("va a capo e si allarga la textview per l'iserimento")
         
         //      funziona ma si deve sistemare
         //      DispatchQueue.main.async {
         //        self.heightCostraint.constant = 48 * 2
         //        UIView.animate(withDuration: 0.3) {
         //          self.view.layoutIfNeeded()
         //        }
         //      }
         
      } else {
         //      qui si può gestire il caso in cui le righe del messaggio diminuiscono
      }
      
      previousRect = currentRect
   }
}



extension UINavigationController {
   override open var preferredStatusBarStyle: UIStatusBarStyle {
      return topViewController?.preferredStatusBarStyle ?? .default
   }
}
