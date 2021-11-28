{
  "output": [
    {
      "destination": "out.c-marketing_systems.00_adwords",
      "source": "out_adwords",
      "primaryKey": [
        "id",
        "currency"
      ],
      "incremental": true,
      "deleteWhereColumn": "",
      "deleteWhereOperator": "eq",
      "deleteWhereValues": []
    }
  ],
  "queries": [
    "CREATE OR REPLACE FUNCTION NmrStr(word STRING)\nRETURNS VARCHAR \nAS \n$$\nTRANSLATE(lower(trim(word)) ,'áčďéěíľňóřšťúůýžäöü','acdeeilnorstuuyzaou')\n$$;",
    "create or replace view \"tmp_ADW_ad_groups\" as \nSELECT *\nfrom \"ADW_ad_groups\"\n--WHERE TO_date(\"Day\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "CREATE OR REPLACE TABLE \"tmp_adwords\" AS\nSELECT a.\"Day\" as \"date\"\n,ifnull(right(parse_url(\"Landing_page\",1):\"host\"::string,2),'cz') as \"domain\"\n,'google' as \"source\"\n,'cpc'  AS \"medium\"\n,ifnull(left(ifnull(c.\"name\",''), 300),'')  as \"campaign\"\n,a.\"Impressions\" AS \"impressions\"\n,a.\"Clicks\" AS \"clicks\"\n,to_varchar(round(to_number(a.\"Cost\")/1000000,1)) as \"costs\"\n,'CZK' as \"currency\"\nFROM \"tmp_ADW_ad_groups\" AS a\nLEFT JOIN \"ADW_campaigns\" AS c \nON a.\"Campaign_ID\"=c.\"id\"\nLEFT JOIN \"ADW_customers\" AS b \nON c.\"customerId\"=b.\"customerId\"\nLEFT JOIN \"ADW_Url_adw\" \"d\"\nON a.\"Campaign_ID\"=\"d\".\"Campaign_ID\" AND a.\"Ad_group_ID\"=\"d\".\"Ad_group_ID\" AND a.\"Day\"=\"d\".\"Day\";",
    "CREATE OR REPLACE TABLE \"out_adwords\" AS\nSELECT \"date\" ||  '*' || NmrStr(\"domain\") || '*' || NmrStr(\"source\") || '*' || NmrStr(\"medium\") || '*' || NmrStr(\"campaign\") as \"id\"\n,\"date\"\n,NmrStr(\"source\") as \"source\"\n,NmrStr(\"medium\") as \"medium\"\n,NmrStr(\"campaign\") as \"campaign\"\n,NmrStr(\"domain\") as \"domain\"\n,\"currency\"\n,sum(\"impressions\") AS \"impressions\" \n,sum(\"clicks\") AS \"clicks\"\n,round(sum(\"costs\"),2) AS \"costs\"\nFROM \"tmp_adwords\"\nWHERE \"costs\" IS NOT NULL\nGROUP BY \"date\"\n,NmrStr(\"source\")\n,NmrStr(\"medium\")\n,NmrStr(\"campaign\")\n,NmrStr(\"domain\")\n,\"currency\";"
  ],
  "input": [
    {
      "source": "in.c-keboola-ex-adwords-v201809-94155653.ad_groups",
      "destination": "ADW_ad_groups",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-adwords-v201809-94155653.campaigns",
      "destination": "ADW_campaigns",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-adwords-v201809-94155653.customers",
      "destination": "ADW_customers",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-adwords-v201809-94155653.Url_adw",
      "destination": "ADW_Url_adw",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    }
  ],
  "name": "M00_T03_Google_Adwords",
  "packages": [],
  "requires": [],
  "backend": "snowflake",
  "type": "simple",
  "id": "94169675",
  "phase": 1,
  "disabled": false
}