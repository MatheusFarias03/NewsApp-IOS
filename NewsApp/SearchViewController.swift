//
//  SearchedViewController.swift
//  NewsApp
//
//  Created by Matheus Matsumoto on 10/07/22.
//

import UIKit

class SearchViewController: UIViewController, UITableViewDelegate {

    var searchKeyword: String = "Apple"
    var currentLocation: String = "us"
    var apiKey: String = ""
    var searchNewsArray: [CellArticle] = []
    
    @IBOutlet weak var searchLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var searchTableView: UITableView!
    
    // Date settings.
    var date = Date()
    var dateFormater = DateFormatter()
    var currentDate: String = "2022-01"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchTableView.dataSource = self
        searchTableView.delegate = self
        
        // Get current date.
        dateFormater.dateFormat = "yyyy-MM"
        currentDate = dateFormater.string(from: date)
        
        searchLabel.text = "Searched for : \(searchKeyword)"
        
        // Language configuration
        if currentLocation == "br" {
            backButton.setTitle("Voltar", for: .normal)
            searchLabel.text = "Busca : \(searchKeyword)"
        }
        
        // Get the news for keyword.
        getSearchedNews()
        
        // Back button color
        backButton.tintColor = .orange
        
    }
    
    @IBAction func backButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    func getSearchedNews() {
        
        let urlString: String = "https://newsapi.org/v2/everything?q=\(searchKeyword)&from=\(currentDate)&sortBy=popularity&apiKey=\(apiKey)"
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
                    
                    let searchNewsFeed = try decoder.decode(NewsFeed.self, from: data!)
                    let searchNewsFeedCount: Int = (searchNewsFeed.articles?.count)!
                    
                    for i in 0..<searchNewsFeedCount {
                        
                        let cellTitle = searchNewsFeed.articles?[i].title
                        let cellUrl = searchNewsFeed.articles?[i].url
                        
                        if searchNewsFeed.articles?[i].urlToImage != nil {
                            let cellImage = searchNewsFeed.articles?[i].urlToImage
                            self.searchNewsArray.append(CellArticle(title: cellTitle, imageName: cellImage, url: cellUrl))
                        }
                        else {
                            self.searchNewsArray.append(CellArticle(title: cellTitle ?? "-", imageName: "newspaper", url: cellUrl ?? "-"))
                        }
                        
                    }
                    
                    DispatchQueue.main.async {
                        self.searchTableView.reloadData()
                    }
                }
                
                catch {
                    print("Error in JSON Parsing.")
                    print(error)
                }
            }
        }
        
        // Make API Call.
        dataTask.resume()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }

}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchNewsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let currentArticle = searchNewsArray[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchTableViewCell
        
        // Setting the cell's label text.
        cell.label.text = currentArticle.title
        cell.label.numberOfLines = 0
        cell.label.sizeToFit()
        
        
        // Setting the cell's image.
        if currentArticle.imageName == "newspaper" {
            cell.iconImageView.image = UIImage(systemName: "newspaper")        }
        else {
            let urlToImage = URL(string: currentArticle.imageName!)
            if let dataImage = try? Data(contentsOf: urlToImage!) {
                cell.iconImageView.image = UIImage(data: dataImage)
            } else {cell.iconImageView.image = UIImage(systemName: "newspaper")}
        }
        
        // Setting cell's button properties.
        cell.goButton.tintColor = .orange
        
        if currentLocation == "br" {
            cell.goButton.setTitle("Ir", for: .normal)
        }
        
        // Add target ViewController to cell's button.
        cell.goButton.tag = indexPath.row
        cell.goButton.addTarget(self, action: #selector(SearchViewController.goButtonTapped(_ :)), for: UIControl.Event.touchUpInside)
        
        // Setting cell's article content.
        cell.url = currentArticle.url
        
        return cell
        
    }
    
    @objc func goButtonTapped(_ sender: UIButton!) {
        UIApplication.shared.open(URL(string: searchNewsArray[sender.tag].url!)!)
    }
    
    
}
