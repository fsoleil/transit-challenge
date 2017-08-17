//
//  MapViewController.swift
//  Transit
//
//  Created by Florian Soleil on 2017-08-16.
//  Copyright © 2017 Florian Soleil. All rights reserved.
//

import UIKit
import MapKit
import PromiseKit

class MapViewController: UIViewController,MKMapViewDelegate {
    
    @IBOutlet weak var map : MKMapView!

    var mapViewModel : MapViewModel! {
        
        didSet {
            mapViewModel.getAnnotations{ annotations in
                for annotation in annotations{
                    self.map.addAnnotation(annotation)
                }
            }
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if !(annotation is FeedAnnotation) {
            return nil
        }
        
        let customAnnotation = annotation as! FeedAnnotation
        let annotationIdentifier = "FeedAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier)
        
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: customAnnotation, reuseIdentifier: annotationIdentifier)
            annotationView!.canShowCallout = true
        }
        else {
            annotationView!.annotation = customAnnotation
        }

        let pinColor = UIColor(hex: customAnnotation.pinColor)
        annotationView!.image = UIImage(named: "pin")?.image(withColor:pinColor)
        annotationView?.canShowCallout = true
    
        return annotationView
    }
    
}

