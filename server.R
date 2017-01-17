library("shiny")
library("threejs")
library("RSQLite")
library("RColorBrewer")

# 設定
options <- list(
  img="/Users/tsuyusakikouki/Desktop/data/PubMed.db/data/world.topo.bathy.200412.3x5400x2700.jpg", # 背景
  bodycolor="#0011ff", # 輪郭
  emissive="#0011ff", # 暗さ？
  lightcolor="#99ddff", #反射光
  arcsColor='#ff00ff', # エッジの色
  arcsHeight=0.4, # エッジの高さ
  arcsOpacity=0.3, # エッジの透明度
  atmosphere=FALSE, # 大気を加えるか（NASA画像の場合関係ない）
  rotationlong=5.5, # 初期位置
  rotationlat=0.5 # 初期位置
  )

# ここの書き方は同じ（input = ui.Rから来る？, output = ui.Rに送られる？）
shinyServer(function(input, output) {
  # cullの設定（reactiveで設定が毎回反映される?）
  cull <- reactive({

    out <- demodata.bc[intersect(
        which(demodata.bc$YEAR >= input$Y[1]),
        which(demodata.bc$YEAR <= input$Y[2])), ]

      if(input$Keyword != ""){
        out[grep(input$Keyword, out$TITLE), ]
      }else{
        out
      }
  })

  # プロット
  output$plot1 <- renderPlot({
      barplot(table(demodata.bc$YEAR), col=rgb(0,1,0,0.5))
    })

  # valuesの設定
  values <- reactive({
    col <- brewer.pal(11, "Spectral")
    names(col) <- c()
    myinput <- cull() # cullで切り出されたデータ
    value <- input$B * log10(myinput$Freq+1) / max(log10(myinput$Freq+1))
    col <- col[floor(length(col) * (input$B - value) / input$B) + 1]
    list(value=value, color=col, myinput=myinput)
  })

  # edgesの設定
  edges <- reactive({
    myinput <- values()$myinput # cullで切り出されたデータ

    demo <- sapply(names(table(myinput$TITLE)), function(x){
        authors <- which(x == myinput$TITLE)
        if(length(authors) != 1){
          comb <- t(combn(authors, 2)) # あらゆる著者の組み合わせ
          # 緯度・経度に変換
          out <- unlist(apply(comb, 1, function(xx){
                  longlat <- myinput[xx, 11:10]
                  as.numeric(c(longlat[1,], longlat[2, ]))
                 }))
          out <- t(out)
          out
        }
      })

    edge <- c()
    for(i in 1:length(demo)){
      edge <- rbind(edge, demo[[i]])
    }
    edge
  })

  # レンダリング
  output$mytable1 <- renderDataTable({
    myinput <- cull()
    myinput$LONGITUDE <- round(myinput$LONGITUDE, 2)
    myinput$LATTITUDE <- round(myinput$LATTITUDE, 2)
    myinput
  })

  output$globe <- renderGlobe({
    v <- values()
    e <- edges()
    # globejsのオプション
    args <- c(
              options,
              list(
                lat=v$myinput$LATTITUDE,
                long=v$myinput$LONGITUDE,
                value=v$value,
                color=v$color,
                arcs=e,
                arcsLwd=input$E)
              )
    # 出力
    do.call(globejs, args=args)
  })
})
