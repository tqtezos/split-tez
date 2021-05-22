
# Split Tez

This repo includes a contract to split inbound Tez among a fixed list
of receivers:

```ocaml
parameter (or (option %setDelegate key_hash)
              (or (unit %default)
                  (list %flush (pair nat
                                     address))));
```

Design doc: https://gist.github.com/michaeljklein/125bfe8737876f3cca4926acf9120356

## Contract Source

[`split_tez.tz`](./contracts/split_tez.tz)

