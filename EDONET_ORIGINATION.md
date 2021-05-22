
```bash
❯❯❯ tezos-client --wait none originate contract SplitTezTest \
  transferring 0 from $BOB_ADDRESS running \
  "$(cat split_tez.tz | tr -d '\n')" \
  --init "Pair 0 {}" --burn-cap 0.21275
Waiting for the node to be bootstrapped...
Current head: BLmWKz67vM8L (timestamp: 2021-05-13T20:59:25.000-00:00, validation: 2021-05-13T20:59:49.973-00:00)
Node is bootstrapped.
Estimated gas: 4064.994 units (will add 100 for safety)
Estimated storage: 851 bytes added (will add 20 for safety)
Operation successfully injected in the node.
Operation hash is 'op6DTV2feTYr5yL22Uw2xLQCBivHu5DcqxnDT6nyrqqWfgCbXcC'
NOT waiting for the operation to be included.
Use command
  tezos-client wait for op6DTV2feTYr5yL22Uw2xLQCBivHu5DcqxnDT6nyrqqWfgCbXcC to be included --confirmations 30 --branch BLmWKz67vM8LuWQcV7PFXqFPFrm5vJMhoXkGgLiwre4PnAjs25n
and/or an external block explorer to make sure that it has been included.
This sequence of operations was run:
  Manager signed operations:
    From: tz1bDCu64RmcpWahdn9bWrDMi6cu7mXZynHm
    Fee to the baker: ꜩ0.001208
    Expected counter: 489314
    Gas limit: 4165
    Storage limit: 871 bytes
    Balance updates:
      tz1bDCu64RmcpWahdn9bWrDMi6cu7mXZynHm .................. -ꜩ0.001208
      fees(the baker who will include this operation,122) ... +ꜩ0.001208
    Origination:
      From: tz1bDCu64RmcpWahdn9bWrDMi6cu7mXZynHm
      Credit: ꜩ0
      Script:
        { parameter
            (or (option %setDelegate key_hash)
                (or (unit %default) (list %flush (pair nat address)))) ;
          storage (pair (nat %totalBalance) (big_map %ledger address (pair nat nat))) ;
          code { DUP ;
                 CAR ;
                 DIP { CDR } ;
                 IF_LEFT
                   { SENDER ;
                     PUSH address "tz1QS8VYYVDjv7iReBzXeheL6x63A1oATTj8" ;
                     COMPARE ;
                     EQ ;
                     IF { SET_DELEGATE ; NIL operation ; SWAP ; CONS } { FAILWITH } }
                   { IF_LEFT
                       { DROP ;
                         DUP ;
                         CAR ;
                         DIP { CDR } ;
                         BALANCE ;
                         PUSH mutez 1 ;
                         EDIV ;
                         IF_NONE { FAILWITH } { CAR ; ADD ; PAIR ; NIL operation } }
                       { SWAP ;
                         DUP ;
                         CAR ;
                         DIP { CDR } ;
                         DUP ;
                         DIP { PUSH nat 0 ;
                               EDIV ;
                               IF_NONE
                                 { UNIT ; FAILWITH }
                                 { CAR ;
                                   SWAP ;
                                   DIG 2 ;
                                   MAP { DUP ;
                                         DUP ;
                                         CAR ;
                                         DIP { CDR } ;
                                         PUSH mutez 1 ;
                                         MUL ;
                                         SWAP ;
                                         CONTRACT unit ;
                                         IF_NONE
                                           { FAILWITH }
                                           { SWAP ;
                                             UNIT ;
                                             TRANSFER_TOKENS ;
                                             DIP { DUP ;
                                                   CAR ;
                                                   DIP { CDR } ;
                                                   SWAP ;
                                                   DUP ;
                                                   DIP { DIP { SWAP ; DUP } ;
                                                         GET ;
                                                         IF_NONE
                                                           { UNIT ; FAILWITH }
                                                           { DUP ;
                                                             CAR ;
                                                             DIP { CDR } ;
                                                             DUP ;
                                                             DIP { DIG 4 ;
                                                                   DUP ;
                                                                   DIP { MUL ;
                                                                         SWAP ;
                                                                         DIG 3 ;
                                                                         ADD ;
                                                                         DUP ;
                                                                         DIP { COMPARE ; LE ; IF {} { UNIT ; FAILWITH } } } ;
                                                                   DUG 2 } ;
                                                             PAIR ;
                                                             SOME } } ;
                                                   UPDATE } } } ;
                                   DIG 2 ;
                                   DROP ;
                                   SWAP } } ;
                         PAIR ;
                         SWAP } } ;
                 PAIR } }
        Initial storage: (Pair 0 {})
        No delegate for this contract
        This origination was successfully applied
        Originated contracts:
          KT1Fkgxe64aCcb1WvDUeg8vCsMhH3GU3VKFB
        Storage size: 594 bytes
        Updated big_maps:
          New map(104578) of type (big_map address (pair nat nat))
        Paid storage size diff: 594 bytes
        Consumed gas: 4064.994
        Balance updates:
          tz1bDCu64RmcpWahdn9bWrDMi6cu7mXZynHm ... -ꜩ0.1485
          tz1bDCu64RmcpWahdn9bWrDMi6cu7mXZynHm ... -ꜩ0.06425

New contract KT1Fkgxe64aCcb1WvDUeg8vCsMhH3GU3VKFB originated.
Contract memorized as SplitTezTest.
```


