//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by pan zhansheng on 16/8/4.
//  Copyright © 2016年 pan zhansheng. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var textFileUrl: UITextField!
    var textFile:String?
    @IBOutlet weak var audioFileUrl: UITextField!
    var audioFile:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        audioFileUrl.text = audioFile ?? ""
        textFileUrl.text = textFile ?? ""
    }

    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func storeTranscription (audioFileUrlString: String, textFileUrlString: String) {
        let context = getContext()
        
        //retrieve the entity that we just created
        let entity =  NSEntityDescription.entity(forEntityName: "Transcription", in: context)
        
        let transc = NSManagedObject(entity: entity!, insertInto: context)
        
        //set the entity values
        transc.setValue(audioFileUrlString, forKey: "audioFileUrlString")
        transc.setValue(textFileUrlString, forKey: "textFileUrlString")
        
        //save the object
        do {
            try context.save()
            print("saved!")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }
    func getTranscriptions () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Transcription> = Transcription.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for trans in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                print("\(trans.value(forKey: "audioFileUrlString"))")
            }
        } catch {
            print("Error with request: \(error)")
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

