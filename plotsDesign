## Pacotes necessários
library(DiGGer)
library(R.oo)
library(R.methodsS3)
library(ggplot2)
library(tidyr)
library(readxl)
library(dplyr)
library(viridis)

# Tamanho de parcela: 0,9mx3,5m
#
# ID's únicos Esalq: 340
# Parcelas totais Esalq: 623 -> round for 625 (25*25)
#
# ID's únicos Anhumas: 349
# Parcelas totais Anhumas: 631 -> round for 638 (22*29)

##-----------------
## ESALQ design
##
## Ajuste feito:
##  Vide que o n° de parcelas não completa um esquema quadrado, foi adicionado um novo grupo de valores fantasmas a serem retirados
##  Valores fantasmas: 2

Esalq <- data.frame(1:341)
Esalq <- prDiGGer(numberOfTreatments=341,
                  rowsInDesign=25, 
                  columnsInDesign=25, 
                  treatRepPerRep=rep(c(1,2,5,2),c(72,263,5,1)), 
                  treatGroup=rep(c(1,2,3),c(335,5,1)),
                  blockSequence=list(c(25,5),c(5,5),c(5,1)),
                  ##rngSeeds = c(1928, 7568),
                  runSearch=T)

#Esalq <- run(Esalq)

mEsalq <- getDesign(Esalq)

desPlot(mEsalq,seq(72),col="#D5E4CF",new=TRUE,label=TRUE)
desPlot(mEsalq,seq(263)+72,col="#9dcc9b",new=FALSE,label=TRUE)
desPlot(mEsalq,seq(1)+340,col="#ffffff",new=FALSE,label=TRUE)
desPlot(mEsalq,seq(5)+335,col="#2a836B",new=FALSE,label=TRUE,
        bdef=cbind(5,5),bcol="#1f2124",bwd=4)

write.csv(mEsalq, file="mE.csv")

##-----------------
## ANHUMAS design
##
## Ajuste feito:
##  Vide que o n° de parcelas não completa um esquema quadrado, foi adicionado um novo grupo de valores fantasmas a serem retirados
##  Valores fantasmas: 7
Anhumas <- data.frame(1:350)
Anhumas <- prDiGGer(numberOfTreatments=350,
                    rowsInDesign=29, ##Linhas
                    columnsInDesign=22, ##Colunas
                    treatRepPerRep=rep(c(1,2,5,7),c(82,262,5,1)), 
                    treatGroup=rep(c(1,2,3),c(344,5,1)),
                    blockSequence=list(c(29,11),c(15,11),c(15,1)),
                    rngSeeds = c(1928, 7568),
                    runSearch=T)

#Anhumas <- run(Anhumas)

mAnhumas <- getDesign(Anhumas)

desPlot(mAnhumas,seq(82),col="#CAF0F8",new=T,label=T)
desPlot(mAnhumas,seq(262)+82,col="#7AA2C4",new=FALSE,label=TRUE)
desPlot(mAnhumas,seq(1)+349,col="#ffffff",new=FALSE,label=TRUE)
desPlot(mAnhumas,seq(5)+344,col="#365B86",new=FALSE,label=TRUE,
        bdef=cbind(10,11),bcol=1,bwd=4)

write.csv(mAnhumas, file="mA.csv")

##-----------------
## PLOTAGENS

# Lê os arquivos Excel
dbA <- read_excel("DBanhumas.xlsx") ##Tabela com IDpainel / diggerID / cluster
matrizA <- read_excel("mA.xlsx", col_names = F) ##Abrir arquivo .csv gerado, excluir linhas e colunas e salvar como .xlsx

# Selecionar apenas as colunas relevantes
subA <- dbA %>% select(diggerID, `ID painel`, Cluster)

# Renomeia as colunas da matriz para números sequenciais
colnames(matrizA) <- 1:ncol(matrizA)

# Transforma a matriz do formato largo para longo, especificando manualmente as colunas de valor e os nomes das colunas
longA <- matrizA %>%
  mutate(Linha = row_number()) %>% ##Cria uma coluna chamada "linha" com valores advindos da "row_number" da matriz
  pivot_longer(cols = -Linha, ##Colunas passam para linhas e o seu número é armazenado em uma nova coluna chamada "Coluna"
               names_to = "Coluna", 
               values_to = "diggerID")

# Realizar o join para substituir os valores de diggerID para o ID do painel
newA <- longA %>%
  left_join(subA, by = "diggerID") %>%
  select(-diggerID) %>%
  rename(Value = `ID painel`)

# Coloca os numeros da coluna como um valor ineiro, pois o R considera eles como um char
newA <- newA %>%
  mutate(Coluna = as.integer(Coluna))

# Clusteriza uma paleta de cores e armazena na var. cores
cores <- viridis_pal()(nlevels(factor(newA$Cluster)))

# Plota a matriz clusterizada
ggplot(newA, aes(x = Coluna, y = Linha, fill = factor(Cluster), label = Value)) +
  geom_tile(
    lwd = 1) + ## espaço entre os plots
  geom_text(color = "white") +
  scale_fill_manual(values = cores) +
  scale_x_continuous(breaks = unique(newA$Coluna), labels = unique(newA$Coluna),
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = unique(newA$Linha), labels = unique(newA$Linha),
                     expand = c(0, 0)) +
  labs(title = "Anhumas | Croqui do experimento clusterizado",
       x = "Coluna",
       y = "Linha",
       fill = "Agrupamento") +
  theme_light() +
  theme(panel.grid = element_blank(), 
        plot.title = element_text(hjust = 0.5))

# Plota a matriz generalizada
ggplot(newA, aes(x = Coluna, y = Linha, fill = Value, label = Value)) +
  geom_tile(
    width = 1, height = 1) + ## espaço entre os plots (0.0 maior espaço // 1 sem espaçamento)
  geom_text(color = "black") +
  scale_fill_gradient(low = "#E5F5E0", high = "mediumseagreen") +
  scale_x_continuous(breaks = unique(newA$Coluna), labels = unique(newA$Coluna),
                     expand = c(0, 0)) +
  scale_y_continuous(breaks = unique(newA$Linha), labels = unique(newA$Linha),
                     expand = c(0, 0)) +
  labs(title = "Anhumas | Croqui do experimento",
       x = "Coluna",
       y = "Linha",
       fill = "Agrupamento") +
  theme_light() +
  theme(panel.grid = element_blank(), 
        plot.title = element_text(hjust = 0.5))

# Casas cinzas são plots que devemos completar com "checks" para manter o delineamento retangular