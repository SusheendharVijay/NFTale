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

    event NFTCharacterMinted(
        address sender,
        uint256 tokenId,
        uint256 characterIndex
    );

    event AttackComplete(uint256 newBossHp, uint256 newCharacterHp);

    constructor(
        string[] memory characterNames,
        string[] memory characterImageURIs,
        string[] memory characterAttackType,
        uint256[] memory characterHp,
        uint256[] memory characterAttackDmg,
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
                    attackDamage: characterAttackDmg[i]
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
            attackDamage: defaultCharacters[_characterIndex - 1].attackDamage
        });
        console.log(
            "Minted NFT w/ tokenId %s and characterIndex %s",
            newItemId,
            _characterIndex
        );

        nftHolders[msg.sender].push(newItemId);
        _tokenIds.increment();

        emit NFTCharacterMinted(msg.sender, newItemId, _characterIndex);
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

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        charAttributes.name,
                        " -- NFT #: ",
                        Strings.toString(_tokenId),
                        '", "description": "This is an NFT that lets people play in the game NFTale!", "image": "',
                        charAttributes.imageURI,
                        '", "attributes": [ { "trait_type": "Health Points", "value": ',
                        strHp,
                        ', "max_value":',
                        strMaxHp,
                        '}, { "trait_type": "Attack Damage", "value": ',
                        strAttackDamage,
                        '},{"trait_type":"Attack Type","value": "',
                        charAttributes.attackType,
                        '"}]}'
                    )
                )
            )
        );

        string memory output = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return output;
    }

    function attackBoss(uint256 nft_index) public {
        uint256 nftTokenIdOfPlayer = nftHolders[msg.sender][nft_index];
        CharacterAttributes storage player = nftHolderAttributes[
            nftTokenIdOfPlayer
        ];
        console.log(
            "\nPlayer w/ character %s about to attack. Has %s HP and %s AD",
            player.name,
            player.hp,
            player.attackDamage
        );
        console.log(
            "Boss %s has %s HP and %s AD",
            bigBoss.name,
            bigBoss.hp,
            bigBoss.attackDamage
        );

        require(player.hp > 0, "Player is dead!");
        require(bigBoss.hp > 0, "Boss is already nmgi");

        if (player.attackDamage > bigBoss.hp) {
            bigBoss.hp = 0;
        } else {
            bigBoss.hp = bigBoss.hp - player.attackDamage;
        }

        if (bigBoss.attackDamage > player.hp) {
            player.hp = 0;
        } else {
            player.hp = player.hp - bigBoss.attackDamage;
        }

        // Console for ease.
        console.log("Player attacked boss. New boss hp: %s", bigBoss.hp);
        console.log("Boss attacked player. New player hp: %s\n", player.hp);

        emit AttackComplete(bigBoss.hp, player.hp);
    }

    function checkIfUserHasNFT() public view returns (uint256[] memory) {
        uint256[] memory nftTokenIds = nftHolders[msg.sender];

        return nftTokenIds;
    }

    function getAllDefaultCharacters()
        public
        view
        returns (CharacterAttributes[] memory)
    {
        return defaultCharacters;
    }

    function getBigBoss() public view returns (BigBoss memory) {
        return bigBoss;
    }
}
