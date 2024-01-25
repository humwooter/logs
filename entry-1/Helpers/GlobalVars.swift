//
//  GlobalVars.swift
//  entry-1
//
//  Created by Katyayani G. Raman on 10/24/23.
//

import Foundation
import SwiftUI
import CoreHaptics


let vibration_heavy = UIImpactFeedbackGenerator(style: .heavy)
let vibration_light = UIImpactFeedbackGenerator(style: .light)
let vibration_medium = UIImpactFeedbackGenerator(style: .medium)

enum SortOption {
    case timeAscending
    case timeDescending
    case image
    case wordCount
}

var defaultBackgroundColor = Color(UIColor.systemGroupedBackground)


let fontCategories: [String: [String]] = [
    "Traditional": ["Gill Sans", "Menlo Regular", "Didot", "Futura", "Georgia", "Arial Rounded MT Bold","Superclarendon Regular", "American Typewriter"],
    "Monospace": ["Courier New", "STIX Two Math"],
    "Handwriting": ["Bradley Hand", "Noteworthy Light", "SavoyeLetPlain", "Marker Felt Thin", "BarelyEnough-Regular", "MotleyForces-Regular", "ClickerScript-Regular", "Mueda-City", "SunnySpellsBasic-Regular", "Papyrus Condensed", "Nathan-CondensedRegular", "Lilly", "NjalBold", "Darlin\'Pop", "Chalkboard SE Regular", "Cute_Aurora_demo",],
    "Cursive" : ["Savoye LET", "Snell Roundhand", "SignPainter","DancingScript", "stainellascript", "Magiera-Script", "Barrbar"],
    "Decorative": ["Bodoni Ornaments",  "Auseklis", "AstroDotBasic", "MageScript", "HaraldRunic", "LuciusCipher"],
    "Unique": ["Spicy-Chips",  "SparkyStones-Regular", "TheNightOne", "Boekopi", "Emperialisme", "PixelDigivolve", "Academy Engraved LET Plain:1.0", "Copperplate Light"],
    "Bold": ["Impact"],
    "Antique": ["aAnggaranDasar", "IrishUncialfabeta-Bold", "QuaeriteRegnumDei"],
    "Calligraphy": []
]




let imageCategories: [String: [String]] = [
    "Shapes": ["circle.fill", "triangle.fill", "square.fill", "rhombus.fill", "diamond.fill", "pentagon.fill", "hexagon.fill", "octagon.fill", "seal.fill",  "staroflife.fill", "star.fill", "heart.fill", "bolt.heart.fill", "heart.slash.fill"],
    "Animals": ["bird.fill", "lizard.fill", "hare.fill", "tortoise.fill", "dog.fill", "cat.fill", "ladybug.fill", "fish.fill", "ant.fill", "teddybear.fill"],
    "Nature": ["leaf.fill", "moon.stars.fill", "sun.haze.circle.fill", "wind.snow", "sun.max.fill", "drop.fill",  "flame.fill", "tree.fill", "globe.asia.australia.fill", "camera.macro", "snowflake", "tornado", "cloud.rainbow.half", "mountain.2.fill"],
    "Symbols": ["folder.fill",  "key.fill", "exclamationmark", "checkmark","lightbulb.fill", "lightbulb", "gearshape", "bolt.fill", "bookmark.fill", "hourglass", "power", "atom",  "music.note", "globe.desk.fill", "envelope.fill", "house.fill", "pills.fill"],
    "Human": ["brain", "ear.fill", "mustache.fill", "hand.raised.fill", "brain.filled.head.profile", "shoe.fill", "lungs.fill"],
    "Gaming" : ["gamecontroller.fill", "playstation.logo", "xbox.logo"],
    "Food" : ["frying.pan.fill", "cup.and.saucer.fill", "wineglass.fill", "carrot", "fork.knife", "waterbottle.fill"],
    "Actions": ["figure.run", "figure.mind.and.body", "book.fill", "paintpalette.fill", "eye.fill", "list.clipboard" ,  "figure.yoga", "music.mic", "figure.strengthtraining.traditional", "paintbrush.fill", "pianokeys.inverse", "paintbrush.pointed.fill"],
    "Fitness": ["gym.bag.fill", "surfboard.fill", "snowboard.fill", "volleyball.fill", "tennis.racket", "basketball.fill", "baseball.fill", "soccerball", "football", "football.fill"],
    "Commerce": ["bag.fill", "cart.fill", "creditcard.fill", "giftcard.fill", "dollarsign", "basket.fill", "handbag.fill"],
    "Sleep": ["bed.double.fill"],
    "Emotions" : ["face.smiling.inverse", "hand.thumbsup.fill", "hands.thumbsdown.fill", "hands.and.sparkles.fill"],
    "Transportation": ["car.fill", "bus.fill", "tram.fill", "ferry.fill", "sailboat.fill", "bicycle", "scooter"],
    "Special" : ["graduationcap.fill", "backpack.fill", "sparkle.magnifyingglass", "theatermasks.fill", "camera.filters", "birthday.cake.fill", "trophy.fill", "timelapse", "puzzlepiece.fill" , "crown.fill", "infinity.circle.fill"],
    "Magic": ["suit.club.fill", "suit.spade.fill", "suit.diamond.fill", "hands.and.sparkles.fill", "wand.and.rays.inverse", "bubbles.and.sparkles.fill"],
    "Tools": ["wrench.adjustable.fill", "hammer.fill", "eyedropper.halffull", "screwdriver.fill", "wrench.and.screwdriver.fill", "stethoscope", "compass.drawing", "shield.fill"],
    "Celebratory" : ["balloon.fill", "fireworks"],
    "Other" : ["swirl.circle.righthalf.filled", "lightspectrum.horizontal", "camera.circle.fill",   "camera.aperture", "books.vertical.fill",  "poweroutlet.type.f", "doc.richtext.fill", "tropicalstorm.circle.fill"],
]
