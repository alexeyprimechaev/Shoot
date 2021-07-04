//
//  CaptureInterface.swift
//  Shoot
//
//  Created by Alexey Primechaev on 7/4/21.
//

import SwiftUI
import AVFoundation

struct CaptureInterface: View {
    
    @StateObject var model = CameraViewModel()
    
    @State var isExperimental = false
    
    var body: some View {
        if isExperimental {
            HStack {
                Spacer()
                Button {
                    model.capturePhoto()
                } label: {
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 73, height: 73, alignment: .center)
                        .overlay(
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 65, height: 65, alignment: .center)
                        )

                }
                Spacer()
                Menu {
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Telephoto", systemImage: "circle.grid.cross.up.fill")
                        Label("Wide", systemImage: "circle.grid.cross.right.fill").tag(true)
                        Label("Ultrawide", systemImage: "circle.grid.cross.down.fill")
                    })
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Flash On", systemImage: "bolt").tag(true)
                        Label("Flash Off", systemImage: "bolt.slash").tag(false)
                    })
                    
                    Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                        Label("Grid", systemImage: "square.split.2x2").tag(true)
                        Label("Natural", systemImage: "square").tag(false)
                    })
                    
                    
                } label: {
                    Image(systemName: "ellipsis.circle").font(.title).padding(28).foregroundColor(.white)
                }
                Spacer()
                
            }
        } else {
            GeometryReader { geometry in
            
            Group {
                       if model.photo != nil {
                           Image(uiImage: model.photo.image!)
                               .resizable()
                               .aspectRatio(contentMode: .fill)
                               .frame(width: 32, height: 32)
                               .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                               .animation(.spring())
                           
                       } else {
                           RoundedRectangle(cornerRadius: 8)
                               .frame(width: 52, height: 52, alignment: .center)
                               .foregroundColor(.black)
                       }
                   }.position(x: (geometry.size.width - (geometry.size.width + 73)/2)/2)

            Button {
                model.capturePhoto()
            } label: {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 73, height: 73, alignment: .center)
                    .overlay(
                        Circle()
                            .stroke(Color.black, lineWidth: 2)
                            .frame(width: 65, height: 65, alignment: .center)
                    )

            }
            .position(x: geometry.size.width/2)

            Menu {
                Picker(selection: $model.selectedCamera, label: Text("Flash"), content: {
                    Label("Telephoto", systemImage: "circle.grid.cross.up.fill").tag(SelectedCamera.telephoto)
                    Label("Wide", systemImage: "circle.grid.cross.right.fill").tag(SelectedCamera.wide)
                    Label("Ultrawide", systemImage: "circle.grid.cross.down.fill").tag(SelectedCamera.ultrawide)
                    Label("Front", systemImage: "circle.grid.cross.down.fill").tag(SelectedCamera.front)
                })
                Picker(selection: $model.isFlashOn, label: Text("Flash"), content: {
                    Label("Flash On", systemImage: "bolt").tag(true)
                    Label("Flash Off", systemImage: "bolt.slash").tag(false)
                })
                
                
                
            } label: {
                Image(systemName: "ellipsis.circle").font(.title).padding(28).foregroundColor(.white)
            }.position(x: geometry.size.width - (geometry.size.width - (geometry.size.width + 73)/2)/2)
            .frame(height: 73)
            .onAppear {
                print(geometry.size.width)
                print(geometry.size.height)
            }
            
        

        }.frame(height: 73)
        }
    
    }
}
