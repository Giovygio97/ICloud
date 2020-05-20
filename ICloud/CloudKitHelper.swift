//
//  CloudKitHelper.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 20/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//
import Foundation
import CloudKit
import SwiftUI

struct CloudKitHelper{

    struct recordType{
        static let topic = "Topic"
        static let phrase = "Phrases"
    }
    
    enum CloudKitHelperError: Error{
        case recordFailure
        case recordIDFailure
        case castFailure
        case cursorFailure
        case referenceFailure
    }

    static func saveTopic(item: Topic, completion: @escaping(Result<Topic, Error>) -> ()){
        let recordZoneId = CKRecordZone(zoneName: "Personal")
        let itemInZone = CKRecord(recordType: recordType.topic, recordID: CKRecord.ID(zoneID: recordZoneId.zoneID))
        CKContainer.default().privateCloudDatabase.save(itemInZone){(record, error) in
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let record = record else{
                completion(.failure(CloudKitHelperError.recordFailure))
                return
            }
            
            let id = record.recordID
            
            guard let name = record["name"] as? String else{
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            
            let emptyPhrase : [CKRecord.Reference] = []
            
            let element = Topic(name: name, recordID: id, phrases: emptyPhrase)
            completion(.success(element))
            
        }
    }
    
    static func savePhrase(topicID: CKRecord.Reference, item: PhraseStructure, completion: @escaping(Result<PhraseStructure, Error>) -> ()){
        let recordZoneId = CKRecordZone(zoneName: "Personal")
        let item = CKRecord(recordType: recordType.phrase, recordID: CKRecord.ID(zoneID: recordZoneId.zoneID))
//        CKContainer.default().privateCloudDatabase.save(item)
        
    }
    
    static func fetch(completion: @escaping(Result<PhraseStructure, Error>) -> ()){
        
    }
    
    
}
