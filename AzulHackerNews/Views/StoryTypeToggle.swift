import SwiftUI

struct StoryTypeToggle: View {
    @Binding var selectedType: StoryType
    let onSelectionChange: (StoryType) -> Void
    
    var body: some View {
        Picker("Story Type", selection: $selectedType) {
            Text("Top").tag(StoryType.top)
            Text("New").tag(StoryType.new)
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(width: 120)
        .onChange(of: selectedType) { _, newType in
            onSelectionChange(newType)
        }
        .accentColor(.azulPrimary)
    }
}

#Preview {
    @Previewable @State var selectedType: StoryType = .top
    
    return StoryTypeToggle(
        selectedType: $selectedType,
        onSelectionChange: { type in
            print("Selected: \(type)")
        }
    )
    .padding()
}