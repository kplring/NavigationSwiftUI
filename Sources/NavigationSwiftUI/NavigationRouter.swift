//
//  NavigationRouter.swift
//
//  Created by zh on 2024/4/8.
//

import SwiftUI

public class NavigationRouterRegistrar {
    public static let shared = NavigationRouterRegistrar()
    private var routerList: [NavigationRouter] = []
    
    private init () { }
    
    public func register(@RegisterRoutersBuilder _ routers: () -> [NavigationRouter]) {
        let routerList = routers()
        if !routerList.isEmpty {
            self.routerList.append(contentsOf: routerList)
            // 根据 uri 去重
            var ls: [NavigationRouter] = []
            self.routerList.forEach { route in
                if ls.first(where: { $0.uri == route.uri }) == nil {
                    ls.append(route)
                }
            }
            
            self.routerList = ls
        }
    }

    public class func register(@RegisterRoutersBuilder _ routers: () -> [NavigationRouter]) {
        shared.register(routers)
    }
    
    class func routerFor(_ uri: String) -> NavigationRouter? {
        shared.routerList.last { router in router.uri == uri }
    }
}

@resultBuilder
public struct RegisterRoutersBuilder {
    public static func buildBlock(_ components: NavigationRouter...) -> [NavigationRouter] {
        components
    }
}

public struct NavigationRouter {
    let uri: String
    
    @ViewBuilder
    let content: () -> AnyView
    
    public init(uri: String, content: @escaping () -> some View) {
        self.uri = uri
        self.content = { AnyView(content()) }
    }
    
    func build() -> some View {
        content()
    }
}
