//
//  PartyEditFormViewController.swift
//  App2Night
//
//  Created by Robin Niebergall on 12.12.16.
//  Copyright © 2016 DHBW. All rights reserved.
//

import UIKit
import Eureka
import RealmSwift

// this is just a straight copy of PartyCreateFormViewController with replaced post functions.. could be solved by just inheriting the other controller..
// last minute implementation

class PartyEditFormViewController: FormViewController {
	
	var party: Party?
	var delegate: PartyDetailTableViewController?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup navigation bar
		navigationItem.title = "Party editieren"
		navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(post))
		
		form = Section("Party Details")
			<<< TextRow() { row in
				row.title = "Name"
				row.value = party?.name
				row.placeholder = "max. 32 Zeichen"
				row.add(rule: RuleRequired())
				row.add(rule: RuleMaxLength(maxLength: 32))
				row.validationOptions = .validatesOnChange
				row.tag = "name"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< TextRow() { row in
				row.title = "Beschreibung"
				row.value = party?.text
				row.placeholder = "max. 256 Zeichen"
				row.add(rule: RuleRequired())
				row.add(rule: RuleMaxLength(maxLength: 256))
				row.validationOptions = .validatesOnChange
				row.tag = "text"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< IntRow() { row in
				row.title = "Preis (€)"
				row.value = party?.price
				row.placeholder = "z.B. 5"
				row.add(rule: RuleRequired())
				row.tag = "price"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< DateTimeRow() { row in
				row.title = "Datum"
				row.value = party?.date
				row.dateFormatter?.dateFormat = "dd.MM.yyyy', 'HH:mm"
				row.minimumDate = Date()
				row.tag = "date"
			}
			<<< ActionSheetRow<String>() { row in
				row.title = "Typ"
				row.selectorTitle = "Typ der Party auswählen"
				row.options = [PartyType.Venue.rawValue, PartyType.Disco.rawValue, PartyType.Remote.rawValue]
				row.value = PartyType.from(hashValue: (party?.type)!).rawValue
				row.tag = "type"
			}
			<<< ActionSheetRow<String>() { row in
				row.title = "Musikrichtung"
				row.selectorTitle = "Musikrichtung auswählen"
				row.options = [MusicGenre.Mixed.rawValue, MusicGenre.Rock.rawValue, MusicGenre.Pop.rawValue, MusicGenre.HipHop.rawValue, MusicGenre.Rap.rawValue, MusicGenre.Electro.rawValue]
				row.value = MusicGenre.from(hashValue: (party?.musicGenre)!).rawValue
				row.tag = "musicGenre"
			}
			+++ Section("Standort Details")
			<<< TextRow() { row in
				row.title = "Land"
				row.value = party?.countryName
				row.placeholder = "z.B. Deutschland"
				row.add(rule: RuleRequired())
				row.validationOptions = .validatesOnChange
				row.tag = "countryName"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< TextRow() { row in
				row.title = "Stadt"
				row.value = party?.cityName
				row.placeholder = "z.B. Horb am Neckar"
				row.add(rule: RuleRequired())
				row.validationOptions = .validatesOnChange
				row.tag = "cityName"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< TextRow() { row in
				row.title = "Straßenname"
				row.value = party?.streetName
				row.placeholder = "z.B. Florianstraße"
				row.add(rule: RuleRequired())
				row.validationOptions = .validatesOnChange
				row.tag = "streetName"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< ZipCodeRow() { row in
				row.title = "Hausnummer"
				row.value = party?.houseNumber
				row.placeholder = "z.B. 15"
				row.add(rule: RuleRequired())
				row.validationOptions = .validatesOnChange
				row.tag = "houseNumber"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
			}
			<<< ZipCodeRow() { row in
				row.title = "Postleitzahl"
				row.value = party?.zipcode
				row.placeholder = "z.B. 72160"
				row.add(rule: RuleRequired())
				row.validationOptions = .validatesOnChange
				row.tag = "zipcode"
				}
				.cellUpdate { cell, row in
					if !row.isValid {
						cell.titleLabel?.textColor = .red
					}
		}
	}
	
	// post party
	func post() {
		let errors = form.validate()
		tableView?.reloadData()
		
		if (errors.isEmpty) {
			// SwiftSpinner.show("Party wird gepostet...")
			let assembledParty = assembleParty()
			
			// overly nested check if token is old -> check if location is valid -> post party
			SwiftSpinner.show("Dein Token wird geprüft...")
			SwaggerCommunication.shared.revokeToken { (success) in
				if success {
					SwiftSpinner.show("Der Standort wird gegoogelt...")
					SwaggerCommunication.shared.validateLocation(with: assembledParty.toLocationRawData()) { success in
						if success {
							SwiftSpinner.show("Deine Party wird editiert...")
							SwaggerCommunication.shared.putParty(with: assembledParty.toPartyRawData(), for: (self.party?.id)!) { success in
								if success {
									print("POST OK.")
									
									// stop the spinner
									SwiftSpinner.hide()
									
									// update realm with this party.. copy pasta deluxe
									let values = self.form.values()
									
									try! RealmManager.currentRealm.write {
										let editedParty = try! Realm().object(ofType: Party.self, forPrimaryKey: (self.party?.id)!)!
										editedParty.name = values["name"] as! String
										editedParty.date = (values["date"] as! Date).floorSeconds()
										editedParty.musicGenre = (MusicGenre(rawValue: values["musicGenre"] as! String)?.hashValue)!
										editedParty.countryName = values["countryName"] as! String
										editedParty.cityName = values["cityName"] as! String
										editedParty.streetName = values["streetName"] as! String
										editedParty.houseNumber = values["houseNumber"] as! String
										editedParty.zipcode = values["zipcode"] as! String
										editedParty.type = (PartyType(rawValue: values["type"] as! String)?.hashValue)!
										editedParty.text = values["text"] as! String
										editedParty.price = values["price"] as! Int
										RealmManager.currentRealm.add(editedParty, update: true)
									}
									
									// update previous view
									self.delegate?.reloadTable()
									
								} else {
									print("POST FAILED.")
									
									// stop the spinner
									SwiftSpinner.hide()
									
									self.displayAlert(title: "Party wurde nicht editiert!", message: "Irgendetwas ist schiefgelaufen.", buttonTitle: "Okay")
								}
							}
						} else {
							SwiftSpinner.hide()
							self.displayAlert(title: "Standort wurde nicht gefunden!", message: "Bitte gib einen gültigen Standort ein.", buttonTitle: "Okay")
						}
					}
					
				}
				else {
					SwiftSpinner.hide()
					self.displayAlert(title: "Token konnte nicht widerrufen werden!", message: "Oops.", buttonTitle: "Okay")
				}
			}
		}
		else {
			SwiftSpinner.hide()
			self.displayAlert(title: "Alle Felder müssen korrekt ausgefüllt werden!", message: "Überprüfe bitte deine Eingaben.", buttonTitle: "Okay")
		}
		
	}
	
	func assembleParty() -> Party {
		let party = Party()
		let values = form.values()
		
		party.name = values["name"] as! String
		party.date = (values["date"] as! Date).floorSeconds()
		party.musicGenre = (MusicGenre(rawValue: values["musicGenre"] as! String)?.hashValue)!
		party.countryName = values["countryName"] as! String
		party.cityName = values["cityName"] as! String
		party.streetName = values["streetName"] as! String
		party.houseNumber = values["houseNumber"] as! String
		party.zipcode = values["zipcode"] as! String
		party.type = (PartyType(rawValue: values["type"] as! String)?.hashValue)!
		party.text = values["text"] as! String
		party.price = values["price"] as! Int
		
		return party
	}
	
	// alert controllers
	func displayAlert(title: String, message: String, buttonTitle: String) {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let defaultAction = UIAlertAction(title: buttonTitle, style: .default, handler: nil)
		alert.addAction(defaultAction)
		self.present(alert, animated: true, completion: nil)
	}
	
}