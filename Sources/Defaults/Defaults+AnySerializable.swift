import CoreGraphics
import Foundation

extension Defaults {
	/**
	Type-erased wrapper for `Defaults.Serializable` values.

	It can be useful when you need to create an `Any` value that conforms to `Defaults.Serializable`.

	It will have an internal property `value` which should always be a `UserDefaults` natively supported type.

	`get` will deserialize the internal value to the type that user specify in the function parameter.

	```swift
	let any = Defaults.Key<Defaults.AnySerializable>("independentAnyKey", default: 121_314)

	print(Defaults[any].get(Int.self))
	//=> 121_314
	```

	- Note: The only way to assign a non-serializable value is using `ExpressibleByArrayLiteral` or `ExpressibleByDictionaryLiteral` to assign a type that is not a `UserDefaults` natively supported type.

	```swift
	private enum mime: String, Defaults.Serializable {
		case JSON = "application/json"
	}

	// Failed: Attempt to insert non-property list object
	let any = Defaults.Key<Defaults.AnySerializable>("independentAnyKey", default: [mime.JSON])
	```
	*/
	public struct AnySerializable: Serializable {
		var value: Any
		public static let bridge = AnyBridge()

		init<T>(value: T?) {
			self.value = value ?? ()
		}

		public init<Value: Serializable>(_ value: Value) {
			self.value = Value.toSerializable(value) ?? ()
		}

		public func get<Value: Serializable>() -> Value? { Value.toValue(value) }

		public func get<Value: Serializable>(_: Value.Type) -> Value? { Value.toValue(value) }

		public mutating func set<Value: Serializable>(_ newValue: Value) {
			value = Value.toSerializable(newValue) ?? ()
		}

		public mutating func set<Value: Serializable>(_ newValue: Value, type: Value.Type) {
			value = Value.toSerializable(newValue) ?? ()
		}
	}
}

extension Defaults.AnySerializable: Hashable {
	public func hash(into hasher: inout Hasher) {
		switch value {
		case let value as Data:
			hasher.combine(value)
		case let value as Date:
			hasher.combine(value)
		case let value as Bool:
			hasher.combine(value)
		case let value as UInt8:
			hasher.combine(value)
		case let value as Int8:
			hasher.combine(value)
		case let value as UInt16:
			hasher.combine(value)
		case let value as Int16:
			hasher.combine(value)
		case let value as UInt32:
			hasher.combine(value)
		case let value as Int32:
			hasher.combine(value)
		case let value as UInt64:
			hasher.combine(value)
		case let value as Int64:
			hasher.combine(value)
		case let value as UInt:
			hasher.combine(value)
		case let value as Int:
			hasher.combine(value)
		case let value as Float:
			hasher.combine(value)
		case let value as Double:
			hasher.combine(value)
		case let value as CGFloat:
			hasher.combine(value)
		case let value as String:
			hasher.combine(value)
		case let value as [AnyHashable: AnyHashable]:
			hasher.combine(value)
		case let value as [AnyHashable]:
			hasher.combine(value)
		default:
			break
		}
	}
}

extension Defaults.AnySerializable: Equatable {
	public static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs.value, rhs.value) {
		case (let lhs as Data, let rhs as Data):
			return lhs == rhs
		case (let lhs as Date, let rhs as Date):
			return lhs == rhs
		case (let lhs as Bool, let rhs as Bool):
			return lhs == rhs
		case (let lhs as UInt8, let rhs as UInt8):
			return lhs == rhs
		case (let lhs as Int8, let rhs as Int8):
			return lhs == rhs
		case (let lhs as UInt16, let rhs as UInt16):
			return lhs == rhs
		case (let lhs as Int16, let rhs as Int16):
			return lhs == rhs
		case (let lhs as UInt32, let rhs as UInt32):
			return lhs == rhs
		case (let lhs as Int32, let rhs as Int32):
			return lhs == rhs
		case (let lhs as UInt64, let rhs as UInt64):
			return lhs == rhs
		case (let lhs as Int64, let rhs as Int64):
			return lhs == rhs
		case (let lhs as UInt, let rhs as UInt):
			return lhs == rhs
		case (let lhs as Int, let rhs as Int):
			return lhs == rhs
		case (let lhs as Float, let rhs as Float):
			return lhs == rhs
		case (let lhs as Double, let rhs as Double):
			return lhs == rhs
		case (let lhs as CGFloat, let rhs as CGFloat):
			return lhs == rhs
		case (let lhs as String, let rhs as String):
			return lhs == rhs
		case (let lhs as [AnyHashable: Any], let rhs as [AnyHashable: Any]):
			return lhs.toDictionary() == rhs.toDictionary()
		case (let lhs as [Any], let rhs as [Any]):
			return lhs.toSequence() == rhs.toSequence()
		default:
			return false
		}
	}
}

extension Defaults.AnySerializable: ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self.init(value: value)
	}
}

extension Defaults.AnySerializable: ExpressibleByNilLiteral {
	public init(nilLiteral _: ()) {
		self.init(value: nil as Any?)
	}
}

extension Defaults.AnySerializable: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool) {
		self.init(value: value)
	}
}

extension Defaults.AnySerializable: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self.init(value: value)
	}
}

extension Defaults.AnySerializable: ExpressibleByFloatLiteral {
	public init(floatLiteral value: Double) {
		self.init(value: value)
	}
}

extension Defaults.AnySerializable: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: Any...) {
		self.init(value: elements)
	}
}

extension Defaults.AnySerializable: ExpressibleByDictionaryLiteral {
	public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
		self.init(value: [AnyHashable: Any](uniqueKeysWithValues: elements))
	}
}

extension Defaults.AnySerializable: _DefaultsOptionalProtocol {
	// Since `nil` cannot be assigned to `Any`, we use `Void` instead of `nil`.
	public var isNil: Bool { value is Void }
}

extension Sequence {
	fileprivate func toSequence() -> [Defaults.AnySerializable] {
		map { Defaults.AnySerializable(value: $0) }
	}
}

extension Dictionary {
	fileprivate func toDictionary() -> [AnyHashable: Defaults.AnySerializable] {
		reduce(into: [AnyHashable: Defaults.AnySerializable]()) { memo, tuple in memo[tuple.key] = Defaults.AnySerializable(value: tuple.value) }
	}
}
