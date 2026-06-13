# NSE---Sectoral---Intelligence---Dashboard
21 years of NSE stock market analysis using Excel, MySQL and Tableau

# 📈 21 Years of the Indian Stock Market — A Data Story

> *"If you had invested ₹1 lakh in the right sector in 2000, where would you be today?"*
> 
> This project answers that question — with data.

---

## 🌟 Live Dashboard
👉 **[Explore the Full Interactive Dashboard on Tableau Public](https://public.tableau.com/app/profile/sucheta.de/viz/NSE-Sectoral-Intelligence-Dashboard/NSEDashboard)**

---

## 🎬 The Story Begins

It's the year 2000. The Indian stock market is young, volatile, and full of promise.

Over the next **21 years**, India would go through:
- 💥 The dot-com crash
- 🌏 The 2008 global financial crisis
- 📱 The rise of digital India
- 🦠 A global pandemic that shook every market in the world

**This project tracks all of it** — through 2,35,192 rows of real NSE trading data, across 9 sectors and 49 stocks, from January 2000 to April 2021.

The question I set out to answer:

> *Which sectors survived, which thrived, and which ones were simply not worth the risk?*

---

## 🗂️ The Dataset

| Property | Details |
|---|---|
| 📦 Source | Kaggle — NIFTY50 Stock Market Data |
| 🔗 Link | [Download Dataset](https://www.kaggle.com/datasets/rohanrao/nifty50-stock-market-data) |
| 📏 Size | **2,35,192 rows × 19 columns** |
| 📅 Period | January 2000 – April 2021 |
| 🏢 Coverage | 49 stocks · 9 sectors · 21 years |

> ⚠️ Dataset not uploaded here due to file size. Please download directly from Kaggle using the link above.

**Sectors covered:**
`Banking & Finance` · `Information Technology` · `Pharma` · `Oil & Gas` · `FMCG & Consumer` · `Metals` · `Auto` · `Infra & Cement` · `Others`

---

## 🛠️ Tools & Workflow

---

Raw NSE Data (CSV)

↓

EXCEL

Clean · Transform · Enrich

↓

MySQL

Query · Aggregate · Analyze

↓

TABLEAU

Visualize · Dashboard · Publish

---

## 🧹 Chapter 1 — Cleaning the Mess (Excel)

Raw data is never pretty. This dataset was no different.

When I first opened the file, here's what I found:
- **Duplicate company names** — the same company listed under 2 different ticker symbols as names changed over the years (Hero Honda → Hero MotoCorp, Tisco → Tata Steel...)
- **No sector column** — 49 stocks with zero categorization
- **Useless columns** — Series (always "EQ") and Last (identical to Close)
- **1,14,848 missing values** in the Trades column — but not random noise. NSE simply didn't record this metric before June 2011.

**What I did:**
- Fixed **15 duplicate ticker symbols** using Find & Replace
- Dropped 2 useless columns
- Built a **Sector Mapping table** and pulled sector names using VLOOKUP across all 2,35,192 rows
- Added 6 new calculated columns:

| New Column | Formula Logic |
|---|---|
| `Daily Return %` | (Close − Prev Close) / Prev Close × 100 |
| `Year` | Extracted from Date |
| `Month` | Extracted from Date |
| `Month-Year` | For time series axis labels |
| `Price Range` | High − Low (daily volatility) |
| `Sector` | VLOOKUP from sector mapping table |

- Built **3 Pivot Tables** — sector returns, top stocks, monthly volume trends

---

## 🗄️ Chapter 2 — Asking the Right Questions (MySQL)

With clean data loaded into MySQL (2,35,192 rows imported in 7 seconds), I wrote **6 analytical queries** to answer real business questions:

---

**Query 1 — Which sector gave the best returns?**
```sql
SELECT Sector,
       ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annualized_Return
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Annualized_Return DESC;
```

---

**Query 2 — Which sector carried the most risk?**
```sql
SELECT Sector,
       ROUND(STD(Daily_Return_Pct) * SQRT(252), 4) AS Annual_Volatility
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Annual_Volatility DESC;
```

---

**Query 3 — Who were the stars inside each sector?**
*(Uses Window Function — RANK)*
```sql
SELECT * FROM (
    SELECT Symbol, Sector,
           ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
           RANK() OVER (
               PARTITION BY Sector
               ORDER BY AVG(Daily_Return_Pct) DESC
           ) AS Sector_Rank
    FROM nifty50
    WHERE Sector != 'Unknown'
    GROUP BY Symbol, Sector
) ranked
WHERE Sector_Rank <= 5
ORDER BY Sector, Sector_Rank;
```

---

**Query 4 — Which sector gave the best bang for the risk?**
*(Sharpe-like Risk-Adjusted Score)*
```sql
SELECT Sector,
       ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
       ROUND(STD(Daily_Return_Pct) * SQRT(252), 4) AS Annual_Risk,
       ROUND(
           (AVG(Daily_Return_Pct) * 252) /
           NULLIF(STD(Daily_Return_Pct) * SQRT(252), 0)
       , 2) AS Risk_Adj_Score
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Risk_Adj_Score DESC;
```

---

**Query 5 — How did trading volumes shift over 21 years?**
```sql
SELECT Sector, Year, Month_Year,
       ROUND(AVG(Volume) / 1000000, 2) AS Avg_Volume_Millions
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector, Year, Month, Month_Year
ORDER BY Sector, Year, Month;
```

---

**Query 6 — What were the best and worst years for each sector?**
```sql
SELECT Sector, Year,
       ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
       RANK() OVER (
           PARTITION BY Sector
           ORDER BY AVG(Daily_Return_Pct) DESC
       ) AS Best_Year_Rank
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector, Year
ORDER BY Sector, Best_Year_Rank;
```

---

## 📊 Chapter 3 — Telling the Story (Tableau)

Three dashboards. Three perspectives. One complete picture.

---

### Dashboard 1 — Performance Overview
*"Which sector should you have put your money in?"*

![Performance Overview](https://raw.githubusercontent.com/suchetade2/NSE---Sectoral---Intelligence---Dashboard/main/screenshots/dashboard1.png))

- **Bar chart** — Annualized return by sector, color scaled green to gold
- **Risk vs Return scatter** — Bubble size = risk-adjusted score, quadrant lines show average risk and return
- **Best Worst Years heatmap** — 21 years × 9 sectors, green = best year, red = worst

---

### Dashboard 2 — Top Stocks Per Sector
*"Within each sector, who actually delivered?"*

![Top Stocks](screenshots/dashboard2.png)

- **Stock heatmap** — Top performing stocks per sector
- Blue = high return, Orange = lower return
- Instantly shows which stocks drove sector performance

---

### Dashboard 3 — Market Volume Trends
*"What did 21 years of market activity look like?"*

![Volume Trends](screenshots/dashboard3.png)

- **Line chart** — Monthly trading volume across all 9 sectors
- Massive spike visible in **2020** — COVID-19 market volatility
- Shows how market participation evolved over 2 decades

---

## 🔑 The Answers — Key Findings

After 21 years of data, here's what the numbers revealed:

| Finding | Detail |
|---|---|
| 🏆 Best Sector | **Infra & Cement** — 319.1% annualized return |
| ⚡ Most Volatile | **Infra & Cement** — Avg annual risk: 2,872 |
| 🌟 Best Single Stock | **LT** (Infra & Cement) — 1,923% total return |
| 🏦 Best Banking Stock | **KOTAKBANK** — 29% avg annual return |
| 😴 Lowest Return | **Pharma** — 10.9% annualized return |
| 📈 Peak Volume Year | **2020** — COVID-19 market spike |
| 🛡️ Best Risk-Adjusted | **FMCG & Consumer** — Consistent returns, low volatility |

> **The big insight:** Infra & Cement dominated raw returns — but came with the highest risk.
> For a conservative investor, FMCG & Consumer offered the best balance of return and stability.
> This is exactly the kind of insight a portfolio manager or banking analyst uses every quarter.

---

## 💡 Skills Demonstrated

---

Data Cleaning          ████████████  Excel VLOOKUP, Find & Replace, Pivot Tables

SQL Analysis           ████████████  GROUP BY, STD(), SQRT(), Window Functions

Financial Metrics      ████████████  Annualized Return, Volatility, Sharpe Score

Data Visualization     ████████████  Bar, Scatter, Heatmap, Line — Tableau Public

Domain Knowledge       ████████████  NSE, Sectors, Risk-Return, Indian Markets

Storytelling           ████████████  Business context, insights, recommendations

---

## 🔗 Links

| Resource | Link |
|---|---|
| 📊 Live Tableau Dashboard | [Click here](https://public.tableau.com/app/profile/sucheta.de/viz/NSE-Sectoral-Intelligence-Dashboard/NSEDashboard) |
| 📦 Dataset | [Kaggle — NIFTY50 Stock Market Data](https://www.kaggle.com/datasets/rohanrao/nifty50-stock-market-data) |

---

*Built with curiosity, cleaned with patience, and visualized with purpose.*
**— Sucheta De**
