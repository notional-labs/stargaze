package keeper_test

// import (
// 	tmproto "github.com/tendermint/tendermint/proto/tendermint/types"

// 	// "github.com/cosmos/cosmos-sdk/simapp"
// 	sdk "github.com/cosmos/cosmos-sdk/types"
// 	simapp "github.com/public-awesome/stargaze/app"
// 	"github.com/public-awesome/stargaze/x/mint/types"
// )

// // returns context and an app with updated mint keeper
// func createTestApp(isCheckTx bool) (*simapp.App, sdk.Context) {
// 	app := simapp.Setup(isCheckTx)

// 	ctx := app.BaseApp.NewContext(isCheckTx, tmproto.Header{})
// 	app.MintKeeper.SetParams(ctx, types.DefaultParams())
// 	app.MintKeeper.SetMinter(ctx, types.DefaultInitialMinter())

// 	return app, ctx
// }