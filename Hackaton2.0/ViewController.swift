//
//  ViewController.swift
//  Hackaton2.0
//
//  Created by Eugenie Chupris on 7/12/19.
//  Copyright © 2019 Eugenie Chupris. All rights reserved.
//

import UIKit

import HealthKit
class ViewController: UIViewController {
  
    @IBOutlet weak var ouu: UILabel!
    @IBOutlet weak var water: UILabel!
    @IBOutlet weak var calori: UILabel!
    func authorize(completion: @escaping (Bool, Error?) -> Void) {
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false, Error.self as! Error.Type as! Error)
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
    func readEnergy() {
        guard let energyType = HKSampleType.quantityType(forIdentifier: .activeEnergyBurned) else {
            print("Sample type not available")
            return
        }
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
                                            DispatchQueue.main.async {
                                                self.calori.text = String(format: "Energy: %.2f", total)
                                            }
        }
        HKHealthStore().execute(energyQuery)
    }
    func readWater() {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Sample type not available")
            return
        }
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
                                        DispatchQueue.main.async {
                                            self.water.text = String(format: "Water: %.2f", total)
                                        }
        }
        HKHealthStore().execute(waterQuery)
    }
    @IBAction func writeWater() {
        guard let waterType = HKSampleType.quantityType(forIdentifier: .dietaryWater) else {
            print("Sample type not available")
            return
        }
        
        let waterQuantity = HKQuantity(unit: HKUnit.literUnit(with: .milli), doubleValue: 200.0)
        let today = Date()
        let waterQuantitySample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: today, end: today)
        
        HKHealthStore().save(waterQuantitySample) { (success, error) in
            print("HK write finished - success: \(success); error: \(error)")
            self.readWater()
        }
    }
    func readStep() {
        guard let StepType = HKSampleType.quantityType(forIdentifier: .stepCount) else {
            print("Sample type not available")
            return
        }
        let Lastday = Calendar.current.date(byAdding: .day,value: -1, to: Date())
        let last24hPredicate = HKQuery.predicateForSamples(withStart: Lastday, end: Date(), options: .strictEndDate)
        
        let waterQuery = HKSampleQuery(sampleType: StepType,
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
                                        print("total water: \(total)")
                                        DispatchQueue.main.async {
                                            self.ouu.text = String(format: "Step: %.2f", total)
                                        }
        }
        HKHealthStore().execute(waterQuery)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        authorize { (success, error) in
            print("HK Authorization finished - success: \(success); error: \(error)")
           
            self.readEnergy()
            self.readWater()
            self.readStep()
        }

        
        // Do any additional setup after loading the view.
    }


}

