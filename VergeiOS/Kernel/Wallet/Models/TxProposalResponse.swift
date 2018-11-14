//
// Created by Swen van Zanten on 13/11/2018.
// Copyright (c) 2018 Verge Currency. All rights reserved.
//

import Foundation

/*
{
  "createdOn" : 1542091984,
  "coin" : "btc",
  "id" : "2f72ba69-dcc6-4cc6-ba32-b98612ef9a30",
  "network" : "testnet",
  "message" : "{\"iv\":\"YJ+Uy4zFZ1M5SOtmAYsNvQ==\",\"v\":1,\"iter\":1,\"ks\":128,\"ts\":64,\"mode\":\"ccm\",\"adata\":\"\",\"cipher\":\"aes\",\"ct\":\"fGj7mpBeO7I=\"}",
  "walletN" : 1,
  "inputs" : [
    {
      "publicKeys" : [
        "02a93d08b03b67e0869fe8ed550e007a946af31175a67cfaad6b53895c874b7f26"
      ],
      "scriptPubKey" : "76a91440eabfadadd4e5b6349e700418d96f7a72b588be88ac",
      "vout" : 0,
      "path" : "m\/0\/0",
      "satoshis" : 10283000,
      "txid" : "4e2480194d1c65ddb4fd24b02cfd7319cabf0abd7c0505db962da0a7dae9cc3a",
      "locked" : false,
      "confirmations" : 71,
      "address" : "mmSCkxd9SPGhzVt4NSXcXYjzJXtfkMPRdq"
    }
  ],
  "fee" : 2430,
  "status" : "temporary",
  "creatorId" : "7f6683ddf9d62094e2e9cab0fc88d0ae6fa36d8c83de462a6c35159f6aee27e0",
  "payProUrl" : null,
  "walletM" : 1,
  "outputs" : [
    {
      "amount" : 1000000,
      "message" : null,
      "toAddress" : "2NGZrVvZG92qGYqzTLjCAewvPZ7JE8S8VxE"
    }
  ],
  "amount" : 1000000,
  "changeAddress" : {
    "isChange" : true,
    "coin" : "btc",
    "publicKeys" : [
      "039cf46054cfe49c0b487d5710394090c75e143ba4510dde8e292694d4156687f8"
    ],
    "type" : "P2PKH",
    "version" : "1.0.0",
    "path" : "m\/1\/0",
    "walletId" : "1b10b4bf-7974-42fb-ab2c-3e928aefc974",
    "createdOn" : 1542091984,
    "network" : "testnet",
    "address" : "mitpGcXMKqqGhhCGQMpatZZEBryEGGTYkU",
    "_id" : "5bea74d0ece276045c55e21b"
  },
  "walletId" : "1b10b4bf-7974-42fb-ab2c-3e928aefc974",
  "requiredSignatures" : 1,
  "version" : 3,
  "actions" : [

  ],
  "excludeUnconfirmedUtxos" : false,
  "addressType" : "P2PKH",
  "requiredRejections" : 1,
  "feePerKb" : 10000,
  "outputOrder" : [
    1,
    0
  ],
  "inputPaths" : [
    "m\/0\/0"
  ]
}
*/

public struct TxProposalResponse {

}
