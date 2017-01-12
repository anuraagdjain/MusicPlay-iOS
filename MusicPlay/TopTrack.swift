//
//  TopTrack.swift
//  MusicPlay
//
//  Created by Anuraag Jain on 11/01/17.
//  Copyright © 2017 Anuraag. All rights reserved.
//

import Foundation

class Tracks:NSObject{
    var headerTitle:String?
    var tracks:[TopTrack]?
}

class TopTrack:NSObject{
    
    var previewURL:String?
    var artWork:String?
    var trackName:String?
    var artistName:String?
}
