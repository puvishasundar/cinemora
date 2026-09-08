# 🎬 CINEMORA — Premium Streaming Catalog Browser (R Shiny)

## What's inside
```
cinemora/
├── app.R              → the Shiny application (UI + server)
├── movies.csv          → dataset of 50 movies
├── www/
│   ├── style.css        → blue "luxury cinema" theme
│   └── posters/          → 50 generated poster images (one per movie)
└── README.md
```

## How to run
1. Open **RStudio**.
2. Install required packages (only once):
   ```r
   install.packages(c("shiny", "DT", "dplyr", "ggplot2"))
   ```
3. Open the `cinemora` folder as your working directory (or open `app.R` directly — RStudio will show a **Run App** button).
4. Click **Run App**, or run:
   ```r
   shiny::runApp("cinemora")
   ```

## Features included
- Cinematic hero landing section with animated entrance
- Featured Tonight carousel (top 10 rated movies)
- Search by title, Genre dropdown, Release Year slider, Minimum Rating slider
- "Calculate Popularity" checkbox → dynamically **mutates** the data with a new
  `Popularity` (Engagement Score) column, computed from Rating + Views + Reviews,
  normalized to 0–100
- Two views: **Card gallery** (with poster, rating badge, popularity bar) and
  **Dynamic Data Table** (DT), both driven by the same filtered/mutated reactive data
- Click any card to open a **Movie Details modal** (poster, description, stats)
- Catalog Insights section: total movies, genres, oldest release, highest &
  average rating, plus a ggplot2 bar chart of **Average Rating by Genre**
- Reset Filters button
- Fully responsive, dark-blue "luxury cinema" visual theme with hover/scroll
  animations — all built with base Shiny + custom CSS (no external frameworks)

## Notes on the dataset & images
- `movies.csv` uses real movie **titles, years, genres, and directors** (these are
  facts, not copyrighted expression) paired with **synthetic** ratings/views/
  reviews and **original one-line descriptions** written for this project — not
  copied from any source.
- All 50 poster images in `www/posters/` are **procedurally generated** placeholder
  artwork (gradient + title card, matching the blue Cinemora theme) — not real
  movie posters — so there are no image-licensing concerns. You're welcome to
  swap in your own poster images later: just keep the same filenames listed in
  the `Image` column of `movies.csv`.

## For your viva — mapping features → R/Shiny concepts
| Feature            | R / Shiny Concept                     |
|---------------------|----------------------------------------|
| Loading the catalog  | `read.csv()`, `data.frame`             |
| Search box            | String filtering with `grepl()`        |
| Genre dropdown         | Conditional row filtering              |
| Year slider              | `sliderInput()` + reactive filtering   |
| Rating slider              | Logical condition (`>=`)              |
| Multiple filters combined   | Sequential `&`-style row slicing     |
| Popularity checkbox           | Conditional `mutate()`               |
| Card grid / table update        | Reactive expressions (`reactive()`)|
| Movie details modal               | `showModal()` + custom JS input   |
| Insights & chart                    | `dplyr` summarise + `ggplot2`   |
