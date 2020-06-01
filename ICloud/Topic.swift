//
//  Topic.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 20/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI
import CloudKit

class Topic: ObservableObject{
    var id : UUID
    var name: String
    var recordID : CKRecord.ID?
    var phrases: [CKRecord.Reference]?
    
    init(n: String, rID: CKRecord.ID, references: [CKRecord.Reference]){
        self.id = UUID()
        self.name = n
        self.recordID! = rID
        if references.count != 0{
            self.phrases = references
        }else{
            self.phrases = []
        }
    }
    
    init(name: String){
        self.id = UUID()
        self.name = name
    }
}
