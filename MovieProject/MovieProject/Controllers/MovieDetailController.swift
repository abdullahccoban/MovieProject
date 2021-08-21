//
//  MovieDetailController.swift
//  MovieProject
//
//  Created by Abdullah Coban on 16.07.2021.
//

import UIKit
import Alamofire
import AlamofireImage
import CoreData

class MovieDetailController: UIViewController {

    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var movieImg: UIImageView!
    @IBOutlet weak var voteCountLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var notFavoriteBtn: UIButton!
    @IBOutlet weak var FavoriteBtn: UIButton!
    
    var id: Int = 0
    var movie = Movie(id: 0, title: "", overview: "", vote_count: 0, poster_path: "")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        movie = fetchMovieWithId(id: id)
        titleLabel.text = movie.title
        voteCountLabel.text = String(movie.vote_count)
        descriptionLabel.text = movie.overview
        Alamofire.request("https://image.tmdb.org/t/p/w200/\(movie.poster_path)").responseImage { response in

        if let image = response.result.value {
            self.movieImg.image = image
        }
        }
        
        let check = checkFavorite(id: id)
        
        if check == true {
            notFavoriteBtn.alpha = 1
            FavoriteBtn.alpha = 0
        } else {
            notFavoriteBtn.alpha = 0
            FavoriteBtn.alpha = 1
        }
        
    }
    
    @IBAction func tappedFavoriteBtn(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let favoriteItem = NSEntityDescription.insertNewObject(forEntityName: "Favorite", into: context)
        favoriteItem.setValue(id, forKey: "id")
        
        do {
            try context.save()
            print("\(movie.title) favorilere kaydedildi.")
            notFavoriteBtn.alpha = 1
            FavoriteBtn.alpha = 0
        } catch  {
            print("\(movie.title) favorilere kaydedilemedi.")
        }
    }
    
    @IBAction func tappedNotFavoriteBtn(_ sender: Any) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favorite]

           for object in resultData {
                context.delete(object)
           }

           do {
               try context.save()
               notFavoriteBtn.alpha = 0
               FavoriteBtn.alpha = 1
            print("\(movie.title) favorilerden silindi.")
           } catch let error as NSError  {
               print("Could not save \(error), \(error.userInfo)")
           }
    }
    
    func fetchMovieWithId(id: Int) -> Movie {
        
        let apikey = "838c2d168365d294a9ab22ee9e24c488"
        let urlStr = "https://api.themoviedb.org/3/movie/\(id)?language=en-US&api_key=\(apikey)"
        guard let url = URL(string: urlStr) else {
            fatalError("Invalid URL")
        }
        
        let movie = try? JSONDecoder().decode(Movie.self, from: Data(contentsOf: url))
        
        guard let movie = movie else { fatalError("No Data") }
        self.movie = movie
            
        return movie
    }
    
    func checkFavorite(id: Int) -> Bool {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false }
        let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        let predicate = NSPredicate(format: "id == \(id)")
        fetchRequest.predicate = predicate
        let result = try? context.fetch(fetchRequest)
        let resultData = result as! [Favorite]
        
        if resultData.count > 0 {
            return true
        } else {
            return false
        }
        
    }
        
    

}


