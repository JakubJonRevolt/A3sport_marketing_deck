{
  "output": [
    {
      "destination": "out.c-marketing_systems.00_ga_sessions",
      "source": "out_sessions",
      "incremental": true,
      "deleteWhereColumn": "",
      "deleteWhereOperator": "eq",
      "deleteWhereValues": [],
      "primaryKey": [
        "id"
      ]
    },
    {
      "destination": "out.c-marketing_systems.00_ga_targets",
      "source": "out_targets",
      "incremental": true,
      "deleteWhereColumn": "",
      "deleteWhereOperator": "eq",
      "deleteWhereValues": [],
      "primaryKey": [
        "id"
      ]
    }
  ],
  "queries": [
    "-- process only last 5 days\nCREATE OR REPLACE VIEW \"tmp_ga-sessions\" AS \nSELECT *\nfrom \"ga-sessions\"\n--WHERE TO_date(\"date\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "CREATE OR REPLACE VIEW \"tmp_ga-sessions-agr\" AS \nSELECT *\nfrom \"ga-sessions-agr\"\n--WHERE TO_date(\"date\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "CREATE OR REPLACE VIEW \"tmp_ga-transactions\" AS \nSELECT *\nfrom \"ga-transactions\"\n--WHERE TO_date(\"date\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "CREATE OR REPLACE VIEW \"tmp_transaction-agr\" AS \nSELECT *\nfrom \"ga-transactions-agr\"\n--WHERE TO_date(\"date\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "--------------------------------------------------------------------------\nCREATE OR REPLACE FUNCTION NmrStr(word STRING)\nRETURNS VARCHAR \nAS \n$$\nTRANSLATE(lower(trim(word)) ,'áčďéěíľňóřšťúůýžäöü','acdeeilnorstuuyzaou')\n$$;",
    "----------------------------------------------------------------------------\n\n\n-- sessions w/ session id\nCREATE OR REPLACE VIEW \"tmp_sessions_ses\" AS \nSELECT  \"date\"  || '*' || ifnull(\"domain\",'') || '*' || \"source\" || '*' || \"medium\" || '*' || \"campaign\" || '*' || \"client_id\"  || '*' || \"session_id\" AS \"id\" \n,\"date\"  || '*' ||  ifnull(\"domain\",'') || '*' || \"source\"  || '*' ||  \"medium\"  || '*' ||  \"campaign\"   AS \"comp_id\" \n,*\nFROM (\n\tSELECT \"date\"\n  \t,NmrStr(\"channelGrouping\") as \"channel\"\n\t,NmrStr(\"source\") AS \"source\"\n\t,NmrStr(\"medium\") AS \"medium\"\n\t,LEFT(NmrStr(\"campaign\"),300) AS \"campaign\"\n\t,NmrStr(substring(\"hostname\",LENGTH(\"hostname\")-POSITION('.' IN reverse(\"hostname\"))+2)) AS \"domain\"\n\t,NmrStr(\"clientId\") as \"client_id\"\n\t,NmrStr(\"dimension15\") AS \"session_id\"\n\t,\"sessions\"\n\t,\"pageviews\"\n\t,\"bounces\"\n\tFROM \"tmp_ga-sessions\"\n\t);",
    "-- sessions w/o session id\nCREATE OR REPLACE VIEW \"tmp_sessions_agr\" AS \nSELECT  \"date\"  || '*' || ifnull(\"domain\",'') || '*' || \"source\" || '*' || \"medium\" || '*' || \"campaign\"  || \"client_id\"  || '*' || \"session_id\" AS \"id\" \n,\"date\"  || '*' ||  ifnull(\"domain\",'') || '*' || \"source\"  || '*' ||  \"medium\"  || '*' ||  \"campaign\"   AS \"comp_id\" \n,*\nFROM (\n\tSELECT \"date\"\n  \t,NmrStr(\"channelGrouping\") as \"channel\"\n\t,NmrStr(\"source\") AS \"source\"\n\t,NmrStr(\"medium\") AS \"medium\"\n\t,LEFT(NmrStr(\"campaign\"),300) AS \"campaign\"\n\t,NmrStr(substring(\"hostname\",LENGTH(\"hostname\")-POSITION('.' IN reverse(\"hostname\"))+2)) AS \"domain\"\n\t,NmrStr(\"clientId\") as \"client_id\" \n\t,'aggregated_values' AS \"session_id\" \n\t,\"sessions\"\n\t,\"pageviews\"\n\t,\"bounces\"\n\tFROM \"tmp_ga-sessions-agr\"\n\t);",
    "-- merge sessions\nCREATE OR REPLACE VIEW \"out_sessions\" AS \nSELECT  \"id\" \n,\"date\"\n,\"channel\"\n,\"source\"\n,\"medium\"\n,\"campaign\"\n,\"domain\"\n,\"client_id\" \n,\"session_id\" \n,sum(\"sessions\") AS \"sessions\"\n,sum(\"pageviews\") AS \"pageviews\"\n,sum(\"bounces\") AS \"bounces\" \nFROM (\n-- merging\n\tSELECT *\n\tFROM \"tmp_sessions_ses\"\n\tUNION ALL \n\tSELECT *\n\tFROM \"tmp_sessions_agr\" t1\n\tWHERE  NOT EXISTS (SELECT \"id\" FROM  \"tmp_sessions_ses\" t2 WHERE t1.\"comp_id\" = t2.\"comp_id\") \n\t)\nGROUP BY \"id\" \n,\"date\"\n,\"channel\"\n,\"source\"\n,\"medium\"\n,\"campaign\"\n,\"domain\"\n,\"client_id\" \n,\"session_id\";",
    "----------------------------------------------------\t\n\n-- transactions w/ sessions id\nCREATE OR REPLACE VIEW \"tmp_transactions_ses\" AS \nSELECT  \"date\"  || '*' || ifnull(\"domain\",'') || '*' || \"source\" || '*' || \"medium\" || '*' || \"campaign\" || '*' || \"client_id\"  || '*' || \"session_id\"  || '*' || \"transaction_id\" AS \"id\" \n,\"date\"  || '*' ||  ifnull(\"domain\",'') || '*' || \"source\"  || '*' ||  \"medium\"  || '*' ||  \"campaign\"  || '*' || \"transaction_id\"   AS \"comp_id\" \n,*\nFROM (\n\tSELECT \"date\"\n\t,NmrStr(\"source\") AS \"source\"\n\t,NmrStr(\"medium\") AS \"medium\"\n\t,LEFT(NmrStr(\"campaign\"),300) AS \"campaign\"\n\t,NmrStr(substring(\"hostname\",LENGTH(\"hostname\")-POSITION('.' IN reverse(\"hostname\"))+2)) AS \"domain\"\n\t,NmrStr(\"clientId\") as \"client_id\"\n\t,NmrStr(\"dimension15\") AS \"session_id\"\n\t,\"transactionId\" as \"transaction_id\"\n\t,\"itemQuantity\"\n\t,\"transactionRevenue\"\n\t-- optional 1\n\t,\"goal1Completions\" AS \"cnt_goal_1\"\n\t,\"goal1Value\" AS \"val_goal_1\"\n\t-- optional 2\n\t,\"goal2Completions\" AS \"cnt_goal_2\"\n\t,\"goal2Value\" AS \"val_goal_2\"\t\n\t-- optional 5\n\t,\"goal5Completions\" AS \"cnt_goal_5\"\n\t,\"goal5Value\" AS \"val_goal_5\"\n\tFROM \"tmp_ga-transactions\"\n);",
    "-- transactions w/o sessions id\nCREATE OR REPLACE VIEW \"tmp_transactions_agr\" AS \nSELECT  \"date\"  || '*' || ifnull(\"domain\",'') || '*' || \"source\" || '*' || \"medium\" || '*' || \"campaign\" || '*' || \"client_id\"  || '*' || \"session_id\"  || '*' || \"transaction_id\" AS \"id\" \n,\"date\"  || '*' ||  ifnull(\"domain\",'') || '*' || \"source\"  || '*' ||  \"medium\"  || '*' ||  \"campaign\"  || '*' || \"transaction_id\"  AS \"comp_id\" \n,*\nFROM (\n\tSELECT \"date\"\n\t,NmrStr(\"source\") AS \"source\"\n\t,NmrStr(\"medium\") AS \"medium\"\n\t,LEFT(NmrStr(\"campaign\"),300) AS \"campaign\"\n\t,NmrStr(substring(\"hostname\",LENGTH(\"hostname\")-POSITION('.' IN reverse(\"hostname\"))+2)) AS \"domain\"\n\t,NmrStr(\"clientId\") as \"client_id\"\n\t,'aggregated_values' AS  \"session_id\"\n\t,\"transactionId\" as \"transaction_id\"\n\t,\"itemQuantity\"\n\t,\"transactionRevenue\"\n\t-- optional 1\n\t,\"goal1Completions\" AS \"cnt_goal_1\"\n\t,\"goal1Value\" AS \"val_goal_1\"\n\t-- optional 2\n\t,\"goal2Completions\" AS \"cnt_goal_2\"\n\t,\"goal2Value\" AS \"val_goal_2\"\t\n\t-- optional 5\n\t,\"goal5Completions\" AS \"cnt_goal_5\"\n\t,\"goal5Value\" AS \"val_goal_5\"\n\tFROM \"tmp_transaction-agr\"\n\t);",
    "-- merge transactions\nCREATE OR REPLACE VIEW \"out_targets\" AS \nSELECT  \"id\" \n,\"date\"\n,\"source\"\n,\"medium\"\n,\"campaign\"\n,\"domain\"\n,\"client_id\" \n,\"session_id\" \n,\"transaction_id\"\n, \"date\"  || '*' || \"domain\" || '*' || \"source\" || '*' || \"medium\" || '*' || \"campaign\" || '*' || \"client_id\"  || '*' || \"session_id\" AS \"fk_transaction_id\"\n,sum(\"itemQuantity\") AS \"itemQuantity\" \n,sum(\"transactionRevenue\") as \"transactionRevenue\"\n-- optional 1\n,sum(\"cnt_goal_1\") AS \"cnt_goal_1\"\n,sum(\"val_goal_1\") AS \"val_goal_1\"\n-- optional 2\n,sum(\"cnt_goal_2\") AS \"cnt_goal_2\"\n,sum(\"val_goal_2\") AS \"val_goal_2\"\n-- optional 5\n,sum(\"cnt_goal_5\") AS \"cnt_goal_5\"\n,sum(\"val_goal_5\") AS \"val_goal_5\"\nFROM (\n-- merge\n\tSELECT *\n\tFROM \"tmp_transactions_ses\"\n\tUNION ALL \n\tSELECT *\n\tFROM \"tmp_transactions_agr\" t1\n\tWHERE  NOT EXISTS (SELECT \"id\" FROM  \"tmp_transactions_ses\" t2 WHERE t1.\"comp_id\" = t2.\"comp_id\") \n\t)\nWHERE \"itemQuantity\" \u003e 0\n-- optional\nOR \"cnt_goal_1\" \u003e 0\nOR \"cnt_goal_2\" \u003e 0\nOR \"val_goal_5\" \u003e 0\nGROUP BY \"id\" \n,\"date\"\n,\"source\"\n,\"medium\"\n,\"campaign\"\n,\"domain\"\n,\"client_id\" \n,\"session_id\"\n,\"transaction_id\"\n;"
  ],
  "input": [
    {
      "source": "in.c-keboola-ex-google-analytics-v4-94161055.ga-sessions",
      "destination": "ga-sessions",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-google-analytics-v4-94161055.ga-sessions-agr",
      "destination": "ga-sessions-agr",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-google-analytics-v4-94161055.ga-transactions",
      "destination": "ga-transactions",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-google-analytics-v4-94161055.ga-transactions-agr",
      "destination": "ga-transactions-agr",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    }
  ],
  "name": "M00_T01_Google_Analytics",
  "packages": [],
  "requires": [],
  "backend": "snowflake",
  "type": "simple",
  "id": "94169639",
  "phase": 1,
  "disabled": false
}
