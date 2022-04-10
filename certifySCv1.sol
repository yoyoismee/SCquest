// SPDX-License-Identifier: MIT
// author: yoyoismee.eth -- it's opensource but also feel free to send me coffee/beer.
pragma solidity 0.8.13;
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Base64.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Certificate is ERC721Enumerable {
    using Strings for uint256;

    address constant beneficiary = 0x6647a7858a0B3846AbD5511e7b797Fc0a0c63a4b; // irrelevant

    string part1 =
        '<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="700" version="1.1"><style>.small { font: italic 25px sans-serif; } .mini { font: italic 20px sans-serif; } .heavy { font: bold 35px sans-serif; }</style>  <text x="300" y="200" class="heavy">Certify Smart Contract Developer lv ';
    string part2 =
        '</text>  <text x="250" y="300" class="small">This certificate is awarded to :  ';
    string defaultOwner = "the owner of this NFT";
    string part3 =
        '</text>  <text x="200" y="350" class="mini">The Owner of this certificate either have good knowledge about smart contract.</text>  <text x="200" y="400" class="mini">or spent enough money to buy one</text>  <text x="600" y="600" class="mini">Certify by: yoyoismee.eth</text></svg>';

    mapping(uint256 => string) ownerNames;
    mapping(uint256 => uint256) level;
    mapping(uint256 => bool) used;

    uint256 public price = 200 ether;
    uint256 private realPrice = 100 ether;
    uint256 private lv1Price = 20 ether;
    uint256 masterPrice = 1 ether;

    constructor() ERC721("Certify SC dev", "CSC") {}

    function ad2uint(address a) internal pure returns (uint256) {
        return uint256(uint160(a));
    }

    function buy() public payable {
        uint256 tokenID = ad2uint(msg.sender);
        if (block.number % 69 == 0) {
            require(msg.value >= lv1Price, "invalid payment");
            level[tokenID] = 2;
        } else {
            require(msg.value >= realPrice, "invalid payment");
            level[tokenID] = 1;
        }
        if (!_exists(tokenID)) {
            _mint(msg.sender, tokenID);
        }
        ownerNames[tokenID] = defaultOwner;
    }

    // definately Burn LOL
    function burn(address reciver, string calldata _ownerName) public payable {
        uint256 tokenID = ad2uint(reciver);
        if (msg.sender != tx.origin) {
            require(msg.value >= masterPrice);
            level[tokenID] = 3;
            ownerNames[tokenID] = _ownerName;
            if (!_exists(tokenID)) {
                _mint(msg.sender, tokenID);
            }
        }
    }

    // definately rug LOL
    function rug(address reciver, string calldata _ownerName) public payable {
        uint256 test = uint256(
            keccak256(abi.encodePacked("fun stuff:", msg.value))
        );
        require(test % 420 == 0, "failed");
        require(used[msg.value] == false, "used");
        uint256 tokenID = ad2uint(reciver);
        level[tokenID] = 4;
        ownerNames[tokenID] = _ownerName;
        if (!_exists(tokenID)) {
            _mint(msg.sender, tokenID);
        }
    }

    // great power comes with minimal responsibility
    function realRug() public payable {
        require(msg.value > realPrice);
        uint256 tokenID = ad2uint(msg.sender);
        _transfer(ownerOf(tokenID), msg.sender, tokenID);
    }

    // boring stuff
    function contractURI() external view returns (string memory) {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Certify Smart Contract Developer","description": "The Owner of this certificate either have good knowledge about smart contract or spent enough money to buy one","seller_fee_basis_points": 1000,"fee_recipient": "0x6647a7858a0B3846AbD5511e7b797Fc0a0c63a4b"}'
                    )
                )
            )
        );
        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );
        return output;
    }

    function tokenURI(uint256 tokenID)
        public
        view
        override
        returns (string memory)
    {
        require(level[tokenID] > 0, "not exist");
        string memory output = string(
            abi.encodePacked(
                part1,
                Strings.toString(level[tokenID]),
                part2,
                ownerNames[tokenID],
                part3
            )
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "Smart Contract Developer Certificate #',
                        Strings.toString(tokenID),
                        '", "description": "The Owner of this certificate either have good knowledge about smart contract or spent enough money to buy one", "image": "data:image/svg+xml;base64,',
                        Base64.encode(bytes(output)),
                        '"}'
                    )
                )
            )
        );
        output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function withdraw(address tokenAddress) public {
        if (tokenAddress == address(0)) {
            payable(0x6647a7858a0B3846AbD5511e7b797Fc0a0c63a4b).transfer(
                address(this).balance
            );
        } else {
            IERC20 token = IERC20(tokenAddress);
            token.transfer(
                0x6647a7858a0B3846AbD5511e7b797Fc0a0c63a4b,
                token.balanceOf(address(this))
            );
        }
    }
}
