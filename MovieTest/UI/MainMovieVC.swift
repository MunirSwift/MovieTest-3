//
//  MainMovieVC.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import XCDYouTubeKit

class MainMovieVC: BaseVC,  UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: MySearchBar!
    
    var jsonArray : [MainMovieModel] = []
    
    var isLandscape:Bool = false
    
    var width = CGFloat()
    var height = CGFloat()
    
    //  VC Lifecycle
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillDisappear), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        width = UI.getScreenSize().width
        height = UI.getScreenSize().height        

        if(isNetAvailable) { //  normal
            WSRequest();
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        width = size.width
        height = size.height
        
        if !UIDevice.current.orientation.isPortrait {
            Common.Log(str: "Landscape")
            isLandscape = true
        } else {
            Common.Log(str: "Portrait")
            isLandscape = false
        }
    }
    
    //  MARK:   Keyboard Notifications Selectors
    @objc func keyboardWillAppear(_ notification: Notification) {
        //Do something here
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            searchBar.frame = CGRect(x: 0, y: UI.getScreenSize().height - (keyboardHeight + searchBar.frame.size.height), width: width, height: searchBar.frame.size.height)
        }
    }
    
    @objc func keyboardWillDisappear(_ notification: Notification) {
        //Do something here
        searchBar.frame = CGRect(x: 0, y: UI.getScreenSize().height - searchBar.frame.size.height, width: width, height: searchBar.frame.size.height)
    }
    
    //  MARK:   WS    
    func WSRequest() {        
        HttpMgr.shared.get(uri: Server.API_MOVIE_DB_URL) { (json) in
            
            let results = json["results"]
            if results.count > 0 {
                self.jsonArray.removeAll()
                for arr in results.arrayValue {
                    self.jsonArray.append(MainMovieModel(json: arr))
                }
                
                DispatchQueue.main.async {
                    self.searchBar.isHidden = false
                    self.tableView.reloadData()
                }
            }
            else {
                DispatchQueue.main.async {
                    Common.Log(str: "No Result Found")
                    self.searchBar.isHidden = true
                    self.showAlert(msg: "Sorry, movie result not found")
                }
            }
        };
    }
    
    //  MARK:   TableView Delegates
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.jsonArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:MainMovieCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MainMovieCell
        
        //Common.Log(str: self.jsonArray[indexPath.row].poster_path)
        cell.avator.kf.setImage(with: URL(string:String(format:"%@%@",Server.API_POSTER_IMAGE_URL, self.jsonArray[indexPath.row].poster_path)), options: [
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        let title = self.jsonArray[indexPath.row].title
        cell.title.tag = self.jsonArray[indexPath.row].id
        cell.title.text = title
        cell.title.addTapGestureRecognizer {
            Common.Log(str: String(format:"title tapped at index = %i",cell.title.tag))
            if(self.isNetAvailable) {
                DispatchQueue.main.async {
                    if let vc = self.storyboard!.instantiateViewController(withIdentifier: "DetailMovieVC") as? DetailMovieVC {
                        vc.movie_id = cell.title.tag
                        vc.width = self.width
                        vc.height = self.height
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                }
            }
        }
        
        cell.backgroundColor = .clear
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        UIView.animate(withDuration: 0.5) {
            cell.transform = CGAffineTransform.identity
        }
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        Common.Log(str: "You tapped cell number \(indexPath.row).")
        
        let vc = storyboard!.instantiateViewController(withIdentifier: "DetailMovieVC") as! DetailMovieVC
        vc.dicDetails = self.jsonArray[indexPath.row] as! NSDictionary
        self.navigationController!.pushViewController(vc, animated: true)
    }*/
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        let cell:MainMovieCell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! MainMovieCell
        return cell.frame.size.height
        
        //  Tried to control view height in every devices
        /*var h = CGFloat(getScreenSize().height*20/100)
        switch(UIDevice.current.userInterfaceIdiom) {
            case .phone:
                    if(isLandscape) {
                        h = CGFloat(getScreenSize().width*20/100)
                    }
                    else {
                        h = CGFloat(getScreenSize().height*18/100)
                    }
                    break;
            case .pad:
                    if(isLandscape) {
                        h = CGFloat(getScreenSize().width*25/100)
                    }
                    else {
                        h = CGFloat(getScreenSize().height*22/100)
                    }
                    break;
            case .unspecified:
                break;
            case .tv:
                break;
            case .carPlay:
                break;
        }
        
        return h*/
    }
    
    //  MARK:   Searchbar delegates
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        Common.Log(str: searchBar.text!)
        searchBar.resignFirstResponder()
        if let keywords = searchBar.text {
            if keywords.count > 0 {
                // high order function e.g sort, map, filter, reduce here i 've used filter to bring start with result from title
                let searchResults = MainMovieParser.getTitleMovie(keyword: keywords, model: self.jsonArray)
                if searchResults.count > 0 {
                    self.jsonArray = searchResults
                    Common.Log(str: self.jsonArray.description)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                else {
                    self.showAlert(msg: "Sorry, your search record not found")
                }
            }
            else {
                //  normal to get all data from coredb
                WSRequest();
            }
        }
    }
}
