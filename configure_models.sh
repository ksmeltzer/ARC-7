#!/usr/bin/env bash

PROVIDER="github_copilot"

while [[ "$#" -gt 0 ]]; do
    case $1 in
        --provider) PROVIDER="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

echo "✅ Generated Configuration for Provider: $PROVIDER"
echo "Copy and paste this block into your global opencode.json or agent config file:"
echo "--------------------------------------------------"
echo "{"
echo '  "agent": {'

FIRST=1
for file in agents/ARC-7/arc7-*.md; do
    filename=$(basename "$file" .md)
    model=$(grep 'recommended_model:' "$file" | sed -E 's/.*"([^"]+)".*/\1/')
    
    # Map abstract models to provider specifics
    case "$PROVIDER" in
        "github_copilot") 
            provider_model="github-copilot/$model" 
            ;;
        "openai_anthropic_direct") 
            if [[ "$model" == *"claude"* ]]; then provider_model="anthropic/claude-3-5-sonnet-latest"; 
            elif [[ "$model" == *"gemini"* ]]; then provider_model="google/gemini-3.1-pro-preview";
            else provider_model="openai/gpt-4o"; fi
            ;;
        "openrouter")
            if [[ "$model" == *"claude"* ]]; then provider_model="openrouter/anthropic/claude-3.5-sonnet"; 
            elif [[ "$model" == *"gemini"* ]]; then provider_model="openrouter/google/gemini-3.1-pro";
            else provider_model="openrouter/openai/gpt-4o"; fi
            ;;
        *) 
            provider_model="$model" 
            ;;
    esac
    
    if [ $FIRST -eq 0 ]; then echo ","; fi
    printf '    "%s": { "model": "%s" }' "$filename" "$provider_model"
    FIRST=0
done

echo
echo "  }"
echo "}"
echo "--------------------------------------------------"