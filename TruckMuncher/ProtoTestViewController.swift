//
//  ProtoTestViewController.swift
//  TruckMuncher
//
//  Created by Josh Ault on 10/3/14.
//  Copyright (c) 2014 TruckMuncher. All rights reserved.
//

import UIKit
import Alamofire

class ProtoTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        poke(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func poke(sender: AnyObject) {
        let requestBuilder = ActiveTrucksRequest.builder()
        requestBuilder.latitude = 15.0
        requestBuilder.longitude = 14.0
        requestBuilder.searchQuery = "test"
        let truckRequest = requestBuilder.build()
        let data = truckRequest.getNSData()
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-protobuf", "Accept": "application/x-protobuf"]
        Alamofire.upload(.POST, "http://10.0.1.5:8443/com.truckmuncher.api.trucks.TruckService/getActiveTrucks", data)
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                if let nsdata = data as? NSData {
                    var truckResponse = ActiveTrucksResponse.parseFromNSData(nsdata)
                    println("truck response \(truckResponse)")
                }
        }
        
        /*let requestBuilder = HealthRequest.builder()
        let healthRequest = requestBuilder.build()
        let data = healthRequest.getNSData()
        
        Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = ["Content-Type": "application/x-protobuf", "Accept": "application/x-protobuf"]
        Alamofire.upload(.POST, "http://10.0.1.5:8443/com.truckmuncher.api.healthcheck.HealthCheckService/healthcheck", data)
            .response { (request, response, data, error) -> Void in
                println("request \(request)")
                println("response \(response)")
                println("data \(data)")
                println("error \(error)")
                
                if let nsdata = data as? NSData {
                    println("constructing response")
                    var healthResponse = HealthResponse.parseFromNSData(nsdata)
                    println("health response \(healthResponse)")
                }
        }*/
    }
}
