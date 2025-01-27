view: hk_cleaning_pricing {
  sql_table_name: `bigquery-analytics-272822.Gsheets.hk_cleaning_pricing`
    ;;

  dimension: br {
    hidden: yes
    type: number
    sql: ${TABLE}.BR ;;
  }

  dimension: building_title {
    hidden: yes
    type: string
    sql: ${TABLE}.Building_Title ;;
  }

  dimension: pricing {
    label: "Task Price"
    type: number
    sql: CASE WHEN ${hk_pricing_unit_specific.pricing} IS NULL THEN ${TABLE}.Pricing
    ELSE ${hk_pricing_unit_specific.pricing}
    END ;;
  }

  dimension: property_code {
    hidden: yes
    type: string
    sql: ${TABLE}.Property_Code ;;
  }

  dimension: task {
    hidden: yes
    type: string
    sql: ${TABLE}.Task ;;
  }

  measure: total_pricing {
    label: "Total Clean Cost"
    type: sum
    sql_distinct_key: ${bw_cleaning.id};;
    sql: ${pricing};;
    drill_fields: [bw_cleaning.id,hk_pricing_companies.company, bw_cleaning.unit, units.bedrooms, bw_cleaning.name, bw_cleaning.name_revised, pricing]
  }

}
