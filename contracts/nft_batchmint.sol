// SPDX-License-Identifier: GPL-3.0
//Contract has issue with baseuri you can either have base uri or token uri way
pragma solidity >=0.7.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string public baseURI;
    string public baseExtension = ".json";
    uint256 public cost = 0.05 ether; // cost for other than owners to mint
    uint256 public maxSupply = 10000;
    uint256 public maxMintAmount = 100;
    bool public paused = false;
    mapping(address => bool) public whitelisted;
    mapping(uint256 => string) private _tokenURIs;

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */

    constructor(
        string memory _name,
        string memory _symbol,
        string memory _initBaseURI,
        uint256 _initialMintAmount
    ) ERC721(_name, _symbol) {
        setBaseURI(_initBaseURI);
        mint(msg.sender, _initialMintAmount);
    }

    /**
     * @dev Overriden Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    /**
     * @dev Safely mints `tokenId` and transfers it to `to`.
     *
     * Requirements:
     * - Mintnig not paused by owner
     * - Mint amount is greater than zero and less than allowed maxMintAmount
     * - After minting total supply does not exceed max supply
     *
     * Emits a {Transfer} event in parent contract.
     */
    function mint(address _to, uint256 _mintAmount) public payable {
        uint256 supply = totalSupply();
        require(!paused);
        require(_mintAmount > 0);
        require(_mintAmount <= maxMintAmount);
        require(supply + _mintAmount <= maxSupply);

        if (msg.sender != owner()) {
            if (whitelisted[msg.sender] != true) {
                require(msg.value >= cost * _mintAmount);
            }
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            _safeMint(_to, supply + i);
        }
    }

    /**
     * @dev Returns all the token of an address. This is why we use ERC721Enumerable.
     */
    function walletOfOwner(address _owner)
        public
        view
        returns (uint256[] memory)
    {
        uint256 ownerTokenCount = balanceOf(_owner);
        uint256[] memory tokenIds = new uint256[](ownerTokenCount);
        for (uint256 i; i < ownerTokenCount; i++) {
            tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
        }
        return tokenIds;
    }

    /**
     * @dev Returns URI of a token.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "ERC721URIStorage: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If there is no base URI, return the token URI.
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        // If both are set, concatenate the baseURI and tokenURI (via abi.encodePacked).
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }

        return super.tokenURI(tokenId);
    }
    
    /**
     * @dev Sets `_tokenURI` as the tokenURI of `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721URIStorage: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    /**
     * @dev Owner can set/change cost for other to pay.
     */
    function setCost(uint256 _newCost) public onlyOwner {
        cost = _newCost;
    }
    /**
     * @dev Owner can set/change maxMintAmount.
     */
    function setmaxMintAmount(uint256 _newmaxMintAmount) public onlyOwner {
        maxMintAmount = _newmaxMintAmount;
    }
    /**
     * @dev Owner can set/change baseURI.
     */
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        baseURI = _newBaseURI;
    }
    /**
     * @dev Owner can set/change Base ext.
     */
    function setBaseExtension(string memory _newBaseExtension)
        public
        onlyOwner
    {
        baseExtension = _newBaseExtension;
    }
    /**
     * @dev Owner can pause contract in case of emergency. This will stop anyone to use mint function.
     */
    function pause(bool _state) public onlyOwner {
        paused = _state;
    }
    /**
     * @dev Owner can whitelist address which can mint without paying cost.
     */
    function whitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = true;
    }
    /**
     * @dev Owner can remove address from whitelist.
     */
    function removeWhitelistUser(address _user) public onlyOwner {
        whitelisted[_user] = false;
    }
    /**
     * @dev Owner can withdraw funds from contract to owner address.
     */
    function withdraw() public payable onlyOwner {
        (bool success, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(success);
    }
}
