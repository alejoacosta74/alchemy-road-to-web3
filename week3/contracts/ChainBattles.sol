// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";


contract ChainBattles is ERC721URIStorage {
    // libraries initialization
    using Strings for uint256;
    using Counters for Counters.Counter; 
    uint initialNumber = 0;

    Counters.Counter private _tokenIds; // used to calculate the token id
    mapping(uint256 => string) public tokenIdToNames; // stores the name of each token id
    mapping(uint256 => Stats) public tokenIdToStats;

    struct Stats {
        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;
    }

    constructor() ERC721 ("Chain Battles", "CBTLS"){

    }
    
    // to generate and update the SVG image of our NFT
    function generateCharacter(uint256 tokenId) public view returns(string memory){

        uint256 level;
        uint256 speed;
        uint256 strength;
        uint256 life;

        (level, speed, strength, life) = getStats(tokenId);

        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            '<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>',
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',"Warrior",'</text>',
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',"Name: ", getName(tokenId),'</text>',
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">', "Levels: ",level,'</text>',
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">', "Speed: ",speed,'</text>',
            '<text x="50%" y="75%" class="base" dominant-baseline="middle" text-anchor="middle">', "Strength: ",strength,'</text>',
            '<text x="50%" y="80%" class="base" dominant-baseline="middle" text-anchor="middle">', "Life: ",life,'</text>',
            '</svg>'
        );
        return string(
            abi.encodePacked(
                "data:image/svg+xml;base64,",
                Base64.encode(svg)
            )    
        );
    }

     // to get the current name associated to the NFT
    function getName(uint256 tokenId) public view returns (string memory) {
        string memory name = tokenIdToNames[tokenId];
        return name;
    }

    function getStats(uint256 tokenId) internal view returns (uint256, uint256, uint256, uint256) {
        uint256 level = tokenIdToStats[tokenId].level;
        uint256 speed = tokenIdToStats[tokenId].speed;
        uint256 strength = tokenIdToStats[tokenId].strength;
        uint256 life = tokenIdToStats[tokenId].life;

        return (level, speed, strength, life);
    }

    // get the TokenURI of an NFT
    function getTokenURI(uint256 tokenId) public view returns (string memory){
        bytes memory dataURI = abi.encodePacked(
            '{',
                '"name": "Chain Battles #', tokenId.toString(), '",',
                '"description": "Battles on chain",',
                '"image": "', generateCharacter(tokenId), '"',
            '}'
        );
        return string(
            abi.encodePacked(
                "data:application/json;base64,",
                Base64.encode(dataURI)
            )
        );
    }

    function mint(string memory name) public returns (uint256) {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        _safeMint(msg.sender, newItemId);
        tokenIdToNames[newItemId] = name;
        tokenIdToStats[newItemId].level = 0;
        tokenIdToStats[newItemId].speed = getRandomNumber(newItemId);
        tokenIdToStats[newItemId].strength = getRandomNumber(newItemId);
        tokenIdToStats[newItemId].life = getRandomNumber(newItemId);
        _setTokenURI(newItemId, getTokenURI(newItemId));
        return newItemId;
    }
    
    // train an NFT and raise its level
    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(ownerOf(tokenId) == msg.sender, "You must own this NFT to train it!");
        uint256 currentLevel = tokenIdToStats[tokenId].level;
        tokenIdToStats[tokenId].level = currentLevel + 1;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function getRandomNumber(uint256 number) internal returns (uint){       
        return uint(keccak256(abi.encodePacked(initialNumber++))) % number;
    }
    
}