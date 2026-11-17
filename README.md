# COVID-19 World Map — Flutter Prototype

A historical Flutter application prototype for exploring COVID-19 case and recovery statistics by country on an interactive world map.

> **Status:** Pandemic-era learning project, last updated in April 2020. This application and its data source are historical and must not be used for current public-health decisions. The original API response and build compatibility have not been verified with current services/toolchains.

## What the app demonstrates

- Fetches a global and country-level COVID-19 summary from the COVID-19 API.
- Displays global confirmed cases, deaths and recovered counts.
- Lets the user search for a country and select it from a searchable dropdown.
- Geocodes the selected country and moves the Google Map camera to its location.
- Displays a map marker and a summary card for the selected country.

## Technology

- Flutter / Dart
- Google Maps Flutter
- Geolocator and Geocoder
- HTTP client and JSON model parsing
- Searchable Dropdown

The UI and labels are in Portuguese.

## Data source

The original implementation requests:

```text
https://api.covid19api.com/summary
```

The app expects a response with `Global` and `Countries` objects, including new and total confirmed cases, deaths and recoveries.

This endpoint was wired into the app in 2020. Its current availability, response contract and data freshness have not been validated. Treat the code as an example of consuming a REST API and rendering geographic data, not as a live or authoritative epidemiological dashboard.

## Project structure

```text
lib/
  main.dart
android/
ios/
test/
pubspec.yaml
```

Most of the prototype is implemented in `lib/main.dart`, including the widgets, HTTP request and JSON models.

## Running the historical project

The original dependency set targets Dart SDK `>=2.1.0 <3.0.0` and includes older Flutter plugins. It may require dependency and platform-project migration before it can run with a current Flutter SDK.

1. Install a compatible Flutter SDK.
2. Run `flutter pub get`.
3. Configure your own restricted Google Maps API key for Android and iOS.
4. Run the app on a simulator or device.

A clean build with a current Flutter toolchain has not been verified.

## Limitations and safety

COVID-19 statistics change over time and historical API summaries can be incomplete or unavailable. This project is not a medical resource. Before reusing the prototype, migrate its dependencies, handle loading and API errors explicitly, verify data provenance and timestamp, and make the last-updated time visible to users.
