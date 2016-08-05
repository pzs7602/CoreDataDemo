//
//  ItemListController.swift
//  CoreDataDemo
//
//  Created by pan zhansheng on 16/8/4.
//  Copyright © 2016年 pan zhansheng. All rights reserved.
//

import UIKit
import CoreData

class ItemListController: UITableViewController {

    var allItems = [NSManagedObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        // Use the edit button item provided by the table view controller.
        navigationItem.leftBarButtonItem = editButtonItem

        // 数据查询，nil 值为无条件查询
        // 给定audioFileUrlString 值的形式为 like[c] 查询字串，如 "*audio*"
        if let items = self.getTranscriptions(audioFileUrlString: nil){
            self.allItems = NSArray(array:items) as! [NSManagedObject]
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.allItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        // Configure the cell...
        let item = self.allItems[indexPath.row]
        cell.textLabel?.text = item.value(forKey: "audioFileUrlString") as? String
        cell.detailTextLabel?.text = item.value(forKey: "textFileUrlString") as? String
        return cell
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // 数据删除
        if editingStyle == .delete {
            let managedObj = self.allItems[indexPath.row]
            self.getContext().delete(managedObj)
            try! self.getContext().save()
            self.allItems.remove(at: indexPath.row)
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
        }
    }
    // 当在 ViewController 界面按 Done 按钮时，有可能是数据添加或更新，需要区别
    @IBAction func exitToItemList(_ segue: UIStoryboardSegue)
    {
        print("id=\(segue.identifier),selected index=\(self.tableView.indexPathForSelectedRow)")
        let vc = segue.source as! ViewController
        // 数据更新，之前是选某行进入的
        if let row = self.tableView.indexPathForSelectedRow?.row{
            let object = self.allItems[row]
            object.setValue(vc.audioFileUrl.text, forKey: "audioFileUrlString")
            object.setValue(vc.textFileUrl.text, forKey: "textFileUrlString")
            try! self.getContext().save()
            self.tableView.reloadRows(at: [self.tableView.indexPathForSelectedRow!], with: UITableViewRowAnimation.automatic)
        }
        // 数据添加，之前是按＋按钮进入的
        else {
            let object = self.storeTranscription(audioFileUrlString: vc.audioFileUrl.text!, textFileUrlString: vc.textFileUrl.text!)
            self.allItems.append(object!)
            self.tableView.reloadData()
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "add"{
//            let vc = (segue.destination as! UINavigationController).topViewController as! ViewController
        }
        else if segue.identifier == "show"{
            let cell = sender as! UITableViewCell
            let vc = segue.destination as! ViewController
            vc.audioFile = cell.textLabel!.text
            vc.textFile = cell.detailTextLabel!.text
        }
    }
    // CoreData
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    func storeTranscription (audioFileUrlString: String, textFileUrlString: String) -> NSManagedObject? {
        let context = getContext()
        
        //retrieve the entity that we just created
//        let entity =  NSEntityDescription.entity(forEntityName: "Transcription", in: context)
//        let transc = NSManagedObject(entity: entity!, insertInto: context)
        // in iOS 10 way
        let entity = Transcription.entity()
        let transc = Transcription(context: context)
        //set the entity values
        transc.setValue(audioFileUrlString, forKey: "audioFileUrlString")
        transc.setValue(textFileUrlString, forKey: "textFileUrlString")
        
        //save the object
        do {
            try context.save()
            print("saved!")
            return transc
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
        return nil
    }
    func getTranscriptions (audioFileUrlString:String?) -> [NSManagedObject]?{
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Transcription> = Transcription.fetchRequest()
        if audioFileUrlString != nil{
            let queryString = "audioFileUrlString like[c] '\(audioFileUrlString!)'"
            print("query=\(queryString)")
            fetchRequest.predicate = NSPredicate(format: queryString)
        }
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            return searchResults as [NSManagedObject]?
            //You need to convert to NSManagedObject to use 'for' loops
//            for trans in searchResults as [NSManagedObject] {
//                //get the Key Value pairs (although there may be a better way to do that...
//                print("\(trans.value(forKey: "audioFileUrlString"))")
//                self.allItems.append(trans)
//            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }
    // queryString sample: audioFileUrlString like[c] '*audio*'
    func getTranscriptions (queryString:String?) -> [NSManagedObject]?{
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<Transcription> = Transcription.fetchRequest()
        if queryString != nil{
            print("query=\(queryString)")
            fetchRequest.predicate = NSPredicate(format: queryString!)
        }
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            return searchResults as [NSManagedObject]?
            //You need to convert to NSManagedObject to use 'for' loops
//            for trans in searchResults as [NSManagedObject] {
//                //get the Key Value pairs (although there may be a better way to do that...
//                print("\(trans.value(forKey: "audioFileUrlString"))")
//                self.allItems.append(trans)
//            }
        } catch {
            print("Error with request: \(error)")
        }
        return nil
    }

}
