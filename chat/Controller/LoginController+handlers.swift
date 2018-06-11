//
//  LoginController+handlers.swift
//  chat
//
//  Created by Serkan Aysan on 08/05/2018.
//  Copyright © 2018 Serkan Aysan. All rights reserved.
//

import UIKit
import Firebase

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    func handleRegister()  {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else  {
            print("Form is not valid")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print(error!)
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            let imageName = NSUUID.init()
            let refStorage = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                refStorage.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    
                    if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                        let values = ["name" : name, "email" : email, "profileImageUrl" : profileImageUrl]
                        self.registerUserIntoDatabaseWithUID(uid: uid, values: values as [String : AnyObject])
                        
                    }
                })
            }
            
            
        }
        
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let refUsers = Database.database().reference().child("users").child(uid)
        
        refUsers.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            
            let user = User()
            user.setValuesForKeys(values)
            self.messagesController?.setupNavBarWithUser(user: user)
            
            self.dismiss(animated: true, completion: nil )
        })
    }
    
    @objc func handleSelectProfileImageView() {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
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
            profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
