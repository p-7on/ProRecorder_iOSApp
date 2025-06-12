//
//  StatisticsView.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import SwiftUI
import CoreData
import Charts

struct StatisticsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("PROJECTS")) {
                    List {
                        ForEach (projectViewModel.projects) { project in
                            NavigationLink(project.projectName ?? "", destination: DetailsView(project: project))
                        }
                    }
                    .navigationBarTitle("Statistics")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    }
}


// DetailView on NavigationLink for Project
struct DetailsView: View {
    
    @EnvironmentObject var projectViewModel: ProjectViewModel
    var project: CDProject
    @State var dateToString = ""
    
    var body: some View {
        Form {
            Section(header: Text("Chart")) {
                if #available(iOS 16.0, *) {
                    Chart(projectViewModel.recordings) { recording in
                        BarMark(
                            x: .value("Date", recording.date ?? Date()),
                            y: .value("Duration", projectViewModel.convertSecToHours(seconds: Int(recording.recordingDuration)))
                        )
                        .foregroundStyle(.blue.gradient)
                    }
                    .frame(height: 200)
                    .padding()
                } else {
                    // Fallback on earlier versions
                    VStack(alignment: .center) {
                        Image(systemName: "chart.bar.xaxis")
                            .resizable()
                            .frame(width: 50, height: 50)
                        Text("Chart only available on iOS 16.0+!")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .padding()
                }
            }
            
            
            Section(header: Text("DETAILS")) {
                HStack {
                    Text("Project")
                    Spacer()
                    Text(project.projectName ?? "")
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Total worktime")
                    Spacer()
                    Text(projectViewModel.convertSecToHMS(seconds: Int(project.fullTimeRecording)))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("First Session")
                    Spacer()
                    Text(projectViewModel.convertDateToString(date: projectViewModel.recordings.first?.date ?? Date()))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Last Session")
                    Spacer()
                    Text(projectViewModel.convertDateToString(date: projectViewModel.recordings.last?.date ?? Date()))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Sessions")
                    Spacer()
                    Text(String(project.recordings?.count ?? 0))
                        .foregroundColor(.gray)
                }
            }
            
            Section(header: Text("RECORDINGS")) {
                List{
                    ForEach(projectViewModel.getRecordingsFromProject(project: project)) { recording in
                        HStack {
                            VStack {
                                Text(projectViewModel.convertDateToString(date: recording.date ?? Date()))
                                Text("")
                            }
                            Spacer()
                            VStack {
                                Text(projectViewModel.convertDateTimeToString(date: recording.startTime ?? Date()))
                                Text(projectViewModel.convertDateTimeToString(date: recording.endTime ?? Date()))
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitle(project.projectName ?? "")
    }
    
    
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
