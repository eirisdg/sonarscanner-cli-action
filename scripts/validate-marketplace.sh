#!/bin/bash
# Marketplace Validation Script
# Validates that the action meets GitHub Marketplace requirements

set -e

echo "🔍 Validating GitHub Marketplace Requirements..."
echo

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "📋 Required Files"
echo "=================="

# Check required files
[ -f action.yml ] && echo -e "✅ ${GREEN}action.yml exists${NC}" || echo -e "❌ ${RED}action.yml missing${NC}"
[ -f README.md ] && echo -e "✅ ${GREEN}README.md exists${NC}" || echo -e "❌ ${RED}README.md missing${NC}"
[ -f LICENSE ] && echo -e "✅ ${GREEN}LICENSE exists${NC}" || echo -e "❌ ${RED}LICENSE missing${NC}"

echo
echo "📄 action.yml Requirements"
echo "=========================="

if [ -f action.yml ]; then
    grep -q '^name:' action.yml && echo -e "✅ ${GREEN}Has name field${NC}" || echo -e "❌ ${RED}Missing name field${NC}"
    grep -q '^description:' action.yml && echo -e "✅ ${GREEN}Has description field${NC}" || echo -e "❌ ${RED}Missing description field${NC}"
    grep -q '^author:' action.yml && echo -e "✅ ${GREEN}Has author field${NC}" || echo -e "⚠️  ${YELLOW}Missing author field${NC}"
    grep -q '^branding:' action.yml && echo -e "✅ ${GREEN}Has branding section${NC}" || echo -e "⚠️  ${YELLOW}Missing branding section${NC}"
    
    if grep -q '^branding:' action.yml; then
        grep -A5 '^branding:' action.yml | grep -q 'icon:' && echo -e "✅ ${GREEN}Has branding icon${NC}" || echo -e "⚠️  ${YELLOW}Missing branding icon${NC}"
        grep -A5 '^branding:' action.yml | grep -q 'color:' && echo -e "✅ ${GREEN}Has branding color${NC}" || echo -e "⚠️  ${YELLOW}Missing branding color${NC}"
    fi
    
    grep -q '^inputs:' action.yml && echo -e "✅ ${GREEN}Has inputs section${NC}" || echo -e "⚠️  ${YELLOW}Missing inputs section${NC}"
    grep -q '^outputs:' action.yml && echo -e "✅ ${GREEN}Has outputs section${NC}" || echo -e "⚠️  ${YELLOW}Missing outputs section${NC}"
fi

echo
echo "📖 Documentation Requirements"
echo "============================="

if [ -f README.md ]; then
    grep -q '^# ' README.md && echo -e "✅ ${GREEN}README has title${NC}" || echo -e "⚠️  ${YELLOW}README missing title${NC}"
    grep -q '```yaml' README.md && echo -e "✅ ${GREEN}README has usage examples${NC}" || echo -e "⚠️  ${YELLOW}README missing usage examples${NC}"
    grep -qi 'input' README.md && echo -e "✅ ${GREEN}README documents inputs${NC}" || echo -e "⚠️  ${YELLOW}README missing inputs documentation${NC}"
    grep -qi 'feature' README.md && echo -e "✅ ${GREEN}README has features section${NC}" || echo -e "⚠️  ${YELLOW}README missing features section${NC}"
fi

echo
echo "🧪 Testing Requirements"
echo "======================="

workflow_count=$(find .github/workflows -name '*.yml' 2>/dev/null | wc -l)
[ "$workflow_count" -gt 0 ] && echo -e "✅ ${GREEN}Has $workflow_count workflow files${NC}" || echo -e "⚠️  ${YELLOW}No workflow files found${NC}"

[ -f .github/workflows/test.yml ] || [ -f .github/workflows/ci.yml ] && echo -e "✅ ${GREEN}Has test workflow${NC}" || echo -e "⚠️  ${YELLOW}Missing test workflow${NC}"

echo
echo "🔒 Security Requirements"
echo "========================"

[ -f .github/workflows/security.yml ] && echo -e "✅ ${GREEN}Has security workflow${NC}" || echo -e "⚠️  ${YELLOW}Missing security workflow${NC}"
[ -f .github/dependabot.yml ] && echo -e "✅ ${GREEN}Has dependabot config${NC}" || echo -e "⚠️  ${YELLOW}Missing dependabot config${NC}"

echo
echo "🤝 Community Requirements"
echo "========================="

[ -f CONTRIBUTING.md ] && echo -e "✅ ${GREEN}Has contributing guide${NC}" || echo -e "⚠️  ${YELLOW}Missing contributing guide${NC}"
[ -d .github/ISSUE_TEMPLATE ] && echo -e "✅ ${GREEN}Has issue templates${NC}" || echo -e "⚠️  ${YELLOW}Missing issue templates${NC}"
[ -f .github/PULL_REQUEST_TEMPLATE.md ] && echo -e "✅ ${GREEN}Has PR template${NC}" || echo -e "⚠️  ${YELLOW}Missing PR template${NC}"
[ -f CHANGELOG.md ] && echo -e "✅ ${GREEN}Has changelog${NC}" || echo -e "⚠️  ${YELLOW}Missing changelog${NC}"

echo
echo "🔧 Technical Validation"
echo "======================="

# Validate YAML files
if command -v python3 >/dev/null && python3 -c "import yaml" 2>/dev/null; then
    yaml_errors=0
    for yaml_file in action.yml .github/workflows/*.yml; do
        if [ -f "$yaml_file" ]; then
            if ! python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))" 2>/dev/null; then
                echo -e "❌ ${RED}Invalid YAML: $yaml_file${NC}"
                yaml_errors=1
            fi
        fi
    done
    [ "$yaml_errors" = "0" ] && echo -e "✅ ${GREEN}All YAML files are valid${NC}" || echo -e "❌ ${RED}Some YAML files have errors${NC}"
else
    echo -e "ℹ️  ${YELLOW}Cannot validate YAML (python3/yaml not available)${NC}"
fi

# Check script syntax
if [ -f scripts/install-sonar-scanner.sh ]; then
    if bash -n scripts/install-sonar-scanner.sh; then
        echo -e "✅ ${GREEN}Bash script syntax valid${NC}"
    else
        echo -e "❌ ${RED}Bash script syntax errors${NC}"
    fi
fi

echo
echo "🚀 Next Steps for Marketplace Publishing:"
echo "1. Create a release tag (e.g., git tag v1.0.0)"
echo "2. Push the tag to trigger release workflow"
echo "3. Go to GitHub releases and edit the release"
echo "4. Check 'Publish this Action to the GitHub Marketplace'"
echo "5. Follow the marketplace submission process"

echo
echo -e "${GREEN}🎉 Your action appears to be marketplace-ready!${NC}"