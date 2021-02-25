//
//  ContentView.swift
//  Sriteja001
//
//  Created by Amit Gupta on 1/28/21.
//

import SwiftUI

import Alamofire
import SwiftyJSON
//import Alamofire

// This is for predicting battery life https://aiclub.world/projects/32e764d4-0b61-4c36-bce9-2cb85903cc33?tab=service

struct ContentView: View {
    @State var prediction: String = "Lets check"
    
    @State var params: Parameters = [:]
    
    @State var ageScore: Float = 35
    @State var weightScore: Float = 100
    
    @State var rfHlth = false
    @State var rfHyp = false
    @State var rfChol = false
    
    @State var predictionGood = true
    
    let uploadURL = "https://6n11kxb1s9.execute-api.us-east-1.amazonaws.com/Predict/096ba20a-c7f7-4941-b4c5-1b1881a97e04"
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    HStack {
                        Text("Prediction:").font(.largeTitle)
                        Spacer()
                        Text(prediction).foregroundColor(predictionGood ? .green: .red)
                    }
                }
                
                Section(header: Text("Inputs")) {
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "minus")
                                Slider(value: $ageScore, in: 20...100).onChange(of: ageScore, perform: { value in
                                    predictAI()
                                }).accentColor(Color.green)
                                Image(systemName: "plus")
                            }.foregroundColor(Color.green)
                            Text("Age: \(ageScore, specifier: "%.0f")")
                        }
                    }
                    HStack {
                        VStack {
                            HStack {
                                Image(systemName: "minus")
                                Slider(value: $weightScore, in: 50...250).onChange(of: weightScore, perform: { value in
                                    predictAI()
                                }).accentColor(Color.green)
                                Image(systemName: "plus")
                            }.foregroundColor(Color.green)
                            Text("Weight: \(weightScore, specifier: "%.0f")")
                        }
                    }
                    HStack {
                        Text("Health:").fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).foregroundColor(Color.black)
                        Spacer()
                        Text("Good")
                        Toggle("Health:",isOn: $rfHlth).labelsHidden()
                            .onChange(of: rfHlth, perform: { value in
                            predictAI()
                        })
                        Text("Bad").foregroundColor(Color.red)
                    }.foregroundColor(Color.green)
                    
                    HStack {
                        Text("Hypertension:").fontWeight(.bold).foregroundColor(Color.black)
                        Spacer()
                        Text("Good")
                        Toggle("Hypertension",isOn: $rfHyp).labelsHidden()
                            .onChange(of: rfHyp, perform: { value in
                            predictAI()
                        })
                        Text("Bad").foregroundColor(Color.red)
                    }.foregroundColor(Color.green)
                    
                    HStack {
                        Text("Cholesterol:").fontWeight(.bold).foregroundColor(Color.black)
                        Spacer()
                        Text("Good")
                            .multilineTextAlignment(.trailing)
                        Toggle("Cholesterol",isOn: $rfChol).labelsHidden()
                            .onChange(of: rfChol, perform: { value in
                            predictAI()
                        })
                        Text("Bad").foregroundColor(Color.red)
                    }.foregroundColor(Color.green)
                    
                    
                }
                
                

            }
            .navigationBarTitle(Text("Diabetes Risk Checker"),displayMode: .inline)
        }.onAppear(perform: predictAI)
    }
    
    func mappedAge(_ age:Int) -> Int {
        if(age<=24) {
            return 1
        }
        if(age<=29) {
            return 2
        }
        if(age<=34) {
            return 3
        }
        if(age<=39) {
            return 4
        }
        if(age<=44) {
            return 5
        }
        if(age<=49) {
            return 6
        }
        if(age<=54) {
            return 7
        }
        if(age<=59) {
            return 8
        }
        if(age<=64) {
            return 9
        }
        if(age<=69) {
            return 10
        }
        if(age<=74) {
            return 11
        }
        if(age<=79) {
            return 12
        }
        if(age<=99) {
            return 13
        }
       return 14
    }
    
    func predictAI() {
        print("Just got the call to PredictAI()")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        params["_AGEG5YR"] = String(mappedAge(Int(round(ageScore))))
        let wtScore=Int(round(weightScore*100/2.2))
        params["WTKG3"] = String(wtScore)
        params["_RFHLTH"] = rfHlth ? 1 : 2
        params["_RFHYPE5"] = rfHyp ? 1 : 2
        params["_RFCHOL"] = rfChol ? 1 : 2

        
        debugPrint("Calling the AI service with parameters=",params)
        
        AF.request(uploadURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            
            //debugPrint("AF.Response:",response)
            switch response.result {
            case .success(let value):
                var json = JSON(value)
                //debugPrint("Initial value is ",value)
                //debugPrint("Initial JSON is ",json)
                let body = json["body"].stringValue
                //debugPrint("Initial Body is ",body)
                json = JSON.init(parseJSON: body)
                debugPrint("Second JSON is ",json)
                let predictedLabel = json["predicted_label"].stringValue
                predictionGood = predictedLabel=="1"
                let s = predictionGood ?"Low risk":"High risk"
                //debugPrint("Predicted label equals",predictedLabel)
                //let s = (Float(predictedLabel) ?? -0.01)*100
                //let s = (Float(predictedLabel) ?? -0.01)*1
                //self.prediction=String(format: "%.1f%", s)
                self.prediction = s
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
    
    init() {
        
        // UI look-and-feel
        UINavigationBar.appearance().backgroundColor = .yellow
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

