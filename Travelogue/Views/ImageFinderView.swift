//
//  ImageFinderView.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 23/12/20.
//

import SwiftUI

struct ImageFinderView: View {
    @State private var isShowPhotoLibrary = false
        @State private var image = UIImage()
    var googleText = OCRReader()
     
        var body: some View {
            VStack {
     
                Image(uiImage: self.image)
                    .resizable()
                    .scaledToFill()
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .edgesIgnoringSafeArea(.all)
     
                Button(action: {
                    self.isShowPhotoLibrary = true
                }) {
                    HStack {
                        Image(systemName: "photo")
                            .font(.system(size: 20))
     
                        Text("Take Photo")
                            .font(.headline)
                    }
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: 50)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(20)
                    .padding(.horizontal)
                }
            }
            .sheet(isPresented: $isShowPhotoLibrary) {
                ImagePicker(sourceType: .camera) { (image) in
                    self.image = image
                    googleText.performOCR(on: image, recognitionLevel: .accurate)
                }
            }
        }
}

struct ImageFinderView_Previews: PreviewProvider {
    static var previews: some View {
        ImageFinderView()
    }
}
