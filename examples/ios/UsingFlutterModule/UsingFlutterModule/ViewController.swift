//
//  ViewController.swift
//  UsingFlutterFramework
//
//  Created by Eduardo dos santos on 15/04/23.
//

import UIKit
import Flutter

class ViewController: UIViewController {
    
    var flutterEngine: FlutterEngine?
    var flutterMethodChannel: FlutterMethodChannel?
    @IBOutlet weak var returnFlutter: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //Garante que quando voltar de uma tela Flutter ele não irá ficar preso sempre nela
        flutterEngine = FlutterEngine(name: "flutter_engine")
        flutterEngine!.run(withEntrypoint: nil, initialRoute: "/")
        flutterMethodChannel = FlutterMethodChannel(name: "br.com.megamil/callSDK", binaryMessenger: flutterEngine!.binaryMessenger)
    }
    
    //Chama uma tela mais complexa, apresenta ela em tela cheia, sendo que a função de voltar está no código em flutter e retorna dados que são apresentados no Swift.
    @IBAction func openCreateUser() {
        
        let flutterViewController =
        FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
        flutterViewController.modalTransitionStyle = .coverVertical
        flutterViewController.modalPresentationStyle = .fullScreen
        
        let jsonObject: NSMutableDictionary = NSMutableDictionary()
        let randomGender = arc4random_uniform(2) == 0 ? "male" : "female"
        jsonObject.setValue(randomGender, forKey: "gender")

        var convertedString: String? = nil

        do {
            let data =  try JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted)
            convertedString = String(data: data, encoding: String.Encoding.utf8)
            flutterMethodChannel!.invokeMethod("newUser", arguments: convertedString)
            flutterViewController.modalTransitionStyle = .crossDissolve
            flutterViewController.modalPresentationStyle = .fullScreen
            present(flutterViewController, animated: true, completion: nil)
        } catch let myJSONError {
            print(myJSONError)
        }
        
        //Prepara para receber os dados que o Flutter retornar.
        flutterMethodChannel?.setMethodCallHandler { [] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            guard call.method == "userCreated" else {
                result(FlutterMethodNotImplemented)
                return
            }
            print("Retorno de: userCreated recebido no Swift")
            print(call.arguments.debugDescription)
            let jsonString = call.arguments as! String
            
            let json = try! JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: []) as! [String: Any]
            let results = json["results"] as! [[String: Any]]

            for user in results {
                let _name = user["name"] as? [String: Any] ?? [:]
                let name = "\(_name["first"] as? String ?? "") \(_name["last"] as? String ?? "")"
                let email = user["email"] as? String ?? ""
                let phone = user["phone"] as? String ?? ""
                
                let _city = user["location"] as? [String: Any] ?? [:]
                let city = _city["city"] as? String ?? ""
                
                let picture = user["picture"] as? [String: Any] ?? [:]
                let urlImage = picture["large"] as? String ?? ""
                
                self.returnFlutter.text = "Valor retornado pelo Flutter: \n* Nome: \(name), \n* E-mail: \(email), \n* Telefone: \(phone), \n* Cidade: \(city), \n* Imagem: \(urlImage)"
                
            }

        }

    }
    
    //Chama uma tela usando sistema de navigation, simples sem enviar ou receber parametros
    @IBAction func openSampleFlutter() {
        let flutterViewController = FlutterViewController(engine: flutterEngine!, nibName: nil, bundle: nil)
        flutterMethodChannel!.invokeMethod("sample", arguments: nil)
        self.navigationController?.pushViewController(flutterViewController, animated: true)
    }
    
}
