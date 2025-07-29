//
//  Item.swift
//  Vocapita
//
//  Created by Pedro Gregorio on 23/07/2025.
//

import Foundation
import SwiftData

@Model
final class VoiceRecording {
    var id: UUID
    var timestamp: Date
    var transcription: String
    var audioFileName: String?
    var duration: TimeInterval
    
    init(transcription: String = "", audioFileName: String? = nil, duration: TimeInterval = 0) {
        self.id = UUID()
        self.timestamp = Date()
        self.transcription = transcription
        self.audioFileName = audioFileName
        self.duration = duration
    }
}
