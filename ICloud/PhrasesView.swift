//
//  PhrasesView.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI

struct PhrasesView: View {
    
    
    
    var body: some View {
        NavigationView{
            List{
                Text("Ciao")
            }.navigationBarTitle("Phrases")
        }
    }
}

struct PhrasesView_Previews: PreviewProvider {
    static var previews: some View {
        PhrasesView()
    }
}
