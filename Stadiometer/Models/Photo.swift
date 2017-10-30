//
//  Photo.swift
//  Stadiometer
//
//  Created by Tatsuya Tobioka on 2017/09/24.
//  Copyright © 2017 tnantoka. All rights reserved.
//

import UIKit

class Photo {
    static var docDirectory: URL? {
        return try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: false
        )
    }
    static var photosDirectory: URL? {
        guard let docDirectory = docDirectory else { return nil }
        let photosDirectory = docDirectory.appendingPathComponent("photos")
        if !FileManager.default.fileExists(atPath: photosDirectory.path) {
            try? FileManager.default.createDirectory(at: photosDirectory, withIntermediateDirectories: false, attributes: nil)
        }
        return photosDirectory
    }
    static var formatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy_MM_dd_HH_mm_ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }

    static func filename(distance: Float) -> String {
        let date = Date()
        let dateString = formatter.string(from: date)
        let distanceString = String(distance).replacingOccurrences(of: ".", with: "_")
        return "\(dateString)-\(distanceString).png"
    }

    static func date(filename: String) -> Date {
        let dateString = filename.components(separatedBy: "-")[0]
        guard let date = formatter.date(from: dateString) else { return Date() }
        return date
    }

    static func save(image: UIImage, distance: Float) {
        guard let data = UIImagePNGRepresentation(image) else { return }
        let filename = self.filename(distance: distance)
        if let url = photosDirectory?.appendingPathComponent(filename) {
            try? data.write(to: url)
        }
    }

    static func round(distance: Float) -> String {
        return String(Darwin.round(distance * 10000.0) / 100.0)
    }

    static func centimeter(distance: String) -> String {
        return "\(distance) cm"
    }

    static func all() -> [Photo] {
        guard let photosDirectory = photosDirectory else { return [] }
        let contents = (try? FileManager.default.contentsOfDirectory(
            at: photosDirectory,
            includingPropertiesForKeys: nil,
            options: []
        )) ?? []
        return contents.map { Photo(path: $0.path) }
    }

    let path: String

    lazy var image: UIImage? = {
        UIImage(contentsOfFile: self.path)
    }()

    var dateString: String {
        guard let filename = path.components(separatedBy: "/").last else { return "" }
        let date = Photo.date(filename: filename)
        let locale = Locale.current

        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yyyyMMMd", options: 0, locale: locale)

        return formatter.string(from: date)
    }

    var distanceString: String {
        guard let filename = path.components(separatedBy: "/").last else { return "" }
        let distanceString = filename.components(separatedBy: "-")[1]
            .replacingOccurrences(of: "_", with: ".")
            .replacingOccurrences(of: ".png", with: "")
        guard let distance = Float(distanceString) else { return "" }
        return Photo.round(distance: distance)
    }

    init(path: String) {
        self.path = path
    }

    func delete() {
        try? FileManager.default.removeItem(atPath: path)
    }
}
