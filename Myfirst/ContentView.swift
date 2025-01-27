//
//  ContentView.swift
//  Myfirst
//
//  Created by M1_Tugo on 1/20/25.
//

import SwiftUI
import AVKit

// Welcome Screen
struct WelcomeView: View {
    @Binding var isStarted: Bool
    @Binding var exerciseLogs: [String]

    var body: some View {
        VStack(spacing: 40) {
            Text("WELCOME")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            // Instructions for the user
            Text("Instructions:")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            Text("1. Watch the video to understand the exercise.\n2. Once you're ready, press 'Start Exercise' to begin.\n3. Use the 'Done' button to log your exercise time.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal, 40)

            // Start Exercise Button
            Button(action: {
                isStarted = true // Navigate to the first exercise
            }) {
                Text("Start Exercise")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            // History Button
            NavigationLink(destination: HistoryView(exerciseLogs: $exerciseLogs)) {
                Text("History")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            Spacer()
        }
        .padding()
    }
}
// Exercise View
struct ExerciseView: View {
    let videoName: String
    let exerciseName: String
    @Binding var currentExercise: Int
    @Binding var exerciseLogs: [String]
    @State private var elapsedTime = 0
    @State private var timer: Timer?
    @State private var isTimerRunning = false
    @State private var player: AVPlayer?

    var body: some View {
        VStack(spacing: 20) {
            // Exercise Title
            Text(exerciseName)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            // Video Player
            if let videoURL = Bundle.main.url(forResource: videoName, withExtension: "mp4") {
                VideoPlayer(player: AVPlayer(url: videoURL))
                    .onAppear {
                        initializePlayer(with: videoURL)
                    }
                    .onDisappear {
                        player?.pause() // Stop video when leaving screen
                        stopTimer() // Stop the timer
                    }
                    .frame(height: 300)
                    .cornerRadius(10)
            } else {
                Text("Video not found")
                    .foregroundColor(.red)
            }

            // Timer Display
            Text("Elapsed Time: \(elapsedTime) seconds")
                .font(.title2)
                .padding()

            // Start Exercise / Done Button
            Button(action: {
                if !isTimerRunning {
                    startTimer() // Start the timer
                    isTimerRunning = true
                } else {
                    stopTimer() // Stop the timer
                    logExercise() // Log the exercise time
                    isTimerRunning = false
                }
            }) {
                Text(isTimerRunning ? "Done" : "Start Exercise") // Dynamic button label
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(isTimerRunning ? Color.red : Color.green) // Dynamic button color
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)

            Spacer()

            // Next Button
            Button(action: {
                player?.pause() // Ensure the video stops
                stopTimer() // Ensure the timer stops
                logExercise() // Log the exercise time

                if currentExercise < 3 {
                    currentExercise += 1 // Move to the next exercise
                } else {
                    currentExercise += 1 // Navigate to High Five screen
                }
            }) {
                Text("Next")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }

    // MARK: - Initialize Player
    private func initializePlayer(with videoURL: URL) {
        player = AVPlayer(url: videoURL)
    }

    // MARK: - Timer Functions
    private func startTimer() {
        elapsedTime = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            elapsedTime += 1
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Log Exercise Time
    private func logExercise() {
        let log = "\(exerciseName) - \(elapsedTime) seconds"
        exerciseLogs.append(log)
    }
}
// MARK: - High Five Screen
struct HighFiveView: View {
    @Binding var isStarted: Bool

    var body: some View {
        VStack(spacing: 40) {
            Text("🎉 High Five! 🎉")
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
                .padding()

            Text("You’ve completed all the exercises. Great job!")
                .font(.title2)
                .padding()

            Spacer()

            Button(action: {
                isStarted = false // Navigate back to Welcome Screen
            }) {
                Text("Back to Home")
                    .font(.title2)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal, 40)
        }
        .padding()
    }
}

// MARK: - History View
struct HistoryView: View {
    @Binding var exerciseLogs: [String]

    var body: some View {
        VStack {
            Text("Exercise History")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            if exerciseLogs.isEmpty {
                Text("No exercises completed yet.")
                    .foregroundColor(.gray)
            } else {
                List(exerciseLogs, id: \.self) { log in
                    Text(log)
                }
            }
        }
        .padding()
    }
}

//Main Content View
struct ContentView: View {
    @State private var isStarted = false
    @State private var currentExercise = 0
    @State private var exerciseLogs: [String] = []

    let videoNames = ["squat", "step-up", "burpee", "sun-salute"]
    let exerciseNames = ["Squat", "Step Up", "Burpee", "Sun Salute"]

    var body: some View {
        NavigationView {
            if isStarted {
                if currentExercise < exerciseNames.count {
                    ExerciseView(
                        videoName: videoNames[currentExercise],
                        exerciseName: exerciseNames[currentExercise],
                        currentExercise: $currentExercise,
                        exerciseLogs: $exerciseLogs
                    )
                } else {
                    HighFiveView(isStarted: $isStarted)
                }
            } else {
                WelcomeView(isStarted: $isStarted, exerciseLogs: $exerciseLogs)
                    .navigationBarHidden(true)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Full-screen navigation
    }
}

// MARK: - Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
