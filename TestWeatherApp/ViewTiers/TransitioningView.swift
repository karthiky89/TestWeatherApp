//
//  TransitioningView.swift
//  TestWeatherApp
//
//  Created by Karthik Yalamanchili on 8/19/24.
//

import SwiftUI

struct TransitioningView: View {
    var body: some View {
        Image("Splash")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .edgesIgnoringSafeArea(.all)
            .overlay(
                VStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(width: 50, height: 50)
                        .padding()
                }
            )
    }
}

#Preview {
    TransitioningView()
}
