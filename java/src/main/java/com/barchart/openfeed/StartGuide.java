package com.barchart.openfeed;

import org.openfeed.ExchangeResponse;
import org.openfeed.HeartBeat;
import org.openfeed.InstrumentAction;
import org.openfeed.InstrumentDefinition;
import org.openfeed.InstrumentReferenceResponse;
import org.openfeed.InstrumentResponse;
import org.openfeed.ListSubscriptionsResponse;
import org.openfeed.LoginResponse;
import org.openfeed.LogoutResponse;
import org.openfeed.MarketSnapshot;
import org.openfeed.MarketStatus;
import org.openfeed.MarketUpdate;
import org.openfeed.Ohlc;
import org.openfeed.Service;
import org.openfeed.SubscriptionResponse;
import org.openfeed.SubscriptionType;
import org.openfeed.VolumeAtPrice;
import org.openfeed.client.api.OpenfeedClient;
import org.openfeed.client.api.OpenfeedClientEventHandler;
import org.openfeed.client.api.OpenfeedClientHandler;
import org.openfeed.client.api.OpenfeedEvent;
import org.openfeed.client.api.impl.ConnectionStats;
import org.openfeed.client.api.impl.OpenfeedClientConfigImpl;
import org.openfeed.client.api.impl.websocket.OpenfeedClientWebSocket;

import io.netty.channel.ChannelPromise;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.HashMap;
import java.util.Map;

/**
 * OpenFeed Start Guide - Java Edition
 * 
 * Demonstrates market data consumption with state management.
 * Tracks price changes and logs only when prices actually change.
 */
public class StartGuide implements OpenfeedClientEventHandler, OpenfeedClientHandler {

    private static class MarketState {
        int priceDenominator = 1;
        BigDecimal lastPrice = null;
    }

    private final OpenfeedClientWebSocket client;
    // Global state management
    private final Map<String, MarketState> marketState = new HashMap<>();
    private final Map<Long, String> marketIdToSymbol = new HashMap<>();

    public static void main(String[] args) {
        new StartGuide();
    }

    public StartGuide() {
        final OpenfeedClientConfigImpl config = new OpenfeedClientConfigImpl();

        // Replace with your cmdtyView Desktop API credentials
        config.setUserName("YOUR_USERNAME");
        config.setPassword("YOUR_PASSWORD");
        config.setHost("localhost");
        config.setPort(9000);

        client = new OpenfeedClientWebSocket(config, this, this);
        client.connectAndLogin();

        System.out.println("Client started. Press Ctrl+C to exit.");
        registerShutdownHook();
        keepAlive();
    }

    private void registerShutdownHook() {
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            System.out.println("\nShutting down...");
            if (client != null) {
                client.disconnect();
            }
        }));
    }

    private void keepAlive() {
        try {
            Thread.currentThread().join();
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }

    @Override
    public void onLoginResponse(LoginResponse loginResponse) {
        System.out.println("\n LOGIN SUCCESSFUL");

        String[] symbols = { "ZCN26", "ZLN26", "AAPL" };
        System.out.println("Subscribing to: " + String.join(", ", symbols));
        client.subscribe(Service.REAL_TIME, SubscriptionType.ALL, symbols);
    }

    @Override
    public void onLogoutResponse(LogoutResponse logoutResponse) {
        System.out.println("[LOGOUT] " + logoutResponse.getStatus());
    }

    @Override
    public void onSubscriptionResponse(SubscriptionResponse response) {
        System.out.println("[SUBSCRIPTION] " + response.getSymbol() + " - " + response.getStatus());
    }

    @Override
    public void onInstrumentDefinition(InstrumentDefinition definition) {
        String symbol = definition.getSubscriptionSymbol();

        // Initialize state with price denominator
        MarketState state = new MarketState();
        state.priceDenominator = definition.getPriceDenominator();
        marketState.put(symbol, state);

        // Map marketId to symbol for updates (updates use marketId, not symbol)
        marketIdToSymbol.put(definition.getMarketId(), symbol);

        System.out.println("\n[Definition] " + symbol + " - " + definition.getDescription());
        System.out.println("  Price Denominator: " + definition.getPriceDenominator());
    }

    @Override
    public void onMarketSnapshot(MarketSnapshot snapshot) {
        String symbol = marketIdToSymbol.get(snapshot.getMarketId());

        // Make sure state exists
        if (symbol == null || !marketState.containsKey(symbol)) {
            return;
        }

        MarketState state = marketState.get(symbol);

        // Populate initial last price
        if (snapshot.hasLast() && snapshot.getLast().getPrice() != 0) {
            long priceRaw = snapshot.getLast().getPrice();
            state.lastPrice = BigDecimal.valueOf(priceRaw)
                .divide(BigDecimal.valueOf(state.priceDenominator), 6, RoundingMode.HALF_UP);

            System.out.println("[Snapshot] " + symbol + " initialized - Last: " + state.lastPrice);
        }
    }

    @Override
    public void onMarketUpdate(MarketUpdate update) {
        String symbol = marketIdToSymbol.get(update.getMarketId());

        // Make sure state exists (definition and snapshot must arrive first)
        if (symbol == null || !marketState.containsKey(symbol)) {
            return; // Silently ignore updates before state is initialized
        }

        MarketState state = marketState.get(symbol);
        BigDecimal oldPrice = state.lastPrice;
        BigDecimal newPrice = oldPrice;

        // Update state with new data
        // Check for trades with session data first
        if (update.hasTrades() && update.hasSession() &&
            update.getSession().hasLast() && update.getSession().getLast().getPrice() != 0) {
            long priceRaw = update.getSession().getLast().getPrice();
            newPrice = BigDecimal.valueOf(priceRaw)
                .divide(BigDecimal.valueOf(state.priceDenominator), 6, RoundingMode.HALF_UP);
            state.lastPrice = newPrice;
        }
        // Otherwise check for direct last price
        else if (update.hasLast() && update.getLast().getPrice() != 0) {
            long priceRaw = update.getLast().getPrice();
            newPrice = BigDecimal.valueOf(priceRaw)
                .divide(BigDecimal.valueOf(state.priceDenominator), 6, RoundingMode.HALF_UP);
            state.lastPrice = newPrice;
        }

        // Only log if price changed
        if (newPrice != null && !newPrice.equals(oldPrice)) {
            System.out.println("[Update] " + symbol + " - Last: " + newPrice);
        }
    }

    // Minimal implementations for unused handlers
    @Override
    public void onInstrumentResponse(InstrumentResponse response) { }

    @Override
    public void onInstrumentReferenceResponse(InstrumentReferenceResponse response) { }

    @Override
    public void onListSubscriptionsResponse(ListSubscriptionsResponse response) { }

    @Override
    public void setInstrumentPromise(ChannelPromise promise) { }

    @Override
    public void onExchangeResponse(ExchangeResponse response) { }

    @Override
    public void onMarketStatus(MarketStatus status) { }

    @Override
    public void onHeartBeat(HeartBeat hb) { }

    @Override
    public void onVolumeAtPrice(VolumeAtPrice volume) { }

    @Override
    public void onOhlc(Ohlc ohlc) { }

    @Override
    public void onInstrumentAction(InstrumentAction action) { }

    @Override
    public ConnectionStats getConnectionStats() {
        return null;
    }

    @Override
    public void onEvent(OpenfeedClient client, OpenfeedEvent event) {
        if (event.getType() == OpenfeedEvent.EventType.Connected) {
            System.out.println("Connected to OpenFeed");
        } else if (event.getType() == OpenfeedEvent.EventType.Disconnected) {
            System.out.println("Disconnected from OpenFeed");
        }
    }
}
