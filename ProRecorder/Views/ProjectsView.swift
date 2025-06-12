//
//  ContentView.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import SwiftUI
import CoreData

struct ProjectsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @State var projectname: String = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(projectViewModel.projects) { project in
                    ProjectCellView(project: project, timerManager: projectViewModel.getTimer(project: project))
                }
                .onDelete(perform: projectViewModel.deleteProject)
            }
            .navigationBarTitle("Projects")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addProjectAlert) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        }
    }
    
    //add alert for create new project
    func addProjectAlert() {
        let alert = UIAlertController(title: "Project", message: "add new project", preferredStyle: .alert)
        
        alert.addTextField() { (projectname) in
            projectname.placeholder = "projectname ..."
        }
        let add = UIAlertAction(title: "Add", style: .default) { (_) in
            projectname = alert.textFields![0].text!
            projectViewModel.addProject(projectname: projectname)
            projectname = ""
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .destructive) { (_) in
            
        }
        
        alert.addAction(cancel)
        alert.addAction(add)
        
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {})
    }
    
    
    
    
}


//ProjectCellView
struct ProjectCellView: View {
    
    var project: CDProject
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @ObservedObject var timerManager: TimerManager
    @State var recordingDuration = 0
    @State var recordingDescription = ""
    
    
    var body: some View {
        HStack {
            Text(project.projectName ?? "")
                .font(.title)
                .padding()
            Spacer()
            VStack {
                Image(systemName: project.isRecording ? "stop.circle.fill" : "play.circle.fill")
                    .resizable()
                    .foregroundColor(project.isRecording ? .red : .green)
                    .frame(width: 30, height: 30, alignment: .center)
                    .onTapGesture {
                        projectViewModel.toggleRecording(project: project)
                        timerManager.timerStart()
                        
                        if (project.isRecording == false) {
                            recordingDuration = timerManager.seconds
                            saveRecordingAlert()
                            timerManager.timerStop()
                        }
                    }
                
                if (project.isRecording == true) {
                    Text(projectViewModel.convertSecToHMS(seconds: timerManager.seconds))
                    .foregroundColor(.gray)
                }
                
            }
            .padding(.trailing, 10)
        }
        .padding()
    }
    
    //save alert - description for work
    func saveRecordingAlert() {
        let alert = UIAlertController(title: "Save recording", message: "Description of the work", preferredStyle: .alert)
        
        alert.addTextField() { (projectname) in
            projectname.placeholder = "description ..."
        }
        let save = UIAlertAction(title: "Save", style: .default) { (_) in
            recordingDescription = alert.textFields![0].text!
            projectViewModel.saveRecording(project: project, recordingDescription: recordingDescription, recordingDuration: recordingDuration)
        }
        
        alert.addAction(save)
        UIApplication.shared.windows.first?.rootViewController?.present(alert, animated: true, completion: {})
    }
    
    
}






private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ProjectsView()
    }
}
