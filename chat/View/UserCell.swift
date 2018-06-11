//
//  UserCell.swift
//  chat
//
//  Created by Serkan Aysan on 10/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

class UserCell: BaseCell {
    
    var message: Message? {
        didSet {
            setupNameAndProfileImage()
            
            detailLabel.text = message?.text
            
            if let second = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: second)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
            }
        }
    }
    
    func setupNameAndProfileImage() {
        if let Id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(Id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String : AnyObject] {
                    self.nameLabel.text = dictionary["name"] as? String
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
                    }
                }
            }, withCancel: nil)
        }
    }
    
    var nameLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var detailLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .lightGray
        return label
    }()
    
    var profileImageView: UIImageView = {
        var image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    var timeLabel: UILabel = {
        var label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.lightGray
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    var dividerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        backgroundColor = .white
        
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(detailLabel)
        addSubview(timeLabel)
        addSubview(dividerView)
        
        setupProfileImageView()
        setupNameLabel()
        setupDetailLabel()
        setupTimeLabel()
        setupDividerView()
        
    }
    
    func setupProfileImageView() {
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 12).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48 ).isActive = true
    }
    
    func setupNameLabel() {
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        nameLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -84).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 26).isActive = true
    }
    
    func setupDetailLabel() {
        detailLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        detailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor).isActive = true
        detailLabel.widthAnchor.constraint(equalTo: self.widthAnchor, constant: -84).isActive = true
        detailLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func setupTimeLabel() {
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        timeLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: nameLabel.heightAnchor).isActive = true
    }
    
    func setupDividerView() {
        dividerView.centerYAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        dividerView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 12).isActive = true
        dividerView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        dividerView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
}

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        backgroundColor = .blue
    }
}

