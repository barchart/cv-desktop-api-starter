// Copyright 2026 Barchart.com, Inc. All rights reserved.
// OpenFeed Start Guide - Go Implementation

package main

import (
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/joho/godotenv"
	"github.com/openfeed-org/sdk-go/openfeed"
)

// MarketState stores state for each symbol
type MarketState struct {
	priceDenominator int32
	lastPrice        *float64
}

// MarketDataHandler manages market state and message handling
type MarketDataHandler struct {
	marketState      map[string]*MarketState
	marketIdToSymbol map[int64]string
}

// NewMarketDataHandler creates a new market data handler
func NewMarketDataHandler() *MarketDataHandler {
	return &MarketDataHandler{
		marketState:      make(map[string]*MarketState),
		marketIdToSymbol: make(map[int64]string),
	}
}

// NewMessage handles all incoming messages
func (h *MarketDataHandler) NewMessage(msg *openfeed.Message) {
	if msg.Message2 == nil {
		return
	}

	switch msg.MessageType {
	case openfeed.MessageType_SUBSCRIPTION_RESPONSE:
		subResp := msg.Message2.GetSubscriptionResponse()
		if subResp != nil {
			fmt.Printf("Subscription confirmed: %s\n", subResp.GetSymbol())
		}

	case openfeed.MessageType_INSTRUMENT_DEFINITION:
		def := msg.Message2.GetInstrumentDefinition()
		if def != nil {
			h.handleInstrumentDefinition(def)
		}

	case openfeed.MessageType_MARKET_SNAPSHOT:
		snapshot := msg.Message2.GetMarketSnapshot()
		if snapshot != nil {
			h.handleMarketSnapshot(snapshot)
		}

	case openfeed.MessageType_MARKET_UPDATE:
		update := msg.Message2.GetMarketUpdate()
		if update != nil {
			h.handleMarketUpdate(update)
		}
	}
}

// handleInstrumentDefinition processes instrument definitions
func (h *MarketDataHandler) handleInstrumentDefinition(def *openfeed.InstrumentDefinition) {
	symbol := def.GetSymbol()
	description := def.GetDescription()
	marketId := def.GetMarketId()
	denominator := def.GetPriceDenominator()

	if denominator == 0 {
		denominator = 1
	}

	h.marketState[symbol] = &MarketState{
		priceDenominator: denominator,
		lastPrice:        nil,
	}

	// Map marketId to symbol for later use in updates
	h.marketIdToSymbol[marketId] = symbol

	fmt.Printf("\n[Definition] %s - %s\n", symbol, description)
	fmt.Printf("  Price Denominator: %d\n", denominator)
}

// handleMarketSnapshot processes market snapshots
func (h *MarketDataHandler) handleMarketSnapshot(snapshot *openfeed.MarketSnapshot) {
	marketId := snapshot.GetMarketId()

	// Get symbol from marketId mapping
	symbol, exists := h.marketIdToSymbol[marketId]
	if !exists {
		return
	}

	// Make sure state exists
	state, exists := h.marketState[symbol]
	if !exists {
		return
	}

	// Populate initial values
	if snapshot.Last != nil {
		priceRaw := float64(snapshot.Last.GetPrice())
		price := priceRaw / float64(state.priceDenominator)
		state.lastPrice = &price

		fmt.Printf("[Snapshot] %s initialized - Last: %.4f\n", symbol, price)
	}
}

// handleMarketUpdate processes market updates
func (h *MarketDataHandler) handleMarketUpdate(update *openfeed.MarketUpdate) {
	marketId := update.GetMarketId()

	// Get symbol from marketId mapping
	symbol, exists := h.marketIdToSymbol[marketId]
	if !exists {
		return
	}

	// Make sure state exists
	state, exists := h.marketState[symbol]
	if !exists {
		return
	}

	// Track old price
	var oldPrice *float64
	if state.lastPrice != nil {
		oldPriceCopy := *state.lastPrice
		oldPrice = &oldPriceCopy
	}

	var newPrice *float64

	// Update state with new data - check session first, then last
	if update.Session != nil && update.Session.Last != nil {
		priceRaw := float64(update.Session.Last.GetPrice())
		price := priceRaw / float64(state.priceDenominator)
		newPrice = &price
		state.lastPrice = newPrice
	}

	// Only log if price changed
	if newPrice != nil && (oldPrice == nil || *newPrice != *oldPrice) {
		fmt.Printf("[Update] %s - Last: %.4f\n", symbol, *newPrice)
	}
}

func main() {
	log.SetOutput(log.Writer())
	_ = godotenv.Load() // reads .env from this process's working directory

	username := os.Getenv("OPENFEED_USERNAME")
	password := os.Getenv("OPENFEED_PASSWORD")
	if username == "" || password == "" {
		log.Fatal("Missing OPENFEED_USERNAME or OPENFEED_PASSWORD. Set them in your .env file (see README) before running.")
	}

	wsURL := os.Getenv("OPENFEED_WS_URL")
	if wsURL == "" {
		wsURL = "ws://localhost:9000"
	}
	// SDK expects a bare host:port, not a URL scheme
	wsURL = strings.TrimPrefix(strings.TrimPrefix(wsURL, "wss://"), "ws://")

	// Create connection
	conn := openfeed.NewConnection(openfeed.Credentials{
		Username: username,
		Password: password,
	}, wsURL)

	// Create message handler
	handler := NewMarketDataHandler()
	hnd := openfeed.MessageHandler(handler)

	// Subscribe to symbols
	symbols := []string{"AAPL", "ZCZ26"}
	subRequest := openfeed.SubRequest{
		Service: "REAL_TIME",
		Symbols: symbols,
	}

	conn.AddSymbolSubscription(symbols, &hnd, &subRequest)

	fmt.Println("Connected to OpenFeed")

	// Start the connection
	err := conn.Start()
	if err != nil {
		log.Fatalf("Error: %v", err)
	}
}
