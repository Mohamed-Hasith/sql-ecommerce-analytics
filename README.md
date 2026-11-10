# E-commerce Analytics | MySQL

An end-to-end SQL analysis of an online store's data, from building the database and checking data quality to answering business questions on sales, products, customers and returns.

## Business Questions Answered
- How much revenue, profit and order volume does the business generate?
- How have orders and revenue changed month by month?
- Which product categories and individual products perform best?
- Which countries bring in the most revenue?
- Why do customers return products, and what does it cost?
- Does reported revenue reconcile with item-level revenue?

## Dataset
Five related tables, loaded into a MySQL database named `ecommerce_analytics`:

| Table | Description |
|---|---|
| `customers` | Customer details, including country |
| `products` | Product names and categories |
| `orders` | Order dates, status, totals and currency details |
| `order_items` | Line-level quantity, revenue and profit |
| `returns` | Return reasons, quantities and refund amounts |

Cancelled orders are excluded from all revenue and sales analysis.

## Project Workflow
1. **Database Structure** (`01_Database_Structure.sql`): created the schema, tables, keys and relationships
2. **Validation** (`02_Validation.sql`): checked row counts, key integrity and consistency across tables
3. **Data Quality Checks** (`03_Data_quality_Check.sql`): looked for duplicates, nulls and invalid records
4. **Business Analysis** (`04_Business_Analysis.sql`): revenue, orders, customers, quantity sold, profit and category analysis
5. **Sales Performance** (`05_Sales_Performance.sql`): monthly trends, YoY growth, country and category performance, top products, return analysis and revenue reconciliation

## Key Insights

**Overall performance** (Jan 2024 to Jun 2026, excluding cancelled orders)
- 13,193 orders from 2,966 customers generated **$7.50M in revenue**, with an average order value of **$568.52**.
- Total profit was **$2.28M**.
- Monthly orders grew from **143 in Jan 2024 to 752 in May 2026**, the peak month, so order volume increased more than 5x.

**Products and categories**
- **Electronics earns about 50% of item revenue** ($3.34M of $6.70M). Sports ($1.11M) and Apparel ($1.01M) come next.
- The best-selling product by revenue is **Corvid Wearable 0105** at $102.8K, and the top earners are all Electronics.
- Units sold and revenue tell different stories. The top product by quantity, Tanuki Outdoor 0268 (155 units), earned only $26K, and a Beauty product sold 150 units for just $3.8K.

**Geography**
- The **United States is the largest market** at $1.52M (about 20% of revenue) and 2,991 orders, but it has the **lowest average order value** ($507).
- The UK ($822K), India ($796K) and Germany ($772K) follow. Germany has the highest average order value among the top markets ($646).

**Returns**
- 2,433 return records cost about **$410K in refunds**, roughly 5.5% of revenue.
- **Wrong size or fit (29.6%)** and **Not as described (20.0%)** are the top two reasons. Together they cause about half of all returns.

**Revenue reconciliation**
- Gross revenue of $7.16M, minus $464K in discounts, plus $779.7K in tax and $24.3K in shipping, gives the $7.50M in order revenue.
- The $804K gap between order revenue and item revenue ($6.70M) is almost exactly tax plus shipping, so reported revenue includes both.

## Business Recommendations
- **Reduce returns:** better size guides and more accurate product descriptions could address about half of all returns.
- **Protect Electronics:** it drives about half of item revenue, so stock and promotion decisions here matter most.
- **Raise US order value:** the US has the most orders but the lowest average order value, so bundles or free-shipping thresholds could help.
- **Look beyond units sold:** some high-volume products earn very little revenue, so quantity alone is a poor measure of success.

## Sample Outputs
![Overall performance](images/01_overall_performance.png)
![Revenue by category](images/02_revenue_by_category.png)
![Sales by country](images/03_sales_by_country.png)
![Return reasons](images/04_return_reasons.png)
![Revenue bridge](images/05_revenue_bridge.png)

## Database Schema
![Schema](images/schema.png)

## Tools and Skills
- MySQL and MySQL Workbench
- SQL: joins, CTEs, aggregations, date functions, subqueries
- Data validation and data quality checks
- Business and sales analysis

## Repository Structure
```
sql-ecommerce-analytics/
├── README.md
├── data/        # 5 source CSV files
├── sql/         # 5 SQL scripts, numbered in run order
└── images/      # schema diagram and query result screenshots
```

## How to Run
1. Create the database and tables with `sql/01_Database_Structure.sql`.
2. Import the CSV files from `data/` into their matching tables.
3. Run the remaining scripts in order, `02` to `05`.

## Author
**Mohamed Hasith M**
[LinkedIn](https://www.linkedin.com/in/mohamed-hasith-406801443/) | [GitHub](https://github.com/Mohamed-Hasith)
