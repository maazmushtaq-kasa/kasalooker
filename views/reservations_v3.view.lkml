view: reservations_v3 {
  label: "Reservations"
  derived_table: {
    sql:

WITH guest_type_table AS
    (select guest,
    case when count(*) > 1 then "Repeat"
    else "First Time"
    END guest_type
    from reservations
    group by 1),

    extensions AS (
      select r2.confirmationcode as reservation_extensions
      from reservations r1 join reservations r2 on r1.guest = r2.guest
      join units u1 on r1.unit = u1._id join units u2 on r2.unit = u2._id
      and cast(timestamp(r1.checkoutdate) as date) = cast(timestamp(r2.checkindate) as date)
      and u1.complex = u2.complex
      where r1.status IN ('confirmed','checked_in')
      and r2.status IN ('confirmed','checked_in'))

SELECT reservations.*, guest_type,
CASE WHEN reservation_extensions is not null THEN 1
ELSE NULL
END extended_booking
from reservations
LEFT JOIN extensions
ON reservations.confirmationcode = extensions.reservation_extensions
LEFT JOIN guest_type_table
ON reservations.guest = guest_type_table.guest ;;

    # persist_for: "1 hour"
    # datagroup_trigger: kasametrics_v3_default_datagroup
    # indexes: ["night","transaction"]
    # publish_as_db_view: yes

  }

  dimension: guest_type {
    hidden: no
    type: string
    sql: ${TABLE}.guest_type ;;
  }

  dimension: extended_booking {
    type: yesno
    sql: ${TABLE}.extended_booking = 1 ;;
  }

  measure: extended_booking_count {
    view_label: "Metrics"
    label: "Extended Booking Count"
    type: count_distinct
    sql: CONCAT(${extended_booking}, ${confirmationcode}) ;;
    filters: {field: extended_booking
      value: "yes"
    }
  }

  measure: Extension_guesty_count {
    view_label: "Metrics"
    label: "Extended Booking Count (Guesty Label)"
    type: count_distinct
    sql: CONCAT(${Extension_by_channel_label}, ${confirmationcode}) ;;
    filters: {field: Extension_by_channel_label
      value: "yes"
    }
  }

  dimension: _id {
    hidden: yes
    type: string
    sql: ${TABLE}._id ;;
  }

  dimension: Extension_by_channel_label {
    hidden: yes
    type: yesno
    sql: ${TABLE}.guesty.source IN ('Manual (Extension)', 'Manual (extension)', 'Maunal Extension');;
  }

  dimension: additionalguests {
    hidden: yes
    sql: ${TABLE}.additionalguests ;;
  }

  dimension_group: bookingdate {
    view_label: "Date Dimensions"
    group_label: "Booking"
    label: ""
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      week_of_year,
      month,
      month_name,
      quarter,
      year
    ]
    sql: ${TABLE}.bookingdate ;;
  }

  dimension: lead_time {
    type:  number
    sql:  date_diff(CAST(${checkindate} as DATE), CAST(${TABLE}.bookingdate as DATE), DAY) ;;
  }

  dimension: length_of_stay {
    type:  number
    sql:  date_diff(CAST(${checkoutdate} as DATE), CAST(${checkindate} as DATE), DAY) ;;
  }

  measure: avg_lead_time {
    view_label: "Metrics"
    description: "Days between booking and checking in"
    value_format: "0.0"
    type:  average_distinct
    sql_distinct_key: ${confirmationcode} ;;
    sql: ${lead_time};;
    drill_fields: [reservation_details*]
    filters: [capacity_night_part_of_res: "yes"]
  }

  measure: median_lead_time {
    view_label: "Metrics"
    description: "Days between booking and checking in"
    value_format: "0.0"
    type:  median_distinct
    sql_distinct_key: ${confirmationcode} ;;
    sql: ${lead_time};;
    drill_fields: [reservation_details*]
    filters: [capacity_night_part_of_res: "yes"]
  }

  measure: avg_length_of_stay {
    view_label: "Metrics"
    description: "Number of days of stay"
    value_format: "0.0"
    type:  average_distinct
    sql_distinct_key: ${confirmationcode} ;;
    sql: ${length_of_stay};;
    drill_fields: [reservation_details*]
    filters: [capacity_night_part_of_res: "yes"]
  }

  measure: median_length_of_stay {
    view_label: "Metrics"
    description: "Number of days of stay"
    value_format: "0.0"
    type:  median_distinct
    sql_distinct_key: ${confirmationcode} ;;
    sql: ${length_of_stay};;
    drill_fields: [reservation_details*]
    filters: [capacity_night_part_of_res: "yes"]
  }


  dimension: bringingpets {
    type: yesno
    sql: ${TABLE}.bringingpets ;;
  }

  dimension: callboxcode {
    type: string
    sql: ${TABLE}.callboxcode ;;
  }

  dimension_group: cancellationdate {
    view_label: "Date Dimensions"
    group_label: "Cancellation Date"
    label: "Cancellation"
    type: time
    timeframes: [
      time,
      date,
      week,
      month,
      year
    ]
    sql: ${TABLE}.cancellationdate ;;
  }

  dimension: cards {
    hidden: yes
    sql: ${TABLE}.cards ;;
  }

  dimension: chargelogs {
    hidden: yes
    sql: ${TABLE}.chargelogs ;;
  }

  dimension: checkindate {
    hidden: yes
    type: date
    sql: CAST(${TABLE}.checkindatelocal as TIMESTAMP);;
  }

  dimension_group: reservation_checkin {
    type: time
    view_label: "Date Dimensions"
    group_label: "Check-in Date"
    label: "Checkin"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.checkindatelocal as TIMESTAMP);;
  }

  dimension: checkoutdate {
    hidden: yes
    type: date
    sql: CAST(${TABLE}.checkoutdatelocal as TIMESTAMP);;
  }

  dimension_group: reservation_checkout {
    type: time
    view_label: "Date Dimensions"
    group_label: "Check-out Date"
    label: "Checkout"
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}.checkoutdatelocal as TIMESTAMP);;
  }

  dimension: confirmationcode {
    type: string
    primary_key: yes
    sql: ${TABLE}.confirmationcode ;;
    drill_fields: [reservation_details*]
  }

  dimension_group: createdat {
    hidden:  yes
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
    sql: ${TABLE}.createdat ;;
  }

  dimension: earlycheckin {
    hidden: yes
    sql: ${TABLE}.earlycheckin ;;
  }

  dimension: externalrefs {
    hidden: yes
    sql: ${TABLE}.externalrefs ;;
  }

  dimension: guest {
    hidden: yes
    type: string
    sql: ${TABLE}.guest ;;
  }

  dimension: guestscount {
    type: number
    sql: ${TABLE}.guestscount ;;
  }

  measure: guestscount_sum {
    label: "Total Number of Guests"
    view_label: "Metrics"
    type: sum_distinct
    sql_distinct_key: ${confirmationcode} ;;
    sql: ${guestscount} ;;
    filters: [capacity_night_part_of_res: "yes"]
  }

  dimension: keycafeaccess {
    hidden: yes
    sql: ${TABLE}.keycafeaccess ;;
  }

  dimension: licenseplate {
    type: string
    sql: ${TABLE}.licenseplate ;;
  }

  dimension: listingaddress {
    type: string
    sql: ${TABLE}.listingaddress ;;
  }

  dimension: listingname {
    hidden: yes
    type: string
    sql: ${TABLE}.listingname ;;
  }

  dimension: maybebringingpetsdespiteban {
    type: yesno
    sql: ${TABLE}.maybebringingpetsdespiteban ;;
  }

  dimension: nickname {
    type: string
    hidden: yes
    sql: ${TABLE}.nickname ;;
  }

  dimension: notes {
    hidden: yes
    sql: ${TABLE}.notes ;;
  }

  dimension: numberofpets {
    type: number
    sql: ${TABLE}.numberofpets ;;
  }

  dimension: parkingspaceneeded {
    type: yesno
    sql: ${TABLE}.parkingspaceneeded ;;
  }

  dimension: petdescription {
    type: string
    sql: ${TABLE}.petdescription ;;
  }

  dimension: petfeescard {
    hidden: yes
    sql: ${TABLE}.petfeescard ;;
  }

  dimension: pets {
    type: yesno
    sql: ${TABLE}.pets ;;
  }

  dimension: pettype {
    type: string
    sql: ${TABLE}.pettype ;;
  }

  dimension: plannedarrival {
    type: string
    sql: ${TABLE}.plannedarrival ;;
  }

  dimension: planneddeparture {
    type: string
    sql: ${TABLE}.planneddeparture ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}.platform ;;
  }

  dimension: signeddoc {
    type: string
    sql: ${TABLE}.signeddoc ;;
  }

  dimension: smartlockcode {
    type: string
    sql: ${TABLE}.smartlockcode ;;
  }

  dimension: smartlockcodeisset {
    type: yesno
    sql: ${TABLE}.smartlockcodeisset ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  dimension: sourcedetail {
    type: string
    sql: ${TABLE}.sourcedetail ;;
  }

  dimension: specialrequest {
    type: string
    sql: ${TABLE}.specialrequest ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: status_booked{
    description: "Was this night booked?"
    type: yesno
    sql: ${TABLE}.status is null or ${TABLE}.status IN ("confirmed","checked_in");;
  }

  dimension: suspicious {
    type: yesno
    sql: ${TABLE}.suspicious ;;
  }

  dimension: termsaccepted {
    type: yesno
    sql: ${TABLE}.termsaccepted ;;
  }

  dimension: timezone {
    hidden: yes
    type: string
    sql: ${TABLE}.timezone ;;
  }

  dimension: unit {
    type: string
    hidden: yes
    sql: ${TABLE}.unit ;;
  }

  dimension_group: updatedat {
    type: time
    hidden: yes
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.updatedat ;;
  }

  measure: reservation_night {
    view_label: "Metrics"
    label: "Num ReservationNights"
    description: "Reservation night stay"
    type:  count_distinct
    sql: CONCAT(${confirmationcode}, '-', ${capacities_v3.night_date});;
    filters: [capacity_night_part_of_res: "yes", status: "confirmed, checked_in"]
  }

  dimension: financial_night_part_of_res {
    hidden: yes
    type:  yesno
    sql: format_date('%Y-%m-%d', ${financials_v3.night_date}) < ${TABLE}.checkoutdatelocal and
      format_date('%Y-%m-%d', ${financials_v3.night_date}) >= ${TABLE}.checkindatelocal;;
  }

  dimension: financial_night_part_of_res_modified {
    hidden: yes
    description: "This will ultimately just apply the financial night part of reservations for any financial nights prior to 01-21 where neccessary data manipulation for historic data was set in place"
    type:  string
    sql: CASE WHEN (${financial_night_part_of_res} OR ${financials_v3.night_date} >= '2021-01-01')THEN "yes"
    ELSE "no"
    END;;
  }

  dimension: capacity_night_part_of_res {
    type:  yesno
    hidden: yes
    sql: format_date('%Y-%m-%d', ${capacities_v3.night_date}) < ${TABLE}.checkoutdatelocal and
      format_date('%Y-%m-%d', ${capacities_v3.night_date}) >= ${TABLE}.checkindatelocal;;
  }


  measure: num_reservations {
    view_label: "Metrics"
    label: "Num Reservations"
    description: "Number of unique reservations"
    type: count_distinct
    sql: ${confirmationcode} ;;
    filters: [capacity_night_part_of_res: "yes", status: "confirmed, checked_in"]
    drill_fields: [reservation_details*]
  }


  measure: occupancy {
    view_label: "Metrics"
    label: "Occupancy"
    description: "Number of reservation nights / capacity"
    type: number
    value_format: "0.0%"
    sql:  ${reservation_night} / NULLIF(${capacities_v3.capacity}, 0) ;;
  }

  dimension: checkin_night {
    hidden: yes
    type:  yesno
    sql: format_date('%Y-%m-%d', ${capacities_v3.night_date}) = format_date('%Y-%m-%d', ${reservation_checkin_date}) ;;
  }

  dimension: checkout_night {
    hidden: yes
    type:  yesno
    sql: format_date('%Y-%m-%d', ${capacities_v3.night_date}) = format_date('%Y-%m-%d', ${reservation_checkout_date}) ;;
  }

  dimension: checkins_checkouts {
    label: "Clean-up"
    description: "Night is either a check-in or check-out (clean up redundant rows)"
    type: yesno
    sql: format_date('%Y-%m-%d', ${capacities_v3.night_date}) = format_date('%Y-%m-%d', ${reservation_checkout_date})
    OR format_date('%Y-%m-%d', ${capacities_v3.night_date}) = format_date('%Y-%m-%d', ${reservation_checkin_date}) ;;
  }

  measure: number_of_checkins {
    view_label: "Metrics"
    label: "Number of Checkins"
    description: "Number of Check-ins"
    type: count_distinct
    sql: CONCAT(${units.internaltitle},${confirmationcode}) ;;
    filters: [checkin_night: "yes"]
  }

  measure: number_of_checkouts {
    view_label: "Metrics"
    label: "Number of Checkouts"
    description: "Number of Check-outs"
    type: count_distinct
    sql: CONCAT(${units.internaltitle},${confirmationcode}) ;;
    filters: [checkout_night: "yes"]
  }


  set:reservation_details {
    fields: [confirmationcode, status, source, checkindate, checkoutdate, bookingdate_date]
  }

}
