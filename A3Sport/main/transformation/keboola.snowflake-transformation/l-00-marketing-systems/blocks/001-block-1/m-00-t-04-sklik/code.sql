{
  "output": [
    {
      "destination": "out.c-marketing_systems.00_sklik",
      "source": "out_sklik",
      "incremental": true,
      "deleteWhereColumn": "",
      "deleteWhereOperator": "eq",
      "deleteWhereValues": [],
      "primaryKey": [
        "id",
        "currency"
      ]
    }
  ],
  "queries": [
    "create or replace view \"tmp_SKL_campaigns-stats\" as \nSELECT *\nfrom \"SKL_campaigns-stats\"\n--WHERE TO_date(\"date\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "CREATE OR REPLACE FUNCTION NmrStr(word STRING)\nRETURNS VARCHAR \nAS \n$$\nTRANSLATE(lower(trim(word)) ,'áčďéěíľňóřšťúůýžäöü','acdeeilnorstuuyzaou')\n$$;",
    "create or replace view \"out_sklik\" as \nSELECT \"date\" ||  '*' || NmrStr(\"domain\") || '*' || NmrStr(\"source\") || '*' || NmrStr(\"medium\") || '*' || NmrStr(\"campaign\")  as \"id\"\n,\"date\"\n,NmrStr(\"source\") as \"source\"\n,NmrStr(\"medium\") as \"medium\"\n,NmrStr(\"campaign\") as \"campaign\"\n,NmrStr(\"domain\") as \"domain\"\n,\"currency\"\n,sum(\"impressions\") AS \"impressions\" \n,sum(\"clicks\") AS \"clicks\"\n,round(sum(\"costs\"),2) AS \"costs\"\nFROM (\n\tSELECT TO_DATE (c.\"date\",'yyyymmdd') AS \"date\"\n  \t,'sklik' as \"source\"\n  \t,'cpc' as \"medium\"\n  \t,ifnull(left(\"name\", 300),'') AS \"campaign\"\n\t,case when lower(left(\"name\",2)) = 'sk' THEN 'sk'\n\t    ELSE 'cz' END as \"domain\"\n\t,\"impressions\"\n\t,\"clicks\"\n\t,to_number(c.\"totalMoney\",22,2)/100 AS \"costs\"\n  ,'CZK' as \"currency\"\n\tFROM \"SKL_accounts\" AS a\n\tLEFT JOIN\n\t\"SKL_campaigns\" AS b ON a.\"userId\"=b.\"accountId\"\n\tLEFT JOIN\n\t\"tmp_SKL_campaigns-stats\" AS c ON c.\"id\"=b.\"id\"\n\twhere \"createDate\"\u003c\u003e''\n\tand c.\"date\"\u003c\u003e''\n) where \"costs\" is not null\nGROUP BY \"date\"\n,NmrStr(\"source\")\n,NmrStr(\"medium\")\n,NmrStr(\"campaign\")\n,NmrStr(\"domain\")\n,\"currency\";"
  ],
  "input": [
    {
      "source": "in.c-keboola-ex-sklik-168096760.campaigns",
      "destination": "SKL_campaigns",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-sklik-168096760.campaigns-stats",
      "destination": "SKL_campaigns-stats",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-sklik-168096760.accounts",
      "destination": "SKL_accounts",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    }
  ],
  "name": "M00_T04_Sklik",
  "packages": [],
  "requires": [],
  "backend": "snowflake",
  "type": "simple",
  "id": "94484144",
  "phase": 1,
  "disabled": false
}