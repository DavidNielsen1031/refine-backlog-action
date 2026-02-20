#!/usr/bin/env bash
# Validates the action.yml structure
set -e

ACTION_YML="$(dirname "$0")/../action.yml"
ACTION_README="$(dirname "$0")/../README.md"

echo "🔍 Validating action.yml..."
python3 -c "
import yaml, sys
with open('$ACTION_YML') as f:
    data = yaml.safe_load(f)

required = ['name', 'description', 'inputs', 'outputs', 'runs']
missing = [k for k in required if k not in data]
if missing:
    print(f'❌ Missing required fields: {missing}'); sys.exit(1)

required_inputs = ['items', 'file', 'key', 'user-stories', 'gherkin', 'context', 'output-file', 'write-back']
missing_inputs = [i for i in required_inputs if i not in data['inputs']]
if missing_inputs:
    print(f'❌ Missing inputs: {missing_inputs}'); sys.exit(1)

required_outputs = ['refined', 'count']
missing_outputs = [o for o in required_outputs if o not in data['outputs']]
if missing_outputs:
    print(f'❌ Missing outputs: {missing_outputs}'); sys.exit(1)

if data['runs']['using'] != 'composite':
    print(f'❌ Expected composite'); sys.exit(1)

print(f'✅ action.yml valid — {len(data[\"runs\"][\"steps\"])} steps, {len(data[\"inputs\"])} inputs, {len(data[\"outputs\"])} outputs')
"

echo ""
echo "🔍 Validating README..."
python3 -c "
import yaml, sys
with open('$ACTION_YML') as f:
    action = yaml.safe_load(f)
with open('$ACTION_README') as f:
    readme = f.read()
missing = [k for k in list(action['inputs'].keys()) + list(action['outputs'].keys()) if k not in readme]
if missing:
    print(f'❌ README missing: {missing}'); sys.exit(1)
print('✅ README documents all inputs and outputs')
"

echo ""
echo "🎉 All checks passed!"
