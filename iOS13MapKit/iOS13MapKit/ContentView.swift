//
//  ContentView.swift
//  iOS13MapKit
//
//  Created by Anupam Chugh on 09/11/19.
//  Copyright © 2019 iowncode. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView: View {

    var body: some View {
        //PolylineMapView()
        CameraBoundaryMapView()
    }
}

struct CameraBoundaryMapView: UIViewRepresentable {
    
    func updateUIView(_ view: MKMapView, context: Context){

        let region = MKCoordinateRegion(center: CLLocationCoordinate2D(
        latitude: 12.9352, longitude: 77.6244), latitudinalMeters: 500, longitudinalMeters: 500)
                view.setCameraZoomRange(MKMapView.CameraZoomRange(minCenterCoordinateDistance: 500, maxCenterCoordinateDistance: 2000), animated: true)
        
        view.cameraBoundary = MKMapView.CameraBoundary(coordinateRegion: region)
    }
    func makeUIView(context: Context) -> MKMapView{
         MKMapView(frame: .zero)
    }
}

struct PolylineMapView: UIViewRepresentable {
    func makeCoordinator() -> MapViewCoordinator{
         return MapViewCoordinator(self)
    }
    
    func updateUIView(_ view: MKMapView, context: Context){

        view.delegate = context.coordinator
        let b2MLocation = [CLLocationCoordinate2D(
        latitude: 12.9352, longitude: 77.6244), CLLocationCoordinate2D(
        latitude: 19.0760, longitude: 72.8777)]
        let m2DLocation = [CLLocationCoordinate2D(
        latitude: 19.0760, longitude: 72.8777),
                           CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025)]
        let d2BLocation = [CLLocationCoordinate2D(latitude: 28.7041, longitude: 77.1025),
                           CLLocationCoordinate2D(
                           latitude: 12.9352, longitude: 77.6244)]
        
        let polyline1 = MKPolyline(coordinates: b2MLocation, count: b2MLocation.count)
        let polyline2 = MKPolyline(coordinates: m2DLocation, count: m2DLocation.count)
        let polyline3 = MKPolyline(coordinates: d2BLocation, count: d2BLocation.count)
        view.addOverlays([polyline1, polyline2, polyline3])
    }
    
    func makeUIView(context: Context) -> MKMapView{
         MKMapView(frame: .zero)
    }
}

class MapViewCoordinator: NSObject, MKMapViewDelegate {
        var mapViewController: PolylineMapView
        
        init(_ control: PolylineMapView) {
          self.mapViewController = control
        }
    
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

        if let multiPolyline = overlay as? MKMultiPolyline{
            let polylineRenderer = MKMultiPolylineRenderer(multiPolyline: multiPolyline)
            polylineRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.5)
            polylineRenderer.lineWidth = 5
        }
        return MKOverlayRenderer(overlay: overlay)
    }
}


//struct POIContentView: View {
//    var filterCategories = ["Restuarants And Parks", "Brewery"]
//    @State private var selectedLandmark = 0
//
//
//
//    var body: some View {
//
//
//        return VStack{
//            Picker(selection: $selectedLandmark, label: Text("")) {
//                ForEach(0..<filterCategories.count) { index in
//                    Text(self.filterCategories[index]).tag(index)
//                }
//            }.pickerStyle(SegmentedPickerStyle())
//        MapView(selectedLandmark: $selectedLandmark)
//        }
//    }



struct MapView: UIViewRepresentable {
    @Binding var selectedLandmark : Int
    
    func updateUIView(_ view: MKMapView, context: Context){

        let coordinate = CLLocationCoordinate2D(
                latitude: 12.9352, longitude: 77.6244)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: coordinate, span: span)
            view.setRegion(region, animated: true)
    
        switch selectedLandmark {
        case 0:
            view.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [.restaurant, .park]))
        case 1:
            view.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: [.brewery]))
        default:
                view.pointOfInterestFilter = .some(MKPointOfInterestFilter(including: []))
        }
    }
    func makeUIView(context: Context) -> MKMapView{
         MKMapView(frame: .zero)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
