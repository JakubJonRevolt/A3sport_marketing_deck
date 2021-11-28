{
  "output": [
    {
      "destination": "out.c-marketing_systems.00_facebook_ads",
      "source": "out_facebook",
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
    "CREATE OR REPLACE FUNCTION PARSE_UTM(utm STRING,trg_str STRING ) \n RETURNS varchar(255) AS '\n\tcase when position(utm in trg_str) \u003e0 then \n    case when position(''\u0026'' in substring(trg_str,position(utm in trg_str)))\u003e0 then \n            left(substring(trg_str,position(utm in trg_str)+length(utm)+1),position(''\u0026'' in substring(trg_str,position(utm in trg_str)+length(utm)+1))-1)\n         else \n            substring(trg_str,position(utm in trg_str)+length(utm)+1)\n         end             \n else null end\n';",
    "CREATE OR REPLACE FUNCTION NmrStr(word STRING)\nRETURNS VARCHAR \nAS \n$$\nTRANSLATE(lower(trim(word)) ,'áčďéěíľňóřšťúůýžäöü','acdeeilnorstuuyzaou')\n$$;",
    "create or replace view \"tmp_FB_ads_insights\" as \nSELECT *\nfrom \"FB_ads_insights\"\n--WHERE TO_date(\"date_start\")\u003edateadd(days,-5,CURRENT_date())\n;",
    "-- parse url_tags\ncreate or replace view \"tmp_utm\" as \nselect distinct \"parent_id\"\n,PARSE_UTM('utm_source',\"url_tags\") as \"source\"\n,PARSE_UTM('utm_medium',\"url_tags\") as \"medium\"\n,PARSE_UTM('utm_campaign',\"url_tags\") as \"campaign\"\nfrom \"FB_ads_insights_adcreatives\"\nqualify row_number() over (partition by  \"parent_id\" order by LENGTH(\"url_tags\") DESC ) = 1;",
    "create or replace view \"tmp_facebook\" as \nselect \"i\".\"date_start\" as \"date\"\n,ifnull(iff(substring(\"a\".\"targeting_geo_locations\",15,2)='','cz',substring(NmrStr(\"a\".\"targeting_geo_locations\"),15,2)),'') as \"domain\"\n,ifnull(\"utm\".\"source\",'facebook') as \"source\"\n,ifnull(\"utm\".\"medium\",'cpc') as \"medium\"\n,ifnull(left(case when \"utm\".\"campaign\" NOT IN ('{{campaign.name}}','{{adset.name}}','') then \n     ifnull(\"utm\".\"campaign\",\"cmp\".\"name\")\n     when \"utm\".\"campaign\" = '{{adset.name}}' THEN\n     \tifnull(\"as\".\"name\",\"cmp\".\"name\")\n else \n    \"cmp\".\"name\" end,300),'') as \"campaign\"\n,round(IFF(\"i\".\"inline_link_clicks\"='',0,\"i\".\"inline_link_clicks\")) AS \"clicks\"\n,\"i\".\"impressions\"\n,\"i\".\"spend\"\n,'CZK' AS \"currency\"\nfrom \"tmp_FB_ads_insights\" \"i\"\nLEFT JOIN \"FB_ads\" AS \"a\" ON \"i\".\"ad_id\"=\"a\".\"id\"\nLEFT JOIN \"FB_adsets\" AS \"as\" ON \"a\".\"adset_id\"=\"as\".\"id\"\nLEFT JOIN \"tmp_utm\" \"utm\" ON  \"a\".\"id\"=\"utm\".\"parent_id\"\nLEFT JOIN \"FB_campaigns\" AS \"cmp\" ON \"as\".\"campaign_id\"=\"cmp\".\"id\"\nLEFT JOIN \"FB_accounts\" AS \"acc\" ON \"cmp\".\"ex_account_id\"=\"acc\".\"id\";",
    "--output table\ncreate or replace view \"out_facebook\" AS\nselect \"date\" || '*' || NmrStr(\"domain\") || '*' || NmrStr(\"source\") || '*' || NmrStr(\"medium\") || '*' || NmrStr(\"campaign\") as \"id\"\n,\"date\",NmrStr(\"domain\") AS \"domain\",NmrStr(\"source\") AS \"source\",NmrStr(\"medium\") AS \"medium\",NmrStr(\"campaign\") AS \"campaign\"\n,\"currency\"\n,sum(\"clicks\") as \"clicks\"\n,sum(\"impressions\") as \"impressions\"\n,sum(\"spend\") as \"costs\"\nfrom \"tmp_facebook\"\ngroup by \"date\",NmrStr(\"domain\"),NmrStr(\"source\"),NmrStr(\"medium\"),NmrStr(\"campaign\"),\"currency\";"
  ],
  "input": [
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.accounts",
      "destination": "FB_accounts",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.ads",
      "destination": "FB_ads",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.campaigns",
      "destination": "FB_campaigns",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.ads_insights_adcreatives",
      "destination": "FB_ads_insights_adcreatives",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.ads_insights",
      "destination": "FB_ads_insights",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    },
    {
      "source": "in.c-keboola-ex-facebook-ads-94145926.adsets",
      "destination": "FB_adsets",
      "datatypes": {},
      "whereColumn": "",
      "whereValues": [],
      "whereOperator": "eq",
      "columns": [],
      "loadType": "clone"
    }
  ],
  "name": "M00_T02_Facebook_Ads",
  "packages": [],
  "requires": [],
  "backend": "snowflake",
  "type": "simple",
  "id": "94169706",
  "phase": 1,
  "disabled": false
}