//
//  Structures.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import Foundation

//auto-complete data structure model
struct stockResults:Codable{
    var count:Int
    var pages:Int
    var results:[results]
}

struct results:Codable{
    var name:String
    var performanceId:String
}

//real-time data structure model
typealias StockData = [String:StockDataValue]

struct StockDataValue: Codable {
    var lastPrice:LastPrice
}

struct LastPrice:Codable{
    var value:Double
}





