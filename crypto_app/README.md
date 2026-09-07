# CryptoScope 🚀

A modern, fast, and beautifully designed cryptocurrency market tracking application built with **Flutter** and powered by a custom **Node.js Proxy Backend**. 

## 🌟 Features & Data Used
Since the app is optimized for the **Freecryptoapi.com Free Plan**, it utilizes exactly the data points available to you:
- **Live Pricing**: Fetches `last` (Current Price).
- **24-Hour Range**: Displays `highest` (24h High) and `lowest` (24h Low).
- **Daily Performance**: Shows `daily_change_percentage`.
- **Search & Trending**: Quickly search for your favorite coins or discover trending assets from our top 20 list.
- **Watchlist**: Swipe to save coins to your personal watchlist, persisted locally on your device.
- **Premium UI/UX**: Designed with a sleek dark theme, glassmorphic cards, smooth micro-animations, and shimmer loading skeletons.

## 🏗️ Architecture & Project Structure
This project is split into two main parts:

### 1. Backend (`/backend`)
A Node.js/Express server that acts as a caching proxy. It connects to **Freecryptoapi.com**, caches responses (to prevent rate-limiting), and transforms the data to match the Flutter app's expectations.
- `server.js`: The main Express server containing the API routes and data transformation logic.
- `package.json`: Backend dependencies (express, axios, cors, node-cache, dotenv).
- `.env`: Holds your `FREECRYPTO_API_KEY` and port configuration.

### 2. Frontend (`/crypto_app`)
The Flutter application that handles the user interface and state management.
- `lib/main.dart`: The entry point and theme configuration.
- `lib/models/`: Dart classes (`coin.dart`, `coin_detail.dart`, `global_data.dart`) for parsing JSON.
- `lib/providers/`: State management for fetching coins, handling search, and managing the watchlist.
- `lib/screens/`: The main UI views (`home_screen`, `coin_list_screen`, `coin_detail_screen`, `search_screen`, `watchlist_screen`).
- `lib/services/api_service.dart`: Handles HTTP communication with the Node.js backend proxy.
- `lib/widgets/`: Reusable UI components like the `coin_tile`, `stat_card`, and `shimmer_loading`.

---

## 🚀 Getting Started

### Prerequisites
- [Node.js](https://nodejs.org/) (v16+)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable)
- A [Freecryptoapi.com](https://freecryptoapi.com/) API Key (Note: The Free Plan has limitations, such as no historical charts or coin logos).

---

### 1. Starting the Backend Proxy

The Flutter app expects the backend to be running locally on port `3000`.

1. Open a terminal and navigate to the `backend` directory:
   ```bash
   cd backend
   ```
2. Install the dependencies:
   ```bash
   npm install
   ```
3. Configure your environment variables. Ensure the `.env` file exists with your API key:
   ```env
   PORT=3000
   FREECRYPTO_API_KEY=your_api_key_here
   ```
4. Start the server:
   ```bash
   npm start
   ```
   *You should see a message indicating the server is running on `http://localhost:3000`.*

---

### 2. Running the Flutter App

Once the backend is running, you can launch the Flutter application.

1. Open a new terminal and navigate to the `crypto_app` directory:
   ```bash
   cd crypto_app
   ```
2. Get the Flutter packages:
   ```bash
   flutter pub get
   ```
3. Run the app on your preferred device (Chrome/Web is recommended for desktop testing without native toolchains):
   ```bash
   flutter run -d chrome
   ```
   *Note: If you are running on an Android Emulator, you may need to change the `_baseUrl` in `lib/services/api_service.dart` from `127.0.0.1` to `10.0.2.2`.*

---

## 🛠️ Tech Stack
- **Flutter**: Dart, Provider, fl_chart, cached_network_image, shared_preferences, shimmer.
- **Node.js**: Express, Axios, Node-Cache, dotenv, cors.
- **API**: Freecryptoapi.com

## 📝 API Limitations Note
This app is currently configured to use the **Free Plan** of Freecryptoapi.com. Because of the restrictions on this tier:
- The app fetches a hardcoded list of the 20 most popular coins instead of a dynamic "Top Market Cap" list.
- Coin logos, market cap, total volume, circulating supply, and historical chart timelines are hidden/faked, as the API does not provide this data on the free tier.
