//
//  ContentView.swift
//  BetterRest
//
//  Created by mithun srinivasan on 16/02/23.
//
import CoreML
import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 0
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var body: some View {
        NavigationView(){
            Form{
                Section{
                    DatePicker("pick a waking date", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                } header: {
                    Text("When do you wanna wakeup")
                        .font(.headline)
                }
                Section{
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 1...12, step: 0.25)
                } header: {
                    Text("how much sleep do you want")
                        .font(.headline)
                }
                Section{
//                    Stepper(coffeeAmount == 1 ? "1 cup" : "\(coffeeAmount) cups", value: $coffeeAmount, in: 1...12)
                    Picker("no of cups:", selection: $coffeeAmount) {
                        ForEach(1..<13) {
                            if $0 <= 1 {
                                Text("\($0) cup")}
                            else {
                                Text ("\($0)cups")
                            }
                            
                        }
                    }
                } header: {
                    Text("how much coffee u drink")
                        .font(.headline)
                }
                }
                .navigationTitle("Better Rest")
                .toolbar{
                    Button("calculate", action: calculateBedTime)
                }
                .alert(alertTitle, isPresented: $showAlert){
                    Button("OK"){}
                } message: {
                    Text(alertMessage)
                }
            }
    }
    func calculateBedTime(){
        do{
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60
            let minute = (components.minute ?? 0) * 60 * 60
            
            let prediction = try model.prediction(wake: Double(hour+minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            alertTitle = "your ideal bed time is:"
            alertMessage = sleepTime.formatted(date: .omitted, time: .shortened)
        }
        catch{
            alertTitle = "ERROR"
            alertMessage = "sorry, unexpected error has occured"
        }
        showAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
