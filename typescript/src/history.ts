// Fetch historical data from the cmdtyView Desktop API.

type HistoryResponse = {
  data: {
    timestamps: number[];
    Close: number[];
  };
};

const url = "http://localhost:9000/api/history";

const params = new URLSearchParams({
  symbol: "AAPL",
  aggregation: "daily", // or "tick", "1m", "5m", "weekly", ...
  rangeType: "recordsback",
  records: "50",
});

const response = await fetch(`${url}?${params}`);
const history = (await response.json()) as HistoryResponse;

console.log(`Fetched ${history.data.timestamps.length} records`);
console.log("Last 5 closes:", history.data.Close.slice(-5));
