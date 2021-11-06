// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./libraries/Base64.sol";
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
    mapping(address => uint256[]) public nftHolders;

    struct BigBoss {
        string name;
        string imageURI;
        uint256 hp;
        uint256 maxhp;
        uint256 attackDamage;
    }
    BigBoss public bigBoss;

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        string[] memory characterAttackType,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
        uint256[] memory characterAttackCooldown,
        string memory bossName,
        uint256 bossHp,
        uint256 bossAttackDamage,
        string memory bossImageURI
    ) ERC721("Frens", "fren") {
        bigBoss = BigBoss({
            name: bossName,
            imageURI: bossImageURI,
            hp: bossHp,
            maxhp: bossHp,
            attackDamage: bossAttackDamage
        });

        console.log(
            "Done initializing boss %s w/ HP %s, img %s",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.imageURI
        );

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
        _safeMint(msg.sender, newItemId); // assign the token to the function caller
        nftHolderAttributes[newItemId] = CharacterAttributes({
            characterIndex: _characterIndex - 1,
            name: defaultCharacters[_characterIndex - 1].name,
            imageURI: defaultCharacters[_characterIndex - 1].imageURI,
            attackType: defaultCharacters[_characterIndex - 1].attackType,
            hp: defaultCharacters[_characterIndex - 1].hp,
            maxhp: defaultCharacters[_characterIndex - 1].hp,
            attackDamage: defaultCharacters[_characterIndex - 1].attackDamage,
            attackCooldown: defaultCharacters[_characterIndex - 1]
                .attackCooldown
        });
        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender].push(newItemId);
        _tokenIds.increment();
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override
        returns (string memory)
    {
        CharacterAttributes memory charAttributes = nftHolderAttributes[
            _tokenId
        ];

        string memory strHp = Strings.toString(charAttributes.hp);
        string memory strMaxHp = Strings.toString(charAttributes.maxhp);
        string memory strAttackDamage = Strings.toString(
            charAttributes.attackDamage
        );

        string memory strCooldown = Strings.toString(
            charAttributes.attackCooldown
        );

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game Metaverse Slayer!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        '},{"trait_type":"Attack Type","value": "',
                        charAttributes.attackType,
                        '"}, {"trait_type":"Attack Cooldown","value": ',
                        strCooldown,
                        "} ]}"
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }
}
