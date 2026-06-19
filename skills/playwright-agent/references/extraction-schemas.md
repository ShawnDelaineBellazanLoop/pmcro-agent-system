# Playwright Agent — Extraction Schemas
# Schema: 2.0 | Colony: {{colony_name}}
# Load the appropriate schema for the domain being scraped. All fields nullable per EXTRACT-001.

## Property Tax Extraction Schema
# Used by KAN-13 (tax delinquency scraper) and mk_batch_scrape action.

```json
{
  "id": "{{prop_id}}",
  "address": "{{address_string_or_null}}",
  "parcel": "{{parcel_number_or_null}}",
  "owner": "{{owner_name_or_null}}",
  "tax_status": "current | delinquent | unknown | null",
  "years_behind": "{{integer_or_null}}",
  "amount_owed": "{{decimal_or_null}}",
  "last_paid_year": "{{integer_or_null}}",
  "shadow_property": "{{boolean_or_null}}",
  "extracted_at": "{{iso8601_datetime}}",
  "source_url": "{{url}}",
  "extraction_status": "success | partial | failed",
  "nav_failure": "{{failure_description_or_null}}"
}
```

## Generic Page Extraction Schema
# Used for ad-hoc extraction tasks without a domain-specific schema.

```json
{
  "url": "{{url}}",
  "page_title": "{{string_or_null}}",
  "extracted_at": "{{iso8601_datetime}}",
  "fields": {
    "{{field_name}}": "{{value_or_null}}"
  },
  "raw_text_preview": "{{first_500_chars_or_null}}",
  "extraction_status": "success | partial | failed"
}
```

## Shadow Property Flag Logic
# Applied during mk_extract when schema includes shadow_property field.

Mark `shadow_property: true` when ALL of these conditions are met:
1. `tax_status == "delinquent"`
2. `years_behind >= 4`
3. Property input data includes `vacant: true` OR `occupancy_status: "vacant"`

If conditions cannot be confirmed from the accessibility tree, emit `shadow_property: null`.
Never infer or guess — EXTRACT-001.

## Adding New Schemas

To add a domain schema for a new scraping target:
1. Add the JSON schema block to this file under a named heading
2. Reference the schema name in the Planner step that calls `mk_extract`
3. The Maker validates all required fields are present or explicitly null before writing results
