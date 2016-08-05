//
//  Transcription+CoreDataProperties.swift
//  CoreDataDemo
//
//  Created by pan zhansheng on 16/8/4.
//  Copyright © 2016年 pan zhansheng. All rights reserved.
//

import Foundation
import CoreData

extension Transcription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Transcription> {
        return NSFetchRequest<Transcription>(entityName: "Transcription");
    }

    @NSManaged public var audioFileUrlString: String?
    @NSManaged public var textFileUrlString: String?

}
