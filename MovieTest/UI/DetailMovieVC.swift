//
//  DetailMovieVC.swift
//  MovieTest
//
//  Created by Rydus on 18/04/2019.
//  Copyright © 2019 Rydus. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import XCDYouTubeKit
import SwiftyJSON

class DetailMovieVC: BaseVC {

    @IBOutlet weak var scrollView: UIScrollView!    
    
    var movie_id:Int = 0
    
    var barHeight:CGFloat = 0
    
    var width = CGFloat()
    var height = CGFloat()
    
    var linePA:CGFloat = 5

    //  ui controls
    let backdrop_pathImage = UIImageView()
    let trailerView = UIView()
    let nameLabel  = UILabel()
    let watchBtn  = MyButton(type: UIButton.ButtonType.custom)
    let genresTitleLabel  = UILabel()
    let genresLabel  = UILabel()
    let dtTitleLabel  = UILabel()
    let dtLabel  = UILabel()
    let overviewTitleLabel  = UILabel()
    let overviewLabel  = UILabel()
    var overviewTxt = String()
    
    //  XCDYoutube
    let playerViewController = AVPlayerViewController()
    
    //  VC Lifecycle
    deinit {

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        // Do any additional setup after loading the view.
        self.title = "Movie Detail"
        WSRequest();
     }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {        
        
        width = size.width
        height = size.height
        
         if !UIDevice.current.orientation.isPortrait {
            Common.Log(str: "Landscape")
            linePA = 7
            self.setLandscapePosition()
        } else {
            Common.Log(str: "Portrait")
            linePA = 5
            self.setPortraitPosition()
        }
        
        super.viewWillTransition(to: size, with: coordinator)
    }
    
    //  MARK:   WS
    func WSRequest() {
        var url = Server.API_MOVIE_DB_DETAIL_URL
        url = url.replacingOccurrences(of: "#MOVIE_ID#", with: String(format:"%i", movie_id))
        HttpMgr.shared.get(uri: url) { (json) in
            
            if json.count > 0 {
                
                DispatchQueue.main.async {
                    
                    //  render ui controls as per screen orientation
                    self.renderMovieDetail(model: DetailMovieModel(json: json))
                    
                    if self.isLandscape() {
                        self.linePA = 7
                        //  set ui controls position as landscape mode
                        self.setLandscapePosition()
                    } else {
                        self.linePA = 5
                        //  set ui controls position as portrait mode
                        self.setPortraitPosition()
                    }
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showAlert(msg: "Sorry, movie detail result not found")
                }
            }
        };
    }

    //  MARK:   XCDYouTubePlayer Observer for 'done' and on 'finished' capture
    
    struct YouTubeVideoQuality {
        static let hd720 = NSNumber(value: XCDYouTubeVideoQuality.HD720.rawValue)
        static let medium360 = NSNumber(value: XCDYouTubeVideoQuality.medium360.rawValue)
        static let small240 = NSNumber(value: XCDYouTubeVideoQuality.small240.rawValue)
    }
    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?)
    {
        
        self.playerViewController.removeObserver(self, forKeyPath: #keyPath(UIViewController.view.frame))
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
        
        if (self.playerViewController.isBeingDismissed) {
            // Video was dismissed -> apply logic here
            Common.Log(str: "XCDYoutube Player Done Clicked")
        }
    }
    
    @objc func playerItemDidReachEnd(notification: NSNotification) {
        Common.Log(str: "XCDYoutube Player Streaming Complted")
        self.playerViewController.dismiss(animated: true);
    }
    
    //  MARK:   Custom Render Methods
    //  writing code is more accurate to render ui control into specific position and easy through constraint + vary for trait for changing postion in orientation
    func renderMovieDetail(model:DetailMovieModel) {
        
        for sview in scrollView.subviews {
            sview.removeFromSuperview()
        }
        
        //  poster image
        HttpMgr.shared.getImage(uri: String(format:"%@%@",Server.API_POSTER_IMAGE_URL, model.backdrop_path)) { (data) in
            DispatchQueue.main.async {
                self.backdrop_pathImage.image = UIImage(data: data)
            }
        };
        
        scrollView.addSubview(backdrop_pathImage)
        
        //  belongs to collections
        if model.belongs_to_collection.count > 0 {
            
            nameLabel.font = UIFont(name: "Arial Rounded MT Bold", size: 27)
            nameLabel.text = model.belongs_to_collection["name"].stringValue
            nameLabel.textAlignment = .left
            trailerView.addSubview(nameLabel)
            //
            watchBtn.backgroundColor = .groupTableViewBackground
            watchBtn.id = model.imdb_id
            watchBtn.addTarget(self, action: #selector(watchTrailerClicked(sender:)), for: .touchUpInside)
            watchBtn.setTitle("Watch Trailer", for: .normal)
            watchBtn.setTitleColor(.black, for: .normal)
            watchBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
            trailerView.addSubview(watchBtn)
            
            scrollView.addSubview(trailerView)
        }
        
        //  genres
        if model.genres.count > 0 {
            
            var genStr = ""
            //let genresStr = genres.obj(forKey: "").componentsJoined(by: ", ")
            for gen in model.genres {
                genStr += gen["name"].stringValue
                genStr += ", "
            }
            genStr = String(genStr.dropLast(2))
            Common.Log(str: genStr)
            
            genresTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
            genresTitleLabel.text = "Genres"
            genresTitleLabel.textAlignment = .left
            scrollView.addSubview(genresTitleLabel)
            //
            genresLabel.font = UIFont.systemFont(ofSize: 25)
            genresLabel.text = genStr
            genresLabel.textAlignment = .left
            scrollView.addSubview(genresLabel)
        }
        
        //  Release date
        dtTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
        dtTitleLabel.text = "Date"
        dtTitleLabel.textAlignment = .left
        scrollView.addSubview(dtTitleLabel)
        //
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd"
        let showDate = inputFormatter.date(from: model.release_date)
        inputFormatter.dateFormat = "dd.MM.yyyy"
        let dtString = inputFormatter.string(from: showDate!)
        
        dtLabel.font = UIFont.systemFont(ofSize: 25)
        dtLabel.text = dtString
        dtLabel.textAlignment = .left
        scrollView.addSubview(dtLabel)
        
        //  overview
        overviewTxt = model.overview
        overviewTitleLabel.font = UIFont(name: "Viga-Regular", size: 25)
        overviewTitleLabel.text = "Overview"
        overviewTitleLabel.textAlignment = .left
        scrollView.addSubview(overviewTitleLabel)
        //
        overviewLabel.font = UIFont.systemFont(ofSize: 25)
        overviewLabel.text = overviewTxt
        overviewLabel.textAlignment = .left
        overviewLabel.lineBreakMode = .byWordWrapping
        overviewLabel.numberOfLines = 20
        scrollView.addSubview(overviewLabel)
        
    }
    
    @objc func watchTrailerClicked(sender:MyButton) {
        
        var url = Server.API_WATCH_TRAILER_URL
        url = url.replacingOccurrences(of: "#IMDB_ID#", with: sender.id!) //  sender.id = imdb_id
        HttpMgr.shared.get(uri: url) { (json) in
            
            let results = json["results"]
            if results.count > 0 {
                    let videoIdentifier = results[0]["key"].stringValue
                    //  Ready to Play Youtube Video
                    DispatchQueue.main.async {
                        
                        self.present(self.playerViewController, animated: true, completion: nil)
                        
                        XCDYouTubeClient.default().getVideoWithIdentifier(videoIdentifier) { (video: XCDYouTubeVideo?, error: Error?) in
                            if let streamURLs = video?.streamURLs, let streamURL = (streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? streamURLs[YouTubeVideoQuality.hd720] ?? streamURLs[YouTubeVideoQuality.medium360] ?? streamURLs[YouTubeVideoQuality.small240]) {
                                self.playerViewController.player = AVPlayer(url: streamURL)
                                self.playerViewController.player?.play()
                                
                                //  Observer for Done click
                                self.playerViewController.addObserver(self, forKeyPath:#keyPath(UIViewController.view.frame), options: [.old, .new], context: nil)
                                
                                //  Observer for movie finish
                                NotificationCenter.default.addObserver(self,
                                                                       selector: #selector(self.playerItemDidReachEnd),
                                                                       name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                                       object: nil)
                                
                            } else {
                                self.showAlert(msg: error?.localizedDescription ?? "")
                                self.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                }
                else {
                    DispatchQueue.main.async {
                        self.showAlert(msg: "Sorry, Youtube-VideoIdentifer ID as key not found")
                    }
                }
        };
    }
    
    func setPortraitPosition() {
        
        let w:CGFloat = width*90/100
        var y:CGFloat = 0
        var h:CGFloat = height*30/100
        
        Common.Log(str: String(format:"portrait width---%.01f",width))
        Common.Log(str: String(format:"portrait height---%.01f",height))
        
        //  status and navigation bar height
        barHeight = (self.navigationController!.navigationBar.frame.size.height) + UIApplication.shared.statusBarFrame.height
        
        //  scrollview frame
        scrollView.frame = CGRect(x: 0, y: barHeight+2, width: width, height: height-(barHeight+2))
        
        //  cover image
        backdrop_pathImage.frame = CGRect(x:0, y:y, width:width, height:h);
        
        //  name and watch trailer view
        y = y+h+1
        h = height*16/100
        trailerView.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        //{
            //  name label
            nameLabel.frame = CGRect(x:0, y:20, width:trailerView.frame.size.width, height:(trailerView.frame.size.height/2)-20);
            nameLabel.sizeToFit()
        
            //  watch trailer button
            watchBtn.frame = CGRect(x:0, y:trailerView.frame.size.height/2, width:trailerView.frame.size.width, height:trailerView.frame.size.height/2);
        //}
        
        commonPosition(w: w, hh: h, yy: y)
    }
    
    func setLandscapePosition() {
        
        let w = width*90/100
        let y:CGFloat = 0
        let h:CGFloat = height*60/100
        
        //  status and navigation bar height
        barHeight = (self.navigationController!.navigationBar.frame.size.height) + UIApplication.shared.statusBarFrame.height
        
        //  scrollview frame
        scrollView.frame = CGRect(x: 0, y: barHeight+7, width: width, height: height-(barHeight+7))
        
        //  cover image
        //{ 2 columns div
            backdrop_pathImage.frame = CGRect(x:0, y:y, width:width*50/100, height:h);
        
            //  name and watch trailer view
            trailerView.frame = CGRect(x:width*52/100, y:y, width:width*48/100, height:h);
            //{
                //  name label
                nameLabel.frame = CGRect(x:0, y:trailerView.frame.size.height*7/100, width:trailerView.frame.size.width, height:trailerView.frame.size.height*65/100);
                    nameLabel.sizeToFit()
        
                //  watch trailer button
                watchBtn.frame = CGRect(x:0, y:trailerView.frame.size.height*76/100, width:trailerView.frame.size.width, height:trailerView.frame.size.height*23/100);
            //}
        //}
        
        commonPosition(w: w, hh: h, yy: y)
    }
    
    func commonPosition(w:CGFloat, hh:CGFloat, yy:CGFloat) {
        
        var y:CGFloat = yy
        var h:CGFloat = hh
        
        //  genres title
        y = y+h+20
        h = height*linePA/100
        genresTitleLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  genres
        y = y+h+1
        h = height*linePA/100
        genresLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  date title
        y = y+h+20
        h = height*linePA/100
        dtTitleLabel.frame  = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  date
        y = y+h+1
        h = height*linePA/100
        dtLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  overview title
        y = y+h+20
        h = height*linePA/100
        overviewTitleLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        
        //  overview
        y = y+h+1
        h = overviewLabel.estimatedHeight(forWidth: w, text: overviewTxt, ofSize: 25)
        
        overviewLabel.frame = CGRect(x:(width-w)/2, y:y, width:w, height:h);
        overviewLabel.textAlignment = .left
        overviewLabel.sizeToFit()
        
        //  scrollview content size
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        scrollView.contentSize = CGSize(width: width, height: y+h)
    }
}

extension UILabel {
    //  MARK:   Get UILabel height as per text length and font size
    //  Intrinsic Content Size:    amount of space for showing content in ideal state
    func estimatedHeight(forWidth: CGFloat, text: String, ofSize: CGFloat) -> CGFloat {
        let size = CGSize(width: forWidth, height: CGFloat(MAXFLOAT))
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        let attributes = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: ofSize)]
        let rectangleHeight = String(text).boundingRect(with: size, options: options, attributes: attributes, context: nil).height
        return ceil(rectangleHeight)
    }
}
