import Rainbow

enum Terminal {
    static func success(_ text: String) {
        print(text.green)
    }

    static func error(_ text: String) {
        print(text.red)
    }

    static func warning(_ text: String) {
        print(text.yellow)
    }

    static func info(_ text: String) {
        print(text.cyan)
    }

    static func dim(_ text: String) {
        print(text.lightBlack)
    }

    static func header(_ text: String) {
        let border = String(repeating: "─", count: min(text.count + 4, 70))
        print("┌\(border)┐".cyan)
        print("│  \(text.bold)  │".cyan)
        print("└\(border)┘".cyan)
    }

    static func panel(_ title: String, content: String) {
        let border = String(repeating: "─", count: 70)
        print("┌─ \(title.bold) \(String(repeating: "─", count: max(0, 66 - title.count)))┐".cyan)
        for line in content.split(separator: "\n", omittingEmptySubsequences: false) {
            print("│ \(line)".cyan)
        }
        print("└\(border)┘".cyan)
    }
}
