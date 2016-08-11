//
//  ShowItemsViewController.swift
//  CSRecruitmentTest
//
//  Created by msm72 on 08.08.16.
//  Copyright (c) 2016 Monastyrskiy Sergey. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so you can apply
//  clean architecture to your iOS and Mac projects, see http://clean-swift.com
//

import UIKit
import CoreData


// MARK: - Input & Output protocols
protocol ShowItemsViewControllerInput {
    func displayItems(viewModel: ShowItemsViewModel)
}

protocol ShowItemsViewControllerOutput {
    func getItemsWith(request: ShowItemsRequest)
}


class ShowItemsViewController: UIViewController {
    // MARK: - Properties
    var output: ShowItemsViewControllerOutput!
    var router: ShowItemsRouter!
    var itemsForDisplay: [ShowItemsViewModel.DisplayedItem] = []
    var needReloadTable: Bool!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    var searchText: String?
    var fetchedResultsController: NSFetchedResultsController?
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Reloading...")
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), forControlEvents: .ValueChanged)
        
        return refreshControl
    }()
    

    // MARK: - Class Functions
    override func viewDidLoad() {
        super.viewDidLoad()
    
        ShowItemsConfigurator.sharedInstance.configure(self)

        tableView.registerNib(UINib(nibName: "ShowItemsTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        
        // Add UIRefreshControl
        self.tableView.addSubview(self.refreshControl)
        
        // Delegate
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self
        
        // Load data
        self.loadData()
        self.needReloadTable = true
    }
  

    // MARK: - Custom Functions
    func loadData() {
        let request: ShowItemsRequest!
        
        if self.searchText != nil {
            request = ShowItemsRequest(searchText: self.searchText!)
        } else {
            request = ShowItemsRequest(searchText: nil)
        }

        self.output.getItemsWith(request)
    }

    func handleRefresh(refreshControl: UIRefreshControl) {
        let delayInSeconds: Int64 = 2
        let popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * Int64(NSEC_PER_SEC))
        
        dispatch_after(popTime, dispatch_get_main_queue()) {
            NSURLCache.sharedURLCache().removeAllCachedResponses()
            
            // Core Data: delete all entities
            CoreDataManager.instance.cleanCoreData()
            
            self.needReloadTable = false
            self.loadData()
            
            //self.loadDataFromLocalHost()
            self.refreshControl.endRefreshing()
            //self.loadDataFromCoreData(withReloadData: true)
            print("")
        }
    }
}


// MARK: - ShowItemsViewControllerInput
extension ShowItemsViewController: ShowItemsViewControllerInput {
    func displayItems(viewModel: ShowItemsViewModel) {
        self.itemsForDisplay = viewModel.displayedItems
        
        if self.needReloadTable! {
            self.tableView.reloadData()
            self.needReloadTable = false
        }
    }
}


// MARK: - UITableViewDataSource
extension ShowItemsViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.itemsForDisplay.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as! ShowItemsTableViewCell
        
        cell.item = self.itemsForDisplay[indexPath.row]
        
        return cell
    }
}


// MARK: - UITableViewDelegate
extension ShowItemsViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if self.searchBar.isFirstResponder() {
            self.searchBar.resignFirstResponder()
            self.searchText = nil
            self.needReloadTable = true
            
            self.loadData()
        }
    }
}


// MARK: - UISearchBarDelegate
extension ShowItemsViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchText = searchBar.text
        self.needReloadTable = true
        self.loadData()
        self.searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText.isEmpty ? nil : searchBar.text!
        self.needReloadTable = true
        self.loadData()
        
        // Hide keyboard
        //            searchBar.performSelector(#selector(resignFirstResponder), withObject: nil, afterDelay: 0.1)
    }
}

