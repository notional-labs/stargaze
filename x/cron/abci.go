package cron

import (
	"encoding/json"
	"fmt"
	"runtime/debug"
	"time"

	abci "github.com/cometbft/cometbft/abci/types"
	"github.com/cometbft/cometbft/libs/log"
	"github.com/cosmos/cosmos-sdk/telemetry"
	sdk "github.com/cosmos/cosmos-sdk/types"
	"github.com/public-awesome/stargaze/v10/x/cron/contract"
	"github.com/public-awesome/stargaze/v10/x/cron/keeper"
	"github.com/public-awesome/stargaze/v10/x/cron/types"
)

// BeginBlocker sends a BeginBlock SudoMsg to all privileged contracts
func BeginBlocker(ctx sdk.Context, k keeper.Keeper, w types.WasmKeeper) {
	defer telemetry.ModuleMeasureSince(types.ModuleName, time.Now(), telemetry.MetricKeyBeginBlocker)
	sudoMsg := contract.SudoMsg{BeginBlock: &struct{}{}}
	k.IteratePrivileged(ctx, abciContractCallback(ctx, w, sudoMsg))
}

// EndBlocker sends a EndBlock SudoMsg to all privileged contracts
func EndBlocker(ctx sdk.Context, k keeper.Keeper, w types.WasmKeeper) []abci.ValidatorUpdate {
	defer telemetry.ModuleMeasureSince(types.ModuleName, time.Now(), telemetry.MetricKeyEndBlocker)
	sudoMsg := contract.SudoMsg{EndBlock: &struct{}{}}
	k.IteratePrivileged(ctx, abciContractCallback(ctx, w, sudoMsg))
	return nil
}

// returns safe method to send the message via sudo to the privileged contract
func abciContractCallback(parentCtx sdk.Context, w types.WasmKeeper, msg contract.SudoMsg) func(contractAddr sdk.AccAddress) bool {
	logger := keeper.ModuleLogger(parentCtx)
	return func(contractAddr sdk.AccAddress) bool {
		msgBz, err := json.Marshal(msg)
		if err != nil {
			panic(err)
		}
		defer RecoverToLog(logger, contractAddr)()

		logger.Debug("privileged contract callback", "type", contractCallbackType(msg), "msg", string(msgBz))
		ctx, commit := parentCtx.CacheContext()

		if _, err := w.Sudo(ctx, contractAddr, msgBz); err != nil {
			logger.Error(
				"abci callback to privileged contract failed",
				"type", contractCallbackType(msg),
				"cause", err,
				"contract-address", contractAddr,
			)
			return false // return without commit
		}
		commit()
		return false
	}
}

func contractCallbackType(msg contract.SudoMsg) string {
	if msg.BeginBlock != nil {
		return "begin_blocker"
	} else if msg.EndBlock != nil {
		return "end_blocker"
	}
	panic("unknown sudo msg type") // this panic cannot be reached cuz we build the SudoMsg
}

// RecoverToLog catches panic and logs cause to error
func RecoverToLog(logger log.Logger, contractAddr sdk.AccAddress) func() {
	return func() {
		if r := recover(); r != nil {
			var cause string
			switch rType := r.(type) {
			case sdk.ErrorOutOfGas:
				cause = fmt.Sprintf("out of gas in location: %v", rType.Descriptor)
			default:
				cause = fmt.Sprintf("%s", r)
			}
			logger.
				Error("panic executing callback",
					"cause", cause,
					"contract-address", contractAddr.String(),
					"stacktrace", string(debug.Stack()),
				)
		}
	}
}
