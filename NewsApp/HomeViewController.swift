//
//  ViewController.swift
//  NewsApp
//
//  Created by Matheus Matsumoto on 08/07/22.
//

import UIKit

//MARK: - UIViewController and UITableViewDelegate

class HomeViewController: UIViewController, UITableViewDelegate {

    let apiKey: String = "454a83fa14884bb7b225f6b03a92726a"
    var currentLocation: String = "us"
    var topNewsArray: [CellArticle] = []
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var table: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Get current location.
        currentLocation = Locale.current.regionCode?.lowercased() ?? "us"
        
        // Fetch top news.
        getTopNews()
        
        // Change searchButton color
        searchButton.tintColor = .orange
        
        // Change search button language for brazilian portuguese.
        if currentLocation == "br" {
            searchButton.setTitle("Buscar", for: .normal)
        }
    
        table.dataSource = self
        table.delegate = self
        
    }

    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        
        self.performSegue(withIdentifier: "goToSearch", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "goToSearch" {
            let searchVC = segue.destination as! SearchViewController
            searchVC.searchKeyword = searchBar.text!
            searchVC.currentLocation = currentLocation
            searchVC.apiKey = apiKey
        }
        
    }
    
    
    func getTopNews() {
        
        let urlString: String = "https://newsapi.org/v2/top-headlines?country=\(currentLocation)&apiKey=\(apiKey)"
        let url = URL(string: urlString)
        
        // Check if url is available.
        guard url != nil else {
            return
        }
        
        // Create URLSession to download and upload data.
        let session = URLSession.shared
        
        // Create a task that retrieves the contents of the specified URL.
        let dataTask = session.dataTask(with: url!) { data, response, error in
            
            // Check for errors.
            if error == nil && data != nil {
                
                // Parse JSON.
                let decoder = JSONDecoder()
                
                do {
                    
                    let topNewsFeed = try decoder.decode(NewsFeed.self, from: data!)
                    let topNewsCount: Int = (topNewsFeed.articles?.count)!
                    
                    // Add news to the topNewsArray.
                    for i in 0..<topNewsCount {
                        
                        let cellTitle = topNewsFeed.articles?[i].title
                        let cellUrl = topNewsFeed.articles?[i].url
                        
                        if topNewsFeed.articles?[i].urlToImage != nil {
                            let cellImage = topNewsFeed.articles?[i].urlToImage
                            self.topNewsArray.append(CellArticle(title: cellTitle, imageName: cellImage, url: cellUrl))
                        }
                        else {
                            self.topNewsArray.append(CellArticle(title: cellTitle, imageName: "newspaper", url: cellUrl))
                        }
                        
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.table.reloadData()
                    }
                }
                
                catch {
                    print("Error in JSON Parsing.")
                }
            }
        }
        
        // Make the API Call.
        dataTask.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}



//MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topNewsArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentArticle = topNewsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! HomeTableViewCell
        
        // Setting the cell's label text.
        cell.label.text = currentArticle.title
        cell.label.numberOfLines = 0
        cell.label.sizeToFit()
        
        
        // Setting the cell's image.
        if currentArticle.imageName == "newspaper" {
            cell.iconImageView.image = UIImage(systemName: "newspaper")        }
        else {
            let urlToImage = URL(string: currentArticle.imageName!)
            let dataImage = try? Data(contentsOf: urlToImage!)
            cell.iconImageView.image = UIImage(data: dataImage!)
        }
        
        // Setting cell's button properties.
        cell.goButton.tintColor = .orange
        
        if currentLocation == "br" {
            cell.goButton.setTitle("Ir", for: .normal)
        }
        
        // Add target ViewController to cell's button.
        cell.goButton.tag = indexPath.row
        cell.goButton.addTarget(self, action: #selector(HomeViewController.goButtonTapped(_ :)), for: UIControl.Event.touchUpInside)
        
        // Setting cell's article content.
        cell.url = currentArticle.url
        
        return cell
    }
    
    // The goButton will perform a segue
    @objc func goButtonTapped(_ sender: UIButton!) {
        UIApplication.shared.open(URL(string: topNewsArray[sender.tag].url!)!)
    }
}

