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
        itemInZone["name"] = item.name as CKRecordValue
        itemInZone["phrases"] = item.phrases as CKRecordValue?
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
            let element = Topic(n: name, rID: id, references: [])
            completion(.success(element))
            
        }
    }
    
    static func savePhrase(topic: Topic, item: PhraseStructure, completion: @escaping(Result<PhraseStructure, Error>) -> ()){
        let recordIdZone = CKRecordZone(zoneName: "Personal")
        let itemInZone = CKRecord(recordType: recordType.phrase, recordID: CKRecord.ID(zoneID: recordIdZone.zoneID))
        itemInZone["sentence"] = item.sentence as CKRecordValue
        itemInZone["reference"] = CKRecord.Reference(recordID: topic.recordID!, action: .none)
        var info = topic
        info.phrases?.append(CKRecord.Reference(record: itemInZone, action: .deleteSelf))
        CKContainer.default().privateCloudDatabase.save(itemInZone){(record, error) in
            if let error = error{
                DispatchQueue.main.async {
                    completion(.failure(error))
                    return
                }
            }
            let topicModified = CKRecord(recordType: recordType.topic, recordID: info.recordID!)
            topicModified["phrases"] = info.phrases as CKRecordValue?
            CKContainer.default().privateCloudDatabase.save(topicModified){_,error in
                if let error = error{
                    completion(.failure(error))
                    return
                }
            }
            
            guard let record = record else{
                completion(.failure(CloudKitHelperError.recordFailure))
                return
            }
            
            let id = record.recordID
            
            guard let sentence = record["sentence"] as? String else{
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            
            guard let reference = record["reference"] as? CKRecord.Reference else{
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            
            let element = PhraseStructure(record: id, sentence: sentence, reference: reference)
            completion(.success(element))
            
            
        }
    }
    
    static func delete(id: CKRecord.ID, completion: @escaping(Result<CKRecord.ID, Error>) -> ()){
        CKContainer.default().privateCloudDatabase.delete(withRecordID: id){recordId, error in
            if let error = error{
                completion(.failure(error))
                return
            }
            guard let recordId = recordId else{
                completion(.failure(CloudKitHelperError.castFailure))
                return
            }
            completion(.success(recordId))
        }
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
                let element = Topic(n: name, rID: id, references: phrases)
                completion(.success(element))
                
            }
        }
        CKContainer.default().privateCloudDatabase.add(operation)
    }
    
    static func fetchPhrase(for references: [CKRecord.Reference],_ completion: @escaping(Result<[PhraseStructure], Error>) -> ()){
        var phrases : [PhraseStructure] = []
        let recordIDs = references.map { $0.recordID }
        let recordZoneId = CKRecordZone(zoneName: "Personal")
        let predicate = NSPredicate(format: "(recordID = %@)", recordIDs)
        let query = CKQuery(recordType: recordType.phrase, predicate: predicate)
        CKContainer.default().privateCloudDatabase.perform(query, inZoneWith: recordZoneId.zoneID){results, error in
            if let error = error{
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let results = results else{
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            DispatchQueue.main.async {
                for phrase in results{
                    guard let sentence = phrase["sentence"] as? String, let reference = phrase["reference"] as? CKRecord.Reference else{
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    phrases.append(PhraseStructure(record: phrase.recordID, sentence: sentence, reference: reference))
                }
                completion(.success(phrases))
            }
            
        }
        
        
    }
    
    static func modifyTopic(item: Topic, completion: @escaping (Result<Topic, Error>) -> ()) {
        guard let recordID = item.recordID else { return }
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["name"] = item.name as CKRecordValue

            CKContainer.default().publicCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let name = record["name"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let phrases = record["phrases"] as? [CKRecord.Reference] else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    let listElement = Topic(n: name, rID: recordID, references: phrases)
                    completion(.success(listElement))
                }
            }
        }
    }
    
    static func modifyTopic(item: PhraseStructure, completion: @escaping (Result<PhraseStructure, Error>) -> ()) {
        guard let recordID = item.record else { return }
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, err in
            if let err = err {
                DispatchQueue.main.async {
                    completion(.failure(err))
                }
                return
            }
            guard let record = record else {
                DispatchQueue.main.async {
                    completion(.failure(CloudKitHelperError.recordFailure))
                }
                return
            }
            record["sentence"] = item.sentence as CKRecordValue
            
            CKContainer.default().publicCloudDatabase.save(record) { (record, err) in
                DispatchQueue.main.async {
                    if let err = err {
                        completion(.failure(err))
                        return
                    }
                    guard let record = record else {
                        completion(.failure(CloudKitHelperError.recordFailure))
                        return
                    }
                    let recordID = record.recordID
                    guard let sentence = record["sentence"] as? String else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    guard let topic = record["reference"] as? CKRecord.Reference else {
                        completion(.failure(CloudKitHelperError.castFailure))
                        return
                    }
                    let listElement = PhraseStructure(record: recordID, sentence: sentence, reference: topic)
                    completion(.success(listElement))
                }
            }
        }
    }
    
    
    
    
    
    
}
    
    

