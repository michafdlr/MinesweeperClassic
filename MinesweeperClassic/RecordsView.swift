//
//  RecordsView.swift
//  MinesweeperClassic
//
//  Created by Michael Fiedler on 08.06.25.
//

import SwiftUI

struct RecordsView: View {
    @State private var records = [(Int, Int)]()
    @State private var selection = Set<Int>()
    @State private var selectedToDelete = Set<Int>()
    @State private var deleteAllAlertShowing = false
    @State private var deleteSelectedAlertShowing = false
    @State private var editModeOn = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(records, id: \.0) { record in
                    HStack {
                        if editModeOn {
                            Button {
                                if selection.contains(record.0) {
                                    selection.remove(record.0)
                                } else {
                                    selection.insert(record.0)
                                }
                            } label: {
                                Image(
                                    systemName: selection.contains(record.0)
                                        ? "checkmark.circle.fill" : "checkmark.circle"
                                )
                                .font(.title)
                                .foregroundStyle(
                                    selection.contains(record.0) ? .blue : .gray
                                )
                            }
                            .buttonStyle(.plain)
                        }

                        Text("Fields: \(record.0)")
                            .font(.title2)
                        Spacer()
                        Text("Record: \(record.1) seconds")
                            .font(.title2)
                            .frame(maxWidth: 300, alignment: .leading)
                    }
                }
                .onDelete { indices in
                    for index in indices {
                        let key = records[index].0
                        deleteRecord(fieldCount: key)
                    }
                    records.remove(atOffsets: indices)
                }
            }
            .scrollBounceBehavior(.basedOnSize)
            .navigationTitle("Record Times")
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button(editModeOn ? "Done" : "Select") {
                        withAnimation {
                            editModeOn.toggle()
                        }
                    }
                }

                ToolbarItem(placement: .destructiveAction) {
                    Button {
                        if selection.isEmpty || !editModeOn {
                            deleteAllAlertShowing = true
                        } else if editModeOn {
                            deleteSelectedAlertShowing = true
                        }
                    } label: {
                        Image(systemName: "trash")
                            .foregroundStyle(.red)
                    }
                }

            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            records = getAllRecords(file: "records.json").sorted { record1, record2 in
                record1.key < record2.key
            }
        }
        .alert("Delete All Records?", isPresented: $deleteAllAlertShowing) {
            Button("Delet All", role: .destructive) {
                records.forEach { deleteRecord(fieldCount: $0.0) }
                withAnimation {
                    records.removeAll()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Dou you really want to delete all records?")
        }
        .alert("Delete Selected Records?", isPresented: $deleteSelectedAlertShowing) {
            Button("Delet Records", role: .destructive) {
                selection.forEach { fieldCount in
                    deleteRecord(fieldCount: fieldCount)
                    withAnimation {
                        records.removeAll { record in
                            record.0 == fieldCount
                        }
                    }
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Dou you really want to delete the selected records?")
        }
    }
}

#Preview {
    RecordsView()
}
