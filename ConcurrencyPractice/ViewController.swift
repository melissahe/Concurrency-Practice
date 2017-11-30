//
//  ViewController.swift
//  ConcurrencyPractice
//
//  Created by C4Q on 11/30/17.
//  Copyright © 2017 Melissa He @ C4Q. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var spaceImageView: UIImageView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.isHidden = true
    }

    @IBAction func buttonPressed(_ sender: Any) {
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        loadData()
    }
    
    func loadData() {
        let dateInfoStr = self.datePicker.date.description
        let formattedInfo = dateInfoStr.components(separatedBy: " ")[0]
        let urlStr = "https://apod.nasa.gov/apod/image/1711/OrionDust_Battistella_1824.jpg"
        guard let url = URL(string: urlStr) else {
            return
        }
        
        //using a URL, so this will be computationally expensive
            //if its on the main thread, it will take a LONG time and the phone will "freeze" until it's done
        DispatchQueue.global(qos: .userInitiated).async {
            guard let rawImageData = try? Data(contentsOf: url) else {
                return
            }
            //this is a change to the UI, so this must happen on the main thread, which is reserved for UI changes and the only thread you can change UI elements in
            //this is how we get back to the main thread
            DispatchQueue.main.async {
                //it's okay for this queue to be "inside" the global queue, since it is not a nesting of queue
                //this main queue doesn't know its function is inside a global queue functon
                guard let onlineImage = UIImage(data: rawImageData) else {
                    return
                }
                self.spaceImageView.image = onlineImage
                print("just set image") //if this was a sync block, it would wait for this function to finish before going to the line below this function
                    //since this is an async block, it will return immediately (but not complete until later) and go to the line below this function before the function completes
                self.activityIndicatorView.hidesWhenStopped = true
                self.activityIndicatorView.stopAnimating()
            }
            //so the rest of the global queue continues to execute, the main queue will complete in its own time, usually slower (and thus after) the global queue
            print("just dispatched to main queue") //because this line is the global queue.async
                //if it was global queue.sync - the program would wait until this function would complete before running lines after this function
        }
        print("just dispatched to global queue") //because this line is in the main queue.sync
    }
}

