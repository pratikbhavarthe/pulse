//
//  EmojiData.swift
//  Pulse
//
//  Emoji and symbol search data
//

import Combine
import Foundation

public class PinnedEmojiManager: ObservableObject {
    public static let shared = PinnedEmojiManager()

    @Published public var pinnedEmojiIds: Set<String> = []

    private let key = "pulse_pinned_emojis"

    private init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            pinnedEmojiIds = Set(saved)
        }
    }

    public func isPinned(_ emoji: Emoji) -> Bool {
        pinnedEmojiIds.contains(emoji.stableId)
    }

    public func togglePin(_ emoji: Emoji) {
        objectWillChange.send()
        if pinnedEmojiIds.contains(emoji.stableId) {
            pinnedEmojiIds.remove(emoji.stableId)
        } else {
            pinnedEmojiIds.insert(emoji.stableId)
        }
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(pinnedEmojiIds), forKey: key)
    }
}

public struct Emoji: Identifiable {
    public let id = UUID()
    public let symbol: String
    public let name: String
    public let keywords: [String]
    public let category: EmojiCategory

    public var stableId: String {
        "emoji_\(symbol)"
    }
}

public enum EmojiCategory: String, CaseIterable {
    case frequentlyUsed = "Frequently Used"
    case smileysAndPeople = "Smileys & People"
    case animalsAndNature = "Animals & Nature"
    case foodAndDrink = "Food & Drink"
    case activity = "Activity"
    case travelAndPlaces = "Travel & Places"
    case objects = "Objects"
    case symbols = "Symbols"
    case flags = "Flags"
}

public class EmojiData {
    public static let shared = EmojiData()

    private(set) var allEmojis: [Emoji] = []

    private init() {
        loadEmojis()
    }

    private func loadEmojis() {
        // Smileys & People
        let smileys: [Emoji] = [
            Emoji(
                symbol: "😀", name: "Grinning Face", keywords: ["smile", "happy", "joy"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😃", name: "Grinning Face with Big Eyes",
                keywords: ["smile", "happy", "joy"], category: .smileysAndPeople),
            Emoji(
                symbol: "😄", name: "Grinning Face with Smiling Eyes",
                keywords: ["smile", "happy", "joy"], category: .smileysAndPeople),
            Emoji(
                symbol: "😁", name: "Beaming Face with Smiling Eyes",
                keywords: ["smile", "happy", "grin"], category: .smileysAndPeople),
            Emoji(
                symbol: "😆", name: "Grinning Squinting Face",
                keywords: ["laugh", "happy", "smile"], category: .smileysAndPeople),
            Emoji(
                symbol: "😅", name: "Grinning Face with Sweat",
                keywords: ["smile", "sweat", "relief"], category: .smileysAndPeople),
            Emoji(
                symbol: "🤣", name: "Rolling on the Floor Laughing",
                keywords: ["laugh", "lol", "rofl"], category: .smileysAndPeople),
            Emoji(
                symbol: "😂", name: "Face with Tears of Joy", keywords: ["laugh", "cry", "lol"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙂", name: "Slightly Smiling Face", keywords: ["smile", "happy"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙃", name: "Upside-Down Face", keywords: ["silly", "sarcasm"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😉", name: "Winking Face", keywords: ["wink", "flirt"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😊", name: "Smiling Face with Smiling Eyes",
                keywords: ["smile", "happy", "blush"], category: .smileysAndPeople),
            Emoji(
                symbol: "😇", name: "Smiling Face with Halo", keywords: ["angel", "innocent"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥰", name: "Smiling Face with Hearts",
                keywords: ["love", "hearts", "adore"], category: .smileysAndPeople),
            Emoji(
                symbol: "😍", name: "Smiling Face with Heart-Eyes",
                keywords: ["love", "hearts", "adore"], category: .smileysAndPeople),
            Emoji(
                symbol: "🤩", name: "Star-Struck", keywords: ["star", "eyes", "excited"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😘", name: "Face Blowing a Kiss", keywords: ["kiss", "love"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😗", name: "Kissing Face", keywords: ["kiss"], category: .smileysAndPeople),
            Emoji(
                symbol: "😚", name: "Kissing Face with Closed Eyes", keywords: ["kiss"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😙", name: "Kissing Face with Smiling Eyes", keywords: ["kiss", "smile"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥲", name: "Smiling Face with Tear", keywords: ["sad", "happy", "cry"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😋", name: "Face Savoring Food", keywords: ["yum", "delicious", "food"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😛", name: "Face with Tongue", keywords: ["tongue", "playful"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😜", name: "Winking Face with Tongue",
                keywords: ["wink", "tongue", "playful"], category: .smileysAndPeople),
            Emoji(
                symbol: "🤪", name: "Zany Face", keywords: ["crazy", "wild"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😝", name: "Squinting Face with Tongue", keywords: ["tongue", "playful"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤑", name: "Money-Mouth Face", keywords: ["money", "rich"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤗", name: "Hugging Face", keywords: ["hug", "love"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤭", name: "Face with Hand Over Mouth", keywords: ["oops", "surprise"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤫", name: "Shushing Face", keywords: ["quiet", "shh"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤔", name: "Thinking Face", keywords: ["think", "hmm"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤐", name: "Zipper-Mouth Face", keywords: ["quiet", "secret"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤨", name: "Face with Raised Eyebrow",
                keywords: ["skeptical", "suspicious"], category: .smileysAndPeople),
            Emoji(
                symbol: "😐", name: "Neutral Face", keywords: ["neutral", "meh"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😑", name: "Expressionless Face", keywords: ["blank", "meh"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😶", name: "Face Without Mouth", keywords: ["silent", "quiet"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😏", name: "Smirking Face", keywords: ["smirk", "smug"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😒", name: "Unamused Face", keywords: ["annoyed", "meh"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙄", name: "Face with Rolling Eyes", keywords: ["eyeroll", "annoyed"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😬", name: "Grimacing Face", keywords: ["awkward", "oops"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😮‍💨", name: "Face Exhaling", keywords: ["sigh", "relief"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤥", name: "Lying Face", keywords: ["lie", "pinocchio"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😌", name: "Relieved Face", keywords: ["relief", "calm"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😔", name: "Pensive Face", keywords: ["sad", "thoughtful"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😪", name: "Sleepy Face", keywords: ["tired", "sleep"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤤", name: "Drooling Face", keywords: ["drool", "sleep"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😴", name: "Sleeping Face", keywords: ["sleep", "zzz"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😷", name: "Face with Medical Mask", keywords: ["sick", "mask"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤒", name: "Face with Thermometer", keywords: ["sick", "ill"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤕", name: "Face with Head-Bandage", keywords: ["hurt", "injured"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤢", name: "Nauseated Face", keywords: ["sick", "gross"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤮", name: "Face Vomiting", keywords: ["sick", "puke"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤧", name: "Sneezing Face", keywords: ["sick", "sneeze"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥵", name: "Hot Face", keywords: ["hot", "sweat"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥶", name: "Cold Face", keywords: ["cold", "freeze"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😵", name: "Dizzy Face", keywords: ["dizzy", "confused"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤯", name: "Exploding Head", keywords: ["mind blown", "shocked"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😕", name: "Confused Face", keywords: ["confused", "unsure"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😟", name: "Worried Face", keywords: ["worried", "concerned"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙁", name: "Slightly Frowning Face", keywords: ["sad", "frown"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "☹️", name: "Frowning Face", keywords: ["sad", "frown"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😮", name: "Face with Open Mouth", keywords: ["wow", "surprised"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😯", name: "Hushed Face", keywords: ["surprised", "quiet"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😲", name: "Astonished Face", keywords: ["shocked", "surprised"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😳", name: "Flushed Face", keywords: ["embarrassed", "blush"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥺", name: "Pleading Face", keywords: ["puppy eyes", "please"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😦", name: "Frowning Face with Open Mouth", keywords: ["sad", "worried"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😧", name: "Anguished Face", keywords: ["anguish", "worried"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😨", name: "Fearful Face", keywords: ["scared", "fear"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😰", name: "Anxious Face with Sweat", keywords: ["anxious", "nervous"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😥", name: "Sad but Relieved Face", keywords: ["sad", "relief"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😢", name: "Crying Face", keywords: ["cry", "sad", "tear"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😭", name: "Loudly Crying Face", keywords: ["cry", "sob", "sad"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😱", name: "Face Screaming in Fear", keywords: ["scream", "scared"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😖", name: "Confounded Face", keywords: ["frustrated", "confused"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😣", name: "Persevering Face", keywords: ["struggle", "persevere"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😞", name: "Disappointed Face", keywords: ["disappointed", "sad"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😓", name: "Downcast Face with Sweat", keywords: ["sad", "sweat"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😩", name: "Weary Face", keywords: ["tired", "weary"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😫", name: "Tired Face", keywords: ["tired", "exhausted"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🥱", name: "Yawning Face", keywords: ["yawn", "tired", "bored"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😤", name: "Face with Steam From Nose", keywords: ["angry", "frustrated"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😡", name: "Pouting Face", keywords: ["angry", "mad"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "😠", name: "Angry Face", keywords: ["angry", "mad"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤬", name: "Face with Symbols on Mouth", keywords: ["cursing", "angry"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👍", name: "Thumbs Up", keywords: ["like", "yes", "approve"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👎", name: "Thumbs Down", keywords: ["dislike", "no", "disapprove"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👏", name: "Clapping Hands", keywords: ["clap", "applause"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙌", name: "Raising Hands", keywords: ["celebrate", "hooray"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤝", name: "Handshake", keywords: ["shake", "deal", "agreement"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🙏", name: "Folded Hands", keywords: ["pray", "thanks", "please"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "✌️", name: "Victory Hand", keywords: ["peace", "victory"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤞", name: "Crossed Fingers", keywords: ["luck", "hope"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤟", name: "Love-You Gesture", keywords: ["love", "rock"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤘", name: "Sign of the Horns", keywords: ["rock", "metal"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👌", name: "OK Hand", keywords: ["ok", "okay", "good"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤌", name: "Pinched Fingers", keywords: ["italian", "gesture"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👈", name: "Backhand Index Pointing Left", keywords: ["point", "left"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👉", name: "Backhand Index Pointing Right", keywords: ["point", "right"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👆", name: "Backhand Index Pointing Up", keywords: ["point", "up"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👇", name: "Backhand Index Pointing Down", keywords: ["point", "down"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "☝️", name: "Index Pointing Up", keywords: ["point", "up", "one"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "✋", name: "Raised Hand", keywords: ["hand", "stop"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤚", name: "Raised Back of Hand", keywords: ["hand", "stop"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🖐️", name: "Hand with Fingers Splayed", keywords: ["hand", "five"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🖖", name: "Vulcan Salute", keywords: ["spock", "star trek"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "👋", name: "Waving Hand", keywords: ["wave", "hello", "bye"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤙", name: "Call Me Hand", keywords: ["call", "phone"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "💪", name: "Flexed Biceps", keywords: ["strong", "muscle"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🦾", name: "Mechanical Arm", keywords: ["robot", "prosthetic"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "✍️", name: "Writing Hand", keywords: ["write", "pen"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "🤳", name: "Selfie", keywords: ["selfie", "camera"],
                category: .smileysAndPeople),
            Emoji(
                symbol: "💅", name: "Nail Polish", keywords: ["nails", "polish"],
                category: .smileysAndPeople),
        ]

        // Hearts and symbols
        let hearts: [Emoji] = [
            Emoji(symbol: "❤️", name: "Red Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "🧡", name: "Orange Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💛", name: "Yellow Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💚", name: "Green Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💙", name: "Blue Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💜", name: "Purple Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "🖤", name: "Black Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "🤍", name: "White Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "🤎", name: "Brown Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💔", name: "Broken Heart", keywords: ["heartbreak", "sad"],
                category: .symbols),
            Emoji(
                symbol: "❣️", name: "Heart Exclamation", keywords: ["love", "heart"],
                category: .symbols),
            Emoji(
                symbol: "💕", name: "Two Hearts", keywords: ["love", "hearts"], category: .symbols),
            Emoji(
                symbol: "💞", name: "Revolving Hearts", keywords: ["love", "hearts"],
                category: .symbols),
            Emoji(
                symbol: "💓", name: "Beating Heart", keywords: ["love", "heartbeat"],
                category: .symbols),
            Emoji(
                symbol: "💗", name: "Growing Heart", keywords: ["love", "heart"], category: .symbols),
            Emoji(
                symbol: "💖", name: "Sparkling Heart", keywords: ["love", "heart", "sparkle"],
                category: .symbols),
            Emoji(
                symbol: "💘", name: "Heart with Arrow", keywords: ["love", "cupid"],
                category: .symbols),
            Emoji(
                symbol: "💝", name: "Heart with Ribbon", keywords: ["love", "gift"],
                category: .symbols),
        ]

        // Animals
        let animals: [Emoji] = [
            Emoji(
                symbol: "🐶", name: "Dog Face", keywords: ["dog", "puppy", "pet"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐱", name: "Cat Face", keywords: ["cat", "kitten", "pet"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐭", name: "Mouse Face", keywords: ["mouse", "rat"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐹", name: "Hamster", keywords: ["hamster", "pet"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐰", name: "Rabbit Face", keywords: ["rabbit", "bunny"],
                category: .animalsAndNature),
            Emoji(symbol: "🦊", name: "Fox", keywords: ["fox"], category: .animalsAndNature),
            Emoji(symbol: "🐻", name: "Bear", keywords: ["bear"], category: .animalsAndNature),
            Emoji(
                symbol: "🐼", name: "Panda", keywords: ["panda", "bear"], category: .animalsAndNature
            ),
            Emoji(symbol: "🐨", name: "Koala", keywords: ["koala"], category: .animalsAndNature),
            Emoji(
                symbol: "🐯", name: "Tiger Face", keywords: ["tiger"], category: .animalsAndNature),
            Emoji(symbol: "🦁", name: "Lion", keywords: ["lion"], category: .animalsAndNature),
            Emoji(symbol: "🐮", name: "Cow Face", keywords: ["cow"], category: .animalsAndNature),
            Emoji(symbol: "🐷", name: "Pig Face", keywords: ["pig"], category: .animalsAndNature),
            Emoji(symbol: "🐸", name: "Frog", keywords: ["frog"], category: .animalsAndNature),
            Emoji(
                symbol: "🐵", name: "Monkey Face", keywords: ["monkey"], category: .animalsAndNature),
            Emoji(
                symbol: "🙈", name: "See-No-Evil Monkey", keywords: ["monkey", "see no evil"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🙉", name: "Hear-No-Evil Monkey", keywords: ["monkey", "hear no evil"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🙊", name: "Speak-No-Evil Monkey", keywords: ["monkey", "speak no evil"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐔", name: "Chicken", keywords: ["chicken", "bird"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐧", name: "Penguin", keywords: ["penguin", "bird"],
                category: .animalsAndNature),
            Emoji(symbol: "🐦", name: "Bird", keywords: ["bird"], category: .animalsAndNature),
            Emoji(
                symbol: "🐤", name: "Baby Chick", keywords: ["chick", "bird", "baby"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🦆", name: "Duck", keywords: ["duck", "bird"], category: .animalsAndNature),
            Emoji(
                symbol: "🦅", name: "Eagle", keywords: ["eagle", "bird"], category: .animalsAndNature
            ),
            Emoji(
                symbol: "🦉", name: "Owl", keywords: ["owl", "bird"], category: .animalsAndNature),
            Emoji(symbol: "🦇", name: "Bat", keywords: ["bat"], category: .animalsAndNature),
            Emoji(symbol: "🐺", name: "Wolf", keywords: ["wolf"], category: .animalsAndNature),
            Emoji(
                symbol: "🐗", name: "Boar", keywords: ["boar", "pig"], category: .animalsAndNature),
            Emoji(
                symbol: "🐴", name: "Horse Face", keywords: ["horse"], category: .animalsAndNature),
            Emoji(
                symbol: "🦄", name: "Unicorn", keywords: ["unicorn", "magical"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐝", name: "Honeybee", keywords: ["bee", "honey"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐛", name: "Bug", keywords: ["bug", "insect"], category: .animalsAndNature),
            Emoji(
                symbol: "🦋", name: "Butterfly", keywords: ["butterfly"], category: .animalsAndNature
            ),
            Emoji(
                symbol: "🐌", name: "Snail", keywords: ["snail", "slow"], category: .animalsAndNature
            ),
            Emoji(
                symbol: "🐞", name: "Lady Beetle", keywords: ["ladybug", "beetle"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐜", name: "Ant", keywords: ["ant", "insect"], category: .animalsAndNature),
            Emoji(
                symbol: "🦟", name: "Mosquito", keywords: ["mosquito"], category: .animalsAndNature),
            Emoji(
                symbol: "🐢", name: "Turtle", keywords: ["turtle", "slow"],
                category: .animalsAndNature),
            Emoji(symbol: "🐍", name: "Snake", keywords: ["snake"], category: .animalsAndNature),
            Emoji(symbol: "🦎", name: "Lizard", keywords: ["lizard"], category: .animalsAndNature),
            Emoji(
                symbol: "🦖", name: "T-Rex", keywords: ["dinosaur", "t-rex"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🦕", name: "Sauropod", keywords: ["dinosaur"], category: .animalsAndNature),
            Emoji(symbol: "🐙", name: "Octopus", keywords: ["octopus"], category: .animalsAndNature),
            Emoji(symbol: "🦑", name: "Squid", keywords: ["squid"], category: .animalsAndNature),
            Emoji(symbol: "🦐", name: "Shrimp", keywords: ["shrimp"], category: .animalsAndNature),
            Emoji(symbol: "🦞", name: "Lobster", keywords: ["lobster"], category: .animalsAndNature),
            Emoji(symbol: "🦀", name: "Crab", keywords: ["crab"], category: .animalsAndNature),
            Emoji(
                symbol: "🐡", name: "Blowfish", keywords: ["fish", "blowfish"],
                category: .animalsAndNature),
            Emoji(
                symbol: "🐠", name: "Tropical Fish", keywords: ["fish", "tropical"],
                category: .animalsAndNature),
            Emoji(symbol: "🐟", name: "Fish", keywords: ["fish"], category: .animalsAndNature),
            Emoji(symbol: "🐬", name: "Dolphin", keywords: ["dolphin"], category: .animalsAndNature),
            Emoji(
                symbol: "🐳", name: "Spouting Whale", keywords: ["whale"],
                category: .animalsAndNature),
            Emoji(symbol: "🐋", name: "Whale", keywords: ["whale"], category: .animalsAndNature),
            Emoji(symbol: "🦈", name: "Shark", keywords: ["shark"], category: .animalsAndNature),
        ]

        // Food & Drink
        let food: [Emoji] = [
            Emoji(
                symbol: "🍎", name: "Red Apple", keywords: ["apple", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍊", name: "Tangerine", keywords: ["orange", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍋", name: "Lemon", keywords: ["lemon", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🍌", name: "Banana", keywords: ["banana", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🍉", name: "Watermelon", keywords: ["watermelon", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍇", name: "Grapes", keywords: ["grapes", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🍓", name: "Strawberry", keywords: ["strawberry", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🫐", name: "Blueberries", keywords: ["blueberry", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍈", name: "Melon", keywords: ["melon", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🍒", name: "Cherries", keywords: ["cherry", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍑", name: "Peach", keywords: ["peach", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🥭", name: "Mango", keywords: ["mango", "fruit"], category: .foodAndDrink),
            Emoji(
                symbol: "🍍", name: "Pineapple", keywords: ["pineapple", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥥", name: "Coconut", keywords: ["coconut", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥝", name: "Kiwi Fruit", keywords: ["kiwi", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍅", name: "Tomato", keywords: ["tomato", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍆", name: "Eggplant", keywords: ["eggplant", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥑", name: "Avocado", keywords: ["avocado", "fruit"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥦", name: "Broccoli", keywords: ["broccoli", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥬", name: "Leafy Green", keywords: ["lettuce", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥒", name: "Cucumber", keywords: ["cucumber", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🌶️", name: "Hot Pepper", keywords: ["pepper", "spicy", "hot"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🌽", name: "Ear of Corn", keywords: ["corn", "vegetable"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥕", name: "Carrot", keywords: ["carrot", "vegetable"],
                category: .foodAndDrink),
            Emoji(symbol: "🧄", name: "Garlic", keywords: ["garlic"], category: .foodAndDrink),
            Emoji(symbol: "🧅", name: "Onion", keywords: ["onion"], category: .foodAndDrink),
            Emoji(symbol: "🥔", name: "Potato", keywords: ["potato"], category: .foodAndDrink),
            Emoji(
                symbol: "🍠", name: "Roasted Sweet Potato", keywords: ["sweet potato"],
                category: .foodAndDrink),
            Emoji(symbol: "🍞", name: "Bread", keywords: ["bread"], category: .foodAndDrink),
            Emoji(
                symbol: "🥐", name: "Croissant", keywords: ["croissant", "bread"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥖", name: "Baguette Bread", keywords: ["baguette", "bread"],
                category: .foodAndDrink),
            Emoji(symbol: "🥨", name: "Pretzel", keywords: ["pretzel"], category: .foodAndDrink),
            Emoji(symbol: "🥯", name: "Bagel", keywords: ["bagel"], category: .foodAndDrink),
            Emoji(
                symbol: "🥞", name: "Pancakes", keywords: ["pancakes", "breakfast"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🧇", name: "Waffle", keywords: ["waffle", "breakfast"],
                category: .foodAndDrink),
            Emoji(symbol: "🧀", name: "Cheese Wedge", keywords: ["cheese"], category: .foodAndDrink),
            Emoji(symbol: "🍖", name: "Meat on Bone", keywords: ["meat"], category: .foodAndDrink),
            Emoji(
                symbol: "🍗", name: "Poultry Leg", keywords: ["chicken", "meat"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥩", name: "Cut of Meat", keywords: ["steak", "meat"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥓", name: "Bacon", keywords: ["bacon", "meat"], category: .foodAndDrink),
            Emoji(
                symbol: "🍔", name: "Hamburger", keywords: ["burger", "hamburger"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍟", name: "French Fries", keywords: ["fries", "chips"],
                category: .foodAndDrink),
            Emoji(symbol: "🍕", name: "Pizza", keywords: ["pizza"], category: .foodAndDrink),
            Emoji(symbol: "🌭", name: "Hot Dog", keywords: ["hotdog"], category: .foodAndDrink),
            Emoji(symbol: "🥪", name: "Sandwich", keywords: ["sandwich"], category: .foodAndDrink),
            Emoji(symbol: "🌮", name: "Taco", keywords: ["taco"], category: .foodAndDrink),
            Emoji(symbol: "🌯", name: "Burrito", keywords: ["burrito"], category: .foodAndDrink),
            Emoji(
                symbol: "🥙", name: "Stuffed Flatbread", keywords: ["pita", "wrap"],
                category: .foodAndDrink),
            Emoji(symbol: "🧆", name: "Falafel", keywords: ["falafel"], category: .foodAndDrink),
            Emoji(symbol: "🥚", name: "Egg", keywords: ["egg"], category: .foodAndDrink),
            Emoji(
                symbol: "🍳", name: "Cooking", keywords: ["egg", "cooking", "frying"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥘", name: "Shallow Pan of Food", keywords: ["paella", "pan"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍲", name: "Pot of Food", keywords: ["stew", "pot"], category: .foodAndDrink
            ),
            Emoji(
                symbol: "🥣", name: "Bowl with Spoon", keywords: ["bowl", "cereal"],
                category: .foodAndDrink),
            Emoji(symbol: "🥗", name: "Green Salad", keywords: ["salad"], category: .foodAndDrink),
            Emoji(symbol: "🍿", name: "Popcorn", keywords: ["popcorn"], category: .foodAndDrink),
            Emoji(symbol: "🧈", name: "Butter", keywords: ["butter"], category: .foodAndDrink),
            Emoji(symbol: "🧂", name: "Salt", keywords: ["salt"], category: .foodAndDrink),
            Emoji(
                symbol: "🥫", name: "Canned Food", keywords: ["can", "soup"], category: .foodAndDrink
            ),
            Emoji(
                symbol: "🍱", name: "Bento Box", keywords: ["bento", "lunch"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍘", name: "Rice Cracker", keywords: ["rice", "cracker"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍙", name: "Rice Ball", keywords: ["rice", "onigiri"],
                category: .foodAndDrink),
            Emoji(symbol: "🍚", name: "Cooked Rice", keywords: ["rice"], category: .foodAndDrink),
            Emoji(
                symbol: "🍛", name: "Curry Rice", keywords: ["curry", "rice"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍜", name: "Steaming Bowl", keywords: ["ramen", "noodles"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍝", name: "Spaghetti", keywords: ["pasta", "spaghetti"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍠", name: "Roasted Sweet Potato", keywords: ["sweet potato"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍢", name: "Oden", keywords: ["oden", "skewer"], category: .foodAndDrink),
            Emoji(symbol: "🍣", name: "Sushi", keywords: ["sushi"], category: .foodAndDrink),
            Emoji(
                symbol: "🍤", name: "Fried Shrimp", keywords: ["shrimp", "tempura"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍥", name: "Fish Cake with Swirl", keywords: ["fish cake", "narutomaki"],
                category: .foodAndDrink),
            Emoji(symbol: "🥮", name: "Moon Cake", keywords: ["moon cake"], category: .foodAndDrink),
            Emoji(
                symbol: "🍡", name: "Dango", keywords: ["dango", "dessert"], category: .foodAndDrink),
            Emoji(symbol: "🥟", name: "Dumpling", keywords: ["dumpling"], category: .foodAndDrink),
            Emoji(
                symbol: "🥠", name: "Fortune Cookie", keywords: ["fortune cookie"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥡", name: "Takeout Box", keywords: ["takeout", "chinese"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🦀", name: "Crab", keywords: ["crab", "seafood"], category: .foodAndDrink),
            Emoji(
                symbol: "🦞", name: "Lobster", keywords: ["lobster", "seafood"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🦐", name: "Shrimp", keywords: ["shrimp", "seafood"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🦑", name: "Squid", keywords: ["squid", "seafood"], category: .foodAndDrink),
            Emoji(
                symbol: "🦪", name: "Oyster", keywords: ["oyster", "seafood"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍦", name: "Soft Ice Cream", keywords: ["ice cream", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍧", name: "Shaved Ice", keywords: ["shaved ice", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍨", name: "Ice Cream", keywords: ["ice cream", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍩", name: "Doughnut", keywords: ["donut", "doughnut", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍪", name: "Cookie", keywords: ["cookie", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🎂", name: "Birthday Cake", keywords: ["cake", "birthday"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍰", name: "Shortcake", keywords: ["cake", "dessert"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🧁", name: "Cupcake", keywords: ["cupcake", "dessert"],
                category: .foodAndDrink),
            Emoji(symbol: "🥧", name: "Pie", keywords: ["pie", "dessert"], category: .foodAndDrink),
            Emoji(
                symbol: "🍫", name: "Chocolate Bar", keywords: ["chocolate", "candy"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍬", name: "Candy", keywords: ["candy", "sweet"], category: .foodAndDrink),
            Emoji(
                symbol: "🍭", name: "Lollipop", keywords: ["lollipop", "candy"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍮", name: "Custard", keywords: ["custard", "pudding"],
                category: .foodAndDrink),
            Emoji(symbol: "🍯", name: "Honey Pot", keywords: ["honey"], category: .foodAndDrink),
            Emoji(
                symbol: "🍼", name: "Baby Bottle", keywords: ["baby", "bottle", "milk"],
                category: .foodAndDrink),
            Emoji(symbol: "🥛", name: "Glass of Milk", keywords: ["milk"], category: .foodAndDrink),
            Emoji(
                symbol: "☕", name: "Hot Beverage", keywords: ["coffee", "tea", "hot"],
                category: .foodAndDrink),
            Emoji(symbol: "🫖", name: "Teapot", keywords: ["tea", "pot"], category: .foodAndDrink),
            Emoji(
                symbol: "🍵", name: "Teacup Without Handle", keywords: ["tea"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍶", name: "Sake", keywords: ["sake", "alcohol"], category: .foodAndDrink),
            Emoji(
                symbol: "🍾", name: "Bottle with Popping Cork",
                keywords: ["champagne", "celebrate"], category: .foodAndDrink),
            Emoji(
                symbol: "🍷", name: "Wine Glass", keywords: ["wine", "alcohol"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍸", name: "Cocktail Glass", keywords: ["cocktail", "martini", "alcohol"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍹", name: "Tropical Drink", keywords: ["tropical", "drink"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍺", name: "Beer Mug", keywords: ["beer", "alcohol"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🍻", name: "Clinking Beer Mugs", keywords: ["beer", "cheers", "alcohol"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥂", name: "Clinking Glasses", keywords: ["cheers", "champagne"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥃", name: "Tumbler Glass", keywords: ["whiskey", "alcohol"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🥤", name: "Cup with Straw", keywords: ["drink", "soda"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🧋", name: "Bubble Tea", keywords: ["bubble tea", "boba"],
                category: .foodAndDrink),
            Emoji(
                symbol: "🧃", name: "Beverage Box", keywords: ["juice box"], category: .foodAndDrink),
            Emoji(symbol: "🧉", name: "Mate", keywords: ["mate", "tea"], category: .foodAndDrink),
            Emoji(symbol: "🧊", name: "Ice", keywords: ["ice", "cold"], category: .foodAndDrink),
        ]

        // Common symbols
        let symbols: [Emoji] = [
            Emoji(
                symbol: "✅", name: "Check Mark Button", keywords: ["check", "done", "yes"],
                category: .symbols),
            Emoji(
                symbol: "❌", name: "Cross Mark", keywords: ["x", "no", "cancel"], category: .symbols
            ),
            Emoji(symbol: "⭐", name: "Star", keywords: ["star", "favorite"], category: .symbols),
            Emoji(
                symbol: "🌟", name: "Glowing Star", keywords: ["star", "sparkle"], category: .symbols
            ),
            Emoji(symbol: "💫", name: "Dizzy", keywords: ["dizzy", "star"], category: .symbols),
            Emoji(
                symbol: "✨", name: "Sparkles", keywords: ["sparkle", "shine"], category: .symbols),
            Emoji(
                symbol: "⚡", name: "High Voltage", keywords: ["lightning", "bolt", "fast"],
                category: .symbols),
            Emoji(symbol: "🔥", name: "Fire", keywords: ["fire", "hot", "lit"], category: .symbols),
            Emoji(
                symbol: "💥", name: "Collision", keywords: ["boom", "explosion"], category: .symbols),
            Emoji(
                symbol: "💯", name: "Hundred Points", keywords: ["100", "perfect"],
                category: .symbols),
            Emoji(
                symbol: "🎯", name: "Direct Hit", keywords: ["target", "bullseye"],
                category: .symbols),
            Emoji(
                symbol: "🎉", name: "Party Popper", keywords: ["party", "celebrate"],
                category: .symbols),
            Emoji(
                symbol: "🎊", name: "Confetti Ball", keywords: ["confetti", "celebrate"],
                category: .symbols),
            Emoji(
                symbol: "🎈", name: "Balloon", keywords: ["balloon", "party"], category: .symbols),
            Emoji(
                symbol: "🎁", name: "Wrapped Gift", keywords: ["gift", "present"], category: .symbols
            ),
            Emoji(
                symbol: "🏆", name: "Trophy", keywords: ["trophy", "win", "award"],
                category: .symbols),
            Emoji(
                symbol: "🥇", name: "1st Place Medal", keywords: ["gold", "first", "medal"],
                category: .symbols),
            Emoji(
                symbol: "🥈", name: "2nd Place Medal", keywords: ["silver", "second", "medal"],
                category: .symbols),
            Emoji(
                symbol: "🥉", name: "3rd Place Medal", keywords: ["bronze", "third", "medal"],
                category: .symbols),
            Emoji(
                symbol: "⚠️", name: "Warning", keywords: ["warning", "caution"], category: .symbols),
            Emoji(
                symbol: "🚫", name: "Prohibited", keywords: ["no", "prohibited", "ban"],
                category: .symbols),
            Emoji(
                symbol: "💬", name: "Speech Balloon", keywords: ["chat", "message", "talk"],
                category: .symbols),
            Emoji(
                symbol: "💭", name: "Thought Balloon", keywords: ["think", "thought"],
                category: .symbols),
            Emoji(
                symbol: "💡", name: "Light Bulb", keywords: ["idea", "light"], category: .symbols),
            Emoji(
                symbol: "🔔", name: "Bell", keywords: ["bell", "notification"], category: .symbols),
            Emoji(
                symbol: "🔕", name: "Bell with Slash", keywords: ["mute", "silent"],
                category: .symbols),
            Emoji(symbol: "📌", name: "Pushpin", keywords: ["pin", "pushpin"], category: .symbols),
            Emoji(
                symbol: "📍", name: "Round Pushpin", keywords: ["pin", "location"],
                category: .symbols),
            Emoji(symbol: "🔗", name: "Link", keywords: ["link", "chain"], category: .symbols),
            Emoji(symbol: "🔒", name: "Locked", keywords: ["lock", "secure"], category: .symbols),
            Emoji(symbol: "🔓", name: "Unlocked", keywords: ["unlock", "open"], category: .symbols),
            Emoji(symbol: "🔑", name: "Key", keywords: ["key", "password"], category: .symbols),
            Emoji(symbol: "🗝️", name: "Old Key", keywords: ["key", "old"], category: .symbols),
        ]

        allEmojis = smileys + hearts + animals + food + symbols
    }

    public func search(query: String) -> [Emoji] {
        guard !query.isEmpty else {
            // Return frequently used when empty
            return getFrequentlyUsed()
        }

        let lowercaseQuery = query.lowercased()

        return allEmojis.filter { emoji in
            emoji.name.lowercased().contains(lowercaseQuery)
                || emoji.keywords.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }

    public func getFrequentlyUsed() -> [Emoji] {
        // Get recently used emoji IDs from ranking engine
        let recentIds = RankingEngine.shared.getRecents(limit: 16)

        // Filter emojis that match recent IDs
        let recentEmojis = allEmojis.filter { emoji in
            recentIds.contains(emoji.stableId)
        }

        // If no usage history, return some defaults
        if recentEmojis.isEmpty {
            return Array(allEmojis.prefix(16))
        }

        return recentEmojis
    }
}
