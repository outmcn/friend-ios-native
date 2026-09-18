import Foundation
import AVFoundation

@MainActor
final class BackgroundMusicPlayer: ObservableObject {
    static let shared = BackgroundMusicPlayer()
    private var player: AVAudioPlayer?
    @Published private(set) var isPlaying = false

    private init() {
        do {
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try session.setActive(true)
            guard let url = Bundle.main.url(forResource: "bgm", withExtension: "mp3") else { return }
            player = try AVAudioPlayer(contentsOf: url)
            player?.numberOfLoops = -1
            player?.prepareToPlay()
        } catch { print("Background music unavailable: \(error)") }
    }

    func toggle() {
        guard let player else { return }
        if player.isPlaying { player.pause(); isPlaying = false }
        else { player.play(); isPlaying = true }
    }

    func start() {
        guard let player, !player.isPlaying else { return }
        player.play(); isPlaying = true
    }

    func stop() {
        player?.stop(); isPlaying = false
    }
}
