package keeper

import (
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/public-awesome/stargaze/v11/x/globalfee/types"
)

// SetParams sets the total set of minting parameters.
func (k Keeper) SetParams(ctx sdk.Context, params types.Params) {
	if err := params.Validate(); err != nil {
		panic(err)
	}
	k.paramStore.SetParamSet(ctx, &params)
}

// GetParams returns the total set of minting parameters.
func (k Keeper) GetParams(ctx sdk.Context) types.Params {
	var params types.Params
	k.paramStore.GetParamSet(ctx, &params)
	return params
}

func (k Keeper) IsPrivilegedAddress(ctx sdk.Context, address string) bool {
	privilegedAddresses := k.GetParams(ctx).PrivilegedAddresses
	for _, paddr := range privilegedAddresses {
		if address == paddr {
			return true
		}
	}
	return false
}
