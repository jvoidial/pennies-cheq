#!/bin/bash
# Airdrop Manager - Add recipients and send tokens

add_recipient() {
    echo "Enter recipient address (0x...):"
    read ADDRESS
    # Add to airdrop-addresses.json
    python3 -c "
import json
with open('airdrop-addresses.json', 'r') as f:
    data = json.load(f)
if '$ADDRESS' not in data['recipients']:
    data['recipients'].append('$ADDRESS')
    with open('airdrop-addresses.json', 'w') as f:
        json.dump(data, f, indent=2)
    print('✅ Added $ADDRESS')
else:
    print('⚠️ Address already in list')
"
}

view_recipients() {
    echo "Current recipients:"
    python3 -c "
import json
with open('airdrop-addresses.json', 'r') as f:
    data = json.load(f)
for i, addr in enumerate(data['recipients'], 1):
    print(f'{i}. {addr}')
print(f'\nTotal: {len(data[\"recipients\"])} recipients')
"
}

send_airdrop() {
    echo "Sending airdrop to all recipients..."
    gh workflow run airdrop.yml --repo jvoidial/pennies-cheq
    echo "✅ Airdrop triggered!"
    sleep 5
    RID=$(gh run list --repo jvoidial/pennies-cheq --workflow="Airdrop All Three Tokens" --limit 1 --json databaseId --jq '.[0].databaseId')
    echo "Watch: https://github.com/jvoidial/pennies-cheq/actions/runs/$RID"
}

# Menu
echo ""
echo "🎁 AIRDROP MANAGER"
echo "=================="
echo "1. Add recipient"
echo "2. View recipients"
echo "3. Send airdrop now"
echo "4. Exit"
echo ""
read -p "Choose option: " OPTION

case $OPTION in
    1) add_recipient ;;
    2) view_recipients ;;
    3) send_airdrop ;;
    4) exit 0 ;;
    *) echo "Invalid option" ;;
esac
