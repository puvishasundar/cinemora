# =============================================================
# CINEMORA — A Premium Streaming Catalog Browser (R Shiny)
# =============================================================
# Development Question:
# How can a responsive data grid be constructed from a movie
# master data frame that allows users to apply complex row-
# slicing logic and dynamically append a custom engagement
# metric column?
# =============================================================

library(shiny)
library(DT)
library(dplyr)
library(ggplot2)

# ---------------------------------------------------------------
# 1. LOAD DATA
# ---------------------------------------------------------------
movies <- read.csv("movies.csv", stringsAsFactors = FALSE)

movies <- movies %>%
  mutate(
    Rating       = as.numeric(Rating),
    Release_Year = as.integer(Release_Year),
    Views        = as.numeric(Views),      # in thousands
    Reviews      = as.numeric(Reviews),
    Runtime      = as.integer(Runtime)
  )

genre_choices <- c("All Genres", sort(unique(movies$Genre)))

# ---------------------------------------------------------------
# 2. UI
# ---------------------------------------------------------------
ui <- tagList(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel = "preconnect", href = "https://fonts.googleapis.com"),
    tags$title("CINEMORA — Stories Beyond Imagination")
  ),

  # ---------------- NAVBAR ----------------
  div(class = "navbar-cinemora",
      div(class = "brand", "CINE", span("MORA")),
      div(class = "nav-links",
          tags$a(href = "#hero", "Home"),
          tags$a(href = "#featured", "Featured"),
          tags$a(href = "#catalog", "Catalog"),
          tags$a(href = "#insights", "Insights")
      )
  ),

  # ---------------- HERO ----------------
  div(id = "hero", class = "hero",
      div(class = "hero-badge", "PREMIUM STREAMING CATALOG"),
      h1(class = "hero-title", "CINEMORA"),
      p(class = "hero-tagline", "Discover stories beyond imagination."),
      div(class = "hero-cta",
          tags$a(href = "#catalog",
                 tags$button(class = "btn-explore", "EXPLORE THE COLLECTION →"))
      ),
      div(class = "hero-scroll", "↓ SCROLL")
  ),

  # ---------------- FEATURED SECTION ----------------
  div(id = "featured", class = "section-wrap",
      div(class = "section-title", "HAND-PICKED"),
      div(class = "section-heading", "Featured Tonight"),
      div(class = "featured-row", uiOutput("featured_ui"))
  ),

  # ---------------- CATALOG / EXPLORE SECTION ----------------
  div(id = "catalog", class = "section-wrap",
      div(class = "section-title", "EXPLORE"),
      div(class = "section-heading", "The Full Catalog"),

      # ---- Filter Panel ----
      div(class = "filter-panel",
          fluidRow(
            column(3,
                   tags$label("Search Movies"),
                   textInput("search", NULL, placeholder = "🔍 Search by title...")
            ),
            column(3,
                   tags$label("Genre"),
                   selectInput("genre", NULL, choices = genre_choices, selected = "All Genres")
            ),
            column(3,
                   tags$label(paste0("Release Year")),
                   sliderInput("year", NULL,
                               min = min(movies$Release_Year), max = max(movies$Release_Year),
                               value = c(min(movies$Release_Year), max(movies$Release_Year)),
                               sep = "")
            ),
            column(3,
                   tags$label("Minimum Rating"),
                   sliderInput("rating", NULL, min = 0, max = 10,
                               value = 0, step = 0.1)
            )
          ),
          fluidRow(
            column(6,
                   checkboxInput("calc_pop", "☑ Calculate Popularity (adds Engagement Score)", value = FALSE)
            ),
            column(3,
                   tags$label("View"),
                   radioButtons("view_mode", NULL,
                                choices = c("Cards" = "cards", "Table" = "table"),
                                selected = "cards", inline = TRUE)
            ),
            column(3, style = "text-align:right; padding-top: 22px;",
                   actionButton("reset_filters", "↺ RESET FILTERS", class = "btn-reset")
            )
          )
      ),

      # ---- Results count ----
      uiOutput("results_count"),

      # ---- Card grid or table ----
      conditionalPanel(
        condition = "input.view_mode == 'cards'",
        uiOutput("movie_grid")
      ),
      conditionalPanel(
        condition = "input.view_mode == 'table'",
        DTOutput("movie_table")
      )
  ),

  # ---------------- INSIGHTS SECTION ----------------
  div(id = "insights", class = "section-wrap",
      div(class = "section-title", "ANALYTICS"),
      div(class = "section-heading", "Catalog Insights"),
      uiOutput("insight_cards"),
      plotOutput("genre_chart", height = "380px")
  ),

  # ---------------- FOOTER ----------------
  div(class = "footer-cinemora",
      div(class = "brand", "CINEMORA"),
      p("Stories beyond imagination. Built with R & Shiny for academic demonstration."),
      p(paste0("© ", format(Sys.Date(), "%Y"), " Cinemora. A fictional streaming brand — not affiliated with any real platform."))
  ),

  # ---------------- JS: card click -> Shiny input ----------------
  tags$script(HTML("
    Shiny.addCustomMessageHandler('scrollTop', function(x) { window.scrollTo(0,0); });
    function cinemoraSelect(id) {
      Shiny.setInputValue('selected_movie', id, {priority: 'event'});
    }
  "))
)

# ---------------------------------------------------------------
# 3. SERVER
# ---------------------------------------------------------------
server <- function(input, output, session) {

  # ---- Reset filters ----
  observeEvent(input$reset_filters, {
    updateTextInput(session, "search", value = "")
    updateSelectInput(session, "genre", selected = "All Genres")
    updateSliderInput(session, "year", value = c(min(movies$Release_Year), max(movies$Release_Year)))
    updateSliderInput(session, "rating", value = 0)
    updateCheckboxInput(session, "calc_pop", value = FALSE)
  })

  # ---- Core reactive filtering (row-slicing logic) ----
  filtered_movies <- reactive({
    df <- movies

    # Search filter (string matching on Title)
    if (nzchar(trimws(input$search))) {
      df <- df[grepl(trimws(input$search), df$Title, ignore.case = TRUE), ]
    }

    # Genre filter
    if (input$genre != "All Genres") {
      df <- df[df$Genre == input$genre, ]
    }

    # Release year slider filter
    df <- df[df$Release_Year >= input$year[1] & df$Release_Year <= input$year[2], ]

    # Rating filter
    df <- df[df$Rating >= input$rating, ]

    df
  })

  # ---- Popularity calculation (mutation) ----
  # Engagement Score (0-100), normalized blend of rating, views, reviews
  display_movies <- reactive({
    df <- filtered_movies()

    if (input$calc_pop && nrow(df) > 0) {
      max_views   <- max(movies$Views, na.rm = TRUE)
      max_reviews <- max(movies$Reviews, na.rm = TRUE)

      df <- df %>%
        mutate(
          Popularity = round(
            (Rating / 10) * 40 +                       # 40% weight: rating
            (Views / max_views) * 35 +                  # 35% weight: views
            (Reviews / max_reviews) * 25,                # 25% weight: reviews
            1
          )
        )
      df$Popularity <- pmin(df$Popularity, 100)
    }
    df
  })

  # ---- Results count ----
  output$results_count <- renderUI({
    n <- nrow(display_movies())
    div(class = "results-count", HTML(paste0("<b>", n, "</b> movies found")))
  })

  # ---- Featured carousel (top rated, static-ish selection) ----
  output$featured_ui <- renderUI({
    top <- movies %>% arrange(desc(Rating)) %>% head(10)
    tagList(lapply(seq_len(nrow(top)), function(i) {
      m <- top[i, ]
      div(class = "featured-card", onclick = sprintf("cinemoraSelect(%d)", m$Movie_ID),
          tags$img(src = file.path("posters", m$Image)),
          div(class = "card-rating", paste0("★ ", m$Rating)),
          div(class = "card-body",
              div(class = "card-title", m$Title),
              div(class = "card-meta", paste0(m$Genre, " • ", m$Release_Year))
          )
      )
    }))
  })

  # ---- Movie card grid ----
  output$movie_grid <- renderUI({
    df <- display_movies()
    if (nrow(df) == 0) {
      return(div(style = "text-align:center; padding:60px; color:#7a89a8;",
                  h3("No movies match your filters."),
                  p("Try adjusting the search, genre, year, or rating filters.")))
    }

    max_pop <- if ("Popularity" %in% names(df)) max(df$Popularity, na.rm = TRUE) else 100

    div(class = "movie-grid",
        lapply(seq_len(nrow(df)), function(i) {
          m <- df[i, ]
          pop_ui <- NULL
          if ("Popularity" %in% names(df)) {
            pop_ui <- div(class = "card-pop",
                           div(class = "pop-bar-bg",
                               div(class = "pop-bar-fill", style = paste0("width:", m$Popularity, "%;"))),
                           div(class = "pop-score", paste0(m$Popularity)))
          }
          div(class = "movie-card", onclick = sprintf("cinemoraSelect(%d)", m$Movie_ID),
              tags$img(src = file.path("posters", m$Image)),
              div(class = "card-rating", paste0("★ ", m$Rating)),
              div(class = "card-body",
                  div(class = "card-title", m$Title),
                  div(class = "card-meta", paste0(m$Genre, " • ", m$Release_Year, " • ", m$Runtime, " min")),
                  pop_ui
              )
          )
        })
    )
  })

  # ---- Dynamic Data Table ----
  output$movie_table <- renderDT({
    df <- display_movies()
    cols <- c("Title", "Genre", "Release_Year", "Rating", "Views", "Reviews", "Runtime", "Director")
    if ("Popularity" %in% names(df)) cols <- c(cols, "Popularity")
    df_show <- df[, cols]
    names(df_show) <- c("Title", "Genre", "Year", "Rating", "Views (K)", "Reviews", "Runtime", "Director",
                         if ("Popularity" %in% names(df)) "Engagement Score")

    datatable(
      df_show,
      options = list(pageLength = 10, autoWidth = TRUE, dom = "ftip"),
      rownames = FALSE,
      class = "display"
    )
  })

  # ---- Movie details modal ----
  observeEvent(input$selected_movie, {
    m <- movies[movies$Movie_ID == input$selected_movie, ]
    if (nrow(m) == 0) return()

    pop_line <- NULL
    df_pop <- display_movies()
    if ("Popularity" %in% names(df_pop) && input$selected_movie %in% df_pop$Movie_ID) {
      score <- df_pop$Popularity[df_pop$Movie_ID == input$selected_movie]
      pop_line <- tags$p(tags$b("Engagement Score: "), paste0(score, " / 100"))
    }

    showModal(modalDialog(
      title = toupper(m$Title),
      size = "m",
      easyClose = TRUE,
      footer = modalButton("Close"),
      div(style = "display:flex; gap:20px; flex-wrap:wrap;",
          tags$img(src = file.path("posters", m$Image), style = "width:180px; border-radius:10px;"),
          div(style = "flex:1; min-width:220px;",
              p(paste0(m$Release_Year, " • ", m$Genre, " • ", m$Runtime, " min • ", m$Language)),
              p(HTML(paste0("⭐ <b>", m$Rating, " / 10</b>"))),
              p(m$Description),
              tags$hr(style = "border-color: rgba(255,255,255,0.1);"),
              p(tags$b("Director: "), m$Director),
              p(tags$b("Views: "), paste0(format(m$Views, big.mark = ","), "K")),
              p(tags$b("Reviews: "), format(m$Reviews, big.mark = ",")),
              pop_line
          )
      )
    ))
  })

  # ---- Insights: summary cards ----
  output$insight_cards <- renderUI({
    df <- movies
    div(class = "insight-grid",
        div(class = "insight-card",
            div(class = "insight-number", nrow(df)),
            div(class = "insight-label", "Total Movies")),
        div(class = "insight-card",
            div(class = "insight-number", length(unique(df$Genre))),
            div(class = "insight-label", "Genres")),
        div(class = "insight-card",
            div(class = "insight-number", min(df$Release_Year)),
            div(class = "insight-label", "Oldest Release")),
        div(class = "insight-card",
            div(class = "insight-number", max(df$Rating)),
            div(class = "insight-label", "Highest Rating")),
        div(class = "insight-card",
            div(class = "insight-number", round(mean(df$Rating), 1)),
            div(class = "insight-label", "Average Rating"))
    )
  })

  # ---- Insights: chart (Average Rating by Genre) ----
  output$genre_chart <- renderPlot({
    summary_df <- movies %>%
      group_by(Genre) %>%
      summarise(Avg_Rating = mean(Rating), Count = n()) %>%
      arrange(desc(Avg_Rating))

    ggplot(summary_df, aes(x = reorder(Genre, Avg_Rating), y = Avg_Rating)) +
      geom_col(fill = "#4da3ff", width = 0.6) +
      geom_text(aes(label = Avg_Rating), hjust = -0.15, color = "#e8eefc", size = 4) +
      coord_flip(clip = "off") +
      labs(x = NULL, y = "Average Rating", title = "Average Rating by Genre") +
      theme_minimal(base_size = 14) +
      theme(
        plot.background  = element_rect(fill = "#05070d", color = NA),
        panel.background = element_rect(fill = "#05070d", color = NA),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(color = "#1a2540"),
        panel.grid.minor = element_blank(),
        plot.title = element_text(color = "#f2f5fb", face = "bold", size = 16, hjust = 0.5),
        axis.text = element_text(color = "#b7c3da"),
        axis.title = element_text(color = "#b7c3da"),
        plot.margin = margin(10, 40, 10, 10)
      ) +
      ylim(0, max(summary_df$Avg_Rating) + 0.8)
  }, bg = "transparent")

}

# ---------------------------------------------------------------
# 4. RUN APP
# ---------------------------------------------------------------
shinyApp(ui = ui, server = server)
