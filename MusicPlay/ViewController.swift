//
//  ViewController.swift
//  MusicPlay
//
//  Created by Anuraag Jain on 11/01/17.
//  Copyright © 2017 Anuraag. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,MusicCellProtocol,AVAudioPlayerDelegate {

    
    @IBOutlet weak var mTrackImage: UIImageView!
    @IBOutlet weak var mTrackName: UILabel!
    @IBOutlet weak var mDuration: UILabel!
    @IBOutlet weak var mArtistName: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var trackPlayerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playerBlur: UIView!
    @IBOutlet weak var playPauseButton:UIButton!
    
    var topTrack = [TopTrack]()
    var audioPlayer:AVPlayer?
    var myTimer:Timer!
    var sectionHeaders = ["Top Music","Hindi","English","Tamil","Punjabi"]
    var tracks = [Tracks]()
    var isPlaying = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetup()
    }

    func initialSetup(){
        customNavbar()
        let nib =  UINib(nibName: "MusicCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "cell")
        trackPlayerView.isHidden = true
        loadJSON()
        addBlurToPlayer()
        
    }
    
    func loadJSON(){
        let path = Bundle.main.url(forResource: "music", withExtension: "json")
        do{
            let jsonData = try Data(contentsOf: path!, options: Data.ReadingOptions.mappedIfSafe)
            let jsonResult = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.mutableContainers) as? [String:AnyObject]
            let items = jsonResult?["tracks"] as! NSArray
            for k in 0..<sectionHeaders.count{
            let otk = Tracks()
            otk.headerTitle = sectionHeaders[k]
                
            for i in items{
                let data =  i as? [String:AnyObject]
                let object =  TopTrack()
                object.previewURL = data?["preview_url"] as? String
                object.trackName = data?["name"] as? String
                let artists = data?["artists"] as? NSArray
                object.artistName = (artists?.firstObject as? [String:AnyObject])?["name"] as? String
                let albums =  data?["album"] as? [String:AnyObject]
                let artWorkArray = albums?["images"] as! NSArray
                let trackArtWork = artWorkArray.firstObject as! NSDictionary
                object.artWork =  trackArtWork.value(forKey: "url") as? String
                self.topTrack.append(object)
                
            }
            otk.tracks =  self.topTrack
            self.tracks.append(otk)
            self.topTrack.removeAll()
            }
            
            self.tableView.reloadData()
            
        }catch{
            print(error.localizedDescription)
        }
    }
    func customNavbar(){
        self.title = "MusicPlay"
        UIApplication.shared.statusBarStyle = .lightContent
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor.white,NSAttributedStringKey.font:UIFont(name: "Verdana-Bold", size: 15)!]
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = redColor
        let searchButton = UIBarButtonItem(image: UIImage(named:"search")!, style: .done, target: self, action: nil)
        let menuButton =  UIBarButtonItem(image: UIImage(named:"menu")!, style: .done, target: self, action: nil)
        self.navigationItem.leftBarButtonItem = menuButton
        self.navigationItem.rightBarButtonItem = searchButton
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MusicCell
        if indexPath.row == 0{
            cell.seeAllButton.isHidden = true
            cell.cellBg.backgroundColor = redColor
            cell.sectionHeader.textColor = UIColor.white
            cell.sectionHeader.text = sectionHeaders[0]
            
        }else{
            cell.seeAllButton.isHidden = false
            cell.sectionHeader.text = sectionHeaders[indexPath.row]
            cell.cellBg.backgroundColor = UIColor.white
            cell.sectionHeader.textColor = UIColor.black
            
        }
        let obj =  self.tracks[indexPath.row]
        cell.setCollectionViewDataSourceDelegate(index: indexPath,tracks:obj.tracks!)
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 245
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("TableView:\(indexPath)")
    }
    func addBlurToPlayer(){
        let blur =  UIBlurEffect(style: .light)
        let blurView = UIVisualEffectView(effect: blur)
        blurView.frame = playerBlur.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerBlur.addSubview(blurView)
    }
    
    func didTapSeeAll(cell: MusicCell, indexPath: IndexPath) {
        
    }
    
    func didTapOnTrack(cell: MusicCell, indexPath: IndexPath) {
        
        let k = tableView.indexPath(for: cell)
        //self.tracks[k!.row].tracks?[indexPath.row]
        playTrack(track: (self.tracks[k!.row].tracks?[indexPath.row])!)
        print("Location:\(k!.row) \(indexPath.row)")
    }
    
    func playTrack(track:TopTrack){
        tableView.contentInset =  UIEdgeInsets(top: 0, left: 0, bottom: playerBlur.frame.height, right: 0)
        trackPlayerView.isHidden = false
        let musicURL = URL(string:track.previewURL!)
    /*    do{
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
        }
        catch{
            print(error.localizedDescription)
        }*/
        
        self.audioPlayer =  AVPlayer(url: musicURL!)
        self.audioPlayer?.play()
        playPauseButton.setImage(UIImage(named:"pause"), for: .normal)
        myTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateProgressBar), userInfo: nil, repeats: true)
        mTrackImage.setImageWithUrl(url: NSURL(string:track.artWork!)!)
        mTrackName.text = track.trackName!
        mArtistName.text = track.artistName!
    }
    
    @objc func updateProgressBar(){
        
            let t1 =  self.audioPlayer?.currentTime()
            let t2 =  self.audioPlayer?.currentItem?.asset.duration
            
            let current = CMTimeGetSeconds(t1!)
            let total =  CMTimeGetSeconds(t2!)
            
        if Int(current) != Int(total){
            
            let min = Int(current) / 60
            let sec =  Int(current) % 60
            mDuration.text = String(format: "%02d:%02d", min,sec)
            let percent = (current/total)
            
            self.progressBar.setProgress(Float(percent), animated: true)
            print("percent \(percent) - \(current) \(total)")
        }else{
            audioPlayer?.pause()
            audioPlayer = nil
            myTimer.invalidate()
            myTimer = nil
        }
        
        
    }
    
    @IBAction func didTapOnPause(_ sender: Any) {
        if !isPlaying {
            isPlaying = true
            audioPlayer?.play()
            playPauseButton.setImage(UIImage(named:"pause"), for: .normal)
            
        }else{
            isPlaying = false
            audioPlayer?.pause()
            playPauseButton.setImage(UIImage(named:"play"), for: .normal)
        }
        
    
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

}

 let redColor = UIColor(red: 251/255, green: 34/255, blue: 68/255, alpha: 1.0)
