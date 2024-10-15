public struct Stack<Element> {
    
    private var storage: [Element] = []
    
    public init() { }
    
    public init(_ elements: [Element]) {
        storage = elements
    }
    
    public mutating func push(_ element: Element) {
        storage.append(element)
    }
    
    public mutating func pop() -> Element? {
        storage.popLast()
    }
    
    public func peek() -> Element? {
        storage.last
    }
    
    public var isEmpty: Bool {
        peek() == nil
    }
}

extension Stack: CustomStringConvertible {
    public var description: String {
        """
        ----top----
        \(storage.map { "\($0)"}.reversed().joined(separator: "\n"))
        -----------
        """
    }
}

extension Stack: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: Element...) {
        storage = elements
    }
}


var stack1 = Stack<Int>()
stack1.push(1)
stack1.push(2)
stack1.push(3)
stack1.push(4)
    
print(stack1)
    
if let poppedElement = stack1.pop() {
    assert(4 == poppedElement)
    print("Popped: \(poppedElement)")
}

let array = ["A", "B", "C", "D"]
var stack2 = Stack(array)
print(stack2)
stack2.pop()

var stack3: Stack = [1.0, 2.0, 3.0, 4.0]
print(stack3)
stack3.pop()



func printInReverse<T>(_ array: [T]) {
    var stack = Stack<T>()
    
    for value in array {
        stack.push(value)
    }
    
    while let value = stack.pop() {
        print(value)
    }
}

printInReverse(array)

func checkParentheses(_ string: String) -> Bool {
    var stack = Stack<Character>()
    
    for character in string {
        if character == "(" {
            stack.push(character)
        } else  if character == ")" {
            if stack.isEmpty {
                return false
            } else {
                stack.pop()
            }
        }
    }
    return stack.isEmpty
}

print(checkParentheses("((()))"))
