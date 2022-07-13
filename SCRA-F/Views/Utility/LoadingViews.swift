//
//  LoadingViews.swift
//  SCRA-F
//
//  Created by KeefCheif on 6/20/22.
//

import SwiftUI

struct GenericLoadingView: View {
    
    var message: String?
    var size: CGFloat?
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: self.colorScheme == .light ? Color(UIColor.systemGray.withAlphaComponent(0.9)) : Color(UIColor.white.withAlphaComponent(0.9))))
                .scaleEffect(self.size == nil ? 3 : self.size!)
                .padding(2) // Prevents overlapping if the wheel is next to something
            
            if let message = message {
                Text(message)
                    .fontWeight(.heavy)
                    .foregroundColor(.black)
                    .font(.subheadline)
            }
        }
    }
}

struct GenericLoadingViewBackground: View {
    
    var message: String?
    var color: UIColor

    var body: some View {
        
        ZStack {
            Color(self.color)
                .ignoresSafeArea()
                .opacity(0.8)
            
            GenericLoadingView(message: self.message)
        }
    }
}

struct GenericLoadingView_Previews: PreviewProvider {
    static var previews: some View {
        GenericLoadingView()
    }
}
