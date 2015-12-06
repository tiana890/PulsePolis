//
//  MapViewController.swift
//  PulsePolis
//
//  Created by IMAC  on 10.11.15.
//  Copyright © 2015 IMAC . All rights reserved.
//

import UIKit
import Mapbox
import CoreLocation

class MapViewController: UIViewController, MGLMapViewDelegate {
    
    @IBOutlet var mapView: MGLMapView!
    // initialize the map view
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        let locationCoordinate = CLLocationCoordinate2DMake(
            38.894368, -77.036487)
        
        mapView.setCenterCoordinate(locationCoordinate, zoomLevel: 15, animated: false)
        
        /*
        NSURL *styleURL = [NSURL URLWithString:@"asset://styles/dark-v8.json"];
        self.mapView = [[MGLMapView alloc] initWithFrame:self.view.bounds
        styleURL:styleURL];*/
        
        let styleURL = NSURL(string: "asset://styles/streets.json")
        //mapView.styleURL =
        mapView.styleURL = styleURL
        mapView.delegate = self
       
    }
    /*
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    // set the map's center coordinate
    [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake(38.894368, -77.036487)
    zoomLevel:15
    animated:NO];
    [self.view addSubview:self.mapView];*/
    
    func mapViewDidFinishRenderingFrame(mapView: MGLMapView, fullyRendered: Bool) {
        print(mapView.visibleCoordinateBounds)
    }
}
