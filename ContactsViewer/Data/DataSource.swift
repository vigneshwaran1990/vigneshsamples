//
//  DataSource.swift
//  ContactsViewer
//
//  Created by Vigneshwaran S on 25/10/19.
//  Copyright © 2019 Vigneshwaran S. All rights reserved.
//

import UIKit


class AddressInfo : NSObject
{
    var street : String = ""
    var suite : String  = ""
    var city : String  = ""
    var zipCode : String = ""
}

class ContactsInfo: NSObject {
    var contactsId : Int = 0
    var contactName : String = ""
    var userName : String = ""
    var emailId : String  = ""
    var address : AddressInfo? = nil
    var phoneNumber : String = ""
    var webSite : String = ""
    var companyName : String = ""
}

class ContactsInfoContainer : NSObject
{
    var pivotId : String  = ""
    var contactsInfoArr : [ContactsInfo] = []
}


