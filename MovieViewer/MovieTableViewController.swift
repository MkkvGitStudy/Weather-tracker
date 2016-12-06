//
//  MovieTableViewController.swift
//  MovieViewer
//
//  Created by qburst on 05/10/16.
//  Copyright © 2016 qburst. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher

class MovieTableViewController: UITableViewController {
    
//MARK: Properties
    
    var movies = [Movie]()
    var pageNo = 1
    var isrefreshing : Bool = false
   // var loading : Bool = false
        let pending = UIAlertController(title: "Loading Data....", message: nil, preferredStyle: .ActionSheet)
    
    
//MARK: View Functions
override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        
        
        self.refreshControl?.addTarget(self, action: #selector(MovieTableViewController.handleRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
    
//    activityIndicator.hidesWhenStopped = true
//    activityIndicator.activityIndicatorViewStyle  = UIActivityIndicatorViewStyle.Gray;
//    activityIndicator.center = view.center
//    
//    self.view.addSubview(activityIndicator)
    
    
    super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
//MARK: API Section
    
  	func loadData()
    {
//        if loading
//        {
//            loadingIndicator()
//
//        }
        let url = "https://api.themoviedb.org/3/discover/movie?sort_by=popularity.desc&api_key=2923077eb168ca0eada0f6ec4336e448&page=\(pageNo)"
        Alamofire.request(.GET,url).responseJSON { response in
        print(response.result)
        if let json = response.result.value as? [String:AnyObject]
        {
            let results = json["results"] as! [[String:AnyObject]]
           // print(results)
            
            var imagePath : String
            let imageDefault = UIImage(named: "Default")
            for data in results{
                imagePath = data["poster_path"] as! String
                imagePath = "http://image.tmdb.org/t/p/w1000/\(imagePath)"
                let url = NSURL(string: imagePath)!
                //print(url)
                
                KingfisherManager.sharedManager.retrieveImageWithURL(url, optionsInfo: nil, progressBlock: nil, completionHandler: { (image, error, cacheType, imageURL) -> () in
                    //print(image)
                    
                    let title: String = data["original_title"] as! String
                    let overView : String = data["overview"] as! String
                    let release : String = data["release_date"] as! String
                    
                    if (image != nil)
                    {
                        let movie = Movie(movieName: title, movieOverview: overView, releaseDate: release, movieImage: image!)
                        self.movies.append(movie)
                        self.isrefreshing = false
                        self.tableView.reloadData()

                    }
                    else
                    {
                        let movie = Movie(movieName: title, movieOverview: overView, releaseDate: release, movieImage: imageDefault!)
                        self.movies.append(movie)
                        self.isrefreshing = false
                        self.tableView.reloadData()

                    }
                })

                
            }
         
        }
        else
        {
            print("No connection")
            self.alertControl()
        }
        }
    }
    
    
    func loadingIndicator(){
        
        
        //Create the activity indicator to display in it.
        let indicator = UIActivityIndicatorView(frame: CGRectMake(pending.view.frame.width / 2.0, pending.view.frame.height / 2.0, 100.0, 100.0))
        indicator.color = UIColor.blackColor()
        indicator.center = CGPointMake(pending.view.frame.width / 1.5, pending.view.frame.height / 2.0)
        //Add the activity indicator to the alert's view
        pending.view.addSubview(indicator)
        //Start animating
        indicator.startAnimating()
        
        self.presentViewController(pending, animated: true, completion: nil)
    }
 
    
    func alertControl() {
    
    let alert = UIAlertController(title: "Error", message: "No Internet Connection", preferredStyle: UIAlertControllerStyle.ActionSheet)
    let refresh = UIAlertAction(title: "Refresh", style: UIAlertActionStyle.Default, handler: { (_: UIAlertAction) in
        self.loadData()
    })
    alert.addAction(refresh)
    presentViewController(alert, animated: true, completion: nil)
    }
    
    func handleRefresh(refreshControl: UIRefreshControl){
        
    movies.removeAll()
    pageNo = 1
    self.isrefreshing = true
    loadData()
    refreshControl.endRefreshing()
    }
    
    
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        print(scrollView.contentSize.height)
        print(scrollView.contentOffset.y)
        print(scrollView.frame.size.height)
        let maximumOffSet = scrollView.contentSize.height - scrollView.frame.size.height
        let currentOffSet = scrollView.contentOffset.y
        
        
        if (maximumOffSet-currentOffSet <= 10)
        {
            
            
            
            if ( movies.count == pageNo*20)
            {
                pageNo += 1
                //self.loading = true
                loadData()
                
            }
        }
        else
        {
            
        }
    }



// MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return movies.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
                let cellIdentifier = "movieCell"
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! MovieTableViewCell
        if !isrefreshing
        {

        let movie = movies[indexPath.row]
        cell.movieNameLabel.text = movie.movieName
        cell.movieOverview.text = movie.movieOverview
        cell.releaseDateLabel.text = movie.releaseDate
        cell.movieImage.image = movie.movieImage
        }
//        if (movies.count == pageNo*20)
//        {
//            if self.loading
//            {
//                pending.dismissViewControllerAnimated(true, completion: nil)
//                self.loading = false
//            }
//        }
        return cell
    
    }
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
// MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if (segue.identifier == "ShowImage")
        {
        let destinationViewController = segue.destinationViewController as! ViewController
        if let selectedCell = sender as? MovieTableViewCell
        {
            let newIndexPath = tableView.indexPathForCell(selectedCell)!
            let movie = movies[newIndexPath.row]
            destinationViewController.movie = movie
        }
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    
   
}
