//  Use "SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

interface IProNFT {
    function _baseURI() external pure returns (string memory);

    function safeMint(address to, string memory uri, uint tokenId) external;

    function _burn(uint256 tokenId) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function supportsInterface(bytes4 interfaceId) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}
