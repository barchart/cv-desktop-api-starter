import { InstrumentDefinition, OpenFeedClient, OpenfeedGatewayMessage, OpenFeedListeners, Service, SubscriptionType } from "@openfeed/sdk-js";

const wsUrl = process.env.OPENFEED_WS_URL || "ws://localhost:9000";
const username = process.env.OPENFEED_USERNAME;
const password = process.env.OPENFEED_PASSWORD;

if (!username || !password) {
  console.error("Missing OPENFEED_USERNAME or OPENFEED_PASSWORD. Set them in your .env file (see README) before running.");
  process.exit(1);
}

type MarketState = {
  priceDenominator: number;
  lastPrice: number | null;
};
const marketState: Record<string, MarketState> = {};

const listeners = new OpenFeedListeners();

listeners.onConnected = (connection) => {
  console.log("Connected to OpenFeed");
};

listeners.onDisconnected = () => {
  console.log("Disconnected from OpenFeed");
};

listeners.onCredentialsRejected = () => {
  console.error("Invalid credentials - check username/password");
};

listeners.onMessageWithMetadata = (message: OpenfeedGatewayMessage, symbolNames: string[], instrument?: InstrumentDefinition) => {
  const symbol = symbolNames[0];

  // Handle subscription response
  if (message.subscriptionResponse) {
    console.log(`Subscription confirmed: ${message.subscriptionResponse.symbol}`);
    return;
  }

  // Handle instrument definition - Initialize state with metadata
  if (message.instrumentDefinition) {
    const def = message.instrumentDefinition;
    marketState[symbol] = {
      priceDenominator: def.priceDenominator || 1,
      lastPrice: null
    };
    console.log(`\n[Definition] ${symbol} - ${def.description}`);
    console.log(`  Price Denominator: ${def.priceDenominator}`);
    return;
  }

  // Handle market snapshot - Populate initial state
  if (message.marketSnapshot) {
    if (!marketState[symbol]) {
      return;
    }
    if (message.marketSnapshot.last?.price) {
      const price = message.marketSnapshot.last.price.toNumber();
      const denominator = marketState[symbol].priceDenominator;
      marketState[symbol].lastPrice = price / denominator;
      console.log(`[Snapshot] ${symbol} initialized - Last: ${marketState[symbol].lastPrice}`);
    }
    return;
  }

  if (message.greeks) {
    console.log(`\n[Greeks] ${symbol} - Updated Greeks:`, message.greeks);
  }

  // Handle market update - Update existing state and log only on change
  if (message.marketUpdate) {
    const update = message.marketUpdate;
    if (!marketState[symbol]) {
      return; // Silently ignore updates before state is initialized
    }

    const oldPrice = marketState[symbol].lastPrice;
    const denominator = marketState[symbol].priceDenominator;
    let newPrice = oldPrice;

    if (update.trades && update.session?.last?.price) {
      newPrice = update.session.last.price.toNumber() / denominator;
      marketState[symbol].lastPrice = newPrice;
    } else if (update.last?.price) {
      newPrice = update.last.price.toNumber() / denominator;
      marketState[symbol].lastPrice = newPrice;
    }

    if (newPrice !== null && newPrice !== oldPrice) {
      console.log(`[Update] ${symbol} - Last: ${newPrice}`);
    }
    return;
  }
};

const client = new OpenFeedClient(wsUrl, username, password, listeners, console);
client.subscribe(Service.REAL_TIME, SubscriptionType.ALL, 1, ["ESZ26"], null, null, null);
client.subscribe(Service.REAL_TIME, SubscriptionType.ALL, 1, ["ZCZ26"], null, null, null);
