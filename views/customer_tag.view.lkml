view: customer_tag {
  sql_table_name: `kustomer.customer_tag`
    ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}._fivetran_synced ;;
  }

  dimension: customer_id {
    type: string
    # hidden: yes
    sql: ${TABLE}.customer_id ;;
  }

  dimension: tag_id {
    type: string
    # hidden: yes
    sql: ${TABLE}.tag_id ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      tag.name,
      tag.id,
      customer.id,
      customer.first_name,
      customer.last_name,
      customer.display_name,
      customer.name
    ]
  }
}