//
//  ContactDetailViewController.swift
//  goJekTest
//
//  Created by Nikolay S on 19.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import UIKit
import Realm
import Alamofire
import AlamofireImage
import MessageUI

class ContactDetailViewController: UIViewController {
    private var contactRlm = myRealm?.objects(ContactRealm.self)
    enum NameCell {
         case email, mobile, delCell, infoCell, cell
     }
    var selectId:Int?
    @IBOutlet weak var contactDetailTableView: UITableView!
    private var tmpImageAvatar:UIImageView = UIImageView(image: UIImage(named: "defaultUserImg"))
    private var isReqestDetail = false
    private var contact:ContactsModel?
    private var identifierArr:[(identifier:String, nameCell:NameCell)] = []
    private var callNumber:String?
    private let messageController = MFMessageComposeViewController()
    private let mailComposerVC = MFMailComposeViewController()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.contactRlm = myRealm!.objects(ContactRealm.self)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        contactDetailTableView.delegate = self
        contactDetailTableView.dataSource = self
        
        contactDetailTableView.estimatedRowHeight = 78.0
        contactDetailTableView.rowHeight = UITableView.automaticDimension
        loadContactData()
    }
    @objc func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func returnBack(){
        self.showTopDo("Data not load", hexColor: "#F52617")
         DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
             self.backAction()
         }
    }
    
    func loadContactData() {
        guard selectId != nil else {
            self.returnBack()
            return
        }
        let contactFltr = contactRlm!.filter("id == \(self.selectId!)")
        guard contactFltr.count > 0 else {
            self.returnBack()
            return
        }
        self.contact = ContactsModel(id: contactFltr.first!.id,
                                     first_name: contactFltr.first!.first_name,
                                     last_name: contactFltr.first!.last_name,
                                     profile_pic: contactFltr.first!.profile_pic,
                                     favorite: contactFltr.first!.favorite,
                                     url: contactFltr.first!.url,
                                     email: contactFltr.first!.email,
                                     phone: contactFltr.first!.phone)
        
        guard self.contact != nil else {
            return
        }
        self.adapterIdentifier()
        self.callNumber = self.contact!.phone
        if self.contact!.email.count == 0 || self.contact!.phone.count == 0 {
            if !isReqestDetail {
                isReqestDetail = true
                // request GET /contacts/{id}
                Reqest.sharedInstance.requestContactId(self.contact!.id, success: { (bool) in
                    self.loadContactData()
                }) { (error) in
                    self.showTopDo(error.localizedDescription, hexColor: "#F52617")
                }
            }
        }
    }
 
    func adapterIdentifier() {
        identifierArr.removeAll()
        identifierArr.append((identifier: "infoCell", nameCell: .infoCell))
        if self.contact!.phone.count > 0 {
            identifierArr.append((identifier: "deviceCell", nameCell: .mobile))
        }
        if self.contact!.email.count > 0 {
            identifierArr.append((identifier: "deviceCell", nameCell: .email))
        }
        identifierArr.append((identifier: "delCell", nameCell: .delCell))
        identifierArr.append((identifier: "cell", nameCell: .cell))
        self.contactDetailTableView.reloadData()
    }
 
 
    func deleteContact(){
        #if DEBUG
        self.showTopDo("You trying to delete:\n\(contact?.first_name.count ?? 0 > 0 ? contact!.first_name : "\(contact!.id)")\n\(contact?.last_name.count ?? 0 > 0 ? contact!.last_name : "")", hexColor: "#F52617")
        #endif
    }
    @objc func favAction(){
        #if DEBUG
        print("favAction")
        #endif
        guard selectId != nil else {
            return
        }
        let status = !contact!.favorite
        let params:[String : Any] = ["favorite":status]
        Reqest.sharedInstance.requestEditContact(self.selectId!, params: params, success: { (bool) in
                  if bool {
                    self.loadContactData()
                  }else {
                     self.showTopDo("Favorite not add!", hexColor: "#F52617")
                  }
              }) { (error) in
                  self.showTopDo(error.localizedDescription, hexColor: "#F52617")
              }
    }
    @objc func callTo() {
        #if DEBUG
        print("callTo")
        #endif
        callNumber!.makeAColl()
    }
    
    @objc func editAction(_ sender: UIButton) {
        performSegue(withIdentifier: "editAction", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editeContact = segue.destination as? NewContactViewController {
            editeContact.isEditeContact = true
            editeContact.editIdContact = self.selectId!
            editeContact.tmpImageAvatar.image = self.tmpImageAvatar.image
            editeContact.backVoid = {
                self.loadContactData()
            }
        }
    }
}

extension ContactDetailViewController:UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.contact != nil else {
            return 0
        }
        return identifierArr.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: identifierArr[indexPath.row].identifier, for: indexPath)
        
        if identifierArr[indexPath.row].nameCell == .infoCell {
            cell.layerGradient()
        }
        if let infoCell = cell as? ContactInfoTableViewCell {
            infoCell.backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
            infoCell.editBtn.addTarget(self, action: #selector(editAction), for: .touchUpInside)

            if contact?.profile_pic.count ?? 0 > 0 {
                Alamofire.request(APIConstants.sharedInstance.baseUrl + contact!.profile_pic).responseImage { response in
                    if let image = response.result.value {
                        infoCell.userImage.image = image
                        self.tmpImageAvatar.image = image
                    } else {
                        infoCell.userImage.image = UIImage(named: "defaultUserImg")
                    }
                }
            }
            infoCell.userName.text = (contact?.first_name ?? "") + " " + (contact?.last_name ?? "")
            
            infoCell.callBtn.setImage(contact?.phone.count ?? 0 > 0 ? UIImage(named: "call") : UIImage(named: "callNo"), for: .normal)
            infoCell.callBtn.addTarget(self, action: #selector(callTo), for: .touchUpInside)
            
            infoCell.messageBtn.setImage(contact?.phone.count ?? 0 > 0 ? UIImage(named: "Sms") : UIImage(named: "SmsNo"), for: .normal)
            infoCell.messageBtn.addTarget(self, action: #selector(sendSMS), for: .touchUpInside)
            
            infoCell.emailBtn.setImage(contact?.email.count ?? 0 > 0 ? UIImage(named: "Email") : UIImage(named: "EmailNo"), for: .normal)
            infoCell.emailBtn.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
            
            infoCell.favBtn.setImage(contact?.favorite ?? false ? UIImage(named: "Fav") : UIImage(named: "FavNo"), for: .normal)
            infoCell.favBtn.addTarget(self, action: #selector(favAction), for: .touchUpInside)
        }
        if let deviceCell = cell as? ContactDeviceTableViewCell {
    
            switch identifierArr[indexPath.row].nameCell {
            case .mobile:
                deviceCell.titleLabel.text = "mobile"
                deviceCell.descriptionLabel.text = contact?.phone
            case .email:
                deviceCell.titleLabel.text = "email"
                deviceCell.descriptionLabel.text = contact?.email
            default:
                deviceCell.titleLabel.text = ""
                deviceCell.descriptionLabel.text = ""
            }
        }
        
        cell.setNeedsUpdateConstraints()
        cell.updateConstraintsIfNeeded()
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch identifierArr[indexPath.row].nameCell {
        case .infoCell:
            return 313.0
        case .cell:
            return self.view.frame.height/2
        default:
            return UITableView.automaticDimension
        }
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if identifierArr[indexPath.row].nameCell == .delCell {
            self.deleteContact()
        }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// TODO: could move in other new controller
extension ContactDetailViewController: MFMessageComposeViewControllerDelegate {
    
    @objc func sendSMS() {
        guard callNumber != nil else {
            return
        }
        if (MFMessageComposeViewController.canSendText()) {
            messageController.body = ""
            messageController.recipients = [callNumber!]
            messageController.messageComposeDelegate = self
            self.present(messageController, animated: true, completion: nil)
        }
    }
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        //... handle sms screen actions
        self.messageController.dismiss(animated: true, completion: nil)
    }
}
// TODO: could move in other new controller
extension ContactDetailViewController: MFMailComposeViewControllerDelegate {
    
    @objc func sendEmail() {
        guard contact?.email != nil else {
            return
        }
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients([contact!.email])
        mailComposerVC.setSubject("Title message")
        mailComposerVC.setMessageBody("Some your exemple text", isHTML: false)
        return mailComposerVC
    }
    func showSendMailErrorAlert() {
        let alert = UIAlertController(title: "Message not sent!", message: "Your letter for some reason did not go away. Check your internet settings and resubmit", preferredStyle: .actionSheet)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
        })
        alert.addAction(okButton)
        self.present(alert, animated: true, completion: nil)
    }
    /// Need for MFMailComposeViewController to enable cancel button
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
