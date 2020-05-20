//
//  Topics.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI
import CloudKit

class TopicList: ObservableObject{
    @Published var topicStructure : [Topic] = []
}
