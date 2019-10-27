//
//  ContactsViewController.swift
//  ContactsViewer
//
//  Created by Vigneshwaran S on 25/10/19.
//  Copyright © 2019 Vigneshwaran S. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController,UITableViewDelegate,UITableViewDataSource, UISearchBarDelegate {
    
    private var loaderView : UIView? = nil
    private var errorView : UIView? = nil
    private var upSortTag : Int = 0
    private var downSortTag : Int  = 1
    private var searchActive : Bool = false
    @IBOutlet weak var searchController: UISearchBar!
    @IBOutlet weak var contactsTableView: UITableView!
    private var contactsInfoContainerArr : [ContactsInfoContainer] = []
    private var headerHeight : CGFloat = 30
    private var filteredData : [ContactsInfoContainer] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Contacts"
        self.view.backgroundColor = UIColor.white
        self.configureViews()
        // Do any additional setup after loading the view.
    }
    
    // MARK: Config  & Helper Methods
    
    func configureViews(){
        let upSort = UIBarButtonItem(image: UIImage(named: "upSort"), style: .plain, target: self, action: #selector(sortContacts(sender:))) //
        upSort.tag = upSortTag
        self.navigationItem.rightBarButtonItem  = upSort
        
        let downSort = UIBarButtonItem(image: UIImage(named: "downSort"), style: .plain, target: self, action: #selector(sortContacts(sender:))) //
        downSort.tag = downSortTag
        self.navigationItem.leftBarButtonItem  = downSort
        showLoaderView()
        loadContactsData()
    }
    
    func showErrorView(){
        let constants : Constants = Constants.init()
        errorView = UIView.init(frame: self.view.bounds)
        errorView?.backgroundColor = UIColor.white
        
        let errorLbl = UILabel()
        errorLbl.translatesAutoresizingMaskIntoConstraints =  false
        errorLbl.text = "Oops! Something went wrong"
        errorLbl.textAlignment = .center
        errorLbl.font = UIFont.init(name: constants.appRegularFontName, size: constants.appStandardFontSize)
        errorLbl.textColor = constants.appFadedColor
        let widthConstraint = NSLayoutConstraint(item: errorLbl, attribute: .width, relatedBy: .equal,
                                                 toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 300)
        
        let heightConstraint = NSLayoutConstraint(item: errorLbl, attribute: .height, relatedBy: .equal,
                                                  toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40)
        
        let xConstraint = NSLayoutConstraint(item: errorLbl, attribute: .centerX, relatedBy: .equal, toItem: self.errorView, attribute: .centerX, multiplier: 1, constant: 0)
        
        let yConstraint = NSLayoutConstraint(item: errorLbl, attribute: .centerY, relatedBy: .equal, toItem: self.errorView, attribute: .centerY, multiplier: 1, constant: 0)
        
        DispatchQueue.main.async {
            self.errorView?.addSubview(errorLbl)
            NSLayoutConstraint.activate([widthConstraint, heightConstraint, xConstraint, yConstraint])
            self.view.addSubview(self.errorView!)
        }
    }
    
    func showLoaderView() {
        loaderView = UIView.init(frame: self.view.bounds)
        loaderView?.backgroundColor = UIColor.white
        let activityIndicator = UIActivityIndicatorView.init(style: UIActivityIndicatorView.Style.medium)
        activityIndicator.startAnimating()
        activityIndicator.center = loaderView!.center
        
        DispatchQueue.main.async {
            self.loaderView?.addSubview(activityIndicator)
            self.view.addSubview(self.loaderView!)
        }
    }
    
    func hideLoaderView(){
        DispatchQueue.main.async {
            self.loaderView?.removeFromSuperview()
        }
    }
    
    @objc func sortContacts(sender : UIBarButtonItem){
        if(sender.tag == upSortTag)
        {
            contactsInfoContainerArr.sort { $0.pivotId  < $1.pivotId }
        }
        else
        {
            contactsInfoContainerArr.sort { $0.pivotId  > $1.pivotId }
        }
        self.contactsTableView.reloadData()
    }
    
    func checkForAlpha(str : String)->Bool{
        for chr in str {
            if (!(chr >= "a" && chr <= "z") && !(chr >= "A" && chr <= "Z") ) {
                return false
            }
        }
        return true
    }
    
    func loadContactsData(){
        var urlDict: NSDictionary?
        if let path = Bundle.main.path(forResource: "URLInfo", ofType: "plist") {
            urlDict = NSDictionary(contentsOfFile: path)
        }
        
        let connection : Connection =  Connection.init()
        if let url_str = urlDict?.value(forKey: "contacts_url") as? String {
            connection.urlString = url_str
        }
        
        connection.contentType = ContentType.Json
        connection.httpType = HttpMethodType.GetMethod
        
        connection.loadRequest { (responsObj, error) in
            if(responsObj != nil)
            {
                let dataHandler : DataHandler = DataHandler.init()
                self.contactsInfoContainerArr  = dataHandler.parseContactsResponse(responseObject: responsObj as! [Dictionary<String, AnyObject>])
                DispatchQueue.main.async {
                    if(self.errorView != nil)
                    {
                        self.errorView?.removeFromSuperview()
                    }
                    self.contactsTableView.reloadData()
                    self.hideLoaderView()
                }
            }
            else
            {
                self.showErrorView()
            }
        }
    }
    
    // MARK: SearchBar Delegates
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchActive = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchActive = false
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if(searchText == "")
        {
            filteredData = []
            searchActive = false
            self.contactsTableView.reloadData()
            return
        }
        
        let contactsContainerFilteredArr = contactsInfoContainerArr.filter { (contactInfoContainer) -> Bool in
            let firstChar : String = String(searchText.first!)
            let result = contactInfoContainer.pivotId.caseInsensitiveCompare(firstChar) == .orderedSame
            return result
        }
        
        if(!contactsContainerFilteredArr.isEmpty)
        {
            let contactsInfoArr : [ContactsInfo] = contactsContainerFilteredArr[0].contactsInfoArr
            
            let contactsFilteredArr = contactsInfoArr.filter { (contactsInfo) -> Bool in
                if(contactsInfo.contactName.contains(searchText))
                {
                    return true
                }
                return false
            }
            
            var resultData : ContactsInfoContainer? = nil
            
            if(filteredData.count != 0)
            {
                filteredData.removeAll()
            }
            
            resultData  = ContactsInfoContainer.init()
            resultData?.pivotId = contactsContainerFilteredArr[0].pivotId
            
            resultData?.contactsInfoArr = contactsFilteredArr
            filteredData.append(resultData!)
        }
        else
        {
            filteredData = []
            searchActive = true
            self.contactsTableView.reloadData()
            return
        }
        
        
        if (filteredData.count == 0){
            filteredData = []
            searchActive = false
        }
        else{
            searchActive = true
        }
        self.contactsTableView.reloadData()
    }
    
    // MARK: TableView Delegates
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let constants : Constants = Constants.init()
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.contactsTableView.frame.size.width, height: headerHeight))
        headerView.backgroundColor = constants.tableHeaderViewColor
        let headerLabel : UILabel = UILabel.init(frame: CGRect(x: 20, y: 0, width: self.contactsTableView.frame.size.width-20, height: headerHeight))
        var contactsInfoContainer : ContactsInfoContainer? = nil
        if(searchActive == true)
        {
            contactsInfoContainer = self.filteredData[section]
        }
        else
        {
            contactsInfoContainer  = self.contactsInfoContainerArr[section]
        }
        headerLabel.text = contactsInfoContainer?.pivotId
        headerLabel.font = UIFont.init(name: constants.appMediumFontName, size: constants.appHeaderFontSize)
        headerView.addSubview(headerLabel)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerHeight
    }
    
    
    func numberOfSections(in tableView: UITableView) ->  Int {
        if(searchActive == true)
        {
            return self.filteredData.count
        }
        else
        {
            return contactsInfoContainerArr.count
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var contactsInfoContainer : ContactsInfoContainer? = nil
        if(searchActive == true)
        {
            contactsInfoContainer = self.filteredData[section]
        }
        else
        {
            contactsInfoContainer  = self.contactsInfoContainerArr[section]
        }
        
        return contactsInfoContainer!.contactsInfoArr.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) ->  CGFloat {
        return UITableView.automaticDimension
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell : ContactsCell? = nil
        var contactsInfoContainer : ContactsInfoContainer? = nil
        if(searchActive == true)
        {
            contactsInfoContainer = self.filteredData[indexPath.section]
        }
        else
        {
            contactsInfoContainer  = self.contactsInfoContainerArr[indexPath.section]
        }
        let contactsInfo : ContactsInfo = contactsInfoContainer!.contactsInfoArr[indexPath.row]
        cell = tableView.dequeueReusableCell(withIdentifier: "contactsCellId", for: indexPath) as? ContactsCell
        cell?.configureContactCell(contactName: contactsInfo.contactName)
        return cell!
    }
}


class ContactsCell : UITableViewCell
{
    @IBOutlet weak var contactNameLbl: UILabel!
    
    func configureContactCell(contactName : String){
        self.contactNameLbl.text = contactName
    }
    
}
