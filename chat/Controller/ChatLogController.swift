//
//  ChatLogController.swift
//  chat
//
//  Created by Serkan Aysan on 09/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var user: User? {
        didSet {
            if let usr = user {
                setupTitleViewWithUser(user: usr)
            }
            observeMessages()
        }
    }
    
    private func setupTitleViewWithUser(user: User) {
        let titleView: UIView = {
            let view = UIView()
            view.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let partnerProfilePhoto: UIImageView = {
            let image = UIImageView()
            if let profilePhoto = user.profileImageUrl {
                image.loadImageUsingCacheWithUrlString(urlString: profilePhoto)
            }
            image.contentMode = .scaleAspectFill
            image.layer.cornerRadius = 18
            image.clipsToBounds = true
            image.translatesAutoresizingMaskIntoConstraints = false
            return image
        }()
        
        let nameLabel: UILabel = {
            let label = UILabel()
            label.text = user.name
            label.font = UIFont.boldSystemFont(ofSize: 16)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        let detailLabel: UILabel = {
            let label = UILabel()
            label.text = "online"
            label.textColor = .lightGray
            label.font = UIFont.systemFont(ofSize: 12)
            label.translatesAutoresizingMaskIntoConstraints = false
            return label
        }()
        
        titleView.heightAnchor.constraint(equalToConstant: 38).isActive = true
        
        titleView.addSubview(partnerProfilePhoto)
        titleView.addSubview(nameLabel)
        titleView.addSubview(detailLabel)
        
        partnerProfilePhoto.leftAnchor.constraint(equalTo: titleView.leftAnchor).isActive = true
        partnerProfilePhoto.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        partnerProfilePhoto.widthAnchor.constraint(equalToConstant: 36).isActive = true
        partnerProfilePhoto.heightAnchor.constraint(equalToConstant: 36).isActive = true
        
        nameLabel.leftAnchor.constraint(equalTo: partnerProfilePhoto.rightAnchor, constant: 8).isActive = true
        nameLabel.topAnchor.constraint(equalTo: titleView.topAnchor, constant: 2).isActive = true
        
        detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        detailLabel.leftAnchor.constraint(equalTo: partnerProfilePhoto.rightAnchor, constant: 8).isActive = true
        
        navigationItem.titleView = titleView
        
    }
    
    var indexForTheLast: IndexPath?
    var messages = [Message]()
    
    func observeMessages() {
        guard let uid = Auth.auth().currentUser?.uid, let toId = user?.id else {
            return
        }
        
        let userMessageRef = Database.database().reference().child("user-messages").child(uid).child(toId)
        userMessageRef.observe(.childAdded, with: { (snapshot) in
            let messageId = snapshot.key
            let messageRef = Database.database().reference().child("messages").child(messageId)
            messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let dictionary = snapshot.value as? [String:AnyObject] else {
                    return
                }
                
                let message = Message()
                message.setValuesForKeys(dictionary)
                
                self.messages.append(message)
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                    let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: false)
                }
                
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private var reuseIdentifier = "cellId"
    
    lazy var inputTextField: UITextField = {
        let text = UITextField()
        text.placeholder = "Enter message..."
        text.returnKeyType = .send
        text.delegate = self
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColletionviewSettings()
        
        setupKeyboardObserves()
    }
    
    func setupColletionviewSettings() {
        collectionView?.backgroundColor = .white
        
        collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        collectionView?.keyboardDismissMode = .interactive
    }
    
    lazy var inputContainerView: UIView = {
        let containerView = UIView()
        containerView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 50)
        containerView.backgroundColor = .white
        
        let plusButton = UIButton(type: .system)
        plusButton.setTitle("Add", for: .normal)
        plusButton.translatesAutoresizingMaskIntoConstraints = false
        plusButton.addTarget(self, action: #selector(handleAdd), for: .touchUpInside)
        
        containerView.addSubview(plusButton)
        
        plusButton.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        plusButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        plusButton.widthAnchor.constraint(equalToConstant: 44).isActive = true
        plusButton.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        let sendButton = UIButton(type: .system)
        sendButton.setTitle("Send", for: .normal)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        containerView.addSubview(sendButton)
        
        sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
        sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.addSubview(self.inputTextField)
        
        self.inputTextField.leftAnchor.constraint(equalTo: plusButton.rightAnchor).isActive = true
        self.inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        self.inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
        self.inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        let seperatorLineView = UIView()
        seperatorLineView.backgroundColor = UIColor.init(r: 220, g: 220, b: 220)
        seperatorLineView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(seperatorLineView)
        
        seperatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        seperatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        seperatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        seperatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        return containerView
    }()
    
    override var inputAccessoryView: UIView? {
        get {
            return inputContainerView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }  

    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupKeyboardObserves() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        
        
        //NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func handleKeyboardDidShow() {
        if messages.count > 0 {
            let indexPath = IndexPath(row: messages.count-1, section: 0)
            collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    @objc func handleKeyboardWillShow(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double) {
                containerViewBottomAnchor?.constant = -keyboardSize.height
                
                UIView.animate(withDuration: keyboardDuration, animations: {
                    self.view.layoutIfNeeded()
                })
            }
        }
    }
    
    @objc func handleKeyboardWillHide(notification: Notification) {
        if let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double) {
            containerViewBottomAnchor?.constant = 0
            
            UIView.animate(withDuration: keyboardDuration, animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
    
    var containerViewBottomAnchor: NSLayoutConstraint?
    
    @objc func handleAdd() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { action in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Photo & Video Library", style: .default, handler: { action in
            let imagePickerController = UIImagePickerController()
            imagePickerController.allowsEditing = true
            imagePickerController.delegate = self
            self.present(imagePickerController, animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        }
        else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            uploadFirebaseStorageUsingImage(image: selectedImage)
        }
        
        dismiss(animated: true, completion: nil)

    }
    
    private func uploadFirebaseStorageUsingImage(image: UIImage) {
        let imageName = NSUUID().uuidString
        let ref = Storage.storage().reference().child("message_images").child(imageName)
        
        if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
            ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                if error != nil {
                    print(error!)
                    return
                }
                
                if let imageUrl = metadata?.downloadURL()?.absoluteString {
                    self.sendMessageWithImageUrl(imageUrl: imageUrl, image: image)
                }
                
            })
        }
    }
    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        indexForTheLast = indexPath
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ChatMessageCell
        let message = messages[indexPath.item]
        
        cell.chatLogController = self
        setupCell(cell: cell, message: message)
        
        return cell
    }
    
    private func setupCell(cell: ChatMessageCell, message: Message) {
        
        cell.textView.text = message.text
        
        if message.fromId == Auth.auth().currentUser?.uid {
            cell.bubbleView.backgroundColor = UIColor.init(r: 0, g: 137, b: 249)
            cell.textView.textColor = .white
            cell.bubbleRightAnchor?.isActive = true
            cell.bubbleLeftAnchor?.isActive = false
        }
        else {
            cell.bubbleView.backgroundColor = UIColor.init(r: 240, g: 240, b: 240)
            cell.textView.textColor = .black
            cell.bubbleRightAnchor?.isActive = false
            cell.bubbleLeftAnchor?.isActive = true
        }
        
        if let messageImageUrl = message.imageUrl {
            cell.messageImageView.loadImageUsingCacheWithUrlString(urlString: messageImageUrl)
            cell.messageImageView.isHidden = false
            cell.bubbleView.backgroundColor = .clear
            cell.textView.isHidden = true
        }
        else {
            cell.messageImageView.isHidden = true
            cell.textView.isHidden = false
        }
        
        if let text = message.text {
            cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: text).width + 32
        } else if message.imageUrl != nil {
            cell.bubbleWidthAnchor?.constant = 200
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var height: CGFloat = 80
        
        let message = messages[indexPath.item]
        if let text = message.text {
            height = estimateFrameForText(text: text).height + 20
        } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue  {
            height = CGFloat(imageHeight / imageWidth * 200)
        }
        
        return CGSize(width: view.frame.width, height: height)
    }
    
    private func estimateFrameForText(text: String) -> CGRect {
        let size = CGSize(width: 200, height: 1000)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16)], context: nil)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    @objc func handleSend() {
        let properties = ["text" : inputTextField.text!] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithImageUrl(imageUrl: String, image: UIImage) {
        let properties = ["imageUrl" : imageUrl, "imageWidth" : image.size.width, "imageHeight" : image.size.height] as [String : AnyObject]
        sendMessageWithProperties(properties: properties)
    }
    
    private func sendMessageWithProperties(properties: [String:AnyObject]) {
        let ref = Database.database().reference().child("messages")
        let childRef = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timestamp: NSNumber = Int(NSDate().timeIntervalSince1970) as NSNumber
        
        var values = ["toId" : toId, "fromId" : fromId, "timestamp" : timestamp] as [String : Any]
        
        properties.forEach { (arg: (key: String, value: AnyObject)) in
            
            let (k1, v1) = arg
            values[k1] = v1
        }
        
        childRef.updateChildValues(values) { (error, ref) in
            if error != nil {
                print(error!)
                return
            }
            
            self.inputTextField.text = nil
            
            let userMessagesRef = Database.database().reference().child("user-messages").child(fromId).child(toId)
            let messageId = childRef.key
            userMessagesRef.updateChildValues([messageId:1])
            
            let recipientUserMessageRef = Database.database().reference().child("user-messages").child(toId).child(fromId )
            recipientUserMessageRef.updateChildValues([messageId:1])
        }
    }
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = .red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = .black
            blackBackgroundView?.alpha = 0
            self.inputContainerView.alpha = 0
            
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                self.blackBackgroundView?.alpha = 1
                
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                
            })
        }
        
    }
    
    @objc func handleZoomOut(tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view as? UIImageView {
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                self.inputContainerView.alpha = 1
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
    
}
