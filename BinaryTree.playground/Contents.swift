public class BinaryNode<Element> {
    
    public var value: Element
    public var leftChild: BinaryNode?
    public var rightChild: BinaryNode?
    
    public init(value: Element) {
        self.value = value
    }
    
    public func inOrder(visit: (Element) -> Void) {
        leftChild?.inOrder(visit: visit)
        visit(value)
        rightChild?.inOrder(visit: visit)
    }
    
    public func preOrder(visit: (Element) -> Void) {
        visit(value)
        leftChild?.preOrder(visit: visit)
        rightChild?.preOrder(visit: visit)
    }
    
    public func postOrder(visit: (Element) -> Void) {
        leftChild?.postOrder(visit: visit)
        rightChild?.postOrder(visit: visit)
        visit(value)
    }
}

func height<T>(of node: BinaryNode<T>?) -> Int {
    guard let node = node else { return -1 }
    
    return 1 + max(height(of: node.leftChild), height(of: node.rightChild))
}
