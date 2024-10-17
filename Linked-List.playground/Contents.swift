public class Node<Value> {
    
    public var value: Value
    public var next: Node?
    
    public init(value: Value, next: Node? = nil) {
        self.value = value
        self.next = next
    }
}

extension Node: CustomStringConvertible {
    public var description: String {
        guard let next = next else {
            return "\(value)"
        }
        return "\(value) -> " + String(describing: next) + " "
    }
}

public struct LinkedList<Value> {
    
    public var head: Node<Value>?
    public var tail: Node<Value>?
    
    public init() {}
    
    public var isEmpty: Bool {
        head == nil
    }
    
    public mutating func push(_ value: Value) {
        copyNodes()
        head = Node(value: value, next: head)
        if tail == nil {
            tail = head
        }
    }
    
    public mutating func append(_ value: Value) {
        copyNodes()
        guard !isEmpty else {
            push(value)
            return
        }
        
        tail!.next = Node(value: value)
        tail = tail!.next
    }
    
    public func node(at index: Int) -> Node<Value>? {
        var currentNode = head
        var currentIndex = 0
        
        while currentNode != nil && currentIndex < index {
            currentNode = currentNode!.next
            currentIndex += 1
        }
        
        return currentNode
    }
    
    // discardableResult - callers can ignore the return value
    @discardableResult
    public mutating func insert(_ value: Value, after node: Node<Value>) -> Node<Value> {
        copyNodes()
        // === two references point to the same object
        // !== is true if the two variables reference different objects with different addresses.
        guard tail !== node else {
            // Gonna insert last
            append(value)
            return tail!
        }
        
        // Insert in the middle
        node.next = Node(value: value, next: node.next)
        return node.next!
    }
    
    @discardableResult
    public mutating func pop() -> Value? {
        copyNodes()
        // The code inside a defer block runs after the surrounding code finishes, but before the function returns.
        // Meaning it will return first and only then remove the head
        defer {
            head = head?.next
            if isEmpty {
                tail = nil
            }
        }
        return head?.value
    }
    
    @discardableResult
    public mutating func removeLast() -> Value? {
        copyNodes()
        guard let head = head else { return nil }
        guard head.next != nil else { return pop() }
        
        var prev = head
        var current = head
        
        while let next = current.next {
            prev = current
            current = next
        }
        
        prev.next = nil
        tail = prev
        return current.value
    }
    
    @discardableResult public mutating func remove(after node: Node<Value>) -> Value? {
        guard let node = copyNodes(returningCopyOf: node) else { return nil }
        defer {
            if node.next === tail {
                tail = node
            }
            node.next = node.next?.next
        }
        return node.next?.value
    }
    
    private mutating func copyNodes() {
        guard var oldNode = head else { return }
        head = Node(value: oldNode.value)
        var newNode = head
        
        while let nextOldNode = oldNode.next {
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            
            oldNode = nextOldNode
        }
        
        tail = newNode
    }
    
    // Used for COW functionality
    private mutating func copyNodes(returningCopyOf node: Node<Value>?) -> Node<Value>? {
        guard !isKnownUniquelyReferenced(&head) else { return nil }
        guard var oldNode = head else { return nil }
        
        head = Node(value: oldNode.value)
        var newNode = head
        var nodeCopy: Node<Value>?
        
        while let nextOldNode = oldNode.next {
            if oldNode === node {
                nodeCopy = newNode
            }
            newNode!.next = Node(value: nextOldNode.value)
            newNode = newNode!.next
            oldNode = nextOldNode
        }
        return nodeCopy
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        guard let head = head else {
            return "Empty List"
        }
        
        return String(describing: head)
    }
}

// Conforming to Collection Protocol
extension LinkedList: Collection {
    public struct Index: Comparable {
        public var node: Node<Value>?
        
        static public func ==(lhs: Index, rhs: Index) -> Bool {
            switch (lhs.node, rhs.node) {
            case let (left?, right?):
                return left.next === right.next
            case (nil, nil):
                return true
            default:
                return false
            }
        }
        
        static public func <(lhs: Index, rhs: Index) -> Bool {
            guard lhs != rhs else {
                return false
            }
            
            let nodes = sequence(first: lhs.node) { $0?.next }
            return nodes.contains { $0 === rhs.node }
        }
    }
    
    public var startIndex: Index {
        Index(node: head)
    }
    
    public var endIndex: Index {
        Index(node: tail?.next)
    }
    
    public func index(after i: Index) -> Index {
        Index(node: i.node?.next)
    }
    
    public subscript(position: Index) -> Value {
        position.node!.value
    }
}

// Challenge 1 - Print linked list in reverse

public func printInReverse<T>(_ node: Node<T>?) {
    guard let node = node else { return } // nothing to print
    printInReverse(node.next)
    print(node.value)
}

// Challenge 2 - Find the middle node

public func getMiddle<T>(_ list: LinkedList<T>) -> Node<T>? {
    var slowIterator = list.head
    var fastIterator = list.head
    
    while let nextFastIterator = fastIterator?.next {
        fastIterator = nextFastIterator.next
        slowIterator = slowIterator?.next
    }
    
    return slowIterator
}


// Challenge 3 - Reverse a list

extension LinkedList {
    
    mutating func reverseTrivial() {
        var tmpList = LinkedList<Value>()
        for value in self {
            tmpList.push(value)
        }
        
        head = tmpList.head
    }
    
    mutating func reverse() {
        tail = head
        var prev = head
        var current = head?.next
        prev?.next = nil // new end of list
        
        while current != nil { // Traversing backwards
            let next = current?.next
            current?.next = prev
            prev = current
            current = next
        }
        
        head = prev
    }
}

// Challenge 4 - Merge two ordered lists

// Need to use comparable in order to compare T and Value
func mergeLists<T: Comparable>(_ leftList: LinkedList<T>, _ rightList: LinkedList<T>) -> LinkedList<T>? {
    guard !leftList.isEmpty else { return rightList }
    guard !rightList.isEmpty else { return leftList }
    
    var newHead: Node<T>?
    var tail: Node<T>?
    var currentLeft = leftList.head
    var currentRight = rightList.head
    
    if let leftNode = currentLeft, let rightNode = currentRight {
        if leftNode.value < rightNode.value {
            newHead = leftNode
            currentLeft = leftNode.next
        } else {
            newHead = rightNode
            currentRight = rightNode.next
        }
        tail = newHead
    }
    
    while let leftNode = currentLeft, let rightNode = currentRight {
        if leftNode.value < rightNode.value {
            tail?.next = leftNode
            currentLeft = leftNode.next
        } else {
            tail?.next = rightNode
            currentRight = rightNode.next
        }
        tail = tail?.next
    }
    
    if let leftNodes = currentLeft {
        tail?.next = leftNodes
    }
    
    if let rightNodes = currentRight {
        tail?.next = rightNodes
    }
    
    var list = LinkedList<T>()
    list.head = newHead
    list.tail = {
        while let next = tail?.next {
            tail = next
        }
        return tail
    }()
    return list
}

// Challenge 5 - Remove all occurrences

// Need to use comparable in order to compare T and Value
extension LinkedList where Value: Equatable {
    public mutating func removeAllOccurrences(of value: Value) {
        // remove head case
        while let head = head, head.value == value {
            self.head = head.next
        }
        
        var prev = head
        var current = head?.next
        
        while let currentNode = current {
            guard currentNode.value != value else {
                prev?.next = currentNode.next
                current = prev?.next
                continue
            }
            
            prev = current
            current = current?.next
        }
        
        tail = prev
    }
}

var list = LinkedList<Int>()
list.append(1)
list.append(2)
list.append(2)
list.append(3)
list.append(2)

print("Before removal: \(list)")
list.removeAllOccurrences(of: 2)
print("After removal: \(list)")




