it("Get byte code", async function () {  
    
    //await TokenContract.connect(owner).mint(addr1.address, 5 * ETHERS);
    //expect(await TokenContract.balanceOf(addr1.address)).to.equal(5 * ETHERS);

    byteCode = web3.eth.abi.encodeFunctionCall({
        "inputs": [
            {
                "internalType": "uint256",
                "name": "",
                "type": "uint256"
            }
        ],
        "name": "proposals",
        "outputs": [
            {
                "internalType": "uint256",
                "name": "endTimeOfVoting",
                "type": "uint256"
            },
        ],
        "type": "function"        
    }, [0]);


});