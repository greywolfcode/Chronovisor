from textual.app import App, ComposeResult
from textual.widgets import Header

class ArchiveGeneratorApp(App):

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode")]

    def compose(self) -> ComposeResult:
        yield Header(name = 'Chronovisor Archive Generator')

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()