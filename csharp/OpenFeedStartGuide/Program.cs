using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Org.Openfeed;
using Org.Openfeed.Client;

namespace OpenFeedStartGuide
{
    class Program
    {
        // Global state management - Store state by symbol
        private static readonly Dictionary<string, MarketState> MarketStateBySymbol = new();

        class MarketState
        {
            public long PriceDenominator { get; set; } = 1;
            public decimal? LastPrice { get; set; }
        }

        static async Task Main(string[] args)
        {
            // Replace with your cmdtyView Desktop API credentials
            var openfeedUrl = "ws://localhost:9000";
            var username = "YOUR_USERNAME";
            var password = "YOUR_PASSWORD";

            Console.WriteLine("Connecting to OpenFeed...");

            var listeners = new OpenfeedListeners
            {
                OnConnected = _ =>
                {
                    Console.WriteLine("Connected to OpenFeed");
                    return ValueTask.CompletedTask;
                },
                OnDisconnected = () =>
                {
                    Console.WriteLine("Disconnected from OpenFeed");
                    return ValueTask.CompletedTask;
                },
                OnCredentialsRejected = () =>
                {
                    Console.WriteLine("Invalid credentials - check username/password");
                    return ValueTask.CompletedTask;
                },
                OnConnectFailed = exception =>
                {
                    Console.WriteLine($"Connection failed: {exception.Message}");
                    return ValueTask.CompletedTask;
                },
                OnMessageWithMetadata = (message, definition, symbols) =>
                {
                    HandleMessage(message, definition, symbols);
                    return ValueTask.CompletedTask;
                }
            };

            var client = OpenfeedFactory.CreateClient(
                new Uri(openfeedUrl),
                username,
                password,
                listeners,
                clientId: null
            );

            await client.GetConnectionAsync(default);

            client.Subscribe(
                Service.RealTime,
                SubscriptionType.All,
                snapshotIntervalSeconds: 1,
                symbols: new[] { "ZCN26", "ZLN26" },
                marketIds: null,
                exchanges: null,
                channels: null
            );

            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
        }

        private static void HandleMessage(OpenfeedGatewayMessage message, InstrumentDefinition? definition, string[] symbols)
        {
            // Get the symbol from the provided list
            var symbol = symbols.Length > 0 ? symbols[0] : "unknown";

            // Handle subscription response
            if (message.SubscriptionResponse != null)
            {
                Console.WriteLine($"[Subscription] {message.SubscriptionResponse.Symbol}");
                return;
            }

            // Handle instrument definition - Initialize state with metadata
            if (message.InstrumentDefinition != null)
            {
                var def = message.InstrumentDefinition;

                // Initialize state with price denominator
                MarketStateBySymbol[symbol] = new MarketState
                {
                    PriceDenominator = def.PriceDenominator == 0 ? 1 : def.PriceDenominator
                };

                Console.WriteLine($"\n[Definition] {symbol} - {def.Description}");
                Console.WriteLine($"  Price Denominator: {def.PriceDenominator}");
                return;
            }

            // Handle market snapshot - Populate initial state
            if (message.MarketSnapshot != null)
            {
                // Make sure state exists
                if (!MarketStateBySymbol.ContainsKey(symbol))
                    return;

                // Populate initial values
                if (message.MarketSnapshot.Last != null)
                {
                    var price = message.MarketSnapshot.Last.Price;
                    var denominator = MarketStateBySymbol[symbol].PriceDenominator;
                    MarketStateBySymbol[symbol].LastPrice = (decimal)price / denominator;

                    Console.WriteLine($"[Snapshot] {symbol} initialized - Last: {MarketStateBySymbol[symbol].LastPrice}");
                }
                return;
            }

            // Handle market update - Update existing state and log only on change
            if (message.MarketUpdate != null)
            {
                var update = message.MarketUpdate;

                // Make sure state exists (definition and snapshot must arrive first)
                if (!MarketStateBySymbol.ContainsKey(symbol))
                    return; // Silently ignore updates before state is initialized

                // Track if state changed
                var oldPrice = MarketStateBySymbol[symbol].LastPrice;
                var denominator = MarketStateBySymbol[symbol].PriceDenominator;
                decimal? newPrice = null;

                // Update state with new data
                if (update.Trades != null && update.Session?.Last != null)
                {
                    newPrice = (decimal)update.Session.Last.Price / denominator;
                }
                else if (update.Last != null)
                {
                    newPrice = (decimal)update.Last.Price / denominator;
                }

                if (newPrice != null && newPrice != oldPrice)
                {
                    MarketStateBySymbol[symbol].LastPrice = newPrice;
                    Console.WriteLine($"[Update] {symbol} - Last: {newPrice}");
                }
                return;
            }
        }
    }
}
