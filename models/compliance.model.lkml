connection: "bigquery_new"
include: "../views/*"


datagroup: compliance_tracker_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}


persist_with: compliance_tracker_default_datagroup
label: "Legal"
explore: compliance_tracker {
}
