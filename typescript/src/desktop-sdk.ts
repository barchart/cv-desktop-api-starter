import "dotenv/config"; // reads .env from this process's working directory
import { DesktopSdk } from "@barchart/desktop-sdk-js";

const wsUrl = process.env.OPENFEED_WS_URL || "ws://localhost:9000";
const username = process.env.OPENFEED_USERNAME;
const password = process.env.OPENFEED_PASSWORD;

if (!username || !password) {
    throw new Error("Missing OPENFEED_USERNAME or OPENFEED_PASSWORD environment variables");
}

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
