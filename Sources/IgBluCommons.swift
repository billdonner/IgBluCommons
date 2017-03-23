struct IgBluCommons {

    var text = "Hello, World!"
}

public struct TestKit {
    public  static let text = "Hello, IgBluCommons! Tag is 0.0.2"
}
// touch07
import Foundation
import Kitura
import KituraNet
import KituraRequest
import Configuration
import CloudFoundryEnv
import CloudFoundryConfig
import LoggerAPI
import Dispatch

public enum RemoteCallType {
    case tURLSession
    case tKituraSynch
    case tKituraRequest
    case tContentsOfFile
}

public let remoteCallType = RemoteCallType.tKituraSynch



open class StandardController {
    fileprivate static let startdate = Date()
    open let router: Router
    open let configMgr: ConfigurationManager
    open  let serverConfig: ServerConfig
    open   var jsonEndpointEnabled: Bool = true
    open   var jsonEndpointDelay: UInt32 = 0
    open  var globalData = GlobalData()
    open var port: Int {
        get { return configMgr.port }
    }
    
    open var url: String {
        get { return configMgr.url }
    }
    
    // routes setup down below
    
    //check usage by mans
    
    public  init(_ sc :ServerConfig ) throws {
        print("IgKitCommons loaded with \(TestKit.text)")
        configMgr = ConfigurationManager().load(.environmentVariables)
        serverConfig = sc
        // All web apps need a Router instance to define routes
        router = Router()
        //setupBasicRoutes(router:router)
        Log.info("Starting Server \(serverConfig.servertitle) \(serverConfig.softwareversion)  on \(url).")
    }
    
    
    
}


public func qrandom(max:Int) -> Int {
    #if os(Linux)
        return Int(rand()) % Int(max)
    #else
        return Int(arc4random_uniform(UInt32(max)))
    #endif
}


protocol SloRunner {
    func sloRunningWebService(id:String, token: String,completion:(Int,Int,[String:Any])->())
}

extension SloRunner {
    func sloRunningWebService(id:String, token: String,completion:(Int,Int,[String:Any])){
        print("replace sloRunningWebService soon")
    }
}

protocol RemoteWebServiceCall {
    func remoteGet(_ urlstr: String, session: URLSession?,completion:@escaping (Int,Data?) ->())
}
extension RemoteWebServiceCall {
    func remoteGet(_ urlstr: String, session: URLSession?, completion:@escaping (Int,Data?) ->()) {
        print("replace remoteGet")
    }
}
open class ServerConfig {
    open let softwareversion : String // "0.998920"
    open let servertitle: String // ""IGBLUEREPORTS"
    open  let description : String // " "/report and /report-list routes"
    open let identityServer : String // ""https://igblue.mybluemix.net"
    
    public init(version:String,title:String,description:String,ident:String) {
        softwareversion = version; servertitle = title ; self.description = description; identityServer = ident
    }
}
//tpicj
open class BlueConfig {
    public var blueConfig:[String:Any]
    public var grandConfig:[String:Any]
    public init() {
        blueConfig  = [:]
        grandConfig  = [:]
    }
    
    fileprivate func readFirstLevelConfig(_ configurl:URL) throws -> [String:Any]  {
        func fallback() -> [String:Any] {
            print("--- cant parse first level config, falling back to embedded configuration")
            return ["grandConfig":"https://billdonner.com/tr/blue-server-config.json","softwarenamed":"igblu","debugPrint":"on"]
        }
        let data = try Data(contentsOf: configurl)
        if let config = try JSONSerialization.jsonObject(with:data, options: .allowFragments) as? [String: Any] {
            return  config
        } else {
            return fallback()
        }
    }
    fileprivate func readSecondLevelConfig(_ configurl:URL) throws -> [String:Any]  {
        func fallback() -> [String:Any] {
            print("--- cant parse second level config, falling back to embedded configuration")
            return ["mocked":"data here is mocked up, for some reason we could not read \(configurl)","date":"\(Date())"]
        }
        do {
            let data = try Data(contentsOf: configurl)
            if let config = try JSONSerialization.jsonObject(with:data, options: .allowFragments) as? [String: Any] {
                return  config
            } else {
                return fallback()
            }
        } catch {
            return fallback()
        }
    }
    
    
    
    func tiny() throws -> String {
        // #if os(Linux)
        return "https://billdonner.com/tr/blue-server-config.json"
    }
    public func process(configurl:URL?) throws {
        if configurl == nil {
            // read from infodictionary
            let levtwoconfigurl = try tiny()
            if  let levtwourl = URL(string:levtwoconfigurl)  {
                let levtwoconfig = try readSecondLevelConfig(levtwourl)
                grandConfig = levtwoconfig
                blueConfig = ["grandConfig":levtwoconfigurl]
            }
        } else {
            do {
                // read small local config as bootstrap
                let levoneconfig = try readFirstLevelConfig(configurl!)
                if let levtwoconfigurl = levoneconfig["grandConfig"] as? String ,
                    let levtwourl = URL(string:levtwoconfigurl) {
                    let levtwoconfig = try readSecondLevelConfig(levtwourl)
                    grandConfig = levtwoconfig
                }
                blueConfig = levoneconfig
            } catch {
                
            }
        }
    }
    
    // quix and easy
    class func load(configurl:URL) throws -> BlueConfig  {
        let bc = BlueConfig()
        do {
            try  bc.process(configurl: configurl)
            return bc
        }
        
    }
}// of BlueConfig


public extension String {
    
    public func leftPadding(toLength: Int, withPad character: Character) -> String {
        
        let newLength = self.characters.count
        
        if newLength < toLength {
            
            return String(repeatElement(character, count: toLength - newLength)) + self
            
        } else {
            
            return self.substring(from: index(self.startIndex, offsetBy: newLength - toLength))
            
        }
    }
    
}

///////////
///////////
///////////
///////////
///////////

struct TraceLog {
    static var buffer :[String] = []
    static func bufrd_clear( ) {
        buffer = []
    }
    static func bufrd_print(_ s:String) {
        buffer += [s]
    }
    static func bufrd_print(_ s:[String]) {
        buffer += s
    }
    static func bufrd_contents()->[String] {
        return buffer
    }
}
public struct ApiCounters {
    public  var getIn = 0
    public   var getOut = 0
    public   var postIn = 0
    public   var postOut = 0
    public   func counters()->[String:Int] {
        return ["get-in":getIn,"get=out":getOut,"post-in":postIn,"post-out":postOut]
    }
}
open class GlobalData {
    open var localConfig:[String:Any] = [:]
    open var apic = ApiCounters()
    open var usersLoggedOn : [String:[String:String]] = [:]
    
    public init () {
        
    }
}


public struct Fetch {
    
    public static func get (_ urlstr: String, session:URLSession?,use:RemoteCallType,
                            completion:@escaping (Int,Data?) ->()){
        
        func fetchViaURLSession (_ urlstr: String,_ session:URLSession?,completion:@escaping (Int,Data?) ->()){
            let url  = URL(string: urlstr)!
            let request = URLRequest(url: url)
            
            // now using a session per datatask so it hopefully runs better under linux
            
            //fatal error: Transfer completed, but there's no currect request.: file Foundation/NSURLSession/NSURLSessionTask.swift, line 794
            
            //https://github.com/stormpath/Turnstile/issues/31
            let task = session?.dataTask(with: request) {data,response,error in
                if let httpResponse = response as? HTTPURLResponse  {
                    let code = httpResponse.statusCode
                    guard code == 200 else {
                        print("remoteHTTPCall to \(url) completing with error \(code)")
                        completion(code,nil) //fix
                        return
                    }
                }
                guard error == nil  else {
                    
                    print("remoteHTTPCall to \(url) completing  error \(error)")
                    completion(529,nil) //fix
                    return
                }
                
                // handle response
                
                completion(200,data)
            }
            task?.resume ()
        }
        
        
        func fetchViaContentsOfFile(_ urlstr: String, _ session:URLSession?,completion:@escaping (Int,Data?) ->()) {/// makes http request outbund
            do {
                if
                    let nurl = URL(string:urlstr) {
                    
                    let  data =  try Data(contentsOf: nurl)
                    
                    completion (200,data)
                    
                }
            }
            catch {
                completion (527, nil)
            }
        }
        
        func fetchViaKituraRequest(_ urlstr: String, _ session:URLSession?,completion:@escaping (Int,Data?) ->()) {
            KituraRequest.request(.get, urlstr).response {
                request, response, data, error in
                guard error == nil  else {
                    
                    print("remoteHTTPCall to \(urlstr) completing  error \(error)")
                    
                    completion(529,nil) //fix
                    return
                }
                guard let data = data else {
                    completion(527,nil)
                    return
                }
                completion(200,data)
            }
        }
        
        func fetchViaKitura(_ urlstr: String, _ session:URLSession?,completion:@escaping (Int,Data?) ->()) {/// makes http request outbund
            func innerHTTP( requestOptions:inout [ClientRequest.Options],completion:@escaping (Int,Data?) ->()) {
                var responseBody = Data()
                let req = HTTP.request(requestOptions) { response in
                    if let response = response {
                        guard response.statusCode == .OK else {
                            _ = try? response.readAllData(into: &responseBody)
                            completion(404,responseBody)
                            return }
                        _ = try? response.readAllData(into: &responseBody)
                        completion(200,responseBody)
                    }
                }
                req.end()
            }
            var requestOptions: [ClientRequest.Options] = ClientRequest.parse(urlstr)
            let headers = ["Content-Type": "application/json"]
            requestOptions.append(.headers(headers))
            innerHTTP(requestOptions: &requestOptions,completion:completion)
        }
        
        let remoteCallType:RemoteCallType = use
        
        switch remoteCallType {
            
        case RemoteCallType.tURLSession:
            fetchViaURLSession(urlstr, session, completion: completion)
        case RemoteCallType.tKituraSynch:
            fetchViaKitura(urlstr, session, completion: completion)
        case RemoteCallType.tKituraRequest:
            fetchViaKituraRequest(urlstr, session, completion: completion)
        case RemoteCallType.tContentsOfFile:
            fetchViaContentsOfFile(urlstr, session, completion: completion)
        }
    }
}


public extension StandardController {
    
    static let boottime = Date()
    
    // static  let sloCallback : SloRunner = sloRunningWebService as! SloRunner
    
    //  static let remoteWebService: RemoteWebServiceCall =  Fetch.get as! RemoteWebServiceCall
    
    
    public  func sloRunningWebService(id:String, token: String,completion:(Int,Int,[String:Any])->()){
        
    }
    
    
    
    //MARK: - ///////////// HANDLERS ////////////////////////
    
    
    public   func jsonEndpointManager(request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        Log.debug("POST - /enable route handler...")
        response.headers["Content-Type"] = "text/plain; charset=utf-8"
        guard let jsonPayload = request.body?.asJSON else {
            try response.status(.badRequest).send("JSON payload not provided!").end()
            return
        }
        guard let enabled = jsonPayload["enabled"].bool,
            let delay = jsonPayload["delay"].int else {
                try response.status(.badRequest).send("Required fields in JSON payload not found!").end()
                return
        }
        self.jsonEndpointEnabled = enabled
        self.jsonEndpointDelay = UInt32(delay)
        try response.status(.OK).send("/json endpoint settings updated!").end()
    }
    
    /**
     * Handler for getting an application/json response.
     */
    public  func finishJSONStatusResponse(_ extra: [String:Any], request: RouterRequest, response: RouterResponse  , status:Int = 200, next: @escaping () -> Void) throws {
        let now = Date()
        let uptime = now.timeIntervalSince(StandardController.startdate)
        let prettysecs = String(format:"%0.2f",uptime)
        var out :  [String:Any] = ["server-url":url,"response-status":status,"servertitle":serverConfig.servertitle,"description":serverConfig.description,"softwareversion":serverConfig.softwareversion,"elapsed-secs":"\(prettysecs)","up-time":uptime,"timenow":"\(Date())","httpgets":globalData.apic.getIn]
        
        for (key,val) in extra {
            out[key]=val
        }
        
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        let data = try JSONSerialization.data(withJSONObject:out, options:.prettyPrinted )
        try response.status(.OK).send(data:data).end()
    }
    
    /// standard error responses -
    public   func log (request: RouterRequest, response: RouterResponse, next: @escaping () -> Void) throws {
        let qp = request.queryParameters
        /// for now - just put all the query paramters into the log
        Log.info("LOGLINE \(qp)")
        // prepare payload
        let out = ["logged":qp ] as [String : Any]
        // send ack to caller
        try finishJSONStatusResponse(out, request: request, response: response, next: next)
        
    }
    
    public  func missingID(_ response:RouterResponse) {
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        let out:[String:Any] = ["status":404 ,"results":"no ID","timenow":"\(Date())"]
        do {
            let data = try JSONSerialization.data(withJSONObject:out, options: .prettyPrinted)
            
            try response.status(.OK).send(data:data).end() } catch {
                Log.error("can not send response in missingID")
        }
    }
    public   func unkownOP(_ response:RouterResponse) {
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        let out:[String:Any] = ["status":404 ,"results":"no ID","timenow":"\(Date())"]
        do {
            let data = try JSONSerialization.data(withJSONObject:out, options: .prettyPrinted)
            
            try response.status(.OK).send(data:data).end() } catch {
                Log.error("can not send response in missingID")
        }
    }
    func sendCallAgainSoon(_ response: RouterResponse) {
        response.headers["Content-Type"] = "application/json; charset=utf-8"
        do {
            
            let jsonResponse : [String : Any] = ["status":500 ,"results":"initializing - try again soon","timenow":"\(Date())"]
            let data = try JSONSerialization.data(withJSONObject:jsonResponse, options:.prettyPrinted )
            
            try response.status(.OK).send(data:data).end() } catch {
                Log.error("can not send response in getJSON")
        }
    }
    
    /// standard outbound calls -
    
    
    
    
    public   func finally(code:Int,data:Data,userid:String,token:String,
                          request: RouterRequest, response: RouterResponse)
        
    {
        /// now , finally we c
        
        guard let what = request.parameters["what"] else { return  self.missingID(response)  }
        switch what {
            
        case "json" :
            sloRunningWebService(id: userid, token: token){status,html, dict in
                do{
                    response.headers["Content-Type"] = "application/json; charset=utf-8"
                    let edict = ["fetchedStatus":status ,"status":status ,"payload":dict,"serverURL":self.url,"time-of-report":"\(Date())"] as [String : Any]
                    let jsonResponse = try JSONSerialization.data(withJSONObject:edict, options:.prettyPrinted )
                    
                    try response.status(.OK).send(data: jsonResponse).end()
                }
                catch{
                    print("sloRunningWebService json try failed")
                    
                }
                return
            }
            //        case "plain" :
            //            sloRunningWebService(id: userid, token: token){status,html,dict in
            //                do {
            //                    response.headers["Content-Type"] = "text/html"
            //                    let html = MasterTasks.htmlDynamicPageDisplay(baseurl: self.url)
            //                    try response.status(.OK).send(html).end()
            //
            //                }
            //                catch {
            //                    print("sloRunningWebService plain try failed")
            //                }
            //                return
        //            }
        default: break
        }
        
    }//finally
    
    public   func fetchWithTokens(userid:String,smtoken:String, targeturl:String, request: RouterRequest, response: RouterResponse,completion:@escaping(Int,[String:Any])->())  {
        let fetchurl  = "https://igblue.mybluemix.net"
            + "/igtoken/\(userid)?smtoken=\(smtoken)"
        let escapedFetchURL = fetchurl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "URL-MUCKED"
        let starttime = Date()
        
        //// LOOKING UP ACCESS TOKEN
        Fetch.get( escapedFetchURL,
                   session: nil,
                   use:remoteCallType){ status, data in
                    
                    do   {
                        response.headers["Content-Type"] = "application/json; charset=utf-8"
                        
                        var edict:[String:Any] = ["fetchedStatus":status ]
                        edict["timenow"] = "\(starttime)"
                        edict["URLtoFetch"] = fetchurl
                        edict["originalURL"] = request.originalURL
                        
                        let elapsed:TimeInterval =  Date().timeIntervalSince(starttime)
                        edict["fetchedMsTime"]  = Float( elapsed * 1000.0 )
                        guard let data = data  else {
                            print ("cant parse no json")
                            return self.missingID(response)
                        }
                        let bycount = data.count
                        edict["fetchByteCount"] =  bycount
                        
                        
                        // see if we have any json
                        
                        guard  let jsdict  = try JSONSerialization.jsonObject(with:data, options: .allowFragments)
                            as? [String: Any] ,
                            let token = jsdict["ig-token"] as? String,
                            let userid = jsdict["ig-userid"] as? String else
                        {
                            print ("cant parse no json")
                            return self.missingID(response)
                        }
                        
                        /// here we can call our target webservice
                        
                        Fetch.get ( targeturl,session:nil,use:remoteCallType) {status2,data2 in
                            // and finally
                            do {
                                self.finally(code:status2,data:data2!,userid:userid,token:token,request: request, response: response)
                                
                                completion(200,edict)
                                let jsonResponse = try JSONSerialization.data(withJSONObject:edict, options:.prettyPrinted )
                                try response.status(.OK).send(data:jsonResponse).end()
                            }//inner do in closure
                            catch {
                                //TODO:
                                print ("Inner fetch.get failure")
                                completion(407,[:])
                            }
                        } // inner fetch
                    }  // outer fetch
                        // outer do
                    catch   {
                        //TODO:
                        print ("outer fetch.get failure")
                        completion(409,[:])
                    }
        } // end fetchWithTokens
    }// end Fetch.get
    
}

// doesnt this neesd


// MARK: - Sorting

public func sortNestedData(lhsIsFolder: Bool, rhsIsFolder: Bool,  ascending: Bool,
                           attributeComparation: Bool) -> Bool {
    if(lhsIsFolder && !rhsIsFolder) {
        return ascending ? true : false
    }
    else if (!lhsIsFolder && rhsIsFolder) {
        return ascending ? false : true
    }
    return attributeComparation
}

public func itemComparator<T:Comparable>(lhs: T, rhs: T, ascending: Bool) -> Bool {
    return ascending ? (lhs < rhs) : (lhs > rhs)
}


public func ==(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedSame {
        return true
    }
    return false
}

public func <(lhs: Date, rhs: Date) -> Bool {
    if lhs.compare(rhs) == .orderedAscending {
        return true
    }
    return false
}

//////public

extension StandardController: SloRunner {
    
    func sloRunningWebService(id:String, token: String, completion:  (Int,Int,[String:Any])){
        print("replace slownner soon")
    }
    
}
