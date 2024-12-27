//
//  SplashScreenView.swift
//  iOS_Coffee
//
//  Created by Yohanes  Ari on 18/11/24.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        VStack {
            Image("logo")
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}


#Preview {
    SplashScreenView()
}
