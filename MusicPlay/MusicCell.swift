//
//  MusicCell.swift
//  MusicPlay
//
//  Created by Anuraag Jain on 11/01/17.
//  Copyright © 2017 Anuraag. All rights reserved.
//

import UIKit
protocol MusicCellProtocol {
    func didTapSeeAll(cell:MusicCell,indexPath:IndexPath)
    func didTapOnTrack(cell:MusicCell,indexPath:IndexPath)
}


class MusicCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            let nib = UINib(nibName: "TrackCell", bundle: nil)
            self.collectionView.register(nib, forCellWithReuseIdentifier: "cell")
        }
    }
    
    @IBOutlet weak var sectionHeader: UILabel!
    @IBOutlet weak var cellBg: UIView!
    @IBOutlet weak var seeAllButton: UIButton!

    var indexPath:IndexPath?
    var delegate:MusicCellProtocol? = nil
    var topTracks:[TopTrack]?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    @IBAction func didTapOnSeeAll(_ sender: Any) {
        if let _  = delegate{
            delegate?.didTapSeeAll(cell: self, indexPath: indexPath!)
        }
    }

    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCollectionViewDataSourceDelegate(index:IndexPath,tracks:[TopTrack]){
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        indexPath = index
        topTracks =  tracks
        self.collectionView.reloadData()
        
        
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
       return topTracks!.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TrackCell
        
        
            let obj = topTracks?[indexPath.row]
            cell.artistName.text = obj!.artistName
            cell.trackName.text = obj!.trackName
            cell.coverImage.setImageWithUrl(url: NSURL(string:(obj?.artWork)!)!)
            return cell
        
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Coll:\(indexPath) - \(self.indexPath)")
        if let _ = delegate{
            delegate?.didTapOnTrack(cell: self, indexPath: indexPath)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 120, height: 185)
    }
    
    

}
