//
//  PhraseStructure.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI
import CloudKit

struct PhraseStructure: Identifiable{
    var id = UUID()
    var record : CKRecord.ID?
    var sentence : String
    private var reference: CKRecord.Reference
}