//
//  ContentView.swift
//  ThreadsScroll
//
//  Created by Afeez Yunus on 29/07/2025.
//

import SwiftUI
import RiveRuntime

struct ContentView: View {
    var reload = RiveViewModel(fileName: "reload", stateMachineName: "State Machine 1")
    @State var reloadValue: Float = 0
    @State private var reductionTimer: Timer?
    @State var padTop: CGFloat = 0
    @State var logoSize: CGFloat = 50
    var body: some View {
        ZStack{
            VStack {
                reload.view()
                    .frame(width:50, height:50)
                    .padding(.top, (padTop / 4) + 24)
                Spacer()
            }
                RoundedRectangle(cornerRadius: 16 )
                    .frame(maxWidth:.infinity, maxHeight: .infinity)
                    .foregroundStyle(Color("Bg"))
                    .padding(16)
                    .padding(.top, padTop)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                // Calculate drag value based on vertical movement
                                // Clamp between 0 and 100
                                let dragDistance = max(0, value.translation.height)
                                self.reloadValue = min(100, Float(dragDistance / 6)) // Divide by 2 to make it less sensitive
                                self.padTop = CGFloat(min(300, Float(dragDistance / 3)))
                                logoSize  = CGFloat(min(100, Float(dragDistance / 12))) + 50
                                print (reloadValue)
                                
                            }
                            .onEnded { _ in
                                // Reset to 0 when drag ends
                                startGradualReduction()
                                withAnimation(.spring(duration:0.4)){
                                    padTop = 0
                                    logoSize = 50
                                }
                                
                            }
                    )
                    .onAppear{
                        updateBind()
                    }
                    .onChange(of: reloadValue) { oldValue, newValue in
                        updateBind()
                    }
            
        }
        .preferredColorScheme(.dark)
    }
    func updateBind() {
        let reloadVm = reload.riveModel!.riveFile.viewModelNamed("Reload Vm")
        let reloadInstance = reloadVm?.createInstance(fromName: "Main Instance")
        if let reloadInstance = reloadInstance {
            reload.riveModel?.stateMachine?.bind(viewModelInstance: reloadInstance)
        }
        reloadInstance?.numberProperty(fromPath: "drag value")?.value = reloadValue
        reload.triggerInput("advance")
    }
    private func startGradualReduction() {
        reductionTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { timer in
            if reloadValue > 0 {
                reloadValue = max(0, reloadValue - 3) // Reduce by 2 each tick
               // padTop = CGFloat(reloadValue)
            } else {
                timer.invalidate()
                reductionTimer = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
