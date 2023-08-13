# InterGas-Station-SuperHack

Project Description

As many new chains are being developed in OpStack, users find it difficult to bridge their ETH onto these chains. Thus, using our product you can use your ETH on any chain to pay for gas fees in any remote chain. Later you can also use any ERC20 tokens to pay for it as well. Moreover, our solution is permissionless, anybody who has ETH in their account can create their own gas station and the users can use it to pay for their gas fees.

How it's Made

Hyperlane is the core of this project. The user signs the calldata which he/she wants to execute on the parent chain and submits the signature details and other important data to the remote station contract along with the required gas fees on the remote chain. This remote station contract verifies the signature and then passes on the details to the parent chain, and then the parent chain executes the calldata on behalf of the user.

You can find the frontend in :- super_swaph folder.
You can find the contracts in the src folder.

Contract Addresses:- 
Optimism Goerli:- 0x52A868439FEa090Bcf7a5a0d8483187d3095C58F
Base Goerli:- 0x2A67Cf654F8EE1660639938BE9f3e30522A443b6
