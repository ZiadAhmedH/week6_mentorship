# Week6 Task — Movies App

Lightweight Flutter app that shows popular movies (TMDB) with pagination, offline cache, logging and Sentry integration. Designed with clean separation: data / domain / presentation, BLoC (Cubit) for state, and a MoviePaginator use-case to keep pagination logic out of the UI.

---

## Screenshots

Replace these placeholders with real screenshots in `docs/screenshots/`:

- Movies grid (home)
  
  ![Movies Grid](docs/screenshots/movies_grid.png)

- Movie details (Netflix-like UI)
  
  ![Movie Details](docs/screenshots/movie_details.png)

- Offline cached banner / snackbar
  
  ![Offline Banner](docs/screenshots/offline_banner.png)

---

## Features

- Fetch popular movies from TMDB API
- Domain-layer pagination using `MoviePaginator` (CUBIT does not manage page state)
- Offline cache per-page (Hive); stale-fallback when network unavailable
- AppLogger (console + optional external handler)
- Sentry integration via `SentryService` helper and `SentryException` wrapper
- Simple theme switcher (dark / light) via `ThemeCubit`
- Clean UI:
  - MoviesView (BlocProvider) -> MovieBodyView (grid with pull-to-refresh and infinite scroll)
  - MovieDetailsView (simple Netflix-like layout)
  - Reusable `MovieCard` using `cached_network_image`
- Snackbars for transient network/fallback messages
- Service locator with `get_it`

---

## Architecture (high level)

- features/
  - movies/
    - data/ (remote/local/data models, repo impl)
    - domain/ (entities, repo interface, use-cases like `MoviePaginator`)
    - presentation/ (cubit, views, widgets)
- core/
  - service locator, app logger, sentry wrapper, theme

Key design choices:
- Repository returns `PaginatedMovies` with `isFromCache` flag
- `MoviePaginator` handles page state & merging
- UI (`MovieBodyView`) consumes `MovieState` and shows cached banner/snackbar on fallback

---

## Getting started

Prerequisites:
- Flutter SDK (tested on stable 3.7+ / adjust for your setup)
- Android/iOS toolchain configured
- A TMDB API token (v4 Bearer) and optional Sentry DSN

1. Clone and open project:
   git clone <repo>
   cd week6_task

2. Create `.env` file in project root:
