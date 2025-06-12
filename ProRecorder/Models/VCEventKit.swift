//
//  VCEventKit.swift
//  ProRecorder
//
//  Created by Simon Puchner on 14.07.22.
//

import Foundation
import UIKit
import EventKit
import EventKitUI
import SwiftUI

class VCEventKit: ObservableObject {
    let eventStore = EKEventStore()
    
    func checkCalendarAuthorizationStatus(recordings: [CDRecordings]) {
        eventStore.requestAccess(to: .event, completion: {(granted: Bool, error: Error?) -> Void in
            if granted {
                self.insertEvent(store: self.eventStore, recordings: recordings)
            } else {
                print("Access denied")
            }
        })
    }
    
    func insertEvent(store: EKEventStore, recordings: [CDRecordings]) {
        
        DispatchQueue.main.async {
            guard let calendar = self.eventStore.defaultCalendarForNewEvents else { return }
            
            for recording in recordings {
                let event = EKEvent(eventStore: self.eventStore)
                event.title = recording.project
                event.startDate = recording.startTime
                event.endDate = recording.endTime
                event.notes = recording.recordingDescription
                
                event.calendar = calendar
                
                do {
                    try store.save(event, span: .thisEvent, commit: true)
                } catch {
                    print("failed to access to calendar")
                }
            }
        }
    }
    
    
}
