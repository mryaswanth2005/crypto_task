require('dotenv').config();
const express = require('express');
const axios = require('axios');
const NodeCache = require('node-cache');
const cors = require('cors');

const app = express();
const cache = new NodeCache({ stdTTL: 60, checkperiod: 120 }); // 1 min cache

app.use(cors());
app.use(express.json());

const PORT = process.env.PORT || 3000;
const API_KEY = process.env.FREECRYPTO_API_KEY;
const BASE_URL = 'https://api.freecryptoapi.com/v1';

// Hardcoded list of popular coins since Free Plan doesn't support /getTop
const POPULAR_SYMBOLS = [
  'BTC', 'ETH', 'USDT', 'BNB', 'SOL', 'USDC', 'XRP', 'DOGE', 'TON', 'ADA',
  'SHIB', 'AVAX', 'TRX', 'DOT', 'BCH', 'LINK', 'MATIC', 'LTC', 'NEAR', 'ICP'
];

// ---------- helpers ----------

function buildHeaders() {
  const headers = { 'Accept': 'application/json' };
  if (API_KEY) {
    headers['Authorization'] = `Bearer ${API_KEY}`;
  }
  return headers;
}

async function cachedGet(cacheKey, url, ttl = 60) {
  const cached = cache.get(cacheKey);
  if (cached) {
    return { source: 'cache', data: cached };
  }
  try {
    const response = await axios.get(url, {
      headers: buildHeaders(),
      timeout: 15000,
    });
    cache.set(cacheKey, response.data, ttl);
    return { source: 'api', data: response.data };
  } catch (error) {
    console.error(`Error fetching ${url}:`, error.message);
    throw error;
  }
}

// Convert Freecryptoapi format to CoinGecko-like format for the frontend
function mapToCoinGeckoFormat(fcCoin) {
  const symbol = fcCoin.symbol.toLowerCase();
  return {
    id: symbol,
    symbol: symbol,
    name: fcCoin.symbol, // We don't have full names
    image: null, // No image provided
    current_price: parseFloat(fcCoin.last || 0),
    market_cap: null, // Not provided
    market_cap_rank: null,
    fully_diluted_valuation: null,
    total_volume: null,
    high_24h: parseFloat(fcCoin.highest || 0),
    low_24h: parseFloat(fcCoin.lowest || 0),
    price_change_24h: null,
    price_change_percentage_24h: parseFloat(fcCoin.daily_change_percentage || 0),
    market_cap_change_24h: null,
    market_cap_change_percentage_24h: null,
    circulating_supply: null,
    total_supply: null,
    max_supply: null,
    ath: parseFloat(fcCoin.highest || 0),
    ath_change_percentage: null,
    ath_date: null,
    atl: parseFloat(fcCoin.lowest || 0),
    atl_change_percentage: null,
    atl_date: null,
    roi: null,
    last_updated: fcCoin.date,
    sparkline_in_7d: {
      // Fake sparkline data to prevent flutter chart crash
      price: [parseFloat(fcCoin.lowest || 0), parseFloat(fcCoin.last || 0), parseFloat(fcCoin.highest || 0), parseFloat(fcCoin.last || 0)]
    }
  };
}

// ---------- routes ----------

app.get('/', (req, res) => {
  res.json({ status: 'ok', service: 'cryptoscope-backend' });
});

// GET /api/coins/markets
app.get('/api/coins/markets', async (req, res) => {
  try {
    const symbolString = POPULAR_SYMBOLS.join('+');
    const result = await cachedGet('markets', `${BASE_URL}/getData?symbol=${symbolString}`, 60);
    
    if (result.data.status === 'success' && result.data.symbols) {
      const mapped = result.data.symbols.map(mapToCoinGeckoFormat);
      res.json(mapped);
    } else {
      res.status(500).json({ error: 'Failed to parse Freecryptoapi response' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error fetching markets data' });
  }
});

// GET /api/coins/:id
app.get('/api/coins/:id', async (req, res) => {
  try {
    const id = req.params.id.toUpperCase();
    const result = await cachedGet(`coin_${id}`, `${BASE_URL}/getData?symbol=${id}`, 60);
    
    if (result.data.status === 'success' && result.data.symbols && result.data.symbols.length > 0) {
      const fcCoin = result.data.symbols[0];
      const mapped = mapToCoinGeckoFormat(fcCoin);
      
      // Add extra detail fields
      mapped.description = { en: "Description not available on free tier." };
      mapped.links = { homepage: [] };
      mapped.market_data = {
        current_price: { usd: mapped.current_price },
        market_cap: { usd: null },
        total_volume: { usd: null },
        high_24h: { usd: mapped.high_24h },
        low_24h: { usd: mapped.low_24h },
        price_change_percentage_24h: mapped.price_change_percentage_24h,
        circulating_supply: null,
        total_supply: null,
        max_supply: null,
        ath: { usd: mapped.ath },
        atl: { usd: mapped.atl },
      };
      
      res.json(mapped);
    } else {
      res.status(404).json({ error: 'Coin not found' });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error fetching coin details' });
  }
});

// GET /api/coins/:id/market_chart
app.get('/api/coins/:id/market_chart', async (req, res) => {
  // Freecryptoapi doesn't give us history easily, return fake data
  // so the UI doesn't break.
  const prices = [];
  const now = Date.now();
  for (let i = 0; i < 24; i++) {
    prices.push([now - (24 - i) * 3600000, 100 + Math.random() * 10]); // Fake prices
  }
  res.json({ prices, market_caps: [], total_volumes: [] });
});

// GET /api/search
app.get('/api/search', async (req, res) => {
  try {
    const query = req.query.query ? req.query.query.toUpperCase() : '';
    if (!query) return res.json({ coins: [] });
    
    const symbolString = POPULAR_SYMBOLS.join('+');
    const result = await cachedGet('markets', `${BASE_URL}/getData?symbol=${symbolString}`, 60);
    
    if (result.data.status === 'success' && result.data.symbols) {
      const filtered = result.data.symbols.filter(c => c.symbol.includes(query));
      const mapped = filtered.map(c => ({
        id: c.symbol.toLowerCase(),
        name: c.symbol,
        symbol: c.symbol.toLowerCase(),
        thumb: null
      }));
      res.json({ coins: mapped });
    } else {
      res.json({ coins: [] });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error searching' });
  }
});

// GET /api/search/trending
app.get('/api/search/trending', async (req, res) => {
  try {
    // Just return top 5 of our popular list
    const symbolString = POPULAR_SYMBOLS.slice(0, 5).join('+');
    const result = await cachedGet('trending', `${BASE_URL}/getData?symbol=${symbolString}`, 300);
    
    if (result.data.status === 'success' && result.data.symbols) {
      const mapped = result.data.symbols.map(c => ({
        item: {
          id: c.symbol.toLowerCase(),
          name: c.symbol,
          symbol: c.symbol.toLowerCase(),
          thumb: null,
          data: { price: c.last }
        }
      }));
      res.json({ coins: mapped });
    } else {
      res.json({ coins: [] });
    }
  } catch (error) {
    res.status(500).json({ error: 'Error fetching trending' });
  }
});

// GET /api/global
app.get('/api/global', async (req, res) => {
  // Freecryptoapi doesn't provide global data on free tier
  res.json({
    data: {
      active_cryptocurrencies: null,
      markets: null,
      total_market_cap: { usd: null },
      total_volume: { usd: null },
      market_cap_percentage: { btc: null, eth: null },
      market_cap_change_percentage_24h_usd: null
    }
  });
});

app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', using_freecryptoapi: true });
});

app.listen(PORT, () => {
  console.log(`🚀 CryptoScope backend running on http://localhost:${PORT}`);
  console.log(`   Using Freecryptoapi.com with API Key: ${API_KEY ? 'configured' : 'NOT SET'}`);
});
