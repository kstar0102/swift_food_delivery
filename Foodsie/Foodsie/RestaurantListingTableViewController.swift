//
//  RestaurantListingTableViewController.swift
//  Foodsie
//
//  Created by Cons Bulaqueña on 18/05/2018.
//  Copyright © 2018 consios. All rights reserved.
//

import UIKit



class RestaurantListingTableViewController: UITableViewController
{
    
    @IBOutlet weak var SearchBar: UISearchBar!
    
    @IBOutlet weak var menuBarButtonItem: UIBarButtonItem!
    
    //empty array of restaurants
    var restaurants = [Restaurant]()
    
    
    var filteredRestaurants = [Restaurant]()
    let activityIndicatorView = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuBarButtonItem.target = self.revealViewController()
        menuBarButtonItem.action = #selector(SWRevealViewController.revealToggle(_: ))
        
        self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    //tell search bar this class is delegate
        SearchBar.delegate = self
        
        getRestaurants()
        
    }
    
    
    //fetch data
    func getRestaurants()
    {
        showActivityIndicator()
        
        Restaurant.getRestaurants { (restaurants) in
            DispatchQueue.main.async {
                self.restaurants = restaurants
                self.tableView.reloadData()
                
                self.hideActivityIndicator()
            }
            
        }
    }
    
    // MARK: - Activity Indicator method
    
    func showActivityIndicator()
    {
        activityIndicatorView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        activityIndicatorView.center = tableView.center
        activityIndicatorView.activityIndicatorViewStyle = .whiteLarge
        activityIndicatorView.color = .red
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.startAnimating()
    }
    
    func hideActivityIndicator()
    {
        activityIndicatorView.stopAnimating()
        activityIndicatorView.removeFromSuperview()
    }
    
    // Mark: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "ShowMealsViewController" {
        let mealsVC = segue.destination as! MealsViewController
            //should be "" empty string, not nil to avoid fatal error
        if SearchBar.text != "" {
            mealsVC.restaurant =
                self.filteredRestaurants[self.tableView.indexPathForSelectedRow!.row]
        } else {
            mealsVC.restaurant =
            self.restaurants[self.tableView.indexPathForSelectedRow!.row]
        }
    }
}

}
// Mark: UITableViewDataSource
//implement UITableView data source

extension RestaurantListingTableViewController
{
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //not empty thus filtered restos.
        if SearchBar.text != "" {
            return self.filteredRestaurants.count
        }
        
        return restaurants.count
    }
    
    //fetch data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RestaurantCell", for: indexPath) as! RestaurantCell
        
       // For FILTER Restaurants
        var restaurant = self.restaurants[indexPath.row]
        
        //search not empty
        if SearchBar.text != "" {
            restaurant = self.filteredRestaurants[indexPath.row]
            
        }
        
        cell.restaurant = restaurant
        cell.selectionStyle = .none //disable grey selection
        
        
        return cell
    }

}

extension RestaurantListingTableViewController : UISearchBarDelegate
{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filteredRestaurants = self.restaurants.filter({ (restaurant) -> Bool in
            return restaurant.name?.lowercased().range(of: searchText.lowercased()) != nil
        })
        
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}


