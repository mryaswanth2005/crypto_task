A modern, fast, and beautifully designed cryptocurrency market tracking application built with Flutter and powered by a custom Node.js Proxy Backend.

🌟 Features & Data Used
Since the app is optimized for the Freecryptoapi.com Free Plan, it utilizes exactly the data points available to you:

Live Pricing: Fetches last (Current Price).
24-Hour Range: Displays highest (24h High) and lowest (24h Low).
Daily Performance: Shows daily_change_percentage.
Search & Trending: Quickly search for your favorite coins or discover trending assets from our top 20 list.
Watchlist: Swipe to save coins to your personal watchlist, persisted locally on your device.
Premium UI/UX: Designed with a sleek dark theme, glassmorphic cards, smooth micro-animations, and shimmer loading skeletons.
🏗️ Architecture & Project Structure
This project is split into two main parts:

1. Backend (/backend)
A Node.js/Express server that acts as a caching proxy. It connects to Freecryptoapi.com, caches responses (to prevent rate-limiting), and transforms the data to match the Flutter app's expectations.

server.js: The main Express server containing the API routes and data transformation logic.
package.json: Backend dependencies (express, axios, cors, node-cache, dotenv).
.env: Holds your FREECRYPTO_API_KEY and port configuration.
2. Frontend (/crypto_app)
The Flutter application that handles the user interface and state management.

lib/main.dart: The entry point and theme configuration.
lib/models/: Dart classes (coin.dart, coin_detail.dart, global_data.dart) for parsing JSON.
lib/providers/: State management for fetching coins, handling search, and managing the watchlist.
lib/screens/: The main UI views (home_screen, coin_list_screen, coin_detail_screen, search_screen, watchlist_screen).
lib/services/api_service.dart: Handles HTTP communication with the Node.js backend proxy.
lib/widgets/: Reusable UI components like the coin_tile, stat_card, and shimmer_loading.

<img width="360" height="750" alt="Screenshot 2026-09-07 205943" src="https://github.com/user-attachments/assets/a4daa53c-e4a6-49ca-908c-61f7280535bc" />
<img width="360" height="781" alt="Screenshot 2026-09-07 205821" src="https://github.com/user-attachments/assets/f2ff2502-ae2d-4a1b-830c-f664d853a35b" />
<img width="1915" height="1078" alt="Screenshot 2026-09-07 205807" src="https://github.com/user-attachments/assets/4f433ed6-6309-4b02-af1f-eafdac58417f" />
<img width="607" height="912" alt="Screenshot 2026-09-07 204516" src="https://github.com/user-attachments/assets/0dbe89be-ad70-43c6-a42b-72c6ceb72ba1" />
