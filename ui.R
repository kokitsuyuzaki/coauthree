library("shiny")
library("threejs")
library("RSQLite")
library("RColorBrewer")

shinyUI(
  fluidPage(
    # タイトル
    titlePanel("Co-author Network Browser (coauthree)"),

    # レイアウト設定
    sidebarLayout(
      absolutePanel(
        id = "controls",
        class = "panel panel-default",
        fixed = FALSE,
        top = 60,
        left = "auto",
        right = 40,
        bottom = "auto",
        width = 330,
        height = "auto",
        draggable = TRUE,

        textInput(
          "Keyword",
          "Keyword (e.g., iPS cell)"
          ),

        sliderInput(
          "Y",
          "Year published",
          value=c(2000, 2016),
          min = 1867,
          max = 2016,
          step = 1),

        plotOutput("plot1", height=200),

        sliderInput(
          "B",
          "Bar height",
          value=100,
          min = 1,
          max = 500,
          step = 10),

        sliderInput(
          "E",
          "Edge width",
          value = 0.05,
          min = 0.01,
          max = 5,
          step = 0.01),

        # 空白埋め込み
        hr(),

        # 文章埋め込み
        p("Use the mouse zoom to zoom in/out."),
        p("Click and drag to rotate.")
      ),
      # output$globe埋め込み
      mainPanel(
        globeOutput("globe"),
        hr(),

        tabsetPanel(
        tabPanel('result',
          dataTableOutput("mytable1"))
        ),
      hr(),
      p("Copyright (c)", tags$a(href="http://kokitsuyuzaki.github.io", "Koki Tsuyuzaki"), tags$a(hrep="http://bit.riken.jp", "RIKEN ACCC BiT"))
      )
    )
  )
)
