//
//  GameSounds.swift
//  Marbles
//
//  Created by Suresh Thotakura on 23/04/2020.
//  Copyright © 2020 Neharjun Technologies Limited. All rights reserved.
//

import SpriteKit

class GameSounds {
    static let shared = GameSounds()
    
    let blop = SKAction.playSoundFileNamed("blop", waitForCompletion: false)
}
