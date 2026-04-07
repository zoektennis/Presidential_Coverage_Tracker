# ============================================================
# Trump Coverage Tracker — Shiny App (ShinyLive compatible)
# ============================================================

library(shiny)
library(dplyr)
library(lubridate)
library(scales)
library(plotly)
library(zoo)

CHUNKS_PATH <- "trump_performance_chunks.csv"

CBS_SHOWS   <- c("CBS Evening News", "CBS News Mornings", "Face the Nation",
                 "CBS Evening News Plus", "CBS Evening News With Norah O'Donnell",
                 "CBS Overnight News", "CBS News Sunday Morning", "60 Minutes",
                 "The Late Show with Stephen Colbert", "CBS News Roundup",
                 "CBS Weekend News", "CBS Morning News")
CNN_SHOWS   <- c("CNN News Central", "CNN Newsroom With Wolf Blitzer",
                 "CNN This Morning", "CNN This Morning Weekend",
                 "The Source With Kaitlan Collins", "CNN Newsroom With Jim Acosta",
                 "Anderson Cooper 360", "Erin Burnett OutFront",
                 "The Lead With Jake Tapper")
FOX_SHOWS   <- c("Fox News Sunday", "FOX News Saturday Night", "Fox News Live",
                 "FOX and Friends Sunday", "Fox Report With Jon Scott",
                 "FOX News Saturday Night With Jimmy Failla", "The Ingraham Angle",
                 "Hannity", "The Five", "Fox News at Night",
                 "America's Newsroom", "FOX and Friends")
ABC_SHOWS   <- c("This Week With George Stephanopoulos", "Good Morning America",
                 "Jimmy Kimmel Live!", "ABC World News Saturday",
                 "ABC World News Sunday",
                 "ABC World News Tonight With David Muir", "Nightline")
NBC_SHOWS   <- c("NBC News Daily", "Meet the Press",
                 "NBC Nightly News With Lester Holt", "Today")
MSNBC_SHOWS <- c("Chris Jansing Reports", "The Beat With Ari Melber",
                 "Deadline: White House", "Morning Joe",
                 "The Rachel Maddow Show",
                 "The Last Word With Lawrence O'Donnell")

ALL_SHOWS <- c(CBS_SHOWS, CNN_SHOWS, FOX_SHOWS, ABC_SHOWS, NBC_SHOWS, MSNBC_SHOWS)
SHOW_NETWORK_MAP <- c(
  setNames(rep("CBS",        length(CBS_SHOWS)),   CBS_SHOWS),
  setNames(rep("CNN",        length(CNN_SHOWS)),   CNN_SHOWS),
  setNames(rep("Fox",        length(FOX_SHOWS)),   FOX_SHOWS),
  setNames(rep("ABC",        length(ABC_SHOWS)),   ABC_SHOWS),
  setNames(rep("NBC",        length(NBC_SHOWS)),   NBC_SHOWS),
  setNames(rep("MSNBC/MSNow",length(MSNBC_SHOWS)), MSNBC_SHOWS)
)

NETWORK_COLORS <- c(
  "CBS"="1a6bb5","CNN"="cc0001","Fox"="003366",
  "ABC"="00843d","NBC"="9b59b6","MSNBC/MSNow"="e5a823","All Networks"="1a1a1a"
)

load_chunks <- function() {
  df <- read.csv(CHUNKS_PATH, stringsAsFactors=FALSE)
  df$date <- as.Date(df$date, tryFormats=c("%Y-%m-%d","%Y/%m/%d","%m/%d/%Y"))
  df$week <- floor_date(df$date, "week", week_start=1)
  df$debate_performance <- as.numeric(df$debate_performance)
  df$show_name <- trimws(df$show_name)
  df <- df[df$show_name %in% ALL_SHOWS,]
  df$network <- SHOW_NETWORK_MAP[df$show_name]
  df[!is.na(df$date) & !is.na(df$debate_performance),]
}

ui <- fluidPage(
  tags$head(
    tags$link(rel="preconnect", href="https://fonts.googleapis.com"),
    tags$link(rel="stylesheet",
      href="https://fonts.googleapis.com/css2?family=IBM+Plex+Sans:wght@400;600&family=IBM+Plex+Serif:wght@400;600&family=IBM+Plex+Mono&display=swap"),
    tags$style(HTML("
      * { box-sizing: border-box; }
      body { background:#fff; color:#1a1a1a; font-family:'IBM Plex Sans',sans-serif;
             margin:0; padding:0 24px; }
      h1 { font-family:'IBM Plex Serif',serif; font-weight:400; font-size:2em; margin:0; }
      h2 { font-family:'IBM Plex Serif',serif; font-weight:400; }
      h3 { font-family:'IBM Plex Serif',serif; }
      .header-block { padding:32px 0 20px; border-bottom:1px solid #e0e0e0; margin-bottom:28px; }
      .header-subtitle { color:#888; margin-top:6px; font-size:14px; }
      .last-updated { font-size:11px; color:#aaa; margin-top:4px; font-family:'IBM Plex Mono',monospace; }
      .nav-tabs { border-bottom:1px solid #e0e0e0; margin-bottom:28px; }
      .nav-tabs > li > a { color:#666; font-size:12px; letter-spacing:0.1em; text-transform:uppercase; }
      .nav-tabs > li.active > a { color:#1a1a1a; border-bottom:2px solid #1a1a1a; font-weight:600; }
      .well { background:#f8f8f8; border:1px solid #e8e8e8; border-radius:6px; }
      .control-label { font-size:11px; text-transform:uppercase; letter-spacing:0.08em; color:#888; }
      .chart-label { font-size:14px; font-weight:600; margin-bottom:2px; margin-top:16px; }
      .chart-note { font-size:12px; color:#999; margin-bottom:8px; }
      .tab-headline { font-size:1.15em; font-weight:500; font-family:'IBM Plex Serif',serif; margin-bottom:4px; }
      .tab-subhead { font-size:13px; color:#888; margin-bottom:20px; }
      .methodology-text { max-width:780px; line-height:1.8; color:#333; font-size:15px; }
      .methodology-text h3 { color:#1a1a1a; margin-top:32px; }
      .methodology-text code { background:#f0f0f0; padding:2px 6px; border-radius:3px; font-size:13px; }
      hr { border-color:#e8e8e8; }
      table { width:100%; border-collapse:collapse; font-size:13px; }
      th { background:#f8f8f8; padding:8px 12px; text-align:left; border-bottom:2px solid #e0e0e0;
           font-size:11px; text-transform:uppercase; letter-spacing:0.05em; color:#888; }
      td { padding:8px 12px; border-bottom:1px solid #f0f0f0; }
      tr:hover td { background:#fafafa; }
      .btn { background:#1a1a1a; color:#fff; border:none; border-radius:4px;
             padding:8px 16px; font-size:13px; margin-right:8px; cursor:pointer; }
      .positive { color:#2e7d4f; }
      .negative { color:#c0392b; }
    "))
  ),

  div(class="header-block",
    h1("Trump Coverage Tracker"),
    p(class="header-subtitle", "Tone of Trump coverage across major broadcast networks, 2025-present"),
    uiOutput("last_updated_text")
  ),

  tabsetPanel(

    tabPanel("Coverage Over Time",
      br(),
      fluidRow(
        column(3,
          div(class="well", style="padding:20px;",
            tags$label(class="control-label", "Network"),
            selectInput("network_line", NULL,
              choices=c("All Networks","CBS","CNN","Fox","ABC","NBC","MSNBC/MSNow"),
              selected="All Networks", multiple=TRUE),
            hr(),
            tags$label(class="control-label", "Smoothing (rolling avg)"),
            sliderInput("smooth_weeks", NULL, min=1, max=8, value=3, step=1, post=" wk"),
            hr(),
            tags$label(class="control-label", "Date Range"),
            uiOutput("date_range_ui")
          )
        ),
        column(9,
          p(class="tab-headline", "Trump Coverage Over Time"),
          p(class="tab-subhead",
            "How broadcast news covered Trump week by week. Positive = framed as performing well; Negative = framed as performing poorly."),
          p(class="chart-label", "Trump Net Coverage Score (% Positive - % Negative)"),
          p(class="chart-note", "A score above 0 means more positive than negative coverage for Trump that week. Below 0 means more negative."),
          plotlyOutput("line_chart_net", height="400px"),
          br(),
          p(class="chart-label", "% of Trump Segments with Negative Coverage"),
          p(class="chart-note", "Share of Trump-mentioned segments classified as negative for Trump each week."),
          plotlyOutput("line_chart_neg", height="400px"),
          br(),
          p(class="chart-label", "Weekly Trump Mention Count"),
          p(class="chart-note", "Total number of transcript segments mentioning Trump each week, by network."),
          plotlyOutput("line_chart_count", height="380px"),
          br(),
          p(style="font-size:12px;color:#bbb;", "Faint lines show raw weekly values. Bold lines show rolling average smoothing."),
          br(),
          p(style="font-size:12px;color:#999;font-style:italic;",
            "Note: Segment counts reflect transcripts available through the Internet Archive's TV News Archive and may not capture all broadcasts.")
        )
      )
    ),

    tabPanel("Network Comparison",
      br(),
      fluidRow(
        column(3,
          div(class="well", style="padding:20px;",
            tags$label(class="control-label", "Date Range"),
            uiOutput("date_range_bar_ui"),
            hr(),
            tags$label(class="control-label", "Metric"),
            selectInput("bar_metric", NULL,
              choices=c("Net score (% pos - % neg)"="net","% Positive"="pct_pos",
                        "% Negative"="pct_neg","Total segments"="n_chunks"),
              selected="net")
          )
        ),
        column(9,
          p(class="tab-headline", "How Different Networks Covered Trump"),
          p(class="tab-subhead",
            "Comparison of Trump coverage tone across CBS, CNN, Fox News, ABC, NBC, and MSNBC/MSNow."),
          p(class="chart-label", "Network Comparison"),
          plotlyOutput("bar_chart", height="320px"),
          br(),
          p(class="chart-label", "Positive / Neutral / Negative Breakdown by Network"),
          plotlyOutput("stacked_chart", height="280px")
        )
      )
    ),

    tabPanel("Data",
      br(),
      h3(style="font-size:16px;font-weight:600;margin-bottom:16px;", "Download Data"),
      div(style="margin-bottom:24px;",
        downloadButton("download_chunks", "Full Trump analysis chunks CSV", class="btn"),
        downloadButton("download_weekly", "Weekly summary CSV", class="btn")
      ),
      hr(),
      h3(style="font-size:16px;font-weight:600;margin-bottom:12px;", "Weekly Summary"),
      tableOutput("data_table")
    ),

    tabPanel("Methodology",
      br(),
      div(class="methodology-text",
        h2("Methodology"),
        h3("Data Collection"),
        p("Transcripts are collected from the Internet Archive's TV News Archive (archive.org/details/tv).
          We collect transcripts from six networks: CBS, CNN, Fox News, ABC, NBC, and MSNBC/MSNow,
          covering January 2025 to the present. The dataset is updated weekly."),
        h3("Unit of Analysis"),
        p("Each broadcast transcript is split into 3-sentence chunks. Only chunks containing a mention
          of 'Trump' are retained for analysis."),
        h3("Performance Classification"),
        p("Each Trump-mention chunk is classified using a fine-tuned zero-shot natural language
          inference model developed by Michael Burnham. See the ",
          tags$a("Political Debate Performance Model",
            href="https://huggingface.co/mlburnham/Political_DEBATE_large_v1.0",
            target="_blank"), " on HuggingFace."),
        p(style="margin-top:12px;", "The model evaluates two competing hypotheses:"),
        tags$ul(
          tags$li(tags$em('"The author of this text believes Trump is performing/performed/will perform well"')),
          tags$li(tags$em('"The author of this text believes Trump is performing/performed/will perform poorly"'))
        ),
        p("A chunk is classified as +1 (Positive), -1 (Negative), or 0 (Neutral)."),
        h3("Aggregation"),
        tags$blockquote(style="border-left:3px solid #1a1a1a;padding-left:16px;color:#555;",
          tags$em("Net Score = (# positive chunks / total chunks) - (# negative chunks / total chunks)")),
        h3("Limitations"),
        tags$ul(
          tags$li("The model was trained on debate performance language and may not generalize perfectly."),
          tags$li("Closed-caption transcripts may contain OCR errors."),
          tags$li("Not all broadcasts in the archive have transcripts available.")
        ),
        h3("Citation"),
        p("If you use this data, please cite the Yale Political Media Lab and the Internet Archive TV News Archive.")
      )
    )
  )
)

server <- function(input, output, session) {

  df_raw <- reactive({ load_chunks() })

  output$last_updated_text <- renderUI({
    df <- df_raw()
    last_date <- max(df$date, na.rm=TRUE)
    tags$p(class="last-updated",
      paste("Data through", format(last_date, "%B %d, %Y"),
            "·", format(nrow(df), big.mark=","), "Trump-mention segments"))
  })

  output$date_range_ui <- renderUI({
    df <- df_raw()
    min_d <- min(df$week, na.rm=TRUE); max_d <- max(df$week, na.rm=TRUE)
    dateRangeInput("date_range_line", NULL, start=min_d, end=max_d, min=min_d, max=max_d)
  })

  output$date_range_bar_ui <- renderUI({
    df <- df_raw()
    min_d <- min(df$week, na.rm=TRUE); max_d <- max(df$week, na.rm=TRUE)
    dateRangeInput("date_range_bar", NULL, start=min_d, end=max_d, min=min_d, max=max_d)
  })

  df_line <- reactive({
    req(input$date_range_line, input$network_line)
    df <- df_raw()
    if (!"All Networks" %in% input$network_line)
      df <- df[df$network %in% input$network_line,]
    df[df$week >= input$date_range_line[1] & df$week <= input$date_range_line[2],]
  })

  weekly_data <- reactive({
    df <- df_line(); req(nrow(df)>0)
    multi <- !("All Networks" %in% input$network_line && length(input$network_line)==1)
    grp <- if(multi) c("week","network") else "week"
    df %>%
      group_by(across(all_of(grp))) %>%
      summarise(n_chunks=n(),
                pct_pos=mean(debate_performance==1, na.rm=TRUE)*100,
                pct_neg=mean(debate_performance==-1,na.rm=TRUE)*100,
                net_score=pct_pos-pct_neg, .groups="drop") %>%
      arrange(week)
  })

  smoothed_data <- reactive({
    req(input$smooth_weeks)
    wd <- weekly_data(); k <- input$smooth_weeks
    if ("network" %in% names(wd)) {
      wd %>% group_by(network) %>%
        mutate(net_smooth=rollmean(net_score,k=k,fill=NA,align="right"),
               neg_smooth=rollmean(pct_neg,  k=k,fill=NA,align="right")) %>%
        ungroup()
    } else {
      wd %>% mutate(net_smooth=rollmean(net_score,k=k,fill=NA,align="right"),
                    neg_smooth=rollmean(pct_neg,  k=k,fill=NA,align="right"))
    }
  })

  make_line_chart <- function(sd, y_col, y_smooth_col, y_label, color_single) {
    multi <- "network" %in% names(sd)
    p <- plot_ly() %>%
      layout(paper_bgcolor="#fff",plot_bgcolor="#fff",
             font=list(color="#444",family="IBM Plex Sans"),
             xaxis=list(title="",gridcolor="#f0f0f0",linecolor="#ddd",tickformat="%b %Y"),
             yaxis=list(title=y_label,gridcolor="#f0f0f0",linecolor="#ddd",
                        ticksuffix="%",zeroline=TRUE,zerolinecolor="#ccc",zerolinewidth=1),
             legend=list(bgcolor="#fff",bordercolor="#eee",borderwidth=1),
             hovermode="x unified")
    if (multi) {
      for (nw in unique(sd$network)) {
        nd <- sd[sd$network==nw,]
        col <- paste0("#", NETWORK_COLORS[nw]); if(is.na(col)) col <- "#888"
        p <- add_lines(p,data=nd,x=~week,y=~get(y_col),
                       line=list(color=col,width=1,dash="dot"),
                       opacity=0.3,showlegend=FALSE,hoverinfo="none")
        p <- add_lines(p,data=nd,x=~week,y=~get(y_smooth_col),
                       name=nw,line=list(color=col,width=2.5),
                       hovertemplate=paste0(nw,": %{y:.1f}%<extra></extra>"))
      }
    } else {
      p <- add_lines(p,data=sd,x=~week,y=~get(y_col),
                     line=list(color=paste0("#",color_single,"44"),width=1),
                     showlegend=FALSE,hoverinfo="none")
      p <- add_lines(p,data=sd,x=~week,y=~get(y_smooth_col),
                     name="Smoothed",line=list(color=paste0("#",color_single),width=3),
                     hovertemplate="%{y:.1f}%<extra></extra>")
    }
    p
  }

  output$line_chart_net <- renderPlotly({
    sd <- smoothed_data(); req(nrow(sd)>0)
    make_line_chart(sd,"net_score","net_smooth","Net Score (%)","1a1a1a")
  })

  output$line_chart_neg <- renderPlotly({
    sd <- smoothed_data(); req(nrow(sd)>0)
    make_line_chart(sd,"pct_neg","neg_smooth","% Negative","c0392b")
  })

  output$line_chart_count <- renderPlotly({
    df <- df_raw(); req(nrow(df)>0)
    sel <- input$network_line
    multi <- !is.null(sel) && !"All Networks" %in% sel
    if (multi) df <- df[df$network %in% sel,]
    dr <- input$date_range_line
    if (!is.null(dr)) df <- df[!is.na(df$week) & df$week>=as.Date(dr[1]) & df$week<=as.Date(dr[2]),]
    req(nrow(df)>0)
    if (multi) {
      cd <- df %>% group_by(week,network) %>% summarise(n_chunks=n(),.groups="drop") %>% arrange(week)
    } else {
      cd <- df %>% group_by(week) %>% summarise(n_chunks=n(),.groups="drop") %>% arrange(week)
      cd$network <- "All Networks"
    }
    cd$week <- as.Date(cd$week)
    p <- plot_ly() %>%
      layout(paper_bgcolor="#fff",plot_bgcolor="#fff",
             font=list(color="#444",family="IBM Plex Sans"),
             xaxis=list(title="",gridcolor="#f0f0f0",linecolor="#ddd",tickformat="%b %Y"),
             yaxis=list(title="# of segments",gridcolor="#f0f0f0",linecolor="#ddd"),
             legend=list(bgcolor="#fff",bordercolor="#eee",borderwidth=1),
             hovermode="x unified")
    for (nw in unique(cd$network)) {
      nd <- cd[cd$network==nw,]
      col <- paste0("#",NETWORK_COLORS[nw]); if(is.na(col)) col <- "#1a1a1a"
      p <- add_lines(p,data=nd,x=~week,y=~n_chunks,name=nw,
                     line=list(color=col,width=2.5),
                     hovertemplate=paste0(nw,": %{y:,}<extra></extra>"))
    }
    p
  })

  df_bar <- reactive({
    req(input$date_range_bar)
    df <- df_raw()
    df <- df[df$week>=input$date_range_bar[1] & df$week<=input$date_range_bar[2],]
    df %>% group_by(network) %>%
      summarise(n_chunks=n(),
                pct_pos=mean(debate_performance==1, na.rm=TRUE)*100,
                pct_neg=mean(debate_performance==-1,na.rm=TRUE)*100,
                net=pct_pos-pct_neg,.groups="drop") %>%
      arrange(desc(net))
  })

  output$bar_chart <- renderPlotly({
    bd <- df_bar(); req(nrow(bd)>0)
    metric <- input$bar_metric
    y_col <- switch(metric,net=bd$net,pct_pos=bd$pct_pos,pct_neg=bd$pct_neg,n_chunks=bd$n_chunks)
    y_lab <- switch(metric,net="Net Score (%)",pct_pos="% Positive",pct_neg="% Negative",n_chunks="Total Segments")
    bar_colors <- sapply(bd$network,function(n){c<-paste0("#",NETWORK_COLORS[n]);if(is.na(c))"#888" else c})
    plot_ly(bd,x=~network,y=y_col,type="bar",marker=list(color=bar_colors),
            hovertemplate=paste0("%{x}: %{y:.1f}",if(metric!="n_chunks")"%" else "","<extra></extra>")) %>%
      layout(paper_bgcolor="#fff",plot_bgcolor="#fff",
             font=list(color="#444",family="IBM Plex Sans"),
             xaxis=list(title="",gridcolor="#f0f0f0",linecolor="#ddd"),
             yaxis=list(title=y_lab,gridcolor="#f0f0f0",linecolor="#ddd",
                        ticksuffix=if(metric!="n_chunks")"%" else ""),
             showlegend=FALSE)
  })

  output$stacked_chart <- renderPlotly({
    bd <- df_bar(); req(nrow(bd)>0)
    plot_ly(bd,x=~network,y=~pct_pos,type="bar",name="Positive",
            marker=list(color="#2e7d4f"),
            hovertemplate="Positive: %{y:.1f}%<extra></extra>") %>%
      add_trace(y=~(100-bd$pct_pos-bd$pct_neg),name="Neutral",
                marker=list(color="#d0d0d0"),
                hovertemplate="Neutral: %{y:.1f}%<extra></extra>") %>%
      add_trace(y=~pct_neg,name="Negative",
                marker=list(color="#c0392b"),
                hovertemplate="Negative: %{y:.1f}%<extra></extra>") %>%
      layout(barmode="stack",paper_bgcolor="#fff",plot_bgcolor="#fff",
             font=list(color="#444",family="IBM Plex Sans"),
             xaxis=list(title="",gridcolor="#f0f0f0",linecolor="#ddd"),
             yaxis=list(title="Share of segments (%)",gridcolor="#f0f0f0",
                        linecolor="#ddd",ticksuffix="%"),
             legend=list(bgcolor="#fff",bordercolor="#eee",borderwidth=1))
  })

  weekly_summary <- reactive({
    df_raw() %>%
      group_by(week,network) %>%
      summarise(total_segments=n(),
                pct_positive=round(mean(debate_performance==1, na.rm=TRUE)*100,1),
                pct_negative=round(mean(debate_performance==-1,na.rm=TRUE)*100,1),
                pct_neutral =round(mean(debate_performance==0, na.rm=TRUE)*100,1),
                net_score   =round(pct_positive-pct_negative,1),.groups="drop") %>%
      arrange(desc(week),network)
  })

  output$data_table <- renderTable({
    ws <- weekly_summary()
    ws$week <- as.character(ws$week)
    colnames(ws) <- c("Week","Network","Total Segments","% Positive","% Negative","% Neutral","Net Score")
    ws
  }, striped=TRUE, hover=TRUE, bordered=FALSE)

  output$download_chunks <- downloadHandler(
    filename=function() paste0("trump_performance_chunks_",Sys.Date(),".csv"),
    content=function(file) write.csv(df_raw(),file,row.names=FALSE)
  )
  output$download_weekly <- downloadHandler(
    filename=function() paste0("trump_coverage_weekly_",Sys.Date(),".csv"),
    content=function(file) write.csv(weekly_summary(),file,row.names=FALSE)
  )
}

shinyApp(ui=ui,server=server)
