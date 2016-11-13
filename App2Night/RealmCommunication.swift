//
//  RealmCommunication.swift
//  App2Night
//
//  Created by Robin Niebergall on 09.11.16.
//  Copyright © 2016 DHBW. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

class RealmCommunication {
	
	// parse json type safe into realm
	static func parseParties(json: JSON) {
		let realm = try! Realm()
		
		printRealmUrl()
		
		// for each (index, object) in json
		for (_, object) in json {
			let hostId = object["Host"]["HostId"].stringValue
			let existingHost = doesHostExist(id: hostId)
			
			// does the host already exist; add new host or update existing host
			switch existingHost {
			case true:
				// create objects
				let party = Party()
				let location = Location()
				let host = realm.object(ofType: Host.self, forPrimaryKey: hostId)!
				
				// add object references
				party.location = location
				party.host = host
				
				// set party attributes
				party.id = object["PartyId"].stringValue
				party.name = object["PartyName"].stringValue
				party.price = object["Price"].intValue
				party.date = formatDate(string: (object["PartyDate"].stringValue))
				party.musicGenre = object["MusicGenre"].intValue
				party.type = object["PartyType"].intValue
				party.text = object["Description"].stringValue
				
				// set location attributes
				party.location?.countryName = object["Location"]["CountryName"].stringValue
				party.location?.cityName = object["Location"]["CityName"].stringValue
				party.location?.streetName = object["Location"]["StreetName"].stringValue
				party.location?.houseNumber = object["Location"]["HouseNumber"].stringValue
				party.location?.houseNumberAdditional = object["Location"]["HouseNumberAdditional"].stringValue
				party.location?.zipcode = object["Location"]["Zipcode"].stringValue
				party.location?.latitude = object["Location"]["Latitude"].doubleValue
				party.location?.longitude = object["Location"]["Longitude"].doubleValue
				
				try! realm.write {
					realm.add(party)
					host.parties.append(party)
				}
				
			case false:
				// create objects
				let party = Party()
				let location = Location()
				let host = Host()
				
				// add object references
				party.location = location
				party.host = host
				host.parties.append(party)
				
				// set party attributes
				party.id = object["PartyId"].stringValue
				party.name = object["PartyName"].stringValue
				party.price = object["Price"].intValue
				party.date = formatDate(string: (object["PartyDate"].stringValue))
				party.musicGenre = object["MusicGenre"].intValue
				party.type = object["PartyType"].intValue
				party.text = object["Description"].stringValue
				
				// set location attributes
				party.location?.countryName = object["Location"]["CountryName"].stringValue
				party.location?.cityName = object["Location"]["CityName"].stringValue
				party.location?.streetName = object["Location"]["StreetName"].stringValue
				party.location?.houseNumber = object["Location"]["HouseNumber"].stringValue
				party.location?.houseNumberAdditional = object["Location"]["HouseNumberAdditional"].stringValue
				party.location?.zipcode = object["Location"]["Zipcode"].stringValue
				party.location?.latitude = object["Location"]["Latitude"].doubleValue
				party.location?.longitude = object["Location"]["Longitude"].doubleValue
				
				// set host attributes
				party.host?.id = object["Host"]["HostId"].stringValue
				party.host?.userName = object["Host"]["UserName"].stringValue
				
				try! realm.write {
					realm.add(party)
				}
			}
		}
	}
	
	
	// check if host exists
	private static func doesHostExist(id: String) -> Bool {
		let realm = try! Realm()
		
		let existingHost = realm.object(ofType: Host.self, forPrimaryKey: id)
		
		if (existingHost != nil) {
			return true
		}
		
		return false
	}
	
	// format date string
	private static func formatDate(string: String) -> Date {
		let formatter: DateFormatter = {
			let formatter = DateFormatter()
			formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
			return formatter
		}()
		
		return formatter.date(from: string)!
	}
	
	// force delete all realm storage files
	static func reset() {
		let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
		let realmURLs = [
			realmURL,
			realmURL.appendingPathExtension("lock"),
			realmURL.appendingPathExtension("log_a"),
			realmURL.appendingPathExtension("log_b"),
			realmURL.appendingPathExtension("note")
		]
		
		for URL in realmURLs {
			do {
				try FileManager.default.removeItem(at: URL)
			} catch let e {
				print(e)
			}
		}
	}
	
	// clear all objects in realm
	static func clear() {
		let realm = try! Realm()
		
		try! realm.write {
			realm.deleteAll()
		}
	}
	
	// get realm url
	static func printRealmUrl() {
		print("REALM URL: \(Realm.Configuration.defaultConfiguration.fileURL!)")
	}
	
	
}

