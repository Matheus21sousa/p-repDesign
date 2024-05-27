## Libraries
library(DiGGer)
library(R.oo)
library(R.methodsS3)
library(ggplot2)
library(tidyr)
library(readr)
library(readxl)
library(dplyr)
library(viridis)

## library(installr)
## updateR()

# Tamanho de parcela: 0,9mx3,5m
#
# ID's únicos Esalq: 427
# Parcelas totais: 980
# N° Rep.:
#   1 rep (1:9 tub.) 
#   2 rep (10:20 tub.)
#   3 rep (>21 tub.)
#   7 e 10 rep -> For checks 

##-----------------
## ANHUMAS ALL GENOTYPES
##
## Ajuste feito:
##  427 Genótipos
##  5 grupos de de repetições (1,2,3,7,10)

prepDesign <- data.frame(1:427)
prepDesign <- prDiGGer(numberOfTreatments=427,
                  rowsInDesign=28, 
                  columnsInDesign=35, 
                  treatRepPerRep=rep(c(1,2,3,7,10),c(121,88,213,2,3)), 
                  treatGroup=rep(c(1,2),c(422,5)),
                  blockSequence=list(c(14,35),c(7,7),c(7,1)),
                  ##rngSeeds = c(1928, 7568),
                  runSearch=T)

#prepDesign <- run(prepDesign)

prepDesign <- getDesign(prepDesign)

desPlot(prepDesign,seq(121),col="#D5E4CF",new=TRUE,label=TRUE)
desPlot(prepDesign,seq(88)+121,col="#9dcc9b",new=FALSE,label=TRUE)
desPlot(prepDesign,seq(213)+209,col="#2a836B",new=FALSE,label=TRUE)
desPlot(prepDesign,seq(5)+422,col="#ffffff",new=FALSE,label=TRUE,
        bdef=cbind(14,38),bcol="#1f2124",bwd=4)

write.csv(prepDesign, file="matrix.csv")

##-----------------
## PLOTAGENS

# Lê os arquivos Excel
dbGeneral <- read_excel("raw.xlsx") ##Tabela com IDpainel / diggerID / cluster
mx <- read_excel("matrix.xlsx", col_names = F) ##Abrir arquivo .csv gerado, excluir linhas e colunas e salvar como xlsx

# Selecionar apenas as colunas relevantes
###dbFiltered <- dbGeneral %>% select(diggerID, `ID painel`, Cluster)

# Renomeia as colunas da matriz para números sequenciais
colnames(mx) <- 1:ncol(mx)

# Transforma a matriz do formato largo para longo, especificando manualmente as colunas de valor e os nomes das colunas
longMx <- mx %>%
  mutate(Linha = row_number()) %>% #Cria uma coluna chamada "linha" com valores advindos da "row_number" da matriz
  pivot_longer(cols = -Linha, #Colunas passam para linhas e o seu número é armazenado em uma nova coluna chamada "Coluna"
               names_to = "Coluna", 
               values_to = "diggerID")

# Realizar o join para substituir os valores de diggerID para o ID do painel
newMx <- longMx %>%
  left_join(dbGeneral, by = "diggerID") %>%
  select(-diggerID) %>%
  rename(Value = `idAcesso`)

# Coloca os numeros da coluna como um valor inteiro, pois o R considera eles como um char
newMx <- newMx %>%
  mutate(Coluna = as.integer(Coluna))

# Renomeia a coluna Value -> idAcesso e salva um arquivo .csv
newMx <- newMx %>% rename("idAcesso" = "Value")
write_csv(newMx, file = "newMatrix.csv")

# Combinando os dados de newMx com os dados gerais e salvando
# raw <- read_excel("raw.xlsx")
# dbGeneral <- dbGeneral %>% rename("IDpainel" = "ID painel")
# newMx <- newMx %>% select(Linha, Coluna, Value)
# 
# sum(duplicated(newMx$Value))
# sum(duplicated(raw$idAcesso))
# 
# combinedMx <- merge(newMx, dbGeneral, by.x = "Value", by.y = "IDpainel", all.y = F)
# write.csv(combinedMx, file = "combinedMx.csv")

# Clusteriza uma paleta de cores e armazena na var. cores
cores <- viridis_pal()(nlevels(factor(newMx$Cluster)))

# Plota a matriz clusterizada
ggplot(newMx, aes(x = Coluna, y = Linha, fill = factor(Cluster), label = idAcesso)) +
  geom_tile(
    lwd = 1) + ## espaço entre os plots
  geom_text(color = "white") +
  scale_fill_manual(values = cores) +
  scale_x_continuous(breaks = unique(newMx$Coluna), labels = unique(newMx$Coluna),
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = unique(newMx$Linha), labels = unique(newMx$Linha),
                     expand = c(0, 0)) +
  labs(title = "Anhumas | Croqui do experimento clusterizado",
       x = "Coluna",
       y = "Linha",
       fill = "Agrupamento") +
  theme_light() +
  theme(panel.grid = element_blank(), 
        plot.title = element_text(hjust = 0.5))

# Plota a matriz generalizada
ggplot(newMx, aes(x = Coluna, y = Linha, fill = idAcesso, label = idAcesso)) +
  geom_tile(
    width = 1, height = 1) + ## espaço entre os plots (0.0 maior espaço // 1 sem espaçamento)
  geom_text(color = "black") +
  scale_fill_gradient(low = "#E5F5E0", high = "mediumseagreen") +
  scale_x_continuous(breaks = unique(newMx$Coluna), labels = unique(newMx$Coluna),
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = unique(newMx$Linha), labels = unique(newMx$Linha),
                     expand = c(0, 0)) +
  labs(title = "Anhumas | Croqui do experimento",
       x = "Coluna",
       y = "Linha",
       fill = "Agrupamento") +
  theme_light() +
  theme(panel.grid = element_blank(), 
        plot.title = element_text(hjust = 0.5))

# Casas cinzas são plots que devemos completar com "checks" para manter o delineamento retangular