//
//  MasterViewController.swift
//  HomeAwayCodingChallenge
//
//  Created by Andrew Whitehead on 9/11/18.
//  Copyright © 2018 Andrew Whitehead. All rights reserved.
//

import UIKit
import AlamofireImage

class MasterViewController: UITableViewController, UISearchResultsUpdating {

    let CLIENT_ID = "MTMxMTMwMjl8MTUzNjY4MDY3Ny4wMw"
    
    
    let imageCache = AutoPurgingImageCache()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var detailViewController: DetailViewController? = nil
    var events: [Event]?
    
    var queryTask: URLSessionDataTask?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    // MARK: - Query
    
    func apiRequestURL(for searchText: String) -> URL? {
        //if we wanted to do further query string formatting (e.g., remove punctuation, etc), we could pull this into its own method
        //for the purposes of this challenge I decided to keep the formatting to a minimum
        let formattedSearchText = searchText.replacingOccurrences(of: " ", with: "+")
        
        return URL(string: "https://api.seatgeek.com/2/events?client_id=\(CLIENT_ID)&q=\(formattedSearchText)")
    }
    
    func performQuery(for searchText: String, completion: @escaping (_ results: [Event]?, _ response: URLResponse?, _ error: Error?) -> Void) {
        if searchText.count == 0 {
            completion(nil, nil, nil) //in production code we would add a special error for this case
            return
        }
        
        guard let requestURL = apiRequestURL(for: searchText) else {
            completion(nil, nil, nil) //in production code we would add a special error for this case
            return
        }
        
        queryTask?.cancel() //mark the old query for cancellation
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "GET"
        
        queryTask = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data, error == nil else {
                print("fetch error = \(String(describing: error))")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 { //HTTP status code 200 = success
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }
            
            //in production code we would probably want to upload the network responses to some sort of analytics framework
            
            do {
                let decoder = JSONDecoder()
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                decoder.dateDecodingStrategy = .formatted(dateFormatter)
                
                let result = try decoder.decode(QueryResult.self, from: data)
                completion(result.events, response, error)
            } catch let jsonError {
                print("JSON Error = \(String(describing: jsonError))")
                completion(nil, response, error)
            }
        }
        queryTask?.resume()
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showEvent" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.imageCache = imageCache
                controller.event = events![indexPath.row]
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (events?.count ?? 0)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! EventTableViewCell

        if let event = events?[indexPath.row] {
            cell.favoriteIndicator.isHidden = !event.isFavorite
            
            //use AlamofireImage to fetch image asynchronously and then cache
            if let cachedImage = imageCache.image(withIdentifier: String(event.id)) {
                cell.imgView.image = cachedImage
            } else if let imageURL = event.performers?.first?.imageURL {
                cell.imgView.af_setImage(withURL: imageURL, placeholderImage: #imageLiteral(resourceName: "placeholder")) { [weak self, weak cell] (dataResponse) in
                    if let image = cell?.imgView.image {
                        self?.imageCache.add(image, withIdentifier: String(event.id))
                    }
                }
            } else {
                cell.imgView.image = #imageLiteral(resourceName: "placeholder")
                
                imageCache.add(#imageLiteral(resourceName: "placeholder"), withIdentifier: String(event.id))
            }
            
            cell.titleLabel.text = event.title
            
            cell.subtitleLabel.text = (event.venue?.location ?? "Unknown")
            
            cell.detailLabel.text = event.dateDisplayString
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    // MARK: - UISearchResultsUpdating
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else {
            return
        }
        
        performQuery(for: searchText) { [weak self] (events, response, error) in
            self?.events = events
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

}

