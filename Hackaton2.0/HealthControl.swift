//
//  HealthControl.swift
//  Hackaton2.0
//
//  Created by Eugenie Chupris on 7/12/19.
//  Copyright © 2019 Eugenie Chupris. All rights reserved.
//

import Foundation
import HealthKit
import UIKit

class HealthControl
{
    
   
    init() {
        authorize { (success, error) in
            print("HK Authorization finished - success: \(success); error: \(String(describing: error))")
            
           
        }
    }
    func authorize(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, Error.self as Error.Type as! Error)
            return
        }
        
        guard
            let dob = HKObjectType.characteristicType(forIdentifier: .dateOfBirth),
            let sex = HKObjectType.characteristicType(forIdentifier: .biologicalSex),
            let energy = HKObjectType.quantityType(forIdentifier: .activeEnergyBurned),
            let water = HKObjectType.quantityType(forIdentifier: .dietaryWater),
            let step = HKObjectType.quantityType(forIdentifier: .stepCount)
            else {
                completion(false, Error.self as! Error.Type as! Error)
                return
        }
        
        let writing: Set<HKSampleType> = [water]
        let reading: Set<HKObjectType> = [dob, sex, energy, water,step]
        
        HKHealthStore().requestAuthorization(toShare: writing, read: reading, completion: completion)
    }
    func readEnergy() -> Indicator {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return Indicator(NameOfIndicator: "Energy", Value: 0, Norms: 100, Color: UIColor.lightGray)
            
        };
        var values : Double = 0
        let Lastday = Calendar.current.date(byAdding: .day,value: -1, to: Date())
        let last24hPredicate = HKQuery.predicateForSamples(withStart: Lastday, end: Date(), options: .strictEndDate)
        
        let energyQuery = HKSampleQuery(sampleType: energyType,
                                        predicate: last24hPredicate,
                                        limit: HKObjectQueryNoLimit,
                                        sortDescriptors: nil) {
                                            (query, sample, error) in
                                            
                                            guard
                                                error == nil,
                                                let quantitySamples = sample as? [HKQuantitySample] else {
                                                    print("Something went wrong: \(error)")
                                                    return
                                            }
                                            
                                            let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.kilocalorie()) }
                                            print("Total kcal: \(total)")
                                            values = total
                                           
        }
        HKHealthStore().execute(energyQuery)
        return Indicator(NameOfIndicator: "Energy", Value: values, Norms: 1000, Color: UIColor.orange)
    }
    func readWater() -> Indicator {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Sample type not available")
            return Indicator(NameOfIndicator: "Water", Value: 0, Norms: 2000, Color: UIColor.lightGray)
        }
        var values : Double = 0
        let Lastday = Calendar.current.date(byAdding: .day,value: -1, to: Date())
        let last24hPredicate = HKQuery.predicateForSamples(withStart: Lastday, end: Date(), options: .strictEndDate)
        
        let waterQuery = HKSampleQuery(sampleType: waterType,
                                       predicate: last24hPredicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) {
                                        (query, samples, error) in
                                        
                                        guard
                                            error == nil,
                                            let quantitySamples = samples as? [HKQuantitySample] else {
                                                print("Something went wrong: \(error)")
                                                return
                                        }
                                        
                                        let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.literUnit(with: .milli)) }
                                        print("total water: \(total)")
                                        values = total
                                       
        }
        HKHealthStore().execute(waterQuery)
        return Indicator(NameOfIndicator: "Water", Value: values, Norms: 2000, Color: UIColor.blue)
    }
    func writeWater() {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Sample type not available")
            return
        }
        
        let waterQuantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: 200.0)
        let today = Date()
        let waterQuantitySample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: today, end: today)
        
        HKHealthStore().save(waterQuantitySample) { (success, error) in
            print("HK write finished - success: \(success); error: \(error)")
            
        }
    }
    func readStep() -> Indicator {
        guard let StepType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            print("Sample type not available")
            return Indicator(NameOfIndicator: "Step", Value: 0, Norms: 10000,  Color: UIColor.lightGray )
        }
        var values : Double = 0
        let Lastday = Calendar.current.date(byAdding: .day,value: -1, to: Date())
        let last24hPredicate = HKQuery.predicateForSamples(withStart: Lastday, end: Date(), options: .strictEndDate)
        
        let StepQuery = HKSampleQuery(sampleType: StepType,
                                       predicate: last24hPredicate,
                                       limit: HKObjectQueryNoLimit,
                                       sortDescriptors: nil) {
                                        (query, samples, error) in
                                        
                                        guard
                                            error == nil,
                                            let quantitySamples = samples as? [HKQuantitySample] else {
                                                print("Something went wrong: \(error)")
                                                return
                                        }
                                        
                                        let total = quantitySamples.reduce(0.0) { $0 + $1.quantity.doubleValue(for: HKUnit.count()) }
                                      
                                        values = total
                                       
        }
        HKHealthStore().execute(StepQuery)
        
        return Indicator(NameOfIndicator: "Water", Value: values, Norms: 100, Color: UIColor.red)
    }
    
    
}
