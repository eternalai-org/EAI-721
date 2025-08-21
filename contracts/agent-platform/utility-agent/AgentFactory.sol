// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {IERC721} from "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {IAgentFactory, IAgent, IEAI721Intelligence} from "../interfaces/IAgentFactory.sol";
import {AgentUpgradeable} from "./AgentUpgradeable.sol";
import {AgentProxy} from "./AgentProxy.sol";
import {IFileStore} from "../interfaces/IFileStore.sol";
import {Create2} from "@openzeppelin/contracts/utils/Create2.sol";

contract AgentFactory is IAgentFactory, OwnableUpgradeable {
    // single safe factory
    address public constant SINGLE_SAFE_FACTORY = 0x914d7Fec6aaC8cd542e72Bca78B30650d45643d7;
    address public constant FIE_STORE = 0xFe1411d6864592549AdE050215482e4385dFa0FB;

    address _implementation;
    address _collection;

    // agentId => agent address
    mapping(bytes32 => address) public agents;
    // nftId => agentId
    mapping(uint256 => bytes32) public collectionIdToAgentId;
    // agentName => isRegistered
    mapping(string => bool) public isNameRegistered;
    // agentId => agentName
    mapping(bytes32 => string) private agentNames;

    // this section for agent no need to be owned by a NFT
    // nft id => agent address
    mapping (bytes32 => address) public ownerV2;

    // Modifier
    modifier onlyAgentOwner(uint256 collectionId) {
        address nftOwner = IERC721(_collection).ownerOf(collectionId);
        if (
            nftOwner != msg.sender &&
            msg.sender != _collection &&
            !IEAI721Intelligence(_collection).checkAgentDelegate(
                msg.sender,
                nftOwner,
                collectionId
            )
        ) revert("Unauthorized");

        _;
    }

    function initialize(
        address owner,
        address implementation,
        address collection
    ) public initializer {
        require(owner != address(0), "Invalid owner");
        require(implementation != address(0), "Invalid implementation");
        require(collection != address(0), "Invalid collection");

        __Ownable_init();
        _transferOwnership(owner);
        _implementation = implementation;
        _collection = collection;
    }

    function _createAgent(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] memory pointers,
        address[] calldata depsAgents,
        uint256 nftId
    ) internal returns (address agent) {
        require(
            agentId != bytes32(0) && collectionIdToAgentId[nftId] == bytes32(0),
            "Invalid agent id"
        );
        require(agents[agentId] == address(0), "Agent already exists");

        collectionIdToAgentId[nftId] = agentId;
        agent = address(new AgentProxy());
        AgentUpgradeable(agent).initialize(
            nftId,
            agentName,
            codeLanguage,
            pointers,
            depsAgents
        );

        agents[agentId] = agent;

        emit AgentCreated(_collection, agentId, agent);   
    }

    function createAgent(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] memory pointers,
        address[] calldata depsAgents,
        uint256 nftId
    ) external onlyAgentOwner(nftId) returns (address agent) {
        agent = _createAgent(agentId, agentName, codeLanguage, pointers, depsAgents, nftId);
    }

    function publishAgentCode(
        bytes32 agentId,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    )
        external
        onlyAgentOwner(AgentUpgradeable(agents[agentId]).getCollectionId())
        returns (uint16 agentVersion)
    {
        address agent = agents[agentId];
        require(agent != address(0), "Agent does not exist");

        agentVersion = AgentUpgradeable(agents[agentId]).publishAgentCode(
            codeLanguage,
            pointers,
            depsAgents
        );
    }

    function _publishAgentCodeSingleTx(
        bytes[] calldata datas, // salt and data
        string calldata fileName,
        bytes memory metadata
    ) internal {
        require(datas.length > 0, "Datas is empty");

        // init addresses array memory with datas length
        address[] memory pointerAddresses = new address[](datas.length);

        // loop through datas and set pointers
        for (uint256 i = 0; i < datas.length; i++) {
            // check length of datas[i]
            require(datas[i].length > 32, "Invalid data");
            // check contract address is not empty 
            address computedAddress = Create2.computeAddress(bytes32(datas[i][0:32]), keccak256(datas[i][32:]), SINGLE_SAFE_FACTORY);
            require(computedAddress != address(0), "Invalid computed address");

            if (computedAddress.code.length > 0) {
                pointerAddresses[i] = computedAddress;
            } else {
                // call single safe factory
                (bool success, bytes memory pointerAddrBytes) = SINGLE_SAFE_FACTORY.call(datas[i]);
                require(success, "Single safe factory call failed");
                pointerAddresses[i] = address(uint160(bytes20(pointerAddrBytes)));
                require(computedAddress == pointerAddresses[i], "Mismatch address");
            }
        }

        // call fie store
        IFileStore(FIE_STORE).createFileFromPointers(fileName, pointerAddresses, metadata);
    }

    function createAgentSingleTx(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        address[] calldata depsAgents,
        uint256 nftId,
        bytes[] calldata datas, // salt and data
        string calldata fileName,
        IEAI721Intelligence.FileType fileType,
        bytes memory metadata
    ) external onlyAgentOwner(nftId) returns (address agent) {
        // publish agent code
        _publishAgentCodeSingleTx(
            datas,
            fileName,
            metadata
        );

        IEAI721Intelligence.CodePointer[] memory pointers = new IEAI721Intelligence.CodePointer[](1);
        pointers[0] = IEAI721Intelligence.CodePointer({
            retrieveAddress: FIE_STORE,
            fileType: fileType,
            fileName: fileName
        });

        // create agent
        agent = _createAgent(agentId, agentName, codeLanguage, pointers, depsAgents, nftId);
    }

    function publishAgentCodeSingleTx(
        bytes32 agentId,
        string calldata codeLanguage,
        address[] calldata depsAgents,
        bytes[] calldata datas, // salt and data
        string calldata fileName,
        IEAI721Intelligence.FileType fileType,
        bytes memory metadata
    )         
        external
        onlyAgentOwner(AgentUpgradeable(agents[agentId]).getCollectionId())
        returns (uint16 agentVersion)
    {
        _publishAgentCodeSingleTx(
            datas,
            fileName,
            metadata
        );
        
        // call agent
        IEAI721Intelligence.CodePointer[] memory pointers = new IEAI721Intelligence.CodePointer[](1);
        pointers[0] = IEAI721Intelligence.CodePointer({
            retrieveAddress: FIE_STORE,
            fileType: fileType,
            fileName: fileName
        });

        address agent = agents[agentId];
        require(agent != address(0), "Agent does not exist");
        agentVersion = AgentUpgradeable(agent).publishAgentCode(
            codeLanguage,
            pointers,
            depsAgents
        );
    }

    function setAgentName(
        bytes32 agentId,
        string calldata agentName
    )
        external
        onlyAgentOwner(AgentUpgradeable(agents[agentId]).getCollectionId())
    {
        agentNames[agentId] = agentName;

        // call setAgentName on the agent
        AgentUpgradeable(agents[agentId]).setAgentName(agentName);

        emit AgentNameSet(agentId, agentName);
    }

    // @notice V2 functions for agents not owned by NFTs
    function createAgentV2(
        bytes32 agentId,
        string calldata agentName,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] memory pointers,
        address[] calldata depsAgents
    ) external returns (address agent) {
        uint nftId = uint256(agentId);
        require(IERC721(_collection).ownerOf(nftId) == address(0), "NFT must not exist or burned");

        agent = _createAgent(agentId, agentName, codeLanguage, pointers, depsAgents, nftId);
        ownerV2[agentId] = msg.sender;
    }

    function publishAgentCodeV2(
        bytes32 agentId,
        string calldata codeLanguage,
        IEAI721Intelligence.CodePointer[] calldata pointers,
        address[] calldata depsAgents
    )
        external
        returns (uint16 agentVersion)
    {
        require(ownerV2[agentId] == msg.sender, "Unauthorized");

        address agent = agents[agentId];
        require(agent != address(0), "Agent does not exist");

        agentVersion = AgentUpgradeable(agents[agentId]).publishAgentCode(
            codeLanguage,
            pointers,
            depsAgents
        );
    }

    function setAgentNameV2(
        bytes32 agentId,
        string calldata agentName
    )
        external
    {
        require(ownerV2[agentId] == msg.sender, "Unauthorized");
        agentNames[agentId] = agentName;

        // call setAgentName on the agent
        AgentUpgradeable(agents[agentId]).setAgentName(agentName);

        emit AgentNameSet(agentId, agentName);
    }

    function publishAgentCodeSingleTxV2(
        bytes32 agentId,
        string calldata codeLanguage,
        address[] calldata depsAgents,
        bytes[] calldata datas, // salt and data
        string calldata fileName,
        IEAI721Intelligence.FileType fileType,
        bytes memory metadata
    )         
        external
        returns (uint16 agentVersion)
    {
        require(ownerV2[agentId] == msg.sender, "Unauthorized");
        
        _publishAgentCodeSingleTx(
            datas,
            fileName,
            metadata
        );
        
        // call agent
        IEAI721Intelligence.CodePointer[] memory pointers = new IEAI721Intelligence.CodePointer[](1);
        pointers[0] = IEAI721Intelligence.CodePointer({
            retrieveAddress: FIE_STORE,
            fileType: fileType,
            fileName: fileName
        });

        address agent = agents[agentId];
        require(agent != address(0), "Agent does not exist");
        agentVersion = AgentUpgradeable(agent).publishAgentCode(
            codeLanguage,
            pointers,
            depsAgents
        );
    }

    function setImplementation(address implementation) external onlyOwner {
        require(implementation != address(0), "Invalid implementation");
        _implementation = implementation;

        emit ImplementationSet(implementation);
    }

    function getImplementation() external view returns (address) {
        return _implementation;
    }

    function getCollection() external view returns (address) {
        return _collection;
    }

    function getAgentName(
        bytes32 agentId
    ) external view returns (string memory) {
        return agentNames[agentId];
    }
}
