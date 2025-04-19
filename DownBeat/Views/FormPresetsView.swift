import SwiftUI
import SwiftData

struct FormPresetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var presets: [FormPreset]
    @Binding var selectedPreset: FormPreset?
    @State private var showingAddPreset = false
    
    var onPresetSelected: (FormPreset) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Standard Forms")) {
                    Button("12-Bar Blues") {
                        let preset = FormPreset.twelveBarBlues()
                        onPresetSelected(preset)
                    }
                    .foregroundColor(.primary)
                    
                    Button("32-Bar AABA") {
                        let preset = FormPreset.thirtyTwoBarForm()
                        onPresetSelected(preset)
                    }
                    .foregroundColor(.primary)
                }
                
                Section(header: Text("Custom Presets")) {
                    if presets.isEmpty {
                        Text("No custom presets yet")
                            .foregroundColor(.gray)
                            .italic()
                            .frame(maxWidth: .infinity, alignment: .center)
                            .listRowBackground(Color.clear)
                    } else {
                        ForEach(presets) { preset in
                            Button(action: { onPresetSelected(preset) }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(preset.name)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    HStack(spacing: 5) {
                                        Text("\(preset.bpm) BPM")
                                        Text("•")
                                        Text(preset.timeSignature.description)
                                        Text("•")
                                        Text("\(preset.structure.count) Sections")
                                    }
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                }
                            }
                            .padding(.vertical, 4)
                            .swipeActions {
                                Button(role: .destructive) {
                                    deletePreset(preset)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Form Presets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddPreset = true }) {
                        Label("Add", systemImage: "plus")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPreset) {
                AddPresetView()
            }
        }
    }
    
    private func deletePreset(_ preset: FormPreset) {
        modelContext.delete(preset)
        
        // If this was the selected preset, deselect it
        if selectedPreset?.id == preset.id {
            selectedPreset = nil
        }
    }
}

struct AddPresetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var name = ""
    @State private var bpm = 120
    @State private var beats = 4
    @State private var noteValue = 4
    @State private var sections: [PhraseSection] = [PhraseSection(name: "A", barCount: 8)]
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Basic Info")) {
                    TextField("Preset Name", text: $name)
                    
                    Stepper("BPM: \(bpm)", value: $bpm, in: 40...300)
                    
                    HStack {
                        Text("Time Signature:")
                        Picker("Beats", selection: $beats) {
                            ForEach(2...12, id: \.self) { beat in
                                Text("\(beat)")
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                        
                        Text("/")
                        
                        Picker("Note Value", selection: $noteValue) {
                            Text("2").tag(2)
                            Text("4").tag(4)
                            Text("8").tag(8)
                            Text("16").tag(16)
                        }
                        .pickerStyle(.menu)
                        .frame(width: 60)
                    }
                }
                
                Section(header: Text("Structure")) {
                    ForEach(0..<sections.count, id: \.self) { index in
                        HStack {
                            TextField("Section Name", text: Binding(
                                get: { sections[index].name },
                                set: { sections[index].name = $0 }
                            ))
                            .frame(width: 80)
                            
                            Spacer()
                            
                            Stepper("Bars: \(sections[index].barCount)", value: Binding(
                                get: { sections[index].barCount },
                                set: { sections[index].barCount = $0 }
                            ), in: 1...32)
                        }
                    }
                    .onDelete { indexSet in
                        sections.remove(atOffsets: indexSet)
                    }
                    
                    Button("Add Section") {
                        withAnimation {
                            let newSection = PhraseSection(name: "New", barCount: 4)
                            sections.append(newSection)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("Add Preset")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreset()
                    }
                    .disabled(name.isEmpty || sections.isEmpty)
                    .fontWeight(.bold)
                }
            }
        }
    }
    
    private func savePreset() {
        let timeSignature = TimeSignature(beats: beats, noteValue: noteValue)
        let preset = FormPreset(name: name, bpm: bpm, timeSignature: timeSignature, structure: sections)
        
        modelContext.insert(preset)
        dismiss()
    }
} 