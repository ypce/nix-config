local wezterm = require("wezterm")
local act = wezterm.action

return {
	leader = { key = "a", mods = "CTRL" },

	keys = {
		{
			key = "w",
			mods = "CMD",
			action = act.CloseCurrentPane({ confirm = true }),
		},

		-- activate resize mode
		{
			key = "r",
			mods = "LEADER",
			action = act.ActivateKeyTable({
				name = "resize_pane",
				one_shot = false,
			}),
		},

		-- focus panes
		{ key = "h",	mods = "LEADER",	action = act.ActivatePaneDirection("Left"), },
		{ key = "e",	mods = "LEADER",	action = act.ActivatePaneDirection("Up"), },
		{ key = "n",	mods = "LEADER",	action = act.ActivatePaneDirection("Down"), },
		{ key = "i",	mods = "LEADER",	action = act.ActivatePaneDirection("Right"), },

		-- focus panes Arrows
		{ key = "LeftArrow",	mods = "LEADER",	action = act.ActivatePaneDirection("Left"), },
		{ key = "UpArrow",	mods = "LEADER",	action = act.ActivatePaneDirection("Up"), },
		{ key = "DownArrow",	mods = "LEADER",	action = act.ActivatePaneDirection("Down"), },
		{ key = "RightArrow",	mods = "LEADER",	action = act.ActivatePaneDirection("Right"), },

		-- add new panes
		{ key = "h", mods = "LEADER", action = act.SplitVertical({ domain = "CurrentPaneDomain" }), },
		{ key = "v", mods = "LEADER", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }), },
		-- rotate panes
		{ key = "c", mods = "LEADER", action = act.RotatePanes("CounterClockwise") },
	},

	key_tables = {
		resize_pane = {
			{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 5 }) },
			{ key = "h", action = act.AdjustPaneSize({ "Left", 5 }) },

			{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 5 }) },
			{ key = "i", action = act.AdjustPaneSize({ "Right", 5 }) },

			{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 2 }) },
			{ key = "n", action = act.AdjustPaneSize({ "Up", 2 }) },

			{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 2 }) },
			{ key = "e", action = act.AdjustPaneSize({ "Down", 2 }) },

			{ key = "Escape", action = "PopKeyTable" },
		},
	},
}
