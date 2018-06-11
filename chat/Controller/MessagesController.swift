//
//  ViewController.swift
//  chat
//
//  Created by Serkan Aysan on 07/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

class MessagesController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    private let reuseIdentifier = "Cell"
    var messages = [Message]()
    var messagesDictionary = [String:Message]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColletionviewSettings()
        
        setupNavigation()
        
        checkIfUserLoggedIn()
    }
    
    func setupColletionviewSettings() {
        collectionView?.backgroundColor = .white
        
        collectionView?.register(UserCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.alwaysBounceVertical = true
        
        let layout = collectionView?.collectionViewLayout as! UICollectionViewFlowLayout
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        collectionView?.collectionViewLayout = layout
    }
    
    func setupNavigation() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Message", style: .plain, target: self, action: #selector(handleNewMessage))
    }
    
    func observeUserMessages() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.childAdded, with: { (snapshot) in
            let userId = snapshot.key
            Database.database().reference().child("user-messages").child(uid).child(userId).observeSingleEvent(of: .childAdded, with: { (snapshot) in
                let messageId = snapshot.key
                self.fetchMessageWithMessageId(messageId: messageId )
            }, withCancel: nil)
        }, withCancel: nil)
    }
    
    private func fetchMessageWithMessageId(messageId: String) {
        let messageRef = Database.database().reference().child("messages").child(messageId)
        messageRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String:AnyObject] {
                let message = Message()
                message.setValuesForKeys(dictionary)
                if let chatPartnerId = message.chatPartnerId() {
                    self.messagesDictionary[chatPartnerId ] = message
                }
                
                self.attemptReloadOfCollectionView()
            }
        }, withCancel: nil)
    }
    
    @objc func attemptReloadOfCollectionView() {
        self.messages = Array(self.messagesDictionary.values)
        self.messages.sort(by: { (message1, message2) -> Bool in
            return message1.timestamp! .intValue > message2.timestamp!.intValue
        })
        
        self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleReloadCollectionView), userInfo: nil, repeats: false)
    }
    
    var timer: Timer?
    
    @objc func handleReloadCollectionView() {
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    func checkIfUserLoggedIn() {
        if Auth.auth().currentUser?.uid == nil {
            handleLogout()
        } else {
            fetchUserAndSetupNavBarTitle()
        }
    }
    
    func fetchUserAndSetupNavBarTitle () {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject] {
                
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupNavBarWithUser(user: user)
            }
            
        }, withCancel: nil)
    }
    
    func setupNavBarWithUser(user: User) {
        messages.removeAll()
        messagesDictionary.removeAll()
        collectionView?.reloadData()
        
        observeUserMessages()
        
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        /*let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        
        if let profileImageUrl = user.profileImageUrl {
            profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
        
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true*/
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = "Chat"//user.name
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        
        self.navigationItem.titleView = titleView
    }
    
    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        self.title = ""
        chatLogController.user = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func handleLogout(){
        do {
            try Auth.auth().signOut()
        }
        catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        loginController.messagesController = self
        present(loginController, animated: true, completion: nil)
        
    }
    
    @objc func handleNewMessage(){
        let newMessageController = NewMessageController(collectionViewLayout: UICollectionViewFlowLayout())
        newMessageController.messagesController = self
        let navController = UINavigationController(rootViewController: newMessageController)
        present(navController, animated: true, completion: nil)
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        
        let message = messages[indexPath.row]
        cell.message = message
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 68)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        
        let ref = Database.database().reference().child("users").child(chatPartnerId)
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            guard let dictionary = snapshot.value as? [String:AnyObject] else {
                return
            }
            
            let user = User()
            user.id = chatPartnerId
            user.setValuesForKeys(dictionary)
            self.showChatControllerForUser(user: user)
            
        }, withCancel: nil)
    }
    
    
        


}

