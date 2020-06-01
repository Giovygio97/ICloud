//
//  PhrasesView.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI

struct PhrasesView: View {
    @ObservedObject var topic: Topic
    @State var arrayOfPhrases : [PhraseStructure] = []
    var body: some View {
        NavigationView{
            List(arrayOfPhrases){phrase in
                Text(phrase.sentence)
                }
            .navigationBarTitle("Phrases")
        }.onAppear(perform: {
            CloudKitHelper.fetchPhrase(for: self.topic.phrases!){final in
                switch final{
                case .success(let newPhrase):
                    self.arrayOfPhrases.append(contentsOf: newPhrase)
                case .failure(let error):
                    print("Error: \(error).")
                }
            }
        })
    }
}
