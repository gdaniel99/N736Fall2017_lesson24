# ==================================
# N736 Lesson 24 - Computing Reliability
# and Factor Analysis
#
# dated 11/20/2017
# Melinda Higgins, PhD
# 
# ==================================

# ==================================
# we're be working with the 
# helpmkh dataset
# ==================================

library(tidyverse)
library(haven)

helpdat <- haven::read_spss("helpmkh.sav")

h1 <- helpdat %>%
  select(id,f1a,f1b,f1c,f1d,f1e,f1f,f1g,
         f1h,f1i,f1j,f1k,f1l,f1m,f1n,f1o,
         f1p,f1q,f1r,f1s,f1t,cesd)

# run a summary on all 20 items - check amounts of missing
summary(h1)

# let's go ahead and reverse code the 4 items
h2 <- h1 %>%
  mutate(f1dr = ifelse(f1d==0,3,
                       ifelse(f1d==1,2,
                              ifelse(f1d==2,1,0))),
         f1hr = ifelse(f1h==0,3,
                       ifelse(f1h==1,2,
                              ifelse(f1h==2,1,0))),
         f1lr = ifelse(f1l==0,3,
                       ifelse(f1l==1,2,
                              ifelse(f1l==2,1,0))),
         f1pr = ifelse(f1p==0,3,
                       ifelse(f1p==1,2,
                              ifelse(f1p==2,1,0))))

# add the useNA="always" to check
# that missing data was handled correctly
table(h2$f1d, useNA="always")
table(h2$f1dr, useNA="always")
table(h2$f1h, useNA="always")
table(h2$f1hr, useNA="always")
table(h2$f1l, useNA="always")
table(h2$f1lr, useNA="always")
table(h2$f1p, useNA="always")
table(h2$f1pr, useNA="always")

# select the 20 cesd items
# with the 4 reverse coded ones
h2.cesd20 <- h2 %>%
  select(f1a,f1b,f1c,f1dr,f1e,f1f,f1g,
         f1hr,f1i,f1j,f1k,f1lr,f1m,f1n,f1o,
         f1pr,f1q,f1r,f1s,f1t)

# compute the number missing by row (id)
nmiss_cesd <- rowSums(is.na(h2.cesd20))
table(nmiss_cesd)

# compute the sum with mean substitution
sum_cesd <- rowMeans(h2.cesd20, na.rm=TRUE)*20

# compute the sum without mean substitution
sum2_cesd <- rowSums(h2.cesd20, na.rm=TRUE)

h3 <- data.frame(h2,nmiss_cesd,sum_cesd,sum2_cesd)

# compare stats
h3 %>%
  select(nmiss_cesd, cesd, sum_cesd, sum2_cesd) %>%
  summary()

# compute the correlation matrix
# using the reverse coded items
# remove missing values
cmtx <- cor(h2.cesd20, use="complete.obs",
            method="pearson")
         
# load the psych package
library(psych)
         
# compute alpha
a1 <- psych::alpha(cmtx)
a1

# use on complete cases
# 7 subjects with missing data are removed here
pc1 <- princomp(na.omit(h2.cesd20), cor=TRUE)
pc1
summary(pc1)
loadings(pc1)

# scree plot of eigenvalues/variances
plot(pc1,type="lines")

# plot of scores with items overlaid (red arrows)
# plot of factors 1 and 2
biplot(pc1)

# make a loadings plot
plot(pc1$loadings[,1], pc1$loadings[,2],
     xlim=c(-0.5,0.5), ylim=c(-0.5,0.5),
     main="Loadings Plot of Factors 1 and 2",
     xlab="Factor 1", ylab="Factor 2",
     pch=19)
lines(c(-0.5,0.5),c(0,0),col="red")
lines(c(0,0),c(-0.5,0.5),col="red")
text(pc1$loadings[,1], pc1$loadings[,2],
     labels=names(h2.cesd20),
     pos=4, offset=0.5)