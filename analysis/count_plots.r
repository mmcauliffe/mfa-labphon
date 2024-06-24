library(tidyr)
library(dplyr)
library(readr)
library(stringr)

model_counts = read_csv("data/mfa_model_counts.csv", show_col_types = F, lazy=F)

model_counts$model_type <- factor(model_counts$model_type)
model_counts$version <- factor(model_counts$version, levels=sort(levels(as.factor(model_counts$version)), decreasing=T))
model_counts$language <- factor(model_counts$language)
model_counts$dialect <- factor(model_counts$dialect)
model_counts$phoneset <- factor(model_counts$phoneset)
model_counts

plotData <- model_counts %>% subset(count > 0 & phoneset != 'cv' & !language %in% c('multilingual', 'ivector') & model_type == 'acoustic') %>% group_by(language, version) %>% summarize(count_sum=sum(count)) %>% arrange(desc(count_sum))

ggplot(aes(x=reorder(language,-count_sum), y=count_sum, color=version), data=plotData) + geom_point(size = 5) +
  ylab('Download count') + xlab('Language') +ggtitle('Acoustic model downloads') +
  theme_memcauliffe() +
  scale_color_manual(name = 'Version', values = cbbPalette) + 
  #scale_x_discrete(guide = guide_axis(n.dodge = 2)) + 
  #facet_trelliscope(~model_type, ncol = 2, scales="free_x")+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


plotData <- model_counts %>% subset(count > 0 & phoneset != 'cv' & !language %in% c('multilingual', 'ivector') & model_type == 'g2p') %>% group_by(language, version) %>% summarize(count_sum=sum(count)) %>% arrange(desc(count_sum))

ggplot(aes(x=reorder(language,-count_sum), y=count_sum, color=version), data=plotData) + geom_point(size = 5) +
  ylab('Download count') + xlab('Language') +ggtitle('G2P model downloads') +
  theme_memcauliffe() +
  scale_color_manual(name = 'Version', values = cbbPalette) + 
  #scale_x_discrete(guide = guide_axis(n.dodge = 2)) + 
  #facet_trelliscope(~model_type, ncol = 2, scales="free_x")+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))


plotData <- model_counts %>% subset(count > 0 & phoneset != 'cv' & !language %in% c('multilingual', 'ivector') & model_type == 'dictionary') %>% group_by(language, version) %>% summarize(count_sum=sum(count)) %>% arrange(desc(count_sum))

ggplot(aes(x=reorder(language,-count_sum), y=count_sum, color=version), data=plotData) + geom_point(size = 5) +
  ylab('Download count') + xlab('Language') +ggtitle('Dictionary downloads') +
  theme_memcauliffe() +
  scale_color_manual(name = 'Version', values = cbbPalette) + 
  #scale_x_discrete(guide = guide_axis(n.dodge = 2)) + 
  #facet_trelliscope(~model_type, ncol = 2, scales="free_x")+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))



install_counts = read_csv("data/mfa_conda_counts.csv", show_col_types = F, lazy=F)
install_counts$pkg_name <= NULL

ggplot(aes(x=time, y=counts), data=install_counts) + geom_point(size = 5, color='#FB5607') +
  ylab('Install count') + xlab('Month') +ggtitle('MFA conda installs') +
  theme_memcauliffe() +
  scale_color_manual(name = 'Version', values = cbbPalette) + 
  #scale_x_discrete(guide = guide_axis(n.dodge = 2)) + 
  #facet_trelliscope(~model_type, ncol = 2, scales="free_x")+ 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust=1))
