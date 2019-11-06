//
//  ContactTableViewController.swift
//  goJekTest
//
//  Created by Nikolay S on 18.10.2019.
//  Copyright © 2019 Nikolay S. All rights reserved.
//

import UIKit
import Dodo
import Alamofire
import AlamofireImage

class ContactViewController: UIViewController {
    private var contactRlm = myRealm?.objects(ContactRealm.self)
    
    private var contactDictionary = [String: [(name:String, id:Int)]]()
    private var contactSectionTitles = [String]()
    private var contact = [(name:String, id:Int)]()
    
    @IBOutlet var contactsTableView:UITableView!
    private var myRefreshControl: UIRefreshControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactRlm = myRealm!.objects(ContactRealm.self)
        contactsTableView.delegate = self
        contactsTableView.dataSource = self
        contactsTableView.sectionIndexColor = UIColor.init(white: 0.0, alpha: 0.3)
        
        myRefreshControl = UIRefreshControl()
        myRefreshControl.attributedTitle = NSAttributedString(string: "Loading Contacts...")
        myRefreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        contactsTableView.addSubview(myRefreshControl)
        self.view.hideKeyboardWhenTappedAround()
        self.loadContactsData()
        self.loadAllData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.loadContactsData()
    }
    
    func loadAllData() {
        self.viewRefresh()
        Reqest.sharedInstance.requestContact(success: { (_) in
            self.stopRefresh()
            self.loadContactsData()
        }) { (error) in
            self.stopRefresh()
            self.showTopDo(error.localizedDescription, hexColor: "#F52617")
        }
    }
    func viewRefresh() {
        stopRefresh()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        self.myRefreshControl!.beginRefreshing()
        let offset = CGPoint.init(x: 0, y: -60)
        UIView.animate(withDuration: 0.3, animations: {
            self.contactsTableView.setContentOffset(offset, animated: false)
        })
        
    }
    
    @objc func refresh(sender:AnyObject) {
        loadAllData()
    }
    func stopRefresh() {
        self.view.isUserInteractionEnabled = true
        if self.myRefreshControl!.isRefreshing {
            self.myRefreshControl!.endRefreshing()
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    
    func loadContactsData() {
        contact.removeAll()
        for (_, value) in self.contactRlm!.enumerated() {
            contact.append((name:value.first_name, id:value.id))
        }
        for contact in contact {
            let contactKey = String(contact.name.prefix(1))
            if var contactValues = contactDictionary[contactKey] {
                contactValues.append((name: contact.name, id: contact.id))
                contactDictionary[contactKey] = contactValues
            } else {
                contactDictionary[contactKey] = [(name: contact.name, id: contact.id)]
            }
        }
        
        contactSectionTitles = [String](contactDictionary.keys)
        contactSectionTitles = contactSectionTitles.sorted(by: { $0 < $1 })
        self.contactsTableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailVC = segue.destination as? ContactDetailViewController {
            detailVC.selectId = sender as? Int
        }
        if let newContact = segue.destination as? NewContactViewController {
            newContact.backVoid = {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.loadAllData()
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ContactViewController: UITableViewDelegate, UITableViewDataSource {
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return contactSectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let contactKey = contactSectionTitles[section]
        if let contactValues = contactDictionary[contactKey] {
            return contactValues.count
        }
        return 0
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactTableViewCell", for: indexPath)
        
        let contactKey = contactSectionTitles[indexPath.section]
        if let contactValues = contactDictionary[contactKey] {
            if let contactTableViewCell = cell as? ContactTableViewCell {
                if let contact = contactRlm?.filter("id == \(contactValues[indexPath.row].id)") {
                    if contact.count > 0 {
                        contactTableViewCell.nameLabel.text = contact.first!.first_name + " " + contact.first!.last_name
                                           contactTableViewCell.favoriteImage.isHidden = !contact.first!.favorite
                                           if contact.first!.profile_pic.count > 0 {
                                               Alamofire.request(APIConstants.sharedInstance.baseUrl + contact.first!.profile_pic).responseImage { response in
                                                         if let image = response.result.value {
                                                           contactTableViewCell.imageUserView.image = image
                                                         } else {
                                                             contactTableViewCell.imageUserView.image = UIImage(named: "defaultUserImg")
                                                         }
                                                     }
                                                 }
                    }
                }
            }
        }
        
        return cell
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
         let contactKey = contactSectionTitles[indexPath.section]
            if let contactValues = contactDictionary[contactKey] {
            performSegue(withIdentifier: "showDetail", sender: contactValues[indexPath.row].id)
            }
        return indexPath
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return contactSectionTitles[section]
    }
    
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return contactSectionTitles
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = UIColor(white: 0.9, alpha: 0.5)

     }

    
}
