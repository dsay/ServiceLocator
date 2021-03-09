import Foundation

class ServiceLocator {

    static let shared = ServiceLocator()

    private var registry: [ServiceKey: Any] = [:]

    func register<T>(service: @escaping (ServiceLocator) -> T, name: String? = nil) {
        let key = ServiceKey(serviceType: T.self, name: name)
        registry[key] = service
    }

    func register<T>(service: T, name: String? = nil) {
        let key = ServiceKey(serviceType: T.self, name: name)
        registry[key] = service
    }

    func tryGetService<T>(name: String? = nil) -> T? {
        let key = ServiceKey(serviceType: T.self, name: name)
        if let service = registry[key] as? T {
            return service
        } else if let service = registry[key] as? (ServiceLocator) -> T {
            return service(self)
        } else {
            return nil
        }
    }
    
    func getService<T>(name: String? = nil) -> T {
        if let service: T = tryGetService(name: name) {
            return service
        } else {
            fatalError("Service: \(T.self) was not registerd!!!")
        }
    }

    func unregister<T>(service: T, name: String? = nil) {
        let key = ServiceKey(serviceType: T.self, name: name)
        registry.removeValue(forKey: key)
    }
}

private struct ServiceKey {

    let serviceType: Any.Type
    let name: String?
}

extension ServiceKey: Hashable {

    static func == (lhs: ServiceKey, rhs: ServiceKey) -> Bool {
        return lhs.serviceType == rhs.serviceType &&
            lhs.name == rhs.name
    }

    public func hash(into hasher: inout Hasher) {
        ObjectIdentifier(serviceType).hash(into: &hasher)
        name?.hash(into: &hasher)
    }
}

@propertyWrapper
struct Injection<T> {

    var wrappedValue: T {
        get {
            return ServiceLocator.shared.getService()
        }
        set {
            ServiceLocator.shared.register(service: newValue)
        }
    }
}
