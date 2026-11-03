import { DesktopSdk } from "@barchart/desktop-sdk-js";

// Replace with your cmdtyView Desktop API credentials
const wsUrl = "ws://localhost:9000";
const username = "YOUR_USERNAME";
const password = "YOUR_PASSWORD";

const sdk = new DesktopSdk();
sdk.login({ url: wsUrl, username, password });

const symbol = "ESZ26"; 
sdk.subscribeQuote(symbol, {
    onEvent({ kind, instrument, quote, formatted }) {
        console.log(kind, instrument.symbol, formatted.session.last, quote.session.volume);
    },
    onError(error) {
        console.error(error.symbol, error.message);
    },
});

await sdk.whenConnected();
console.log("Connected to the WebSocket server");
