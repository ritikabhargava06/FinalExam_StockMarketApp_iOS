//
//  SearchCompanyTableViewController.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import UIKit

//creating a protocol for this view controller - using delegate design pattern
protocol resultDelegate{
    func didFinishSearch(selectedStockIndex:Int)
}

class SearchCompanyTableViewController: UITableViewController {
 
    //using property observer to reload table view as soon as companyNAmearr value is changed
     var companyNamesArr = [String](){
        didSet{
            DispatchQueue.main.async {[unowned self] in
                self.tableView.reloadData()
            }
        }
    }
    
    var delegate:resultDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return companyNamesArr.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "displayCompanyCell", for: indexPath)
        
        cell.textLabel?.text = companyNamesArr[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //passing the user selected row index to AddStockViewController through protocol function
        delegate?.didFinishSearch(selectedStockIndex: indexPath.row)
    }
}
