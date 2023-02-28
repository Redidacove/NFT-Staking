// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "hardhat/console.sol";

contract TARA is Ownable, ReentrancyGuard, Pausable ,ERC721{
   
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    IERC20 public immutable rewardsToken;
    IERC721 public immutable nftCollection;
    uint mintPrice;
    struct Staker{
        uint256[] stakedTokenIds;
        uint256[] mintedTokenIds;
         uint256 unclaimedRewards;
    }

    uint256 public TotalSupply = 50000;
    mapping (uint => address) public stakerAddresses;
    mapping (address=>Staker)Stakers;
    address[] public stakersArray;

    constructor () ERC721("TARA","TR") {
        address owner = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory){
        return "https://google.com";
    }
    // modifier onlyOwner {
    //     require(msg.sender==owner);
    //     _;
    // }

    function minting(address _minter,uint _tokenId) external onlyOwner{
        _safeMint(_minter,_tokenId);
    }

    function stake(uint256[] calldata tokenIds) external whenNotPaused {
        Staker memory staker = Stakers[msg.sender] ;
        if( staker.stakedTokenIds.length > 0){
            //update rewards
             updateRewards(msg.sender);
        }else{
            stakersArray.push(msg.sender);
        }
        uint len = tokenIds.length;

        for(uint i=0;i<len;i++){

            // require(nftCollection.ownerof[_tokenIds]==msg.sender,"YOU CAN'T STAKE TOKEN YOU DON'T OWN");
             nftCollection.transferFrom(msg.sender, address(this), tokenIds[i]);
	         Staker.stakedTokenIds.push(tokenIds[i]);
	         stakerAddresses[tokenIds[i]] = msg.sender;
        }
    }
    function userStakeInfo(address _user) public view returns (uint256[] memory _stakedTokenIds, uint256 _availableRewards)
    {
	        return (Stakers[_user].stakedTokenIds, availableRewards(_user));
    }

    function availableRewards(address _user) internal view returns (uint256 _rewards)
    {
	    Staker memory staker = Stakers[_user];
	    if (staker.stakedTokenIds.length == 0){
	         return staker.unclaimedRewards;
	    }
	    _rewards = staker.unclaimedRewards + calculateRewards(_user);
	}

    function updateRewards(address _staker) internal {
	        Staker storage staker = Stakers[_staker];
	        staker.unclaimedRewards += calculateRewards(_staker);
	        staker.timeOfLastUpdate = block.timestamp;
	}

    function calculateRewards(address _staker) internal view returns (uint256 _rewards)
    {
    Staker memory staker = Stakers[_staker];
    return (1/100*mintPrice)(rewardsToken);
    }

    function pause() external onlyOwner {
	        _pause();
    }
    function unpause() external onlyOwner {
	        _unpause();
    }
	
}
