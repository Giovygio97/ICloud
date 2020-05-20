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
    
    static func fetchTopic(completion: @escaping(Result<Topic, Error>) -> ()){
        let predicate = NSPredicate(value: true)
        let sort = NSSortDescriptor(key: "creationDate", ascending: false)
        let query = CKQuery(recordType: recordType.topic, predicate: predicate)
        query.sortDescriptors = [sort]
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
        
        operation.queryCompletionBlock = { (_,error) in
            DispatchQueue.main.async {
                if let error = error{
                    completion(.failure(error))
                    return
                }
            }
        }
        operation.recordFetchedBlock = {record in
            DispatchQueue.main.async {
                let id = record.recordID
                guard let name = record["name"] as? String, let phrases = record["phrases"] as? [CKRecord.Reference] else{
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                let element = Topic(name: name, recordID: id, phrases: phrases)
                completion(.success(element))
                
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    static func fetchPhrase(for references: [CKRecord.Reference],_ completion: @escaping(Result<[PhraseStructure], Error>) -> ()){
        let recordIDs = references.map { $0.recordID }
        let predicate = NSPredicate(format: "(recordID = %@)", recordIDs)
        let query = CKQuery(recordType: recordType.phrase, predicate: predicate)
        let operation = CKQueryOperation(query: query)
        operation.resultsLimit = 50
        
        operation.recordFetchedBlock = {record in
            DispatchQueue.main.async {
                let id = record.recordID
                guard let sentence = record["sentence"] as? String, let reference = record["reference"] as? CKRecord.Reference else{
                    completion(.failure(CloudKitHelperError.castFailure))
                    return
                }
                let element = PhraseStructure(record: id, sentence: sentence, reference: reference)
                completion(.success(element))
                
            }
        }
    }
    
    
    
    
}
    
    

