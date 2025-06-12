//
//  CalendarView.swift
//  ProRecorder
//
//  Created by Simon Puchner on 30.06.22.
//

import SwiftUI
import CoreData
import EventKit
import EventKitUI

struct CalendarView: View {
    @Environment(\.managedObjectContext) private var viewContext
        
    @EnvironmentObject var projectViewModel: ProjectViewModel
    @State var selectedDate: Date = Date()
    @State var showAddNewRecording: Bool = false
    @State var isShowingConfirmationCalendarExport: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("calendar", selection: $selectedDate, displayedComponents: .date)
                    .padding()
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                List {
                    ForEach (projectViewModel.recordings) { recording in
                        if (projectViewModel.convertDateToString(date: recording.date ?? Date()) == projectViewModel.convertDateToString(date: selectedDate)) {
                            
                            NavigationLink {
                                CalendarDetailView(recording: recording)
                            } label: {
                                HStack {
                                    VStack {
                                        Capsule()
                                            .fill(.blue)
                                            .frame(width: 4, height: 35, alignment: .leading)
                                    }
                                    
                                    VStack {
                                        Text(recording.project ?? "")
                                            .bold()
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
                .listStyle(PlainListStyle())
                Spacer()
                
            }
            .navigationBarTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        isShowingConfirmationCalendarExport.toggle()
                    } label: {
                        Text("Export")
                    }
                }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showAddNewRecording.toggle()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .sheet(isPresented: $showAddNewRecording) {
                        CalendarAddView()
                    }
                }
            }
            
        }
        .confirmationDialog("Are you sure to export recordings to calendar?", isPresented: $isShowingConfirmationCalendarExport, titleVisibility: .visible) {
            Button("Export", role: .destructive) {
                projectViewModel.exportToCalendar()
            }
            
        }
    }
    
}

struct CalendarView_Previews: PreviewProvider {
    static var previews: some View {
        CalendarAddView()
    }
}


struct CalendarDetailView: View {
    
    @EnvironmentObject var projectViewModel: ProjectViewModel
    var recording: CDRecordings
    @State var isShowingConfirmationDelete: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("RECORDING:")) {
                
                HStack {
                    Text("Start")
                    Spacer()
                    Text(projectViewModel.convertDateTimeToString(date: recording.startTime ?? Date()))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("End")
                    Spacer()
                    Text(projectViewModel.convertDateTimeToString(date: recording.endTime ?? Date()))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Duration")
                    Spacer()
                    Text(projectViewModel.convertSecToHMS(seconds: Int(recording.recordingDuration)))
                        .foregroundColor(.gray)
                }
                
                HStack {
                    Text("Description")
                    Spacer()
                    Text(recording.recordingDescription ?? "")
                        .foregroundColor(.gray)
                }
            }
            
            Section {
                HStack {
                    Spacer()
                    Text("delete recording")
                        .foregroundColor(.red)
                    Spacer()
                }
            }
            .onTapGesture {
                isShowingConfirmationDelete.toggle()
            }
        }
        .navigationBarTitle(recording.project ?? "")
        .confirmationDialog("Are you sure to delete?", isPresented: $isShowingConfirmationDelete, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                projectViewModel.deleteRecording(recording: recording)
            }
            
        }
    }
    
}

struct CalendarAddView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    
    @EnvironmentObject var projectViewModel: ProjectViewModel
    
    @State var projectName: String = ""
    @State var recordingDescription: String = ""
    @State var selectedStartDate: Date = Date()
    @State var selectedEndDate: Date = Date().addingTimeInterval(60)
    @State var selectedProject: CDProject?
    
    var body: some View {
        VStack {
            Capsule()
                .fill(.secondary)
                .frame(width: 30, height: 5, alignment: .center)
                .padding(.top, 10)
        }
        
        HStack {
            Button("Cancel") {
                self.presentationMode.wrappedValue.dismiss()
            }
            Spacer()
            Text("new recording")
                .bold()
            
            Spacer()
            Button("Add") {
                saveEntry()
                self.presentationMode.wrappedValue.dismiss()
            }
            .disabled(selectedProject == nil)
        }
        .padding()
        
        NavigationView {
            Form {
                Section(header: Text("PROJECT")) {
                    Picker("select project", selection: $selectedProject) {
                        ForEach(projectViewModel.projects, id: \.self) { project in
                            Text(project.projectName!).tag(project as CDProject?)
                        }
                    }
                }
                
                TextField("Description", text: $recordingDescription)
                    .textFieldStyle(.roundedBorder)
                
                HStack {
                    Text("Start")
                    Spacer()
                    DatePicker("", selection: $selectedStartDate)
                        .padding()
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                
                HStack {
                    Text("End")
                    Spacer()
                    DatePicker("", selection: $selectedEndDate)
                        .padding()
                        .datePickerStyle(CompactDatePickerStyle())
                }
                
                
            }
            .navigationBarTitle("")
            .navigationBarHidden(true)
        }
        Spacer()
    }
    
    func saveEntry() {
        projectViewModel.saveEntryRecording(project: selectedProject!, recordingDescription: recordingDescription, startDate: selectedStartDate, endDate: selectedEndDate)
    }
    
}
