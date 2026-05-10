import SwiftUI

enum ReadingTimerState {
    case waiting
    case reading
    case recording

    var imageName: String {
        switch self {
        case .waiting:
            return "kuu_waiting"
        case .reading:
            return "kuu_reading"
        case .recording:
            return "kuu_recording"
        }
    }

    var message: String {
        switch self {
        case .waiting:
            return "準備ができたら始めましょう、ご主人様。"
        case .reading:
            return "読書中です。クーは静かに見守ります。"
        case .recording:
            return "今の感想を、忘れる前に残しましょう。"
        }
    }
}

struct KuuImageView: View {
    let state: ReadingTimerState

    var body: some View {
        VStack(spacing: 10) {
            Image(state.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxHeight: state == .recording ? 260 : 300)
                .clipShape(RoundedRectangle(cornerRadius: 28))
                .shadow(color: .blue.opacity(0.12), radius: 12, x: 0, y: 8)
                .transition(.opacity)

            Text(state.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .animation(.easeInOut(duration: 0.25), value: state.imageName)
    }
}
