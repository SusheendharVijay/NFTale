// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
// NFT contract to inherit from.
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

// Helper functions OpenZeppelin provides.
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyEpicGame is ERC721 {
    struct CharacterAttributes {
        uint256 characterIndex;
        string name;
        string imageURI;
        string attackType;
        uint256 hp;
        uint256 maxhp;
        uint256 attackDamage;
        uint256 attackCooldown;
    }
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    CharacterAttributes[] defaultCharacters;
    mapping(uint256 => CharacterAttributes) public nftHolderAttributes;
    mapping(address => uint256) public nftHolders;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        string[] memory characterAttackType,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        uint256[] memory characterAttackCooldown
    ) ERC721("Frens", "fren") {
        for (uint256 i = 0; i < characterNames.length; i += 1) {
            defaultCharacters.push(
                CharacterAttributes({
                    characterIndex: i,
                    name: characterNames[i],
                    imageURI: characterImageURIs[i],
                    attackType: characterAttackType[i],
                    hp: characterHp[i],
                    maxhp: characterHp[i],
                    attackDamage: characterAttackDmg[i],
                    attackCooldown: characterAttackCooldown[i]
                })
            );

            CharacterAttributes memory c = defaultCharacters[i];
            console.log(
                "Done initializing %s w/ HP %s,img %s",
                c.name,
                c.hp,
                c.imageURI
            );
        }
        _tokenIds.increment();
    }

    function mintCharacterNFT(uint256 _characterIndex) external {
        uint256 newItemId = _tokenIds.current(); // get current index
        _safeMint(msg.sender, newItemId); //
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex,
            name: defaultCharacters[_characterIndex].name,
            imageURI: defaultCharacters[_characterIndex].imageURI,
            attackType: defaultCharacters[_characterIndex].attackType,
            hp: defaultCharacters[_characterIndex].hp,
            maxhp: defaultCharacters[_characterIndex].hp,
            attackDamage: defaultCharacters[_characterIndex].attackDamage,
            attackCooldown: defaultCharacters[_characterIndex].attackCooldown
        });
    }
}
