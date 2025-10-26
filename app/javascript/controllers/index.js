// Import and register all your controllers
import { application } from "./application"

// Import individual controllers
import MarketDataController from "./market_data_controller"

// Register controllers
application.register("market-data", MarketDataController)

