//
//  Topic.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 20/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI
import CloudKit

struct Topic: Identifiable{
    var id = UUID()
    var name: String
    var recordID : CKRecord.ID?
    var phrases: [CKRecord.Reference]?
}
