//
//  NetworkClient.swift
//  PulsePolis
//
//  Created by IMAC  on 05.03.16.
//  Copyright © 2016 IMAC . All rights reserved.
//

import RxSwift
import RxAlamofire
import SwiftyJSON

class NetworkClient: NSObject {
    let disposeBag = DisposeBag()
    
    let BASE_SETTINGS_URL = "http://hotfinder.ru/hotjson/settings"
    //func authorize(params: [String: AnyObject]) ->
    
    func updateSettings() -> Observable<NetworkResponse>{
       return requestJSON(.GET, BASE_SETTINGS_URL)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, object) -> NetworkResponse in
                return self.mapResponseToNetworkResponse(object)
            })
    }
    
    private func mapResponseToNetworkResponse(object: AnyObject) -> NetworkResponse{
        let response = NetworkResponse()
        let json = JSON(object)
        response.errMsg = json["errormsg"].string
        response.status = Status(rawValue: json["status"].string ?? "ERR")
        if(response.status == Status.Success){
            APP.i().networkManager?.domain = json["domain"].string
            APP.i().networkManager?.version = json["version"].string
            APP.i().networkManager?.token = json["token"].string
            
            if let version = json["version"].string{
                if let apiDict = json["api"][version]["methods"].dictionaryObject{
                    APP.i().networkManager?.methodsStructure = MethodsStructure(dictionary: apiDict)
                }
            }
        }
        return response
    }
    
    func getCities() -> Observable<NetworkResponse>{
        return requestJSON(.GET, (APP.i().networkManager?.domain ?? "") + (APP.i().networkManager?.methodsStructure?.getCitiesURL() ?? ""), parameters: ["token": (APP.i().networkManager?.token ?? "")], encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, object) -> CitiesResponse in
                return CitiesResponse(json: JSON(object))
            })
        
    
    }
    
    func getPlaces(cityId: String) -> Observable<NetworkResponse>{
        return requestJSON(.GET, (APP.i().networkManager?.domain ?? "") + (APP.i().networkManager?.methodsStructure?.getPlacesURL() ?? ""), parameters: ["token": (APP.i().networkManager?.token ?? ""), "city_id": cityId], encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, object) -> PlacesResponse in
                return PlacesResponse(json: JSON(object))
            })
    }
    
    func getStatisticsPlaces(cityId: String, time: String, day: String) -> Observable<NetworkResponse>{
        return requestJSON(.GET, (APP.i().networkManager?.domain ?? "") + (APP.i().networkManager?.methodsStructure?.getStat() ?? ""), parameters: ["token": (APP.i().networkManager?.token ?? ""), "city_id": cityId, "time": time, "day": day], encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, object) -> PlacesResponse in
                return PlacesResponse(json: JSON(object))
            })
    }
    
    func getForecastPlaces(cityId: String, time: String) -> Observable<NetworkResponse>{
        return requestJSON(.GET, (APP.i().networkManager?.domain ?? "") + (APP.i().networkManager?.methodsStructure?.getForecastURL() ?? ""), parameters: ["token": (APP.i().networkManager?.token ?? ""), "city_id": cityId, "time": time], encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, object) -> PlacesResponse in
                return PlacesResponse(json: JSON(object))
            })
    }
    
    func defineCity() -> Observable<NetworkResponse>{
        let parametersDict:[String: AnyObject] = ["user_id": APP.i().user?.userId ?? "", "lat": APP.i().locationManager?.location?.lat ?? "", "lon": APP.i().locationManager?.location?.lon ?? "", "token": (APP.i().networkManager?.token ?? "")]
        return requestData(.POST, (APP.i().networkManager?.domain ?? "") + (APP.i().networkManager?.methodsStructure?.getDefineCityURL() ?? ""), parameters: parametersDict, encoding: .URL, headers: nil)
            .observeOn(MainScheduler.instance)
            .debug()
            .map({ (response, data) -> DefineCityResponse in
                return DefineCityResponse(json: JSON(data: data))
            })
    }
}
