//
//  CollectionViewController.swift
//  MovieProject
//
//  Created by Abdullah Coban on 30.07.2021.
//

import UIKit
import Alamofire
import AlamofireImage

class CollectionViewController: UIViewController {
    
    var movies = MovieList(results: [Movie](), page: 1)
    var movieList = [Movie]()
    var filteredMovies = [Movie]()
    var isFiltering: Bool = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let PageMovies = fetchMovie(Page: 1)
        movieList.append(contentsOf: PageMovies.results)
        
        collectionView.register(MovieCollectionViewCell.self, forCellWithReuseIdentifier: MovieCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        view.addSubview(collectionView)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        collectionView.frame.origin.y = 155
        collectionView.backgroundColor = .systemBackground
    }
    
    @IBAction func goTableView(_ sender: Any) {
        let story = UIStoryboard(name: "Main", bundle: nil)
        let controller = story.instantiateViewController(identifier: "ViewController") as! ViewController
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


extension CollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if isFiltering {
            return filteredMovies.count
        }
        
        return movies.results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieCollectionViewCell.identifier, for: indexPath) as! MovieCollectionViewCell
     
        let movie: Movie
        
        if isFiltering {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies.results[indexPath.row]
        }
        
        Alamofire.request("https://image.tmdb.org/t/p/w200/\(movie.poster_path)").responseImage { response in

        if let image = response.result.value {
            cell.imageView.image = image
        }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.size.width/2)-6, height: (view.frame.size.width/2)-6)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "movieDetail", sender: movies.results[indexPath.row].id)
    }
    
    /*func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.row == movies.results.count - 1 {  //numberofitem count
            let page = movies.page + 1
            movies = fetchMovie(Page: page)
            movieList.append(contentsOf: movies.results)
            collectionView.reloadData()
        }
    }*/
}

extension CollectionViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        filteredMovies = movies.results.filter({ (movie: Movie) -> Bool in
            return movie.title.lowercased().contains(searchText.lowercased())
        })
        
        isFiltering = true
        collectionView.reloadData()
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isFiltering = false
        searchBar.text = ""
        collectionView.reloadData()
    }
}

