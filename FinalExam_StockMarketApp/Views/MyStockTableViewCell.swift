//
//  MyStockTableViewCell.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import UIKit

class MyStockTableViewCell: UITableViewCell {

    
    @IBOutlet weak var stockNotesLabel: UILabel!
    @IBOutlet weak var stockPriceLabel: UILabel!
    @IBOutlet weak var stockNameLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setNotesLabel(notesList:NSSet?){
        if let notesArr = notesList {
            var notesString = "Notes:"
            //if notes exists, joining all notes wiht a "," and storing it in a string
            if notesArr.count>0{
                var notesDescArr = [String]()
                for eachNote in notesArr.reversed(){
                    if let noteDesc = (eachNote as! Note).noteDescription{
                        notesDescArr.append(noteDesc)
                    }
                }
                let oldNotesString = notesDescArr.joined(separator:",")
                //appending Notes: with already added notes string
                notesString = notesString+oldNotesString
            }
            stockNotesLabel.text = notesString
        }else{
            stockNameLabel.text = ""
        }
    }
    
    func setPriceLabel(performID:String){
        //calling real-time-data endpoint with performance id as query param to get price value
        let url = "https://ms-finance.p.rapidapi.com/market/v2/get-realtime-data"
        let query = ["performanceIds":performID]
    Service.shared.getData(urlString: url, query: query) { result in
        switch result{
        case .failure(let err) : print ("\(err)")
        case .success(let xdata) :
            print("\(xdata)")
            guard let resultSet = try? JSONDecoder().decode(StockData.self, from: xdata) else{
                return
            }
            //setting up the lastprice value on UI
            if let firstStock = resultSet[performID] {
                DispatchQueue.main.async {[unowned self] in
                    let stringVal = String(firstStock.lastPrice.value)
                    print("\(stringVal)")
                    self.stockPriceLabel.text = stringVal
                }
            }
        }
    }
}
    
    func configCell(stockObj:Stocks){
        if let name = stockObj.stockName{
            print("\(name)")
        }
        
        stockNameLabel.text = stockObj.stockName
        setNotesLabel(notesList:stockObj.notes)
        guard let perfromanceID = stockObj.performanceId else{return}
        print("\(perfromanceID)")
        setPriceLabel(performID:perfromanceID)
    }

}
