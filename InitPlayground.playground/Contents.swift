import UIKit
//import Foundation
//import Swift

// Write a function that lists numbers from 1 to 50;
// take the even numbers out, and put them in a different array

//var starter = [ "hello", "darkeness", "my", "old" , "Friend"]

var evenNumbers:[Int] = [];
for i  in 1...50 {
    guard i % 2 == 0 else {continue}
    evenNumbers.append(i);
}

struct MyJSONResponse : Decodable  {
    var request:[Food]
}

struct Food : Decodable {
    var carbs :Int
    var name :String
    var description: String
    var id : Int
    var calories : Int
    var imageURL : String
    var protein : Int
    var price : Float
}

enum InternetError:Error{
    case networkError
    case unknownError
    case randomError
    case emptyData
    case invalidURL
    
    var message :String {
        switch self {
        case .networkError:
            return "Looks like something happened to your network.";
        case .emptyData :
            return "Looks like your request did not return any data";
        case .invalidURL :
            return " Your URL might be invalid";
        default:
            return ""
        }
            
    }
}
// --- A model that is used as type to parse values obtained from a network request ---
// --- Inits with either available Data or InternetError
struct InternetResponse {
    var data : Data?
    var decoder  = JSONDecoder();
    var error : InternetError?
    
    init(error:InternetError) {
        self.error = error;
    }
    
    init(data:Data) {
        self.data = data;
    }
}
// ------ A class that is used to make network request calls in swift.
// ------ Returns  InternetResponse everytime ----------
class InternetExplorer{
    static let getInstance = InternetExplorer()
    public var link : String = ""
    private var goToURL : URL{
        return URL (string:self.link)!
    }
    private let networkSession = URLSession.shared;
    
    func search(onComplete: @escaping (InternetResponse) -> Void ){
        
        //---- Escape function if URL is not provided...
        guard self.link != "" else {
            onComplete(InternetResponse(error: .invalidURL))
            return
        }
        let networkTask =  self.networkSession.dataTask(with: self.goToURL, completionHandler:{ data, response, error in
            
           // --- Check if error is available, then return response object with error field set and quit running.
            guard error == nil else {
                onComplete(InternetResponse(error:(.networkError)))
                return;
            }
            let netResponse = InternetResponse(data:data!)
            onComplete(netResponse)
        });
        
        networkTask.resume();
    }
    
    func roamAndFind(link:String?, callback onComplete: @escaping (InternetResponse) -> Void){
        self.link = link ?? ""
        self.search(){ netResponse in
            onComplete(netResponse)
        }
    }
}






// --- Creating network calls ------

let API_URL = "https://seanallen-course-backend.herokuapp.com/swiftui-fundamentals/appetizers";
let url  = URL( string: API_URL)

func callNetworkFxn(link: URL) -> Void {
    let networkHandler = URLSession.shared.dataTask(with: link, completionHandler: {data , response, error in
        let decoder = JSONDecoder();
        do {
            let returned = try decoder.decode(MyJSONResponse.self, from: data!)
            print (returned);
            
        }
        catch{
            print ("An error occured bro ---> \(error)")
        }
        
    });
    networkHandler.resume();
}


var explorer = InternetExplorer.getInstance;

explorer.roamAndFind( link: API_URL,callback:{ response in
    do{
        guard response.error == nil else {
            print("Error here please: --> \(response.error!.message)")
            return;
        }
        let realContent = try response.decoder.decode(MyJSONResponse.self, from: response.data!);
        print("I am the response bro \n--------------------->\n---------------------------->");
        print(realContent);
    }catch{
        print(InternetError.randomError.message);
    }
    
    
})
