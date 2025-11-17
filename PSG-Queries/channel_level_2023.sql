WITH phff AS (
    SELECT DISTINCT
        CAST(hierarchy_code AS INT) AS hierarchy_code,
        path->>'sku' AS sku,
        path->>'l0_name' AS brand
    FROM global.product_hierarchies_filter
    WHERE level = 7
      AND active = TRUE
),
pm AS (
    SELECT DISTINCT 
        paf.l0_name AS brand,
        paf.sku,
        phff.hierarchy_code
    FROM phff
    JOIN global.product_attributes_filter paf
        ON paf.sku = phff.sku
       AND paf.l0_name = phff.brand
    WHERE paf.active = TRUE
),
final AS (
    SELECT
        lly.hierarchy_code,
        p.brand,
        p.sku,
        '2023' as fiscal_year,
        lly.channel,
      SUM(COALESCE(lly.warranty_units, 0)) AS warranty_units,
        SUM(COALESCE(lly.warranty_dollar, 0)) AS warranty_dollar,
        SUM(COALESCE(lly.zero_dollar_orders_units, 0)) AS zero_dollar_orders_units,
        SUM(COALESCE(lly.zero_dollar_orders_dollar, 0)) AS zero_dollar_orders_dollar,
        SUM(COALESCE(lly.rtp_units, 0)) AS rtp_units,
        SUM(COALESCE(lly.rtp_dollar, 0)) AS rtp_dollar,
             SUM(COALESCE(lly.total_receipt_units, 0)) AS total_receipt_units,
        SUM(COALESCE(lly.total_receipt_cost, 0)) AS total_receipt_cost
    FROM item_smart.lly_master lly
    JOIN pm p
        ON p.hierarchy_code = lly.hierarchy_code
    WHERE lly.sub_channel  IN (
            'Ecom_warehouse',
            'Indirect_warehouse',
            'Store_warehouse'
        )
      AND lly.compared_week BETWEEN 202303 AND 202553
    GROUP BY
        lly.hierarchy_code,
        p.brand,
        p.sku,
        lly.channel
 
)
SELECT * FROM final;
