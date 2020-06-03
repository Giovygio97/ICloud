//
//  PhrasesView.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI
import CloudKit

struct PhraseView: View {
    
    @EnvironmentObject var topic: Topic
    @State var phrase: String
    @State var arrayOfPhrases: [PhraseStructure]
    
    var body: some View{
        NavigationView{
            VStack{
                HStack {
                    TextField("Insert new Phrase: ", text: $phrase)
                    Button(action: {
                        var newPhrase = PhraseStructure(sentence: self.phrase, reference: CKRecord.Reference(recordID: self.topic.recordID!, action: .none))
                        CloudKitHelper.savePhrase(topic: self.topic, item: newPhrase){final in
                            switch final{
                            case .success(let something):
                                newPhrase.record! = something.record!
                            case .failure(let err):
                                print(err.localizedDescription)
                            }
                        }
                    }){
                        Text("Add")
                    }
                }
                List{
                    ForEach(arrayOfPhrases, id: \.self){info in
                        TextField("", text: self.$phrase)
                    }
                    .onDelete(perform: deleteInfo)
                }
                Button(action: saveItem){
                    Text("Save")
                }
            }
        }
        .navigationBarTitle(self.topic.name)
        .navigationBarItems(trailing: EditButton())
    }
    
    func deleteInfo(index: IndexSet){
        let indice = index.first!
        CloudKitHelper.delete(id: arrayOfPhrases[indice].record!){final in
            switch final{
            case .success(let itemToDelete):
                self.arrayOfPhrases.removeAll(where: {$0.record == itemToDelete})
            case .failure(let err):
                print(err.localizedDescription)
            }
            
        }
    }
    
    func saveItem(){
        
    }
    
}

