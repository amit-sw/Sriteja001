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
    
    let uploadURL = "https://6n11kxb1s9.execute-api.us-east-1.amazonaws.com/Predict/096ba20a-c7f7-4941-b4c5-1b1881a97e04"
    
    var body: some View {
        NavigationView {
            Form {
                
                Section {
                    HStack {
                        Text("Predict:").font(.largeTitle)
                        Spacer()
                        Text(prediction)
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
                                Slider(value: $weightScore, in: 90...120).onChange(of: weightScore, perform: { value in
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
                        Toggle(isOn: $rfHlth) {
                            Text("Good")
                                .multilineTextAlignment(.trailing)
                        }.onChange(of: rfHlth, perform: { value in
                            predictAI()
                        })
                        Text("Bad")
                    }.foregroundColor(Color.green)
                    
                    HStack {
                        Text("Hypertension:").fontWeight(.bold).foregroundColor(Color.black)
                        Spacer()
                        Toggle(isOn: $rfHyp) {
                            Text("Good")
                                .multilineTextAlignment(.trailing)
                        }.onChange(of: rfHyp, perform: { value in
                            predictAI()
                        })
                        Text("Bad")
                    }.foregroundColor(Color.green)
                    
                    HStack {
                        Text("Cholesterol:").foregroundColor(Color.black)
                        Text("Good")
                            .multilineTextAlignment(.trailing)
                        Toggle(isOn: $rfChol) {
                        }.onChange(of: rfChol, perform: { value in
                            predictAI()
                        })
                        Text("Bad")
                    }.foregroundColor(Color.green)
                    
                    
                }
                
                

            }
            .navigationBarTitle(Text("Diabetes Risk Checker"),displayMode: .inline)
        }.onAppear(perform: predictAI)
    }
    
    func predictAI() {
        print("Just got the call to PredictAI()")
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        params["_AGEG5YR"] = String(ageScore)
        params["WTKG3"] = String(weightScore)
        params["_RFHLTH"] = rfHlth ? 1 : 0
        params["_RFHYPE5"] = rfHyp ? 1 : 0
        params["_RFCHOL"] = rfChol ? 1 : 0

        
        debugPrint("Calling the AI service with parameters=",params)
        
        AF.request(uploadURL, method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON { response in
            
            debugPrint("AF.Response:",response)
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
                //debugPrint("Predicted label equals",predictedLabel)
                let s = (Float(predictedLabel) ?? -0.01)*100
                self.prediction=String(format: "%.1f%%", s)
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

