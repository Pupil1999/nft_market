import { createPublicClient, http, getContract } from 'viem'
import { abi } from '../out/Nft.sol/ERC721A.json';
import { mainnet } from 'viem/chains'
 
async function main() {
    const client = createPublicClient({ 
        chain: mainnet, 
        transport: http(), 
    })

    const someOwner = await client.readContract({
        address: '0x0483B0DFc6c78062B9E999A82ffb795925381415',
        abi: abi,
        functionName: 'ownerOf',
        args: [403n]
    })

    console.log("Token 403 is owned by:", someOwner)

    const tokenURI = await client.readContract({
        address: "0x0483B0DFc6c78062B9E999A82ffb795925381415",
        abi: abi,
        functionName: 'tokenURI',
        args: [403n]
    })

    console.log("And the token URI is:", tokenURI)
}

main().catch(error => {
    console.error("Uncaught Error:", error);
});