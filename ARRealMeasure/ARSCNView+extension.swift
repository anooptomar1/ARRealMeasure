//
//  ARSCNView+extension.swift
//  ARRealMeasure
//
//  Created by iMeraj-MacbookPro on 14/11/2017.
//  Copyright © 2017 Meraj. All rights reserved.
//

import SceneKit
import ARKit

extension ARSCNView {
    func realWorldVector(screeenPosition: CGPoint) -> SCNVector3? {
        let results = self.hitTest(screeenPosition, types: [.featurePoint])
        guard let result = results.first else { return nil }
        return SCNVector3.positionFromTransform(result.worldTransform)
    }
}
