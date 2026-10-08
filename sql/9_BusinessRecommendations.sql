#------------------------------- Business Recommendations --------------------------------------- 
# What should management do based on the analysis?
SELECT
    'High' AS priority,
    'Frequent Stockouts' AS business_issue,
    'Products repeatedly reach zero inventory' AS evidence,
    'Review reorder points and replenish high-demand products earlier' AS recommended_action
UNION ALL
SELECT
    'High',
    'Overstock',
    'Products have high inventory compared with units sold',
    'Reduce future purchasing and consider promotions or markdowns'
UNION ALL
SELECT
    'High',
    'Key Revenue Products',
    'A small group of products contributes a large share of total revenue',
    'Prioritize availability and closely monitor inventory for these products'
UNION ALL
SELECT
    'Medium',
    'Underperforming Stores',
    'Store sales are below the company average',
    'Investigate product mix, customer demand and store-level performance'
UNION ALL
SELECT
    'Medium',
    'High-Volume Low-Revenue Products',
    'Products have high unit sales but relatively low revenue',
    'Review pricing, margins and promotional strategy'
UNION ALL
SELECT
    'Medium',
    'High-Value Products',
    'Products generate high revenue despite relatively low unit sales',
    'Maintain availability and avoid unnecessary stockouts'
UNION ALL
SELECT
    'Low',
    'Unusual Transactions',
    'Some transactions have sales significantly above their category average',
    'Investigate unusual orders and determine whether they represent one-time events or recurring demand';