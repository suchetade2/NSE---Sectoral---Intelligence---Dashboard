Query 1 - Which Sector gave best returns?

SELECT 
    Sector,
    ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annualized_Return
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Annualized_Return DESC;

Query 2 - Which Sector is most risky?

SELECT 
    Sector,
    ROUND(STD(Daily_Return_Pct) * SQRT(252), 4) AS Annual_Volatility
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Annual_Volatility DESC;

Query 3 - Top 5 Stocks Per Sector

SELECT * FROM (
    SELECT 
        Symbol, Sector,
        ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
        RANK() OVER (PARTITION BY Sector ORDER BY AVG(Daily_Return_Pct) DESC) AS Sector_Rank
    FROM nifty50
    WHERE Sector != 'Unknown'
    GROUP BY Symbol, Sector
) ranked
WHERE Sector_Rank <= 5
ORDER BY Sector, Sector_Rank;

Query 4 - Risk vs Return Score

SELECT 
    Sector,
    ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
    ROUND(STD(Daily_Return_Pct) * SQRT(252), 4) AS Annual_Risk,
    ROUND((AVG(Daily_Return_Pct) * 252) / NULLIF(STD(Daily_Return_Pct) * SQRT(252), 0), 2) AS Risk_Adj_Score
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector
ORDER BY Risk_Adj_Score DESC;

Query 5 - Monthly Volume Trend

SELECT 
    Sector, Year, Month, Month_Year,
    ROUND(AVG(Volume) / 1000000, 2) AS Avg_Volume_Millions
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector, Year, Month, Month_Year
ORDER BY Sector, Year, Month;

Query 6 - Best & Worst Year Per Sector

SELECT 
    Sector, Year,
    ROUND(AVG(Daily_Return_Pct) * 252, 2) AS Annual_Return,
    RANK() OVER (PARTITION BY Sector ORDER BY AVG(Daily_Return_Pct) DESC) AS Best_Year_Rank
FROM nifty50
WHERE Sector != 'Unknown'
GROUP BY Sector, Year
ORDER BY Sector, Best_Year_Rank;
