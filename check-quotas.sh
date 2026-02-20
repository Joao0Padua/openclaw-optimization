#!/usr/bin/env bash
# check-quotas.sh
# Checks usage/quota status across OpenRouter, Anthropic, and OpenAI.
# Reads API keys from ~/.openclaw/credentials/ by default.
# Usage: ./check-quotas.sh [--json]

set -euo pipefail

CREDENTIALS_DIR="${OPENCLAW_CREDENTIALS_DIR:-$HOME/.openclaw/credentials}"
OUTPUT_JSON=false

if [[ "${1:-}" == "--json" ]]; then
  OUTPUT_JSON=true
fi

# --------------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------------

read_credential() {
  local name="$1"
  local path="$CREDENTIALS_DIR/$name"
  if [[ -f "$path" ]]; then
    tr -d '[:space:]' < "$path"
  else
    echo ""
  fi
}

print_header() {
  if [[ "$OUTPUT_JSON" == false ]]; then
    echo ""
    echo "=== $1 ==="
  fi
}

print_field() {
  local label="$1"
  local value="$2"
  if [[ "$OUTPUT_JSON" == false ]]; then
    printf "  %-24s %s\n" "$label:" "$value"
  fi
}

# --------------------------------------------------------------------------
# OpenRouter
# --------------------------------------------------------------------------

check_openrouter() {
  local key
  key=$(read_credential "openrouter")

  if [[ -z "$key" ]]; then
    print_header "OpenRouter"
    print_field "Status" "No credential found at $CREDENTIALS_DIR/openrouter"
    return
  fi

  local response
  response=$(curl -sf \
    -H "Authorization: Bearer $key" \
    "https://openrouter.ai/api/v1/auth/key" 2>/dev/null) || {
    print_header "OpenRouter"
    print_field "Status" "API request failed"
    return
  }

  local limit usage remaining rate_limit
  limit=$(echo "$response" | grep -o '"limit":[0-9.]*' | head -1 | cut -d: -f2)
  usage=$(echo "$response" | grep -o '"usage":[0-9.]*' | head -1 | cut -d: -f2)
  rate_limit=$(echo "$response" | grep -o '"rate_limit":{"requests":[0-9]*' | grep -o '[0-9]*$')

  if [[ -n "$limit" && -n "$usage" ]]; then
    remaining=$(echo "$limit $usage" | awk '{printf "%.4f", $1 - $2}')
    local pct
    pct=$(echo "$usage $limit" | awk '{printf "%.1f", ($1/$2)*100}')
    print_header "OpenRouter"
    print_field "Credit limit" "\$$limit"
    print_field "Used" "\$$usage ($pct%)"
    print_field "Remaining" "\$$remaining"
  else
    print_header "OpenRouter"
    print_field "Raw response" "$response"
  fi

  if [[ -n "$rate_limit" ]]; then
    print_field "Rate limit" "$rate_limit req/min"
  fi
}

# --------------------------------------------------------------------------
# Anthropic
# --------------------------------------------------------------------------

check_anthropic() {
  local key
  key=$(read_credential "anthropic")

  if [[ -z "$key" ]]; then
    print_header "Anthropic"
    print_field "Status" "No credential found at $CREDENTIALS_DIR/anthropic"
    return
  fi

  # Anthropic doesn't have a public quota/usage endpoint.
  # We do a minimal API call to verify the key is valid.
  local http_code
  http_code=$(curl -so /dev/null -w "%{http_code}" \
    -H "x-api-key: $key" \
    -H "anthropic-version: 2023-06-01" \
    "https://api.anthropic.com/v1/models" 2>/dev/null) || http_code="000"

  print_header "Anthropic"
  case "$http_code" in
    200) print_field "Key status" "Valid" ;;
    401) print_field "Key status" "Invalid (401 Unauthorized)" ;;
    429) print_field "Key status" "Rate limited (429)" ;;
    *)   print_field "Key status" "Unknown (HTTP $http_code)" ;;
  esac
  print_field "Usage dashboard" "https://console.anthropic.com/settings/usage"
}

# --------------------------------------------------------------------------
# OpenAI
# --------------------------------------------------------------------------

check_openai() {
  local key
  key=$(read_credential "openai")

  if [[ -z "$key" ]]; then
    print_header "OpenAI"
    print_field "Status" "No credential found at $CREDENTIALS_DIR/openai"
    return
  fi

  local response http_code
  response=$(curl -sf \
    -H "Authorization: Bearer $key" \
    "https://api.openai.com/v1/models" 2>/dev/null) || {
    # Try to get HTTP code separately on failure
    http_code=$(curl -so /dev/null -w "%{http_code}" \
      -H "Authorization: Bearer $key" \
      "https://api.openai.com/v1/models" 2>/dev/null) || http_code="000"
    print_header "OpenAI"
    case "$http_code" in
      401) print_field "Key status" "Invalid (401 Unauthorized)" ;;
      429) print_field "Key status" "Rate limited (429)" ;;
      *)   print_field "Key status" "Request failed (HTTP $http_code)" ;;
    esac
    print_field "Usage dashboard" "https://platform.openai.com/usage"
    return
  }

  local model_count
  model_count=$(echo "$response" | grep -o '"id"' | wc -l | tr -d ' ')
  print_header "OpenAI"
  print_field "Key status" "Valid ($model_count models accessible)"
  print_field "Usage dashboard" "https://platform.openai.com/usage"
}

# --------------------------------------------------------------------------
# Main
# --------------------------------------------------------------------------

if [[ "$OUTPUT_JSON" == false ]]; then
  echo "OpenClaw Quota Check — $(date '+%Y-%m-%d %H:%M %Z')"
fi

check_openrouter
check_anthropic
check_openai

if [[ "$OUTPUT_JSON" == false ]]; then
  echo ""
  echo "Note: Anthropic and OpenAI don't expose quota via API."
  echo "Check their dashboards for full usage details."
  echo ""
fi
