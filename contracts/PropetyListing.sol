// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./interfaces/IProNFT.sol";
import "./ProNFT.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract PropetyListing is AccessControl, Ownable {
    using Counters for Counters.Counter;
    address public marketPlaceOwner;
    IProNFT public NFTContract;
    Counters.Counter private _tokenIdCounter;
    bytes32 public constant MODERATOR_ROLE = keccak256("MODERATOR_ROLE");
    bytes32 public constant INSPECTOR_ROLE = keccak256("INSPECTOR_ROLE");
    mapping(uint => bool) public onSale;
    mapping(uint => address) public ownerOf;
    mapping(uint => bool) public isListedForSale;
    mapping(uint256 => uint256) public purchasePrice;
    mapping(uint256 => bool) public inspectionPassed;
    mapping(uint256 => mapping(address => bool)) public approval;

    event SaleStarted(uint indexed _tokenId, address indexed owner);
    event SaleCanceled(uint indexed _tokenId);
    event InspectionStatusUpdated(uint indexed _tokenId, bool _status);
    event PropertySold(address indexed _buyer, address indexed _seller, uint _tokenId);

    modifier onlyNFTOwner(uint _tokenId) {
        require(ownerOf[_tokenId] == msg.sender, "Only Owner can put for sale");
        _;
    }

    constructor(address _nftContractAddress, address _inspectorAddress, address _moderatorAddress) {
        marketPlaceOwner = msg.sender;
        _grantRole(MODERATOR_ROLE, _moderatorAddress);
        _grantRole(INSPECTOR_ROLE, _inspectorAddress);
        NFTContract = IProNFT(_nftContractAddress);
    }

    function mint(string memory tokenURI) public returns (uint256) {
        _tokenIdCounter.increment();
        uint256 newItemId = _tokenIdCounter.current();
        NFTContract.safeMint(msg.sender, tokenURI, newItemId);
        return newItemId;
    }

    function putOnSale(
        uint256 _nftID,
        uint256 _purchasePrice,
        bytes calldata dataByte
    ) public payable onlyNFTOwner(_nftID) {
        // Transfer NFT from seller to this contract
        NFTContract.safeTransferFrom(msg.sender, address(this), _nftID, dataByte);
        isListedForSale[_nftID] = true;
        purchasePrice[_nftID] = _purchasePrice;
        emit SaleStarted(_nftID, msg.sender);
    }

    function totalItemsonSale() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function updateInspectionStatus(uint256 _nftID, bool _passed) public onlyRole(INSPECTOR_ROLE) {
        inspectionPassed[_nftID] = _passed;
        emit InspectionStatusUpdated(_nftID, _passed);
    }

    function cancelSale(uint256 _nftID, bytes calldata data) public {
        isListedForSale[_nftID] = false;
        NFTContract.safeTransferFrom(address(this), ownerOf[_nftID], _nftID, data);
        emit SaleCanceled(_nftID);
    }

    function buyProperty(uint256 _nftID, bytes calldata data) public {
        require(inspectionPassed[_nftID], "PropetyListing: inspection must be passed");
        // TODO: add require checking balance of our token for msg.sender
        isListedForSale[_nftID] = false;
        //TODO: transfer tokens to seller
        // payable(seller).transfer(amount);
        NFTContract.safeTransferFrom(address(this), ownerOf[_nftID], _nftID, data);
    }
}
