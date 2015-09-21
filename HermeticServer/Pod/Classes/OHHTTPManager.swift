//
//  OHHTTPManager.swift
//  OHHTTPHermeticServer
//
//  Created by MACBOOK on 30/08/15.
//  Copyright © 2015 JaimeLeon. All rights reserved.
//

import UIKit
import OHHTTPStubs


let DownloadSpeedGPRS : Double  =   -7
let DownloadSpeedEDGE : Double =    -16
let DownloadSpeed3G : Double =      -400
let DownloadSpeed3GPlus : Double =  -900
let DownloadSpeedWifi : Double   =  -1500


class OHHTTPManager: NSObject {
    
    static let sharedInstance = OHHTTPManager()
    
    //MARK:Setup---
    
    func start()
    {
        OHHTTPStubs.setEnabled(true)
        self.configurationFromPlist()
    }
    
    func stop()
    {
        OHHTTPStubs.removeAllStubs()
    }
    
    
    //MARK:Private pList---
    private func configurationFromPlist()
    {
        let path = NSBundle.mainBundle().pathForResource("ConfigurationHermetic", ofType: "plist")
        let configurationHermetic: NSDictionary = NSDictionary(contentsOfFile: path!)!
        let requests = configurationHermetic.objectForKey("request") as! NSArray
        
        for request in requests
        {
            let enable = request.objectForKey("enable") as! Bool
            
            if enable == true
            {
                let statusCode = request.objectForKey("status") as! NSNumber
                let downloadSpeed = request.objectForKey("downloadSpeed") as! NSNumber
                let url = request.objectForKey("url") as! String
                let contains = request.objectForKey("contains") as! String
                let endPoint = request.objectForKey("endPoint") as! String
                
                
                if url.isEmpty
                {
                    if contains.isEmpty
                    {
                        if !endPoint.isEmpty
                        {
                            self.startHermeticServerJSONWithEndpoint(endPoint, pathForFile: request.objectForKey("path") as! String, statusCode: statusCode.intValue, downloadSpeed: downloadSpeed.doubleValue)
                        }
                    }
                    else
                    {
                        self.startHermeticServerJSONWithContainsURL(contains, pathForFile: request.objectForKey("path") as! String, statusCode: statusCode.intValue, downloadSpeed:downloadSpeed.doubleValue)
                        
                    }
                }
                else
                {
                    self.startHermeticServerJSONWithURL(url, pathForFile: request.objectForKey("path") as! String, statusCode: statusCode.intValue, downloadSpeed: downloadSpeed.doubleValue)
                    
                }
            }
        }
        
    }
    
    
    //MARK:Private General Hermetic---
    private func startHermeticServer(url:String, endPoint:String ,data:NSData, downloadSpeed:Double, requestTime:Double, responseTime:Double)
    {
        OHHTTPStubs.stubRequestsPassingTest({(request: NSURLRequest!) in
            
            if !(endPoint.isEmpty)
            {
                let predicateValide = self.predicateWithEndPoint(endPoint, request: request) as Bool
                return (predicateValide == true) ? true : false
            }
            else if !(url.isEmpty)
            {
                return request.URL! == (NSURL(string:url)) ? true : false
            }
            else
            {
                return false
            }
            
            }, withStubResponse: { _ in
                
                return OHHTTPStubsResponse(data: data, statusCode:200, headers:nil).responseTime(downloadSpeed)
        })
    }
    
    //MARK:URL---
    func startHermeticServerURLData(url:String, data:NSData ,downloadSpeed:Double)
    {
        self.startHermeticServer(url, endPoint: "",data: data, downloadSpeed:downloadSpeed, requestTime:0, responseTime:0)
    }
    
    func startHermeticServerURLString(url:String, string:String ,downloadSpeed:Double)
    {
        let data : NSData = string.dataUsingEncoding(NSUTF8StringEncoding)!
        self.startHermeticServer(url, endPoint: "", data: data, downloadSpeed:downloadSpeed, requestTime:0, responseTime:0)
    }
    
    func startHermeticServerURLImage(url:String, image:UIImage ,downloadSpeed:Double)
    {
        let data : NSData = UIImageJPEGRepresentation(image, 1.0)!
        self.startHermeticServer(url, endPoint: "",data: data , downloadSpeed:downloadSpeed, requestTime:0, responseTime:0)
    }
    
    //MARK:URL---
    private func startHermeticServerJSON(url:String, endPoint:String, containsURL:String, pathForFile:String, statusCode: Int32, downloadSpeed:Double)
    {
        OHHTTPStubs.stubRequestsPassingTest({(request: NSURLRequest!) in
            
            if !(endPoint.isEmpty)
            {
                let predicateValide = self.predicateWithEndPoint(endPoint, request: request) as Bool
                return (predicateValide == true) ? true : false
            }
            else if !(containsURL.isEmpty)
            {
                let predicateValide = self.predicateWithURLContains(containsURL, request: request) as Bool
                return (predicateValide == true) ? true : false
            }
            else if !(url.isEmpty)
            {
                return request.URL! == (NSURL(string:url)) ? true : false
            }
            else
            {
                return false
            }
            
            }, withStubResponse: { _ in
                let stubPath = OHPathForFile(pathForFile, self.dynamicType)
                return OHHTTPStubsResponse(fileAtPath: stubPath!, statusCode: statusCode, headers: ["Content-Type":"application/json"]).responseTime(downloadSpeed)
        })
    }
    
    func startHermeticServerJSONWithURL(url:String, pathForFile:String, statusCode:Int32, downloadSpeed:Double)
    {
        self.startHermeticServerJSON(url, endPoint: "", containsURL: "", pathForFile: pathForFile, statusCode: statusCode, downloadSpeed:downloadSpeed)
    }
    
    func startHermeticServerJSONWithEndpoint(endPoint:String, pathForFile:String, statusCode:Int32, downloadSpeed:Double)
    {
        self.startHermeticServerJSON("", endPoint: endPoint, containsURL: "", pathForFile: pathForFile, statusCode: statusCode, downloadSpeed:downloadSpeed)
    }
    
    func startHermeticServerJSONWithContainsURL(containsURL:String, pathForFile:String, statusCode:Int32, downloadSpeed:Double)
    {
        self.startHermeticServerJSON("", endPoint: "", containsURL: containsURL, pathForFile: pathForFile, statusCode: statusCode, downloadSpeed:downloadSpeed)
    }
    
    
    private func predicateWithEndPoint(endPoint:String , request:NSURLRequest) -> Bool
    {
        let predicate = NSPredicate(format: "SELF ENDSWITH %@", endPoint)
        return predicate.evaluateWithObject(request.URL!.relativePath!) as Bool
    }
    
    private func predicateWithURLContains(containsURL:String , request:NSURLRequest) -> Bool
    {
        let predicate = NSPredicate(format: "SELF CONTAINS %@", containsURL)
        return predicate.evaluateWithObject(request.URL!.absoluteString) as Bool
    }
    
}


