//
//  SwiftNoteCollectionViewController.swift
//  Swfitnotes
//
//  Created by John Lago on 1/18/17.
//  Copyright © 2017 John Lago. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "NoteCell"

class SwiftNoteCollectionViewController: UICollectionViewController {

    typealias CollectionViewItemChange = [ NSFetchedResultsChangeType: [IndexPath?]]
    
    //MARK: - Vars and Properties
    fileprivate var isPaused: Bool = false
    fileprivate var newNoteCreatedByUser: Bool = false
    var collectionViewItemChanges = [CollectionViewItemChange]()
    weak var delegate: NoteSelectionDelegate?
    var collapseViewController = true
    var markedForDeletion = [IndexPath]()
    var detailViewController: DetailViewController?
    let context = DataController.sharedInstance.managedObjectContext
    
    //MARK: - UICollectionViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try? frc.performFetch()
        
        if let layout = collectionView?.collectionViewLayout as? SwiftNoteCollectionViewLayout {
            layout.delegate = self
        }
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem
    
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
        self.navigationItem.rightBarButtonItems = [addButton]
        
        splitViewController?.delegate = self

        // Register cell classes
        self.collectionView!.register(UINib(nibName: "NoteCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView?.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.rightBarButtonItems?[0].isEnabled = true
        self.setPaused(paused: false)
        self.collectionViewLayout.invalidateLayout()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.setPaused(paused: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if editing {
            let deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteNotes(_:)))
            self.navigationItem.setRightBarButtonItems([deleteButton], animated: true)
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.collectionView?.reloadData()
        } else {
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
//            let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: nil)
            self.navigationItem.setRightBarButtonItems([addButton], animated: true)
            self.collectionView?.reloadData()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if self.isEditing {
            if let cell = collectionView.cellForItem(at: indexPath) as? NoteCollectionViewCell{
                if cell.isMarkedForDeletion {
                    cell.isMarkedForDeletion = false
                    if let item = markedForDeletion.index(of: indexPath) {
                        markedForDeletion.remove(at: item)
                    }
                } else {
                    cell.isMarkedForDeletion = true
                    markedForDeletion.append(indexPath)
                    
                }
            }
            navigationItem.rightBarButtonItem?.isEnabled = !markedForDeletion.isEmpty
        } else {
            let selectedNote = frc.object(at: indexPath)
            openDetailViewForNote(selectedNote: selectedNote)
        }
    }
    
    // MARK: - UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frc.sections?[section].numberOfObjects ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NoteCollectionViewCell
        
        let note = frc.object(at: indexPath)
        
        let returnCell = configureCell(cell: cell, note: note, indexPath: indexPath)
        return returnCell
    }
    
    func configureCell(cell: NoteCollectionViewCell, note: Note, indexPath: IndexPath) -> NoteCollectionViewCell{
        cell.lblNoteTitle.text = note.title
        
        if note.body.isEmpty {
            cell.lblNoteBody.frame.size = CGSize(width: cell.lblNoteBody.frame.width, height: 0.0)
            cell.lblNoteBody.text = nil
        }else {
            cell.lblNoteBody.text = note.body
            cell.lblNoteBody.sizeToFit()
        }
        cell.isStarred = note.starred
        cell.btnNoteStar.isEnabled = !isEditing
        cell.btnNoteStar.addTarget(self, action: #selector(self.didTapStarButton(_:)), for: .touchUpInside)
        cell.isMarkedForDeletion = false
        cell.backgroundColor = note.color
        
        return cell
    }
    
    var frc: NSFetchedResultsController<Note> {
        
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let request: NSFetchRequest<Note> = Note.fetchRequest()
        let starSort = NSSortDescriptor(key: "starred", ascending: false)
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [starSort, dateSort]
        
        let aFrc = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        aFrc.delegate = self
        _fetchedResultsController = aFrc
        
        do {
            try _fetchedResultsController?.performFetch()
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
        return _fetchedResultsController!
    }
    
    var _fetchedResultsController: NSFetchedResultsController<Note>?
    
    
    //MARK: - Private Functions
    
    
    internal func  deleteNotes(_ sender: UIBarButtonItem){
        for item in markedForDeletion{
            let object = frc.object(at: item)
            context.delete(object)
        }
        do{
            try context.save()
            markedForDeletion.removeAll()
            navigationItem.rightBarButtonItem?.isEnabled = false
            collectionView?.reloadData()
        } catch {
            print("Failed to delete Items \(error)")
            
        }
    }
    
    internal func didTapStarButton(_ sender: UIButton){
        let view = sender.superview?.superview as! NoteCollectionViewCell
        let path = collectionView?.indexPath(for: view)
//        let indexPath = IndexPath(row: sender.tag, section: 0)
        let note = frc.object(at: path!)
        note.starred = !note.starred
        do {
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Failed to save w/ star: \(nsError)")
        }
    }
    
    fileprivate func openDetailViewForNote(selectedNote: Note){
        self.delegate?.didSelectNote(newNote: selectedNote)
        collapseViewController = false
        
        if let detailViewController = self.delegate as? DetailViewController {
            splitViewController?.showDetailViewController(detailViewController, sender: nil)
        }
    }
    
    internal func insertNewObject(_ sender: UIBarButtonItem) {
        let newNote = Note(context: context)
        
        // If appropriate, configure the new managed object.
        
        newNote.date = Date()
        newNote.title = "New Note"
        newNote.body = ""
        newNote.starred = false
        newNote.id = NSUUID().uuidString
        
        let randomIndex: Int = Int(arc4random_uniform(5))
        let randomColor: UIColor = UIColor.colorNoteOptions[randomIndex]
        newNote.color = randomColor
        
        // Save the context.
        do {
            try context.save()
            sender.isEnabled = false
            newNoteCreatedByUser = true
        } catch {
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    fileprivate func setPaused(paused: Bool){
        self.isPaused = paused
        if isPaused {
            self.frc.delegate = nil
        } else {
            self.frc.delegate = self
            try? frc.performFetch()
            collectionView?.reloadData()
        }
    }
}

//MARK: - NSFetchedResultsControllerDelegate
extension SwiftNoteCollectionViewController: NSFetchedResultsControllerDelegate{
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionViewItemChanges.removeAll()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        collectionViewItemChanges.append([type: [indexPath, newIndexPath]])
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView?.performBatchUpdates({
            self.collectionViewItemChanges.map{
                self.performCollectionViewItemChange(change: $0)}
        }, completion: {(completed: Bool) in
            if completed {
                if self.newNoteCreatedByUser{
                    self.newNoteCreatedByUser = false
                    let selectedNote = self.frc.object(at: IndexPath(row: 0, section: 0))
                    self.openDetailViewForNote(selectedNote: selectedNote)
                }
                 self.collectionViewLayout.invalidateLayout()
            }
        })
    }
    
    func performCollectionViewItemChange(change: CollectionViewItemChange){
        let changeType = change.keys.first!
        let indexPaths: [IndexPath] = change[changeType]!.flatMap{$0}
        
        switch change.keys.first! {
        case .insert:
            collectionView?.insertItems(at: [indexPaths[0]])
        case .update:
            collectionView?.reloadItems(at: [indexPaths[0]])
        case .move:
            if indexPaths[0]==indexPaths[1]{
                collectionView?.reloadItems(at: [indexPaths[0]])
            }else {
                collectionView?.deleteItems(at: [indexPaths[0]])
                collectionView?.insertItems(at: [indexPaths[1]])
            }
        case .delete:
            collectionView?.deleteItems(at: [indexPaths[0]])
        }
    }

}

//MARK: - UISplitViewControllerDelegate

extension SwiftNoteCollectionViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return collapseViewController
    }
}

//MARK: - SwiftNoteCollectionViewLayoutDelegate

extension SwiftNoteCollectionViewController: SwiftNoteCollectionViewLayoutDelegate {
    func collectionView(collectionView: UICollectionView, heightForBodyAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        
        let calcView = UITextView(frame: CGRect(x: 0.0, y: 0.0, width: withWidth, height: 0.0))
        let note = frc.object(at: indexPath)
        if note.body.isEmpty {
            return 0
        }else {
            calcView.text = note.body
            calcView.font = UIFont.systemFont(ofSize: 17, weight: UIFontWeightRegular)
            calcView.textContainer.lineBreakMode = .byWordWrapping
            calcView.sizeToFit()
            return calcView.frame.height
        }
    }
    
    func collectionView(collectionView: UICollectionView, heightForTitleAtIndexPath indexPath: IndexPath, withWidth: CGFloat) -> CGFloat {
        return 34
    }
}

protocol NoteSelectionDelegate: class {
    func didSelectNote(newNote: Note)
}

