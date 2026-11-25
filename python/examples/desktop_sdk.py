"""Live quotes, as numbers and formatted the way the instrument is quoted."""

import time

from barchart_desktop_sdk import Credentials, DesktopSdk, Listener, QuoteEvent, SubscriptionError

# Configuration - replace with your cmdtyView Desktop API credentials
USERNAME = "YOUR_USERNAME"
PASSWORD = "YOUR_PASSWORD"
URL = "ws://localhost:9000"


def on_quote(event: QuoteEvent) -> None:
    # `kind` says why this came: `initial`, `snapshot` or `update`
    session = event.formatted.session
    print(event.symbol, event.kind, session.last, event.quote.best_bid_offer.bid_price, event.quote.best_bid_offer.ask_price)


def on_error(error: SubscriptionError) -> None:
    # `result` is what code should decide on; the text is for reading
    print(error.result, error)


with DesktopSdk() as sdk:
    sdk.login(Credentials(url=URL, username=USERNAME, password=PASSWORD))
    subscriptions = [sdk.subscribe_quote(symbol, Listener(on_event=on_quote, on_error=on_error)) for symbol in ("ES*0", "ZC*0")]
    time.sleep(60)

    # The latest state, from any thread, whether or not a listener has seen it yet.
    print(sdk.get_quote("ES*0"))
