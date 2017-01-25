//
//  DetailViewController.swift
//  Swfitnotes
//
//  Created by John Lago on 1/18/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var txtBody: UITextView!
    @IBOutlet weak var txtTitle: UITextField!
    fileprivate var isDirty: Bool = false

    var detailItem: Note? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }
    
    func configureView() {
        // Update the user interface for the detail item.
        if let detail = self.detailItem {
            if let body = self.txtBody {
                body.text = detail.body
                body.delegate = self
            }
            if let title = self.txtTitle{
                title.text = detail.title
                title.delegate = self
            }
            self.view.backgroundColor = detailItem?.color
        }
    }
    
    func noteDidChange(){
        print ("Value Changed")
        detailItem?.body = txtBody.text!
        detailItem?.title = txtTitle.text!
        detailItem?.date = Date()
        do {
            try DataController.sharedInstance.managedObjectContext.save()
        } catch {
            fatalError("Something went wrong trying to save the context \(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        txtTitle.endEditing(true)
        txtBody.endEditing(true)
        if isDirty {noteDidChange()}
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DetailViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        self.txtBody.becomeFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        if textField.text != detailItem?.title{
            isDirty = true
        }
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        isDirty = true
    }

}

extension DetailViewController: NoteSelectionDelegate{
    func didSelectNote(newNote: Note) {
        self.detailItem = newNote
    }
}

