library(tuneR)
library(stringr)
library(phonTools)
library(grid)
library(gtable)
library(ggpubr)
library(extrafont)
loadfonts(device = "win")
element_grob.element_custom <- function(element, ...)  {
  
  segmentsGrob(c(1,0,0),
               c(0,0,1),
               c(0,0,1),
               c(0,1,1), gp=gpar(lwd=2))
}
## silly wrapper to fool ggplot2
border_custom <- function(...){
  structure(
    list(...), # this ... information is not used, btw
    class = c("element_custom","element_blank", "element") # inheritance test workaround
  ) 
  
}
root_dirs = c(
  #"C:/Users/michael/Documents/Dev/memcauliffe-blog-scripts/misc/english_sound_files",
  "C:/Users/michael/Documents/Dev/mfa-labphon/data"
  #"C:/Users/michael/Documents/Dev/memcauliffe-blog-scripts/misc/japanese_sound_files"
)

plot_height = 450
background_color = very_dark_blue

plot_utterance <- function(filename, keyword=NULL){
  wave =readWave(path)
  duration = length(wave@left)/ wave@samp.rate
  beg = 0
  end = duration
  text_end = duration
  
  csv_path = file.path(root_dir, str_replace(f, '.wav', '.csv'))
  if (file.exists(csv_path)){
    print(csv_path)
    d = read.csv(csv_path, encoding='UTF-8')
    if (!is.null(keyword)){
      print(keyword)
      kw = d[d$Type=='words' & d$Label == keyword,]
      buffer = 0.25
      beg = kw$Begin-buffer
      if (beg < 0){
        beg = 0
      }
      end = kw$End+buffer
      if (end > duration){
        end = duration
      }
      text_end = end
      print(kw)
      print(beg)
      print(end)
      wave = extractWave(wave, beg, end, xunit='time')
      end = end - beg
    }
    d$midpoint = (d$Begin+d$End)/2
    print(d)
  }
  
  s = spectrogram(wave@left, wave@samp.rate, show=F, quality=T, window='gaussian', windowparameter=0.4)
  rownames(s$spectrogram) <- dimnames(s$spectrogram)[[1]]
  colnames(s$spectrogram) <- dimnames(s$spectrogram)[[2]]
  df1 <- as.data.frame(as.table(s$spectrogram))
  df2 <- data.frame(time=as.numeric(as.character(df1$Var1)), frequency=as.numeric(as.character(df1$Var2)), value=as.numeric(df1$Freq))
  df2[df2$value < max(df2$value)-50, ]$value <- max(df2$value)-50
  
  waveform <- ggplot() + geom_line(aes(y=wave@left / 32767, x=1:length(wave@left) /wave@samp.rate), color="#FFC300") +
    theme_memcauliffe() + theme(
      panel.grid = element_blank(),
      panel.border=element_blank(),
      plot.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt"),
      panel.spacing= unit(0,, units="pt"),
      plot.background = element_rect(fill = background_color),
      panel.background = element_rect(fill = background_color, color = background_color),
      panel.grid.major = element_blank(),
      axis.line.y = element_blank(),
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.title.y = element_blank(),
      axis.line.x = element_blank(),
      axis.text.x = element_blank(),
      axis.ticks.x = element_blank(),
      axis.title.x = element_blank(),
      panel.grid.minor = element_blank(),
      axis.line = element_line(color="#FFC300"),
      axis.ticks = element_line(color="#FFC300", size=1),
    ) + ylab('Amplitude') + xlab("Time (s)") + scale_x_continuous(limits=c(0, end), expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))
  
    
    spec <- ggplot(df2, aes(time/1000, frequency, fill=value)) + geom_tile(show.legend = F, interpolate=T) +
      theme_memcauliffe() + theme(
        panel.grid = element_blank(),
        panel.border=element_blank(),
        plot.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt"),
        panel.spacing= unit(0,, units="pt"),
        plot.background = element_rect(fill = background_color),
        panel.background = element_rect(fill = background_color, color = background_color),
        axis.line.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        axis.line.x = element_blank(),
        axis.text.x = element_blank(),
        axis.ticks.x = element_blank(),
        axis.title.x = element_blank(),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
      ) + scale_y_continuous(limits=c(0,7000), expand = c(0, 0)) + scale_x_continuous(limits=c(0, end), expand = c(0, 0)) +scale_fill_gradient(low=background_color, high="#FFD60A", limits=c(max(df2$value)-50, max(df2$value))) + xlab("Time (s)") + ylab("Frequency (Hz)")
    
    text = ggplot(d) + geom_text(aes(label=Label, x = midpoint, y = Type, group = Label, size=Type), color="#FFC300") + geom_tile(aes(x=midpoint, y=Type, height=1, width=End-Begin), fill=NA, color="#FFC300" , size=1) +
      theme_memcauliffe() + theme(
        text = element_text(family="Gentium Book Plus"),
        panel.grid = element_blank(),
        panel.border=element_rect(color="#FFC300", size=1),
        panel.spacing= unit(0,, units="pt"),
        plot.margin = margin(t = 0, r = 0, b = 0, l = 0, unit = "pt"),
        plot.background = element_rect(fill = background_color),
        panel.background = element_rect(fill = background_color, color = background_color),
        panel.grid.major = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.title.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.line = element_line(color="#FFC300", size=1),
        axis.ticks.x = element_blank(),
        axis.text.x = element_blank(),
        axis.title.x = element_blank(),
      ) + scale_x_continuous(limits=c(beg, text_end), expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) + scale_size_manual(values=c(5,9), guide="none")
    return(list(waveform=waveform, spec=spec, text=text))
}

for (root_dir in root_dirs) {
  
  files = list.files(root_dir, recursive = F, full.names = F, pattern="*.wav$")
  
  for (f in files){
    print(f)
    path = file.path(root_dir, f)
    p <- plot_utterance(path)
      
    comb = ggarrange(p$waveform, p$spec, p$text, nrow=3, heights=c(0.7/2, 0.7/2, 0.3))
    
    ggsave(plot=comb, filename=file.path(root_dir, str_replace(f, '.wav', '.svg')), width = 3000, height = 1500, units = 'px', dpi =300)
    ggsave(plot=comb, filename=file.path(root_dir, str_replace(f, '.wav', '.png')), width = 3000, height = 1500, units = 'px', dpi =300)
    
  }
  
  
}

