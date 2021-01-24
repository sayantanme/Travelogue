//
//  ContentView.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 23/12/20.
//

import SwiftUI
import Photos
import AVKit

struct SelectionView: View {
    
    @State var multipleSelectionActivated = false
    @State var initialised : Bool = false
    @ObservedObject var selectionVM : SelectionViewModel
    var body: some View {
        return
            NavigationView {
                GeometryReader { geometry in
                    VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 16, content: {
                        ScrollView([.horizontal, .vertical], showsIndicators: false) {
                            if selectionVM.currentImageModel?.isVideo ?? false {
                                VideoPlayer(player: selectionVM.selectedAVPlayer)
                                    .onAppear() {
                                        selectionVM.selectedAVPlayer?.play()
                                    }.onChange(of: selectionVM.currentImageModel?.id, perform: { (_) in
                                        selectionVM.selectedAVPlayer?.play()
                                    })
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4, alignment: .center)
                            } else {
                                Image(uiImage: selectionVM.selectedImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5, alignment: .center)
                                    .aspectRatio(contentMode: .fit)
                            }
                        }
                        HStack(spacing : 8) {
                            Text("\(selectionVM.currentImageModel?.locations?.first?.thoroughfare ?? "") \(selectionVM.currentImageModel?.locations?.first?.locality ?? "")")
                                .lineLimit(/*@START_MENU_TOKEN@*/2/*@END_MENU_TOKEN@*/)
                                .font(.custom("Courier", size: 16))
                                .padding()
                                .frame(width: 300
                                       , height: 20, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            
                            Button(action: {
                                multipleSelectionActivated.toggle()
                                if !multipleSelectionActivated {
                                    selectionVM.removeAllModels()
                                }
                            }, label: {
                                Text(multipleSelectionActivated ? "Cancel" : "Select")
                                    .fontWeight(.bold)
                                    .font(.custom("Courier", size: 14))
                                    .padding(.all, 6)
                                    .background(Color.gray.blur(radius: 12))
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            })

                        }
                        
                        ImageScrollView(geometry: geometry, selectionVM: selectionVM, multipleSelectionActivated: $multipleSelectionActivated)
                        
                    })
                }.onAppear {
                    PHPhotoLibrary.requestAuthorization { (status) in
                        if status == .authorized {
                            initialised = true
                            selectionVM.fetchAllPhotos()
                        }
                    }
                }
                .navigationBarTitle("Choose", displayMode: .inline)
            }
    }
    
}

struct ImageScrollView : View {
    let geometry: GeometryProxy
    var selectionVM: SelectionViewModel
    let layout = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 0), GridItem(.flexible(), spacing: 4)]
    //var chosenImages: [PhotosModel]
    @Binding var multipleSelectionActivated : Bool
    var body: some View {
        return ScrollView() {
            LazyVGrid(columns: layout, spacing:8, content: {
                ForEach(selectionVM.getAssets()) { item in
                    ZStack(alignment: .bottomTrailing) {
                        Image(uiImage: item.image)
                            .resizable()
                            .frame(width: geometry.size.width * 0.3, height: 120, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            .cornerRadius(8)
                            .opacity(multipleSelectionActivated && selectionVM.selectedImageModels.contains(item) ? 0.5 : 1)
                            .onTapGesture {
                                if multipleSelectionActivated && selectionVM.selectedImageModels.contains(item) {
                                    selectionVM.removeModel(mod: item)
                                } else {
                                    selectionVM.addSelectedModel(model: item)
                                }
                                if item.isVideo {
                                    selectionVM.getVideoFromAsset(asset: item.asset, model: item)
                                } else {
                                    selectionVM.getImageFromAsset(phAsset: item.asset, model: item)
                                }
                            }
                        if item.asset.mediaType == .video {
                            Text(item.duration?.asString(style: .positional) ?? "")
                                .foregroundColor(.white)
                                .padding(4)
                                .shadow(color:.gray,radius: 5)
                        }
                        
                    }
                }
            })
        }
    }
}



struct SelectionView_Preview: PreviewProvider {
    static var previews: some View {
        Group {
            SelectionView(selectionVM: SelectionViewModel())
        }
    }
}
