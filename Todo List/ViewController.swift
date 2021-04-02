//
//  ViewController.swift
//  Todo List
//
//  Created by Royce Remulla on 1/3/21.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var chkImportant: NSButton!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var buttonDelete: NSButton!
    
    var toDoItems: [ToDoItem] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        getToDoItems()
    }

    func getToDoItems() {
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                toDoItems = try context.fetch(ToDoItem.fetchRequest())
                print("ToDo items count: \(toDoItems.count)")
            } catch {}
                
            tableView.reloadData()
        }
    }
     
    @IBAction func addClick(_ sender: Any) {
        if textField.stringValue != "" {
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                let context = appDelegate.persistentContainer.viewContext
                let toDoItem = ToDoItem(context: context)
                toDoItem.name = textField.stringValue
                let isImportant = chkImportant.state.rawValue == 1
                toDoItem.important = isImportant
                
                appDelegate.saveAction(nil)
                resetFormFields()
                
                getToDoItems()
            }
        }
    }
    
    private func resetFormFields() {
        textField.stringValue = ""
        chkImportant.stringValue = "0"
    }
    
    @IBAction func deleteClicked(_ sender: Any) {
        let toDoItem = toDoItems[tableView.selectedRow]
        
        if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
            let context = appDelegate.persistentContainer.viewContext

            context.delete(toDoItem)
            appDelegate.saveAction(nil)
            
            getToDoItems()
            buttonDelete.isHidden = true
        }
    }
    
    
    // MARK: Table View functions
    func tableViewSelectionDidChange(_ notification: Notification) {
        buttonDelete.isHidden = false
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return toDoItems.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let toDoItem = toDoItems[row]
        var cellText = ""
        
        switch tableColumn?.identifier.rawValue {
        case "Important":
            cellText = toDoItem.important ? "❗️": ""
        case "Description":
            cellText = toDoItem.name!
        default:
            cellText = ""
        }
        
        if let column = tableColumn {
            let cellIdentifier = "cell\(column.identifier.rawValue)"
            if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(cellIdentifier) , owner: self) as? NSTableCellView {
                cell.textField?.stringValue = cellText
                return cell
            }
        }
        
        return nil
    }
}

