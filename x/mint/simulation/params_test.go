package simulation_test

import (
	"math/rand"
	"testing"

	"github.com/stretchr/testify/require"

	"github.com/public-awesome/stargaze/x/mint/simulation"
)

func TestParamChangest(t *testing.T) {
	s := rand.NewSource(1)
	r := rand.New(s)

	expected := []struct {
		composedKey string
		key         string
		simValue    string
		subspace    string
	}{
		{"mint/GenesisTime", "GenesisTime", "\"2126-05-08 15:36:50 -0400 EDT\"", "mint"},
		{"mint/GenesisInflation", "GenesisInflation", "\"0.780000000000000000\"", "mint"},
		{"mint/ReductionFactor", "ReductionFactor", "\"0.200000000000000000\"", "mint"},
	}

	paramChanges := simulation.ParamChanges(r)
	require.Len(t, paramChanges, 3)

	for i, p := range paramChanges {
		require.Equal(t, expected[i].composedKey, p.ComposedKey())
		require.Equal(t, expected[i].key, p.Key())
		require.Equal(t, expected[i].simValue, p.SimValue()(r))
		require.Equal(t, expected[i].subspace, p.Subspace())
	}

}