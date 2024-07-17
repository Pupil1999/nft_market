import { createPublicClient, http, parseAbiItem } from 'viem';
import { mainnet } from 'viem/chains';
import { config } from 'dotenv';

async function getLatest100BlocksTransferEvents() {
  config();
  const client = createPublicClient({
    chain: mainnet,
    transport: http(`https://mainnet.infura.io/v3/${process.env.INFURA_API_KEY}`),
  });
  
  // Get the latest block number
  const latestBlockNumber = await client.getBlockNumber();

  // Define the start and end block numbers
  const startBlock = latestBlockNumber - BigInt(99);
  const endBlock = latestBlockNumber;

  // Create an event filter for Transfer events within the last 100 blocks
  const filter = await client.createEventFilter({
    address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
    event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'),
    fromBlock: startBlock,
    toBlock: endBlock,
  });

  // Get logs for the Transfer events
  const logs = await client.getFilterLogs({filter});

  // Process the logs as needed
  const outputs = logs.map(log => {
    const { from, to, value } = log.args;
    const txid = log.transactionHash;
    return `Transfer from ${from} to ${to} USDC ${value?.toString()}, txID:${txid}`;
  });

  outputs.forEach(log => console.log(log));
  
}

async function main(){
    // Execute the function to get the latest 100 blocks Transfer events
    getLatest100BlocksTransferEvents().catch(console.error);
}

main().catch(error => {
    console.error("Uncaught Error:", error);
});