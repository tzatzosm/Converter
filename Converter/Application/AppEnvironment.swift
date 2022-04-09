//
//  AppEnvironment.swift
//  Converter
//
//  Created by Marsel Tzatzo on 6/4/22.
//

import Foundation

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    
    static func bootstrap() -> AppEnvironment {
        let appState = Store<AppState>(AppState())
        let session = URLSession.shared
        let networkRepositories = makeNetworkRepositories(session: session)
        let services = makeServices(appState: appState, networkRepositories: networkRepositories)
        let diContainer = DIContainer(appState: appState, services: services)
        return AppEnvironment(container: diContainer)
    }
    
    private static func makeNetworkRepositories(session: URLSession) -> NetworkRepositories {
//        let exchangeRatesRepository = ExchangeRatesRepository(
//            session: session,
//            baseURL: "http://api.exchangeratesapi.io/")
        let exchangeRatesRepository = MockExchangeRatesRepository()
        return .init(exchangeRatesRpository: exchangeRatesRepository)
    }
    
    
    private static func makeServices(
        appState: Store<AppState>,
        networkRepositories: NetworkRepositories
    ) -> DIContainer.Services {
        let exchangeRatesService = makeExchangeRatesService(
            appState: appState,
            exchangeRatesRepository: networkRepositories.exchangeRatesRpository)
        return .init(currencyExchangeService: exchangeRatesService)
    }
    
    
    private static func makeExchangeRatesService(
        appState: Store<AppState>,
        exchangeRatesRepository: AnyExchangeRatesRepository
    ) -> AnyCurrencyExchangeService {
        CurrencyExchangeService(
            appState: appState,
            exchangeRatesRepository: exchangeRatesRepository)
    }
    
    
}

extension AppEnvironment {
    struct NetworkRepositories {
        let exchangeRatesRpository: AnyExchangeRatesRepository
    }
}
