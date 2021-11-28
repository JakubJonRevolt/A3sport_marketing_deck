{
  "output": [
    {
      "destination": "out.c-marketing_systems.00_cj",
      "source": "out_cj",
      "incremental": true,
      "deleteWhereColumn": "",
      "deleteWhereOperator": "eq",
      "deleteWhereValues": []
    }
  ],
  "queries": [
    "create or replace view \"tmp_cj_cz\"  as \nselect hash(left(\"postingDate\",10),'CZK',lower(right(\"advertiserName\",2)),\"orderId\") as \"id\"\n  ,to_date(convert_timezone('Europe/Prague','Europe/Prague', to_timestamp(\"postingDate\"))) as \"date\" --zde se meni pohled na vratky\n   ,\"orderId\" AS \"order_id\"\n  ,'CZK' AS \"currency\"\n  ,lower(right(\"advertiserName\",2)) as \"domain\"\n  ,\"websiteId\" as \"campaign\"\n  ,to_number(\"advCommissionAmountAdvCurrency\",35,2)*(-1) as \"costs\"\n  from \"CJ_commissions\"\n;",
    "create or replace view \"out_cj\"  as \nSELECT * FROM \"tmp_cj_cz\"\n/*UNION ALL \nSELECT * FROM \"tmp_cj_sk\"*/\n;"
  ],
  "input": [
    {
      "source": "in.c-kds-team-ex-cj-affiliate-168526905.commissions",
      "destination": "CJ_commissions",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    }
  ],
  "name": "M00_T05_CJ",
  "packages": [],
  "requires": [],
  "backend": "snowflake",
  "type": "simple",
  "id": "168530941",
  "phase": 1,
  "disabled": false
}