//
//  ContentView.swift
//  ICloud
//
//  Created by Giovanni Di Guida on 19/05/2020.
//  Copyright © 2020 Giovanni Di Guida. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var topics: TopicList
    @State private var newItem = Topic(name: "")
    @State private var showEditTextField = false
    @State private var editedItem = Topic(name: "")
    
    var body: some View {
        NavigationView {
            List{
                Text("Hello World")
            }
                .navigationBarTitle("Topics")
                .navigationBarItems(trailing: Button(action: {
                    print("Sharing coming soon")
                })
                {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                    }
            )
        }
    }
    
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(TopicList())
    }
}
