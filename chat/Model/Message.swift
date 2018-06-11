//
//  Message.swift
//  chat
//
//  Created by Serkan Aysan on 09/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    @objc var toId: String?
    @objc var fromId: String?
    @objc var text: String?
    @objc var timestamp: NSNumber?
    @objc var imageUrl: String?
    @objc var imageWidth: NSNumber?
    @objc var imageHeight: NSNumber?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId :  fromId
    }
}
