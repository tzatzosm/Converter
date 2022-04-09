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
        let memoryRepositories = makeMemoryRepositories()
        let services = makeServices(
            appState: appState,
            networkRepositories: networkRepositories,
            memoryRepositories: memoryRepositories)
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
    
    private static func makeMemoryRepositories() -> MemoryRepositories {
        let balanceRepository = BalanceRepository()
        return .init(balanceRepository: balanceRepository)
    }
    
    private static func makeServices(
        appState: Store<AppState>,
        networkRepositories: NetworkRepositories,
        memoryRepositories: MemoryRepositories
    ) -> DIContainer.Services {
        let exchangeRatesService = makeExchangeRatesService(
            exchangeRatesRepository: networkRepositories.exchangeRatesRpository,
            balanceRepository: memoryRepositories.balanceRepository)
        return .init(currencyExchangeService: exchangeRatesService)
    }
    
    
    private static func makeExchangeRatesService(
        exchangeRatesRepository: AnyExchangeRatesRepository,
        balanceRepository: AnyBalanceRepository
    ) -> AnyCurrencyExchangeService {
        CurrencyExchangeService(
            exchangeRatesRepository: exchangeRatesRepository,
            balanceRepository: balanceRepository)
    }
    
    
}

extension AppEnvironment {
    struct NetworkRepositories {
        let exchangeRatesRpository: AnyExchangeRatesRepository
    }
    struct MemoryRepositories {
        let balanceRepository: AnyBalanceRepository
    }
}
