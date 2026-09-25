# GSE42872: Vemurafenib vs Control 差异表达分析
# 作者: charon
# 日期: 2026-09-25

library(GEOquery)
library(limma)
library(ggplot2)

# 1. 下载数据
gset <- getGEO("GSE42872", GSEMatrix = TRUE)
eset <- gset[[1]]
expr <- exprs(eset)

# 2. 构建分组
group <- factor(c("Control", "Control", "Control",
                  "Vemurafenib", "Vemurafenib", "Vemurafenib"))

# 3. 差异表达分析
design <- model.matrix(~ group)
fit <- lmFit(expr, design)
fit <- eBayes(fit)
deg <- topTable(fit, coef = 2, number = Inf, sort.by = "P")

# 4. 标记上下调
deg$change <- "Not Sig"
deg$change[deg$adj.P.Val < 0.05 & deg$logFC > 1] <- "Up"
deg$change[deg$adj.P.Val < 0.05 & deg$logFC < -1] <- "Down"

# 5. 保存结果
write.csv(deg, "results/deg_results.csv")

# 6. 画火山图
p <- ggplot(deg, aes(x = logFC, y = -log10(adj.P.Val), color = change)) +
  geom_point(alpha = 0.6, size = 1) +
  scale_color_manual(values = c("Down" = "blue", "Not Sig" = "grey", "Up" = "red")) +
  theme_minimal() +
  labs(title = "GSE42872: Vemurafenib vs Control",
       x = "log2 Fold Change", y = "-log10 adj.P")

ggsave("figures/volcano.png", p, width = 8, height = 6)
