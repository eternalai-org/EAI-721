// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import {Proxy} from "@openzeppelin/contracts/proxy/Proxy.sol";
import {IAgentFactory} from "../interfaces/IAgentFactory.sol";

contract AgentProxy is Proxy {
    //
    IAgentFactory public immutable factory;

    // ======== Constructor =========
    constructor() {
        factory = IAgentFactory(msg.sender);
    }

    /**
     * @dev This is a virtual function that should be overridden so it returns the address to which the fallback function
     * and {_fallback} should delegate.
     */
    function _implementation()
        internal
        view
        virtual
        override
        returns (address impl)
    {
        return factory.getImplementation();
    }
}
