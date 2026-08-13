import json, subprocess, os, random, string

def random_address():
    return '0x' + ''.join(random.choices(string.hexdigits.lower(), k=40))

# Generate 5 random recipients
recipients = []
for i in range(5):
    recipients.append(random_address())

print(f"Generated {len(recipients)} random recipients")

tokens = [
    ('0xb50DCEb0570557B9B7FE43D8cBDc9B3457D3dc5a', 'SGUIDE', '100000000000000000000'),
    ('0x38e4f08D08b4D772A7B75669C356b4749dd2d30b', 'VDOO', '100000000000000000000'),
    ('0x2a92CAA3b01E64634e2E95AA533a5570a76c19A7', 'PENNIES CHEQ', '100000000000000000000')
]

for recipient in recipients:
    print(f"\nSending to {recipient}...")
    for token_addr, name, amount in tokens:
        result = subprocess.run(
            ['cast','send',token_addr,'transfer(address,uint256)',recipient,amount,
             '--rpc-url','https://mainnet.base.org',
             '--private-key',os.environ['PRIVATE_KEY'],
             '--legacy','--gas-price','500000000'],
            capture_output=True, text=True
        )
        if result.returncode == 0:
            print(f"  ✅ {name}")
        else:
            print(f"  ❌ {name}: {result.stderr[:60]}")

print("\n✅ Random airdrop complete!")
