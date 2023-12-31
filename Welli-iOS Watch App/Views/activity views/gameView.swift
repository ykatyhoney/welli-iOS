//
//  GameView.swift
//  welli Watch App
//
//  Created by Raul Cheng on 2/27/23.
//

import SwiftUI
import UIKit
import HealthKit

struct gameView: View {
    let healthStore = HKHealthStore()
    let heartRateQuantity = HKUnit(from: "count/min")
    
    @State var num = 0.0
    @State var scale = 1.0
    @State private var value = 0
    
    @State private var currentImage = 0
    let images = (0...1).compactMap { UIImage(named: "frame_\($0)_delay-0.5s") } //Game Images
    //let images = (0...45).compactMap { UIImage(named: "puzzle_\($0)") } //Puzzle Images
    
    var body: some View{
        ScrollView{
            VStack{
                Text("Take time to play a game. Click finish when you are done.")
                //Text("Take time to do a puzzle. Click finish when you are done.")
                    .padding()
                    .frame(width:180, height: 100)
                
                Image(uiImage: images[currentImage])
                            .resizable()
                            .scaledToFit()
                            .offset(y:-20)
                            //.frame(width: 130, height: 100)
                            .onAppear {
                                Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                                    withAnimation(Animation.linear(duration: 0.0)) {
                                        currentImage = (currentImage + 1) % images.count
                                    }
                                }
                            }
                
                NavigationLink(destination: finishView(), label:{ Text("Finished")
                        .bold()
                }).offset(y:-15)
                //start of animation
                    .opacity(num)
                    .onAppear
                {
                    let delay = Animation.easeIn(duration: 1).delay(2)
                    
                    withAnimation(delay)
                    {
                        num += 1
                    }
                }
            }.navigationBarBackButtonHidden(true)
            .padding()
            .onAppear(perform: start)
        }
    }
    
    func start() {
        authorizeHealthkit()
        startHeartRateQuery(quantityTypeIdentifier: .heartRate)
    }

    func authorizeHealthkit() {
        // Used to define the identifiers that create quanitity type objects.
        let healthKitTypes: Set = [
            HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!]
        /*let typesToShare: Set = [HKQuantityType.quantityType(forIdentifier: .heartRate )]
        let typesToRead: Set = [
            HKQuantityType.quantityType(forIdentifier: .heartRate)!]*/
        // Request permission to save and read the specified data types.
        healthStore.requestAuthorization(toShare: healthKitTypes, read: healthKitTypes) {
            (success, error)
            in
        }
    }

    private func startHeartRateQuery(quantityTypeIdentifier: HKQuantityTypeIdentifier) {
        // We want data points from our current device
        let devicePredicate = HKQuery.predicateForObjects(from: [HKDevice.local()])
        
        // A query that returns changes to the HealthKit store, including a snapshot of new changes and continuous monitoring as a long-runninig query.
        let updateHandler: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            query, samples, deletedObjects, queryAnchor, error in
            
        // A sample that represents a quantity, including the value and the units.
            guard let samples = samples as? [HKQuantitySample] else {
                return
            }
            
            self.process(samples, type: quantityTypeIdentifier)
            
        }
        
        // It provides us with both the ability to receive a snapshot of data, and then on subsequeny calls, a snapshot of what has changed.
        let query = HKAnchoredObjectQuery(type: HKObjectType.quantityType(forIdentifier: quantityTypeIdentifier)!, predicate: devicePredicate, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: updateHandler)
        
        query.updateHandler = updateHandler
        
        // query execution
        
        healthStore.execute(query)
    }

    private func process(_ samples: [HKQuantitySample], type: HKQuantityTypeIdentifier) {
        // variable initialization
        var lastHeartRate = 0.0
        
        // cycle and value assignment
        for sample in samples {
            if type == .heartRate {
                lastHeartRate = sample.quantity.doubleValue(for: heartRateQuantity)
            }
            
            self.value = Int(lastHeartRate)
        }
    }
}

struct gameView_Previews: PreviewProvider {
    static var previews: some View {
        gameView()
    }
}
