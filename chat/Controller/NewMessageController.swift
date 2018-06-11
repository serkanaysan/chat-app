//
//  NewMessageController.swift
//  chat
//
//  Created by Serkan Aysan on 07/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

class NewMessageController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    private let reuseIdentifier = "Cell"
    private var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupColletionviewSettings()
        
        setupNavigation()
        
        fetchUser()
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
    }
    
    func fetchUser() {
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String : AnyObject] {
                let user = User()
                user.id = snapshot.key
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                
                DispatchQueue.main.async {
                    self.collectionView?.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return users.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UserCell
        
        let user = users[indexPath.row]
        cell.nameLabel.text = user.name
        cell.detailLabel.text = user.email
        
        if let profileImageUrl = user.profileImageUrl {
            cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: 68)
    }
    
    var messagesController: MessagesController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dismiss(animated: true) {
            let user = self.users[indexPath.item]
            self.messagesController?.showChatControllerForUser(user: user)
        }
    }
}
