

audio_file = "C:/Users/michael/Documents/Dev/mfa-labphon/data/mfa_kmg.wav"
background_color = very_dark_blue


wave =readWave(audio_file)
duration = length(wave@left)/ wave@samp.rate
beg = 0
end = duration

window_length = 0.025 * wave@samp.rate

mfcc_width = 0.005

begin_time = 0.0
end_time = 0.16

begin_samp = begin_time * wave@samp.rate
if (begin_samp < 1){
  begin_samp = 1
}
end_samp = end_time * wave@samp.rate

if (duration != end_time){
  first_bit <- wave@left[begin_samp:end_samp] / 32767
}
if (duration == end_time){
  first_bit = wave@left
}

max_amp = max(first_bit)

w <- windowfunc(window_length)
w_x = (1:length(w) /wave@samp.rate) - (0.025/2)

windows <- data.frame()

for (i in 0:15){
  windows <- rbind(windows, data.frame(time=begin_time+w_x + (i*0.01), amp=w*max_amp, frame=i))
}
windows <- subset(windows, time >= 0)

window_plot <- ggplot() + geom_segment(aes(y=max(first_bit), x=seq(begin_time,end_time-0.01,0.01), xend=seq(begin_time,end_time-0.01,0.01), yend=min(first_bit)), color=light_red, arrow = arrow(length = unit(0.25, "cm"))) + geom_line(aes(y=first_bit, x=begin_samp:end_samp /wave@samp.rate), color=very_light_blue) + geom_path(aes(y=amp, x=time,group=frame), data=windows, color=base_yellow) +
  theme_memcauliffe() + theme(
    panel.grid = element_blank(),
    panel.border=element_blank(),
    plot.margin = margin(t = 5, r = 5, b = 0, l = 5, unit = "pt"),
    panel.spacing= unit(0, units="pt"),
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
    axis.line = element_blank(),
    axis.ticks = element_blank(),
  ) + scale_x_continuous(limits=c(-mfcc_width*0.9, end_time), expand = c(0, 0)) + scale_y_continuous(expand = c(0, 0))


csv_path = "C:/Users/michael/Documents/Dev/mfa-labphon/data/mfa_kmg_mfccs.csv"
mfccs = read.csv(csv_path, encoding='UTF-8')

#mfccs[mfccs$frame==0,]$width = mfcc_width/ 2
#mfccs[mfccs$frame==0,]$midpoint = half_width/2

#if (end_time != duration){
#  mfccs <- subset(mfccs, midpoint <= end_time)
#  mfccs[mfccs$frame==max(mfccs$frame),]$width = half_width
#  mfccs[mfccs$frame==max(mfccs$frame),]$midpoint = mfccs[mfccs$frame==max(mfccs$frame),]$midpoint - (half_width/2)
#}

mfcc_plot = ggplot(data=mfccs, aes(x = midpoint, y = -feature, fill=coefficient)) + geom_tile(height=1, show.legend = F, color=base_yellow,width=mfcc_width) +
  theme_memcauliffe() + theme(
    panel.grid = element_blank(),
    panel.border=element_blank(),
    plot.margin = margin(t = 5, r = 5, b = 0, l = 5, unit = "pt"),
    panel.spacing= unit(0, units="pt"),
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
    axis.line = element_blank(),
    axis.ticks = element_blank(),
  ) + scale_x_continuous(limits=c(begin_time-mfcc_width, end_time), expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) + scale_fill_gradient(low=background_color, high=very_light_blue)

ggarrange(window_plot,mfcc_plot, nrow=2, heights = c(0.6,0.4))
ggsave(filename=file.path(root_dir, 'feature_extraction.png'), width = 1500, height = 1500, units = 'px', dpi =300)



csv_path = "C:/Users/michael/Documents/Dev/mfa-labphon/data/mfa_kmg.csv"
d = read.csv(csv_path, encoding='UTF-8')
d = subset(d, d$Begin < end_time & d$End > begin_time & Type=='phones')
if (end_time != duration){
  d[d$End > end_time,]$End <- end_time
}
if (begin_time != 0.0){
  d[d$Begin < begin_time,]$Begin <- begin_time
}
d$End = d$End - mfcc_width
d$Begin = d$Begin - mfcc_width
d$midpoint = (d$Begin+d$End)/2

  
text_plot = ggplot(aes(x = midpoint, y = Type, group = Label), data=d) + geom_text(aes(label=Label), size=5, color="#FFC300") + geom_tile(aes(x=midpoint, y=Type, height=1, width=End-Begin), fill=NA, color="#FFC300") +
  theme_memcauliffe() + theme(
    text = element_text(family="Gentium Book Plus"),
    panel.grid = element_blank(),
    panel.border=element_blank(),
    plot.margin = margin(t = 5, r = 5, b = 0, l = 5, unit = "pt"),
    panel.spacing= unit(0, units="pt"),
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
    axis.line = element_blank(),
    axis.ticks = element_blank(),
  ) + scale_x_continuous(limits=c(begin_time-mfcc_width, end_time), expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0))





csv_path = "C:/Users/michael/Documents/Dev/mfa-labphon/data/mfa_kmg_likes.csv"
likes = read.csv(csv_path, encoding='UTF-8')
#likes$midpoint <- likes$midpoint
#likes <- subset(likes, frame != 0)


likes_plot = ggplot(aes(x = midpoint, y = 1, group = phone), data=likes) + geom_tile(aes(x=midpoint, y=1, height=0.75, width=mfcc_width, fill=likelihood), color="#FFC300", show.legend = F) + geom_text(aes(label=phone), size=5, color="#FFC300")+ geom_segment(aes(y=2, x=seq(begin_time,end_time-0.01,0.01), xend=seq(begin_time,end_time-0.01,0.01), yend=1.45), color=light_red, arrow = arrow(length = unit(0.25, "cm"))) +
  theme_memcauliffe() + theme(
    text = element_text(family="Gentium Book Plus"),
    panel.grid = element_blank(),
    panel.border=element_blank(),
    plot.margin = margin(t = 5, r = 5, b = 0, l = 5, unit = "pt"),
    panel.spacing= unit(0, units="pt"),
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
    axis.line = element_blank(),
    axis.ticks = element_blank(),
  ) + scale_x_continuous(limits=c(begin_time-mfcc_width, end_time), expand = c(0, 0)) + scale_y_discrete(expand = c(0, 0)) + scale_fill_gradient(low=background_color, high=very_light_blue)

ggarrange(window_plot,mfcc_plot, likes_plot, text_plot, nrow=4, heights = c(0.5,0.25, 0.15, 0.1))
ggsave(filename=file.path(root_dir, 'alignment.png'), width = 1500, height = 1800, units = 'px', dpi =300)

