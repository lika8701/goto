package edithost

import (
	"github.com/charmbracelet/bubbles/key"
)

type keyMap struct {
	Up      key.Binding
	Down    key.Binding
	Save    key.Binding
	Discard key.Binding
}

func (k keyMap) ShortHelp() []key.Binding {
	return []key.Binding{k.Up, k.Down, k.Save, k.Discard}
}

func (k keyMap) FullHelp() [][]key.Binding {
	return nil
}

var keys = keyMap{
	Up: key.NewBinding(
		key.WithKeys("up", "shift+tab"),
		key.WithHelp("↑", "up"),
	),
	Down: key.NewBinding(
		key.WithKeys("down", "tab", "enter"),
		key.WithHelp("↓", "down"),
	),
	Save: key.NewBinding(
		key.WithKeys("ctrl+s"),
		key.WithHelp("ctrl+s", "save"),
	),
	Discard: key.NewBinding(
		key.WithKeys("esc"),
		key.WithHelp("esc", "discard"),
	),
}
