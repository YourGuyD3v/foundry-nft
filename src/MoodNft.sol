// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract MoodNft is ERC721, Ownable {
    // errors
    error MoodNft__CantFlipMoodIfNotOwner();

    uint256 private s_tokenCounter;
    string private s_sadMoodImageUri;
    string private s_happyMoodImageUri;

    enum MoodState {
        HAPPY,
        SAD
    }

    mapping(uint256 => MoodState) private s_tokenIdToState;

    constructor(string memory sadMoodImageUri, string memory happyMoodImageUri) ERC721("Mood", "MN") {
        s_tokenCounter = 0;
        s_sadMoodImageUri = sadMoodImageUri;
        s_happyMoodImageUri = happyMoodImageUri;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function flipMood(uint256 tokenId) public {
        if (!_isApprovedOrOwner(msg.sender, tokenId)) {
            revert MoodNft__CantFlipMoodIfNotOwner();
        }

        if (s_tokenIdToState[tokenId] == MoodState.HAPPY) {
            s_tokenIdToState[tokenId] = MoodState.SAD;
        } else {
            s_tokenIdToState[tokenId] = MoodState.HAPPY;
        }
    }

    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        string memory imageURI = s_happyMoodImageUri;

        if (s_tokenIdToState[tokenId] == MoodState.SAD) {
            imageURI = s_sadMoodImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name":"',
                            name(),
                            '", "description":"An NFT that reflects the mood of the owner, 100% on Chain!", ',
                            '"attributes": [{"trait_type": "moodiness", "value": 100}], "image":"',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    function getHappySVG() public view returns (string memory) {
        return s_happyMoodImageUri;
    }

    function getSadSVG() public view returns (string memory) {
        return s_sadMoodImageUri;
    }

    function getTokenCounter() public view returns (uint256) {
        return s_tokenCounter;
    }
}
