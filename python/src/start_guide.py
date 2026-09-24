#!/usr/bin/env python3
"""
OpenFeed WebSocket Client - Python starter guide.
Connects to OpenFeed server and receives real-time market data.
"""

import os
import sys
import urllib.request
from datetime import datetime
from collections import defaultdict

try:
    import openfeed
except ImportError:
    print("Please install openfeed: pip install -r requirements.txt")
    sys.exit(1)

from dotenv import load_dotenv

load_dotenv()  # reads .env from this folder (synced here by setup-env.sh/ps1)

# Configuration
USERNAME = os.environ.get("OPENFEED_USERNAME")
PASSWORD = os.environ.get("OPENFEED_PASSWORD")

# OPENFEED_WS_URL may be given with or without a ws://\wss:// prefix - accept both.
WS_URL = os.environ.get("OPENFEED_WS_URL", "ws://localhost:9000")
SERVER = WS_URL.removeprefix("wss://").removeprefix("ws://")  # bare host:port, what the SDK expects

# The Barchart Desktop application hosts the OpenFeed gateway locally - check
# it's actually running before attempting to connect, for a clearer error.
try:
    urllib.request.urlopen(f"http://{SERVER}/health", timeout=3)
except Exception:
    print(f"Could not reach OpenFeed at {SERVER}.")
    print("Make sure the Barchart Desktop application is running and its Desktop API is set up - see:")
    print("  https://docs.barchart.com/cmdtyview-docs/desktop-api/getting-started/")
    sys.exit(1)

# Create client
client = openfeed.OpenfeedClient(USERNAME, PASSWORD, SERVER)

# Connection state handlers
client.on_connected = lambda _: print("Connected to OpenFeed")
client.on_disconnected = lambda _: print("Disconnected from OpenFeed")
client.on_error = lambda err: print(f"Error: {err}")

# Global state variables
market_state = {}  # Dictionary to store state by symbol (includes price denominator)
marketid_to_symbol = {}  # Maps marketId to symbol (updates use marketId, not symbol)

def on_message(msg):
    """
    Callback for market data messages.

    Message flow after subscribing:
    1. subscriptionResponse - confirmation of subscription
    2. instrumentDefinition - metadata about the instrument
    3. marketSnapshot - complete current state of the market
    4. marketUpdate(s) - real-time incremental changes
    """
    global market_state, marketid_to_symbol

    msg_type = msg.WhichOneof('data')

    # Subscription confirmation
    if msg_type == 'subscriptionResponse':
        response = msg.subscriptionResponse
        print(f"Subscription confirmed: {response.symbol}")
        return

    # Instrument metadata
    elif msg_type == 'instrumentDefinition':
        instrument = msg.instrumentDefinition
        symbol = instrument.subscriptionSymbol

        # Initialize state with price denominator
        market_state[symbol] = {
            'price_denominator': instrument.priceDenominator,
            'last_price': None,
        }

        marketid_to_symbol[instrument.marketId] = symbol
        print(f"\n[Definition] {symbol} - {instrument.description}")
        print(f"  Price Denominator: {instrument.priceDenominator}")
        return

    # Initial market state - Populate state object
    elif msg_type == 'marketSnapshot':
        snapshot = msg.marketSnapshot
        symbol = marketid_to_symbol.get(snapshot.marketId, f"Unknown({snapshot.marketId})")

        # Make sure state exists
        if symbol not in market_state:
            return

        # Populate initial values
        if snapshot.HasField('last') and snapshot.last.price:
            price_denom = market_state[symbol]['price_denominator']
            market_state[symbol]['last_price'] = snapshot.last.price / price_denom

        print(f"[Snapshot] {symbol} initialized - Last: {market_state[symbol]['last_price']}")
        return

    # Real-time updates - Update existing state
    elif msg_type == 'marketUpdate':
        update = msg.marketUpdate
        symbol = marketid_to_symbol.get(update.marketId, f"Unknown({update.marketId})")

        # Make sure state exists (definition and snapshot must arrive first)
        if symbol not in market_state:
            return  # Silently ignore updates before state is initialized

        # Track if state changed
        old_price = market_state[symbol]['last_price']
        price_denom = market_state[symbol]['price_denominator']

        # Update state with new data
        if update.HasField("trades") and update.HasField('session'):
            market_state[symbol]['last_price'] = update.session.last.price / price_denom

        elif update.HasField('last'):
            market_state[symbol]['last_price'] = update.last.price / price_denom

        # Only print if price changed
        new_price = market_state[symbol]['last_price']
        if new_price is not None and new_price != old_price:
            print(f"[Update] {symbol} - Last: {new_price}")

# Subscribe to market data (see SDK documentation for available options)
client.add_symbol_subscription(
    symbol=["ZCH26", "AAPL"],  # Corn, Soybean Oil, Apple stock
    callback=on_message,
    service="REAL_TIME",
    subscription_type=["ALL"]
)

# Start receiving data (blocking call)
client.start()