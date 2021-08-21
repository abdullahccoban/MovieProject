//
//  ViewController.swift
//  MovieProject
//
//  Created by Abdullah Coban on 14.07.2021.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData

protocol MyDataSendingDelegateProtocol {
    func sendDataToMovieDetailController(id: Int)
}

class ViewController: UIViewController {
    
    var delegate: MyDataSendingDelegateProtocol? = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionButton: UIButton!
    
    var movies = MovieList(results: [Movie](), page: 1)
    var movieList = [Movie]()
    var filteredMovies = [Movie]()
    var isFiltering: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let PageMovies = fetchMovie(Page: 1)
        movieList.append(contentsOf: PageMovies.results)
        tableView.dataSource = self
        
        let button = UIButton(frame: CGRect(origin: .zero, size: CGSize(width: self.tableView.frame.width, height: 40)))
        button.setTitle("Load more", for: .normal)
        button.backgroundColor = .lightGray
        button.addTarget(self, action: #selector(moreButtonClicked(_:)), for: .touchUpInside)
        self.tableView.tableFooterView = button
        
    }
    
    @objc func moreButtonClicked(_ sender: UIButton) {
        let page = movies.page + 1
        movies = fetchMovie(Page: page)
        movieList.append(contentsOf: movies.results)
        tableView.reloadData()
    }
    
    @IBAction func touchedCollectionBtn(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(identifier: "CollectionViewController") as! CollectionViewController
        self.present(controller, animated: true, completion: nil)
    }
    
    func fetchMovie(Page: Int) -> MovieList {
        
        let apikey = "838c2d168365d294a9ab22ee9e24c488"
        let urlStr = "https://api.themoviedb.org/3/movie/popular?language=en-US&api_key=\(apikey)&page=\(Page)"

        guard let url = URL(string: urlStr) else {
            fatalError("Invalid URL")
        }
        
        let movieList = try? JSONDecoder().decode(MovieList.self, from: Data(contentsOf: url))
        
        guard let movies = movieList else { fatalError("No Data") }
        self.movies = movies
            
        return movies
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "movieDetail" ,
           let senderVC: MovieDetailController = segue.destination as? MovieDetailController {
                senderVC.id = sender as! Int
            }
       
    }
    
}

// TableView Extensions
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredMovies.count
        }
        
        return movies.results.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "movieCell", for: indexPath) as! MovieCell

        let movie: Movie
        
        if isFiltering {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies.results[indexPath.row]
        }
        
        cell.textLabel?.text = movie.title
        
        Alamofire.request("https://image.tmdb.org/t/p/w200/\(movie.poster_path)").responseImage { response in

        if let image = response.result.value {
            cell.imageView?.image = image
        }
        }
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return cell}
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let predicate = NSPredicate(format: "id == \(movies.results[indexPath.row].id)")
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favorite]
        
        if resultData.count > 0 {
            cell.favoriteBtn.alpha = 1
        } else {
            cell.favoriteBtn.alpha = 0
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(movies.results[indexPath.row].id)
        performSegue(withIdentifier: "movieDetail", sender: movies.results[indexPath.row].id)
    }
    
    
    
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovies = movies.results.filter({ (movie: Movie) -> Bool in
            return movie.title.lowercased().contains(searchText.lowercased())
        })
        
        isFiltering = true
        tableView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        tableView.reloadData()
    }
}
