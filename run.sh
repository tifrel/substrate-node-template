#!/usr/bin/env bash

# key1_sr25519
# Secret phrase:       risk horn disagree black seven benefit canvas scare liberty legal sure cement
#   Secret seed:       0xd897287960ed5a0445ea52f1bc20474ff69409745afb7c2ebf56fd7155a255d9
#   Public key (hex):  0xba49ca8a03bb34b6e0c8c18bd9ebf59ba983ef0803aa9a20e2dbadfa2b58bd61
#   Account ID:        0xba49ca8a03bb34b6e0c8c18bd9ebf59ba983ef0803aa9a20e2dbadfa2b58bd61
#   Public key (SS58): 5GGxge9B7w47QBbyFriVz5NmVz6bfGoGvqNujUJeCK3ar2CB
#   SS58 Address:      5GGxge9B7w47QBbyFriVz5NmVz6bfGoGvqNujUJeCK3ar2CB
#
# key1_ed25519
# Secret phrase:       risk horn disagree black seven benefit canvas scare liberty legal sure cement
#   Secret seed:       0xd897287960ed5a0445ea52f1bc20474ff69409745afb7c2ebf56fd7155a255d9
#   Public key (hex):  0x2a00c60ad149e10fd6bcc5c4e2deb6193d4011b133cba201ba58db450c981162
#   Account ID:        0x2a00c60ad149e10fd6bcc5c4e2deb6193d4011b133cba201ba58db450c981162
#   Public key (SS58): 5D1n6eMCtNL1My15nihFwtjYajDNPucsdgQReez81wzEsAPd
#   SS58 Address:      5D1n6eMCtNL1My15nihFwtjYajDNPucsdgQReez81wzEsAPd
#
# key2_sr25519
# Secret phrase:       garbage mango hood length play hat space crop pupil surprise space cupboard
#   Secret seed:       0xc816f97961ec792b4bad6c3338a54c65ca382454b25ead5abbc617ba7d9914a7
#   Public key (hex):  0xb80dad381eb4c2274287a6d44fd1db4b6af3340805b029a65e9651800702694d
#   Account ID:        0xb80dad381eb4c2274287a6d44fd1db4b6af3340805b029a65e9651800702694d
#   Public key (SS58): 5GE2jLWvdV6XScgf8By86grKd6dcVXFVSF1w5YgKvYxU2uCL
#   SS58 Address:      5GE2jLWvdV6XScgf8By86grKd6dcVXFVSF1w5YgKvYxU2uCL
#
# key2_ed25519
# Secret phrase:       garbage mango hood length play hat space crop pupil surprise space cupboard
#   Secret seed:       0xc816f97961ec792b4bad6c3338a54c65ca382454b25ead5abbc617ba7d9914a7
#   Public key (hex):  0x550150d708807f393bcadb05f7fa59dd621f2bce43faab7c870926af665973d0
#   Account ID:        0x550150d708807f393bcadb05f7fa59dd621f2bce43faab7c870926af665973d0
#   Public key (SS58): 5DzAKQmwN2nz719TN5EGnHeJbFhiQW7Boa9uLDnUAzyWkEDa
#   SS58 Address:      5DzAKQmwN2nz719TN5EGnHeJbFhiQW7Boa9uLDnUAzyWkEDa#

argv01=(
  --base-path /tmp/node01
  --chain chainspec-raw.json
  --node-key '0x17c528a1517630cfa8210c05231d13af85e9c616d08f9233380c2be3ea608384'
  --port 30333
  --ws-port 9945
  --rpc-port 9933
  --telemetry-url 'wss://telemetry.polkadot.io/submit/ 0'
  --validator
  --rpc-methods Unsafe
  --name TifrelNode01
)
argv02=(
  --base-path /tmp/node02
  --chain chainspec-raw.json
  --port 30334
  --ws-port 9946
  --rpc-port 9934
  --telemetry-url 'wss://telemetry.polkadot.io/submit/ 0'
  --validator
  --rpc-methods Unsafe
  --name TifrelNode02
  --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWDWrURRcWPmNkCAvWcj571hZb6NPzAoWnSmHkCY5DyqbL
)


init_nodes() {
  # clear any previous state
  rm -r /tmp/node01
  rm -r /tmp/node02

  # start nodes, save PIDs, sleep to allow booting
  ./target/release/node-template "${argv01[@]}" > /dev/null 2>&1 &
  local pid01="$!"
  ./target/release/node-template "${argv02[@]}" > /dev/null 2>&1 &
  local pid02="$!"
  sleep 2

  curl http://127.0.0.1:9933 -H 'Content-Type:application/json;charset=utf-8' -d '@rpc-key01-aura.json'
  curl http://127.0.0.1:9933 -H 'Content-Type:application/json;charset=utf-8' -d '@rpc-key01-grandpa.json'
  curl http://127.0.0.1:9934 -H 'Content-Type:application/json;charset=utf-8' -d '@rpc-key02-aura.json'
  curl http://127.0.0.1:9934 -H 'Content-Type:application/json;charset=utf-8' -d '@rpc-key02-grandpa.json'
  sleep 1

  kill "$pid01"
  kill "$pid02"
}

run_node01() {
  ./target/release/node-template "${argv01[@]}"
}

run_node02() {
  ./target/release/node-template "${argv02[@]}"
}

case "$1" in
  init) init_nodes;;
  node01) run_node01;;
  node02) run_node02;;
  *) echo "Invalid chain to run.";;
esac

# cannot demonstrate in a single script for obvious reasons
