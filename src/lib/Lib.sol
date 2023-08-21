// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "./types.sol";

library ConstraintsLib {
    function isSatisfied(Constraint memory self, Assignment[] memory instance, uint256 gasLimit)
        public
        view
        returns (bool success)
    {
        if (!inScope(self, instance)) {
            return false;
        }
        (success,) =
            self.relation.address.staticcall{gas: gasLimit}(abi.encodeWithSelector(self.relation.selector, instance));
    }

    function inScope(Constraint memory self, Assignment[] memory instance) public pure returns (bool) {
        for (uint256 i = 0; i < self.scope.length; i++) {
            if (RowId.unwrap(self.scope[i]) != RowId.unwrap(instance[RowId.unwrap(self.scope[i])].row_id)) {
                return false;
            }
        }
        return true;
    }
}
