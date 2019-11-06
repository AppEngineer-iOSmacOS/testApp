//
//  NewContactViewController.swift
//  goJekTest
//
//  Created by Nikolay S on 20.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import UIKit
import TLCustomMask
import IQKeyboardManagerSwift

class NewContactViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    private var contactRlm = myRealm?.objects(ContactRealm.self)
    @IBOutlet weak var contactTableView: UITableView!
    var backVoid: (() -> Void)?
    var isEditeContact = false
    var editIdContact:Int?
    private var kSelectCamFoto = Bool()
    var tmpImageAvatar:UIImageView = UIImageView(image: UIImage(named: "newContImag"))
    private var isSelectPhoto = false
    private var phoneMask = TLCustomMask()
    var contact = ContactsModel(id: 0,
                                        first_name: "",
                                        last_name: "",
                                        profile_pic: "",
                                        favorite: false,
                                        url: "",
                                        email: "",
                                        phone: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactTableView.delegate = self
        contactTableView.dataSource = self
        phoneMask.formattingPattern = "+$$ $$$$$$$$$"
        self.contactRlm = myRealm!.objects(ContactRealm.self)
        if isEditeContact {
            guard editIdContact != nil else {
                return
            }
            let contactFltr = contactRlm!.filter("id == \(self.editIdContact!)")
            if contactFltr.count > 0 {
                self.contact.id = contactFltr.first!.id
                self.contact.first_name = contactFltr.first!.first_name
                self.contact.last_name = contactFltr.first!.last_name
                self.contact.profile_pic = contactFltr.first!.profile_pic
                self.contact.favorite = contactFltr.first!.favorite
                self.contact.url = contactFltr.first!.url
                self.contact.email = contactFltr.first!.email
                self.contact.phone = contactFltr.first!.phone
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
          super .viewWillAppear(true)
          IQKeyboardManager.shared.enable = true
      }
      override func viewWillDisappear(_ animated: Bool) {
          IQKeyboardManager.shared.enable = false
      }
    @objc func backAction() {
        if isEditeContact {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func saveAction() {
        // Check new data
        guard contact.first_name.count > 1 else {
            self.showTopDo("No First Name!", hexColor: "#F52617")
            return
        }
        guard contact.last_name.count > 1 else {
            self.showTopDo("No Last Name!", hexColor: "#F52617")
            return
        }
        guard contact.email.isValidEmail() else {
            self.showTopDo("Email invalid!", hexColor: "#F52617")
            return
        }
        
        guard contact.phone.isPhoneNumber else {
            self.showTopDo("Mobile invalid!", hexColor: "#F52617")
            return
        }
        // new data - OK
        var params:[String : Any] = [:]
        if self.contact.first_name.count > 0 {
            params.updateValue(self.contact.first_name, forKey: "first_name")
        }
        if self.contact.last_name.count > 0 {
            params.updateValue(self.contact.last_name, forKey: "last_name")
        }
        if self.contact.email.count > 0 {
            params.updateValue(self.contact.email, forKey: "email")
        }
        if self.contact.phone.count > 0 {
            params.updateValue(self.contact.phone, forKey: "phone_number")
        }
        params.updateValue(false, forKey: "favorite")
        // for exemple profile_pic need convert to base64 data and load to server
        // server answered new url from my pic and I cent url in params.updateValue(self.contact.profile_pic, forKey: "profile_pic")
        // set my photo :))
        params.updateValue("http://nik.sozinov.com/images/omne.png", forKey: "profile_pic")
        if isEditeContact {
            guard editIdContact != nil else {
                return
            }
            Reqest.sharedInstance.requestEditContact(self.editIdContact!, params: params, success: { (bool) in
                   if bool {
                   self.showTopDo("Edit Contact success!", hexColor: "#50E3C2")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.backVoid?()
                        self.backAction()
                    }
                   }else {
                      self.showTopDo("Edit Contact is error!", hexColor: "#F52617")
                   }
               }) { (error) in
                   self.showTopDo(error.localizedDescription, hexColor: "#F52617")
               }
        } else {
            Reqest.sharedInstance.requestNewContact(params, success: { (bool) in
                   if bool {
                   self.showTopDo("Created new Contact success!", hexColor: "#50E3C2")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        self.backVoid?()
                        self.backAction()
                    }
                   }else {
                      self.showTopDo("Created new Contact is error!", hexColor: "#F52617")
                   }
               }) { (error) in
                   self.showTopDo(error.localizedDescription, hexColor: "#F52617")
               }
        }
    }
    
    // MARK: - Table view data source
    // it's static table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var identifier = "cell"
        switch indexPath.row {
        case 0:
            identifier = "newInfoCell"
        case 1...4:
            identifier = "newDeviceCell"
        default:
            break
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let newInfoCell = cell as? NewInfoTableViewCell {
            newInfoCell.layerGradient()
            newInfoCell.cancelBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            newInfoCell.doneBtn.addTarget(self, action: #selector(saveAction), for: .touchUpInside)
            newInfoCell.userImage.image = self.tmpImageAvatar.image
            if isSelectPhoto || isEditeContact {
                newInfoCell.userImage.layer.cornerRadius = newInfoCell.userImage.frame.height/2
                newInfoCell.userImage.layer.masksToBounds = true
                newInfoCell.userImage.layer.borderColor = UIColor.white.cgColor
                newInfoCell.userImage.layer.borderWidth = 2.5
            }
            newInfoCell.selectImageBtn.addTarget(self, action: #selector(captureImage), for: .touchUpInside)
        }
        if let newDeviceCell = cell as? NewDeviceTableViewCell {
            newDeviceCell.descriptionTF.tag = indexPath.row
            newDeviceCell.descriptionTF.delegate = self
            switch indexPath.row {
            case 1:
                newDeviceCell.titleLabel.text = "First Name"
                newDeviceCell.descriptionTF.keyboardType = .default
                newDeviceCell.descriptionTF.text = contact.first_name
            case 2:
                newDeviceCell.titleLabel.text = "Last Name"
                newDeviceCell.descriptionTF.keyboardType = .default
                newDeviceCell.descriptionTF.text = contact.last_name
            case 3:
                newDeviceCell.titleLabel.text = "mobile"
                newDeviceCell.descriptionTF.keyboardType = .numberPad
                newDeviceCell.descriptionTF.text = contact.phone
            case 4:
                newDeviceCell.titleLabel.text = "email"
                newDeviceCell.descriptionTF.keyboardType = .emailAddress
                newDeviceCell.descriptionTF.text = contact.email
            default:
                break
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 206.0
        }
        return 64
    }
    
}

extension NewContactViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let stringRange = Range(range, in: currentText) else { return false }
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch textField.tag {
        case 1:
            self.contact.first_name = updatedText
        case 2:
            self.contact.last_name = updatedText
        case 3:
            let newString = string
            textField.text = phoneMask.formatStringWithRange(range: range, string: newString)
            self.contact.phone = textField.text ?? ""
            return false
        case 4:
            self.contact.email = updatedText

        default:
            break
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField.tag {
        case 1:
            self.contact.first_name = textField.text!
        case 2:
            self.contact.last_name = textField.text!
        case 3:
            let string = textField.text!
            let stringArray = string.components(separatedBy: CharacterSet.decimalDigits.inverted)
            self.contact.phone = ""
            for item in stringArray {
                if let number = Int(item) {
                    #if DEBUG
                    print("number: \(number)")
                    #endif
                    self.contact.phone.append(String(number))
                }
            }
        case 4:
            self.contact.email = textField.text!
        default:
            break
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.dismissKeyboard()
        return true
    }
}

extension NewContactViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: **** Work with photo ****
    @objc func captureImage() {
        //    Alert Cam or Galerey
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertController.Style.actionSheet)
        let fotoAction = UIAlertAction(title: "Select galerey", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.kSelectCamFoto = true
            self.chooseFoto()
        })
        let camAction = UIAlertAction(title: "Take photo", style: UIAlertAction.Style.default, handler: { (action) -> Void in
            self.kSelectCamFoto = false
            self.chooseFoto()
        })
        let canselButton = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) -> Void in
        })
        alert.addAction(fotoAction)
        alert.addAction(camAction)
        alert.addAction(canselButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func chooseFoto() {
        let imageFromSource = UIImagePickerController()
        imageFromSource.delegate = self
        imageFromSource.allowsEditing = false
        if self.kSelectCamFoto != true {
            imageFromSource.sourceType = UIImagePickerController.SourceType.camera
        } else {
            imageFromSource.sourceType = UIImagePickerController.SourceType.photoLibrary
        }
        self.present(imageFromSource, animated: true, completion:nil)
    }
    
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    // Helper function inserted by Swift 4.2 migrator.
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        var pickedImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        //compress
        let rect =  CGRect(x: 0, y: 0, width: pickedImage.size.width/4, height: pickedImage.size.height/4)
        UIGraphicsBeginImageContext(rect.size)
        pickedImage.draw(in: rect)
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let compressedImageData = resizedImage!.jpegData(compressionQuality: 1.0)
        pickedImage = UIImage(data: compressedImageData!)!
        self.tmpImageAvatar.contentMode = .scaleAspectFill
        self.tmpImageAvatar.image = pickedImage
        picker.dismiss(animated: true) {
            self.isSelectPhoto = true
            self.contactTableView.reloadData()
        }
    }
    
}
