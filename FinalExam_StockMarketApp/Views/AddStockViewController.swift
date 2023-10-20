//
//  AddStockViewController.swift
//  FinalExam_StockMarketApp
//
//  Created by user248634 on 10/16/23.
//

import UIKit

class AddStockViewController: UIViewController {
    
    var stockResultsObj : stockResults?
    var addedStockIndex:Int?
    
    @IBOutlet weak var isActiveSegmentedControl: UISegmentedControl!
    @IBOutlet weak var addStockLabel: UILabel!
    @IBOutlet weak var addStackView: UIStackView!
    
        //instantiating a searchbarcontroller object - using UISearchBarController
    lazy var searchCompanyTableController = self.storyboard?.instantiateViewController(withIdentifier: "SearchCompanyStoryBoard") as? SearchCompanyTableViewController
    lazy var searchController = UISearchController(searchResultsController: searchCompanyTableController)
    var context = CoreDataStack.shared.persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()

        addStackView.isHidden = true
        navigationItem.searchController = searchController
        //assiging the delegate for searchcontroller - using delegate design pattern
        searchController.searchResultsUpdater=self
        //assigning the delegate for searchCompanyViewController - using delegate design pattern
        searchCompanyTableController?.delegate = self
        // Do any additional setup after loading the view.
    }
    

    @IBAction func addStockButtonPrssed() {
        //creating stcok object with name & performance id and  saving the context
        //adding entity eobject in out model as per inputs from the view- using MVC design pattern
        let newStockObj = Stocks(context: context)
        if let resultsArr = stockResultsObj?.results {
            newStockObj.stockName = resultsArr[addedStockIndex!].name
            newStockObj.performanceId = resultsArr[addedStockIndex!].performanceId
            if isActiveSegmentedControl.selectedSegmentIndex==0 {
                newStockObj.isActive = true
            }else {
                newStockObj.isActive = false
            }
            print("\(newStockObj)")
            CoreDataStack.shared.saveContext()
        }
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//conforming to searchbarcontroller's protocol - using delegate design pattern
extension AddStockViewController:UISearchResultsUpdating{
 
    func updateSearchResults(for searchController: UISearchController) {
        //calling the auto-complete api user entered search text to get the list of stocks
        if let searchTxt = searchController.searchBar.text{
                let url = "https://ms-finance.p.rapidapi.com/market/v2/auto-complete"
                let query = ["q":searchTxt.lowercased()]
                 Service.shared.getData(urlString: url, query: query) { result in
                     switch result{
                         case .failure(let err) : print ("\(err)")
                         case .success(let xdata) :
                         print("\(xdata)")
                         guard let resultSet = try? JSONDecoder().decode(stockResults.self, from: xdata) else{return}
                         self.stockResultsObj = resultSet
                         print("\(resultSet)")
                         //adding the list of stock company names in an array and assiging it to searchCompanyViewController's object
                         let stocksArr = resultSet.results
                         var arr = [String]()
                         for eachStock in stocksArr{
                             arr.append(eachStock.name)
                         }
                         self.searchCompanyTableController?.companyNamesArr = arr
                }
            }
        }
    }
}

//conforming to SeachCompnayViewController's protocol - using delegate design pattern
extension AddStockViewController:resultDelegate{
    func didFinishSearch(selectedStockIndex: Int) {
        //disabling the searchbarcontroller controller and displaying the stock name on this view
        searchController.isActive=false
        addedStockIndex = selectedStockIndex
        print("\(addedStockIndex!)")
        if let resultsArr = stockResultsObj?.results {
            addStockLabel.text = resultsArr[addedStockIndex!].name
        }
        addStackView.isHidden=false
    }
}
