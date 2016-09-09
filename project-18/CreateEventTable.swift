//
//  CreateEventTable.swift
//  project-18
//
//  Created by Eric Zhang on 8/8/16.
//  Copyright © 2016 stazo. All rights reserved.
//

import UIKit

protocol CreateEventTableProtocol {
    func openStartDatePicker();
    func openEndDatePicker();
}

class CreateEventTable: UITableViewController, UITextFieldDelegate {

    @IBOutlet var eventName: UITextField!
    @IBOutlet var eventDescription: UITextField!
    
    var delegate: CreateEventTableProtocol?; //to register date picker clicks to parent vc
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.eventName.delegate = self;
        self.eventDescription.delegate = self;

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //selected event name cell
        if (indexPath.row == 0) {
            self.eventName.becomeFirstResponder();
        }
        //selected event description cell
        if (indexPath.row == 1) {
            self.eventDescription.becomeFirstResponder();
        }
        //selected start date picker
        if (indexPath.row == 2) {
            self.delegate?.openStartDatePicker();
        }
        //selected end date picker
        if (indexPath.row == 3) {
            self.delegate?.openEndDatePicker();
        }
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder();
        return true;
    }
    
    func updateStartDate(dateText: String?) {
        self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0))!.detailTextLabel!.text = dateText;
    }
    
    func updateEndDate(dateText: String?) {
        self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))!.detailTextLabel!.text = dateText;
    }

    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 5;
        }
        return tableView.sectionHeaderHeight
    }

}
