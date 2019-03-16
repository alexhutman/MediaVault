//: Playground - noun: a place where people can play

import UIKit

let currentDateTime = Date()
let formatter = DateFormatter()
formatter.timeStyle = .medium
formatter.dateStyle = .medium

print(formatter.string(from: currentDateTime))
