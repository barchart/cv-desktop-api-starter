#!/usr/bin/env python3
"""
OpenFeed WebSocket Client - Python starter guide.
Connects to OpenFeed server and receives real-time market data.
"""

import os
import sys
from datetime import datetime
from collections import defaultdict

try:
    import openfeed
except ImportError:
    print("Please install openfeed: pip install -r requirements.txt")
    sys.exit(1)

# Configuration
USERNAME = os.environ.get("OPENFEED_USERNAME")
PASSWORD = os.environ.get("OPENFEED_PASSWORD")

if not USERNAME or not PASSWORD:
    print("Missing OPENFEED_USERNAME or OPENFEED_PASSWORD. Set them in your .env file (see README) before running.")
    sys.exit(1)

# Track property occurrences: property name -> count
property_occurrences: dict[str, int] = defaultdict(int)

# Properties to exclude from logging (metadata/noise)
EXCLUDED_PROPS = {
    'marketId', 'symbol', 'transactionTime', 'distributionTime',
    'marketSequence', 'sourceSequence', 'originatorId',
    'priceDenominator', 'regional'
}


def get_message_fields(msg) -> dict:
    """Extract fields from a protobuf message as a dict."""
    result = {}
    for field in msg.DESCRIPTOR.fields:
        value = getattr(msg, field.name, None)
        if value is not None:
            # Check if field has value (for message types, check if it's set)
            if field.message_type:
                if msg.HasField(field.name):
                    result[field.name] = value
            elif value:  # For scalar types, check if non-empty/non-zero
                result[field.name] = value
    return result


def on_message(msg):
    """Handle incoming market messages with property tracking."""
    timestamp = datetime.now().isoformat()
    symbol = getattr(msg, 'symbol', 'UNKNOWN')

    # Determine message type and extract fields
    msg_type = "MESSAGE"
    fields = {}

    if hasattr(msg, 'marketUpdate') and msg.HasField('marketUpdate'):
        msg_type = "MARKET UPDATE"
        fields = get_message_fields(msg.marketUpdate)
    elif hasattr(msg, 'marketSnapshot') and msg.HasField('marketSnapshot'):
        msg_type = "MARKET SNAPSHOT"
        fields = get_message_fields(msg.marketSnapshot)
    elif hasattr(msg, 'subscriptionResponse') and msg.HasField('subscriptionResponse'):
        print(f"Subscription Response: {msg.subscriptionResponse}")
        return
    else:
        # For other message types, just log them
        print("=" * 63)
        print(f"[{symbol}] at {timestamp}")
        print(f"      {msg}")
        return

    # Get all keys excluding metadata
    props = [k for k in fields.keys() if k not in EXCLUDED_PROPS]

    # Track and log properties (first time and every 50th occurrence)
    props_to_log = []
    for prop in props:
        property_occurrences[prop] += 1
        count = property_occurrences[prop]

        # Log on first occurrence OR every 50th occurrence
        if count == 1 or count % 50 == 0:
            props_to_log.append(prop)

    if props_to_log:
        print("=" * 63)
        print(f"[{symbol}] at {timestamp}")
        print(f"\n📊 {msg_type} PROPERTIES: {', '.join(props_to_log)}")

        # Log each property's content with occurrence info
        for prop in props_to_log:
            value = fields.get(prop)
            count = property_occurrences[prop]
            status = "NEW" if count == 1 else f"#{count}"
            print(f"\n   {prop} [{status}]:")
            print(f"      {value}")

        # Show all discovered properties and their counts
        all_props = ", ".join(
            f"{prop}({count})"
            for prop, count in sorted(property_occurrences.items())
        )
        print(f"\n✅ All properties: {all_props}")


def main():
    """Main entry point."""
    print(f"Username: {USERNAME}")

    # Create client with credentials
    of_client = openfeed.OpenfeedClient(USERNAME, PASSWORD)

    # Optional state handlers
    of_client.on_error = lambda x: print(f"Error: {x}")
    of_client.on_connected = lambda x: print("Connected to OpenFeed")
    of_client.on_disconnected = lambda x: print("Disconnected from OpenFeed")

    # Subscribe to symbols
    symbols = ["ESM26"]
    print(f"Subscribing to: {symbols}")

    for symbol in symbols:
        of_client.add_symbol_subscription(symbol, callback=on_message)

    try:
        # Start the client (blocks until interrupted)
        of_client.start()
    except KeyboardInterrupt:
        print("\nShutting down...")


if __name__ == "__main__":
    main()
