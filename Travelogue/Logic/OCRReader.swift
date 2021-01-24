//
//  AppTxtRecognizer.swift
//  Travelogue
//
//  Created by Sayantan Chakraborty on 23/12/20.
//

import Foundation
import Vision
import UIKit

class OCRReader {
    func performOCR(on image: UIImage?, recognitionLevel: VNRequestTextRecognitionLevel)  {
        guard let img = image else { return }
        let requestHandler =  VNImageRequestHandler(cgImage: img.cgImage!, options: [:])//VNImageRequestHandler(url: url, options: [:])

        let request = VNRecognizeTextRequest  { (request, error) in
            if let error = error {
                print(error)
                return
            }

            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }

            for currentObservation in observations {
                let topCandidate = currentObservation.topCandidates(1)
                if let recognizedText = topCandidate.first {
                    print(recognizedText.string)
                }
            }
        }
        request.recognitionLevel = recognitionLevel

        try? requestHandler.perform([request])
    }
}
