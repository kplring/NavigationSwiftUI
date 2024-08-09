//
//  NavigationSwiftUI.swift
//
//  Created by zh on 2024/4/7.
//

import SwiftUI

public class Navigator: ObservableObject {
    
    @Published
    fileprivate var naviPath = NavigationPath()
    
    enum Destination: Hashable {
        
        case route(NavigationRouter), viewBuilder(AnyView)
        
        static func == (lhs: Navigator.Destination, rhs: Navigator.Destination) -> Bool {
            switch lhs {
                
            case .route(let lRouter):
                switch rhs {
                case .route(let rRouter):
                    // 简单点，只比较 uri...
                    return lRouter.uri == rRouter.uri
                case .viewBuilder(_):
                    return false
                }
                
            case .viewBuilder(_):
                // 既然是 builder 那肯定是 false 了...
                return false
            }
        }
        
        func hash(into hasher: inout Hasher) {
            switch self {
            case .route(let router):
                hasher.combine(router.uri)
                hasher.combine(self)
            case .viewBuilder(let anyView):
                hasher.combine(self)
            }
        }
    }
}

public extension Navigator {
    
    func push(@ViewBuilder _ content: () -> some View) {
        naviPath.append(Destination.viewBuilder(AnyView(content())))
    }
    
    func push(_ uri: String) {
        guard let router = NavigationRouterRegistrar.routerFor(uri) else { return }
        naviPath.append(Destination.route(router))
    }
    
    func pop() {
        naviPath.removeLast()
    }
    
    func popToRoot() {
        naviPath.removeLast(naviPath.count)
    }
}

public struct NavigationRootView<Content: View>: View {
    
    @StateObject
    private var navigator = Navigator()
    
    @ViewBuilder
    public var content: (Navigator) -> Content
    
    public init(content: @escaping (Navigator) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        NavigationStack(path: $navigator.naviPath) {
            content(navigator)
                .navigationDestination(for: Navigator.Destination.self, destination: {
                    switch $0 {
                    case .route(let router):
                        router.build()
                    case .viewBuilder(let content):
                        content
                    }
                })
        }
        .environmentObject(navigator)
    }
}
