//
//  ProjectViewModel.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import Foundation
import CoreData

class ProjectViewModel: ObservableObject {
    @Published var projects: [CDProject] = []
    @Published var recordings: [CDRecordings] = []
    @Published var timers:[TimerManager] = []
    
    //EventKit
    let calendarManager = VCEventKit()
    
    // ---------------------------------------------------------------------------------------------- //
    
    // CoreData
    let manager = PersistenceController.shared
    
    init() {
        getProjects()
        getRecordings()
    }
    
    func getProjects() {
        let request = NSFetchRequest<CDProject>(entityName: "CDProject")
        request.sortDescriptors = [
                    NSSortDescriptor(key: #keyPath(CDProject.timestamp), ascending: true)
                ]
        
        do {
            projects = try manager.container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching .\(error.localizedDescription)")
        }
        
        let items = projects.count
        for _ in 0...items {
            timers.append(TimerManager())
        }
    }
    
    func getRecordings() {
        let request = NSFetchRequest<CDRecordings>(entityName: "CDRecordings")
        request.sortDescriptors = [
            NSSortDescriptor(key: #keyPath(CDRecordings.date), ascending: true)
                ]
        
        
        do {
            recordings = try manager.container.viewContext.fetch(request)
        } catch let error {
            print("Error fetching .\(error.localizedDescription)")
        }
    }
    
    func getTimer(project: CDProject) -> TimerManager {
        guard let index = projects.firstIndex(of: project) else { return TimerManager() }
        
        return timers[index]
    }
    
    func addTimer() {
        timers.append(TimerManager())
    }
    
    func addProject(projectname: String) {
        let newProject = CDProject(context: manager.container.viewContext)
        newProject.timestamp = Date()
        newProject.projectName = projectname
        saveData()
    }
    
    func deleteProject(offsets: IndexSet) {
        guard let index = offsets.first else { return }
        let project = projects[index]
        manager.container.viewContext.delete(project)
        saveData()
    }
    
    func deleteRecording(recording: CDRecordings) {
        guard let index = recordings.firstIndex(of: recording) else { return }
        let rec = recordings[index]
        rec.projects?.fullTimeRecording -= rec.recordingDuration
        manager.container.viewContext.delete(rec)
        saveData()
    }
    
    func toggleRecording(project: CDProject) {
        project.isRecording.toggle()
        saveData()
    }
    
    func saveRecording(project: CDProject, recordingDescription: String, recordingDuration: Int) {
        let newRecording = CDRecordings(context: manager.container.viewContext)
        newRecording.project = project.projectName
        newRecording.recordingDescription = recordingDescription
        newRecording.recordingDuration = Int64(recordingDuration)
        newRecording.date = Date()
        newRecording.startTime = Calendar.current.date(byAdding: .second, value: -recordingDuration, to: Date())
        newRecording.endTime = Date()
        newRecording.isExported = false
        
        newRecording.projects = project
        project.fullTimeRecording += Int64(recordingDuration)
        
        saveData()
    }
    
    func saveEntryRecording(project: CDProject, recordingDescription: String, startDate: Date, endDate: Date) {
        let newRecording = CDRecordings(context: manager.container.viewContext)
        newRecording.project = project.projectName
        newRecording.recordingDescription = recordingDescription
        newRecording.date = startDate
        newRecording.startTime = startDate
        newRecording.endTime = endDate
        newRecording.isExported = false
        
        let duration = endDate.timeIntervalSince(startDate)
        newRecording.recordingDuration = Int64(duration)
        
        newRecording.projects = project
        project.fullTimeRecording += Int64(duration)
        
        saveData()
    }
    
    func saveData() {
        manager.saveData()
        getProjects()
        getRecordings()
    }
    
    // ---------------------------------------------------------------------------------------------- //
    
    // LOGIC
    func convertDateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        let formattedString = formatter.string(for: date)
        
        return formattedString ?? ""
    }
    
    func convertDateTimeToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .medium
        let formattedString = formatter.string(for: date)
        
        return formattedString ?? ""
    }
    
    func convertSecToHMS(seconds: Int) -> String {
        let h = seconds / 3600
        var min = seconds / 60
        let sec = seconds % 60
        
        if (min > 59) {
            min %= 60
        }
        
        let string = String(format: "%02d:%02d:%02d", h, min, sec)
        
        return string
    }
    
    func convertSecToHours(seconds: Int) -> Int {
        return seconds / 3600
    }
    
    func getRecordingsFromProject(project: CDProject) -> [CDRecordings]{
        var rec: [CDRecordings] = []
        
        for recording in recordings {
            if (recording.project == project.projectName) {
                rec.append(recording)
            }
        }
        
        return rec
    }
    
    
    // ---------------------------------------------------------------------------------------------- //
    
    // EVENTKIT
    func exportToCalendar() {
        calendarManager.checkCalendarAuthorizationStatus(recordings: recordings)
    }
    
}
