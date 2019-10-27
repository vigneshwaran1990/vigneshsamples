//
//  DataHandler.swift
//  ContactsViewer
//
//  Created by Vigneshwaran S on 25/10/19.
//  Copyright © 2019 Vigneshwaran S. All rights reserved.
//

import UIKit

class DataHandler: NSObject
{
    func parseContactsResponse(responseObject:  [Dictionary<String, AnyObject>]) -> [ContactsInfoContainer]{
        var contactsInfoContainerArr : [ContactsInfoContainer] = []
        for contactsDict in responseObject
        {
            let contactsInfo : ContactsInfo = ContactsInfo.init()
            contactsInfo.contactsId = contactsDict["id"] as! Int
            contactsInfo.contactName = contactsDict["name"] as! String
            contactsInfo.userName = contactsDict["username"] as! String
            if let emailId = contactsDict["email"] as? String
            {
                contactsInfo.emailId = emailId
            }
            if let phone = contactsDict["phone"] as? String
            {
                contactsInfo.phoneNumber = phone
            }
            if let website = contactsDict["website"] as? String
            {
                contactsInfo.webSite = website
            }
            if let companyName = contactsDict["company"] as? String
            {
                contactsInfo.companyName = companyName
            }
            if let addressDict = contactsDict["address"] as? Dictionary<String, String>
            {
                let addressInfo : AddressInfo = AddressInfo.init()
                if let street = addressDict["street"]
                {
                    addressInfo.street = street
                }
                if let suite = addressDict["suite"]
                {
                    addressInfo.suite = suite
                }
                if let city = addressDict["city"]
                {
                    addressInfo.city = city
                }
                if let zipCode = addressDict["zipcode"]
                {
                    addressInfo.zipCode = zipCode
                }
                contactsInfo.address = addressInfo
            }
            
            let contactsFilteredArr = contactsInfoContainerArr.filter { (contactInfoContainer) -> Bool in
                let firstChar : String = String(contactsInfo.contactName.first!)
                let result = contactInfoContainer.pivotId.caseInsensitiveCompare(firstChar) == .orderedSame
                return result
            }
            var contactsInfoContainer : ContactsInfoContainer
            if(contactsFilteredArr.count == 0)
            {
                contactsInfoContainer = ContactsInfoContainer.init()
                contactsInfoContainer.pivotId = (contactsInfo.contactName.first?.uppercased())!
            }
            else
            {
                contactsInfoContainer  = contactsFilteredArr[0]
            }
            
            contactsInfoContainer.contactsInfoArr.append(contactsInfo)
            let sortedContactsArr = contactsInfoContainer.contactsInfoArr.sorted(by: { $0.contactName < $1.contactName })
            contactsInfoContainer.contactsInfoArr = sortedContactsArr
            if(contactsFilteredArr.count == 0)
            {
                contactsInfoContainerArr.append(contactsInfoContainer)
            }
        }
        let sortedContainerArr = contactsInfoContainerArr.sorted(by: { $0.pivotId < $1.pivotId })
        contactsInfoContainerArr = sortedContainerArr
        return contactsInfoContainerArr
    }
}
