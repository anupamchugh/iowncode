//
//  ContentView.swift
//  SwiftUICoronaMapTracker
//
//  Created by Anupam Chugh on 08/03/20.
//  Copyright © 2020 iowncode. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

struct ContentView: View {
    
    @ObservedObject var coronaCases = CoronaObservable()
    
    var body: some View {
        VStack{
            
            Text("COVID-19 Data")
                .font(.headline)
                .padding()
            
            HStack{
                Text("Total Cases\n\(coronaCases.coronaOutbreak.totalCases)")
                .multilineTextAlignment(.center)
                Text("Total Recovered\n\(coronaCases.coronaOutbreak.totalRecovered)")
                .multilineTextAlignment(.center)
                Text("Total Deaths\n\(coronaCases.coronaOutbreak.totalDeaths)")
                .multilineTextAlignment(.center)
            }
            
            MapView(coronaCases: coronaCases.caseAnnotations, totalCases: Int(coronaCases.coronaOutbreak.totalCases) ?? 0)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct MapView: UIViewRepresentable {

    var coronaCases: [CaseAnnotations]
    var totalCases : Int

    func makeCoordinator() -> MapViewCoordinator {
        MapViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> MKMapView{
        MKMapView(frame: .zero)
    }
    
    func updateUIView(_ view: MKMapView, context: Context){

        view.delegate = context.coordinator
        
        view.addAnnotations(coronaCases)
        if let first = coronaCases.first{
            view.selectAnnotation(first, animated: true)
    
        }
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
    
    var mapViewController: MapView

    init(_ control: MapView) {
        self.mapViewController = control
    }
    
    func mapView(_ mapView: MKMapView, viewFor
        annotation: MKAnnotation) -> MKAnnotationView?{

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "anno")
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "anno")
            annotationView?.canShowCallout = true
            
        }
        
        let subtitleLabel = UILabel()
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        subtitleLabel.text = annotation.subtitle ?? "NA"
        subtitleLabel.numberOfLines = 0
        annotationView?.detailCalloutAccessoryView = subtitleLabel

        return annotationView
    }
}


class CoronaObservable : ObservableObject{
    
    @Published var caseAnnotations = [CaseAnnotations]()
    @Published var coronaOutbreak = (totalCases: "...", totalRecovered: "...", totalDeaths: "...")

   var urlBase = "https://services1.arcgis.com/0MSEUqKaxRlEPj5g/arcgis/rest/services/ncov_cases/FeatureServer/1/query"
    
    var cancellable : Set<AnyCancellable> = Set()
    
    init() {
        fetchCoronaCases()
    }
    
    func fetchCoronaCases()
    {
        
        var urlComponents = URLComponents(string: urlBase)!
        urlComponents.queryItems = [
            URLQueryItem(name: "f", value: "json"),
            URLQueryItem(name: "where", value: "Confirmed > 0"),
            URLQueryItem(name: "geometryType", value: "esriGeometryEnvelope"),
            URLQueryItem(name: "spatialRef", value: "esriSpatialRelIntersects"),
            URLQueryItem(name: "outFields", value: "*"),
            URLQueryItem(name: "orderByFields", value: "Confirmed desc"),
            URLQueryItem(name: "resultOffset", value: "0"),
            URLQueryItem(name: "cacheHint", value: "true")
        ]

        URLSession.shared.dataTaskPublisher(for: urlComponents.url!)
            .map{$0.data}
            .decode(type: CoronaResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
 
        }) { response in
            
            self.casesByProvince(response: response)
        }
        .store(in: &cancellable)
    }
    
    func casesByProvince(response: CoronaResponse)
    {
        var caseAnnotations : [CaseAnnotations] = []
        
        var totalCases = 0
        var totalDeaths = 0
        var totalRecovered = 0

        for cases in response.features{
            
            let confirmed = cases.attributes.confirmed ?? 0

            caseAnnotations.append(CaseAnnotations(title: cases.attributes.provinceState ?? cases.attributes.countryRegion ?? "", subtitle: "\(confirmed)", coordinate: .init(latitude: cases.attributes.lat ?? 0.0, longitude: cases.attributes.longField ?? 0.0)))

            totalCases += confirmed
            totalDeaths += cases.attributes.deaths ?? 0
            totalRecovered += cases.attributes.recovered ?? 0
        }

        self.coronaOutbreak.totalCases = "\(totalCases)"
        self.coronaOutbreak.totalDeaths = "\(totalDeaths)"
        self.coronaOutbreak.totalRecovered = "\(totalRecovered)"
        
        self.caseAnnotations = caseAnnotations

    }
}


class CaseAnnotations: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    
    init(title: String?,
         subtitle: String?,
         coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
    }
}


struct CoronaResponse : Codable{
    
    
    public var features: [CoronaCases]
        
    private enum CodingKeys: String, CodingKey {
        case features
    }
}

struct CoronaCases : Codable{
        
    public var attributes: CaseAttributes

    private enum CodingKeys: String, CodingKey {
        case attributes
    }
}

struct CaseAttributes : Codable {

        let confirmed : Int?
        let countryRegion : String?
        let deaths : Int?
        let lat : Double?
        let longField : Double?
        let provinceState : String?
        let recovered : Int?

        enum CodingKeys: String, CodingKey {
                case confirmed = "Confirmed"
                case countryRegion = "Country_Region"
                case deaths = "Deaths"
                case lat = "Lat"
                case longField = "Long_"
                case provinceState = "Province_State"
                case recovered = "Recovered"
        }
}
