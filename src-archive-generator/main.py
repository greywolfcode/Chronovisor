# Chronovisor archive generator tool.
# Copyright (C) 2026  greywolfcode
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published byl
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

from enum import Enum

from rich.text import Text

from textual.app import App, ComposeResult
from textual.containers import CenterMiddle, Container, Horizontal, Vertical, VerticalScroll
from textual.screen import ModalScreen, Screen
from textual.validation import Number
from textual.widgets import Button, ContentSwitcher, DataTable, Footer, Header, Input, Label

from scripts.id_handeler import IdType

from scripts.archive_handeling import Archive, Message, Person

data = {
    "spaces": {},
    "dms": {}
}

current_uuid = None

class State(Enum):
    MAIN_MENU = 0,
    CREATE_USER = 1,
    HUB = 2,
    CREATE_DM = 3,
    EDIT_PEOPLE = 4,
    CREATE_SPACE = 5

class MainMenu(Screen):
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")
        yield CenterMiddle(Button(label = "New Archive", id = "new_archive"))
        yield Footer()    
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_archive":
            app.set_state(State.CREATE_USER)
            app.install_screen(CreateUserMenu(), name = "Create User Menu")
            app.switch_screen("Create User Menu")

class CreateUserMenu(Horizontal, Screen):

    CSS_PATH = "styles/create_user_menu.tcss"

    class CreateState(Enum):
        NAME = 0,
        EMAIL = 1,

    class SideBar(Container):

        id = "sidebar"

        def __init__(self, bar_parent: Screen):
            super().__init__()
            self._parent = bar_parent

        def compose(self) -> ComposeResult:
            yield Button(label = "Set Name", id = "name")
            yield Button(label = "Set Email", id = "email")
            yield Button(label = "Create", id = "create")
        
        def on_button_pressed(self, event: Button.Pressed) -> None:
            if event.button.id == "name":
                self._parent.set_state(self._parent.CreateState.NAME)
            elif event.button.id == "email":
                self._parent.set_state(self._parent.CreateState.EMAIL)
            elif event.button.id == "create":
                self._parent.create_user()

                app.set_state(State.HUB)
                app.install_screen(HubMenu(), name = "Hub Menu")
                app.switch_screen("Hub Menu")

    
    def __init__(self):
        super().__init__()
        self.state = self.CreateState.NAME
        self.side_bar = self.SideBar(self)

        self._name = "Temp Temp"
        self._email = "Temp@temp.temp"
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.side_bar

        with ContentSwitcher(initial="name", id="label_switcher"):
            yield Label("Name:", id="name")
            yield Label("Email:", id="email")

        with ContentSwitcher(initial="name", id="input_switcher"):
            yield Input(placeholder=self._name, id="name")
            yield Input(placeholder=self._email, id="email")
        
        yield Footer()

    def on_input_changed(self, event: Input.Changed):
        if (event.input.id == "name"):
            self._name = event.input.value
        else:
            self._email = event.input.value

    def set_state(self, new_state: CreateState):
        self.state = new_state
        if (self.state == self.CreateState.NAME):
            self.query_one("#label_switcher", ContentSwitcher).current = "name"
            self.query_one("#input_switcher", ContentSwitcher).current = "name"
        else:
            self.query_one("#label_switcher", ContentSwitcher).current = "email"
            self.query_one("#input_switcher", ContentSwitcher).current = "email"
    
    def create_user(self):
        data["user"] = Person(self._name, self._email)

class HubMenu(Screen):

    CSS_PATH = "styles/hub_menu.tcss"

    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield Button(label = "New Space", id = "new_space")
        yield Button(label = "New DM", id = "new_dm")
        yield Button(label = "Export", id = "export")

        yield Footer()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "new_dm":
            app.set_state(State.CREATE_DM)
            app.install_screen(DMCreationMenu(), name = "DM Creation Menu")
            app.switch_screen("DM Creation Menu")
        elif event.button.id == "new_space":
            app.set_state(State.CREATE_SPACE)
            app.install_screen(SpaceCreationMenu(), name = "Space Creation Menu")
            app.switch_screen("Space Creation Menu")

class DMCreationMenu(Screen):

    CSS_PATH = "styles/create_message_group_menus.tcss"

    class SideBar(Vertical):
        def compose(self) -> ComposeResult:
            yield Button(label = "Edit DM", id = "edit_dm")
            yield Button(label = "Edit People", id = "edit_people")
            yield Button(label = "Add Message", id = "add_message")
            yield Button(label = "Finish", id = "finish")

    def __init__(self):
        global current_uuid

        super().__init__()
        self.uuid = IdType.gen_id(IdType.DM)
        self.sidebar = self.SideBar()
        self.editor = Container()

        current_uuid = self.uuid
        data["dms"][current_uuid] = Archive(self.uuid, IdType.DM)
        data["dms"][current_uuid].add_person(data["user"])
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.sidebar 

        yield Footer()
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.editor.remove()
        if event.button.id == "edit_people":
            self.editor = PersonEditingMenu(2, IdType.DM) # can't add more prople to DM
            self.mount(self.editor)
        elif event.button.id == "edit_dm":
            self.editor = DataEditingMenu(False) #max 400 people in personal spaces
            self.mount(self.editor)

class SpaceCreationMenu(Screen):
    
    CSS_PATH = "styles/create_message_group_menus.tcss"

    class SideBar(Vertical):
        def compose(self) -> ComposeResult:
            yield Button(label = "Edit Space", id = "edit_space")
            yield Button(label = "Edit People", id = "edit_people")
            yield Button(label = "Add Message", id = "add_message")
            yield Button(label = "Finish", id = "finish")

    def __init__(self):
        global current_uuid

        super().__init__()
        self.uuid = IdType.gen_id(IdType.SPACE)
        self.sidebar = self.SideBar()
        self.editor = Container()

        current_uuid = self.uuid
        data["spaces"][current_uuid] = Archive(self.uuid, IdType.SPACE)
        data["spaces"][current_uuid].add_person(data["user"])
    
    def compose(self) -> ComposeResult:
        yield Header(name = "Chronovisor Archive Generator")

        yield self.sidebar 

        yield Footer()
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        self.editor.remove()
        if event.button.id == "edit_people":
            self.editor = PersonEditingMenu(400, IdType.SPACE) #max 400 people in personal spaces
            self.mount(self.editor)
        elif event.button.id == "edit_space":
            self.editor = DataEditingMenu(True) #max 400 people in personal spaces
            self.mount(self.editor)

class PersonEditingMenu(VerticalScroll):
    def __init__(self, max_people: int, type: IdType):
        super().__init__()
        self.max_people = max_people
        self.current_row = None
        self.type = type

        if self.type == IdType.DM:
            self.key = "dms"
        else:
            self.key = "spaces"

    def compose(self) -> ComposeResult:
        
        yield DataTable()

        yield Horizontal(
            Button("Add person", id = "add_person"),
            Button("Edit Person", id = "edit_person"),
            Button("Remove Person", id = "remove_person")
        )
    
    def on_mount(self) -> None:
        rows = [("name", "email")]
        for person in data[self.key][current_uuid].people:
            rows.append((person.name, person.email))

        table = self.query_one(DataTable)
        table.add_columns(*rows[0])
        table.cursor_type = "row"
        for number, row in enumerate(rows[1:], start=1):
            label = Text(str(number))
            table.add_row(*row, label=label)
        
        self.disable_buttons()
    
    def on_data_table_row_highlighted(self, event: DataTable.RowHighlighted) -> None:
        self.current_row = event.cursor_row
        
        self.disable_buttons()

    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "add_person":
            app.push_screen(AddPersonScreen(self.type))
        elif event.button.id == "remove_person":
            app.push_screen(RemovePopup(self.current_row, self.type))
        elif event.button.id == "edit_person":
            app.push_screen(EditPersonMenu(self.current_row, self.type))

    def disable_buttons(self) -> None:
        rows = data[self.key][current_uuid].people

        if len(rows) >= self.max_people:
            self.query_one("#add_person").disabled = True
        else:
            self.query_one("#add_person").disabled = False

        if self.current_row != None and self.current_row != 0:
            self.query_one("#remove_person").disabled = False
        else:
            self.query_one("#remove_person").disabled = True

        if self.current_row != None and self.current_row != 0:
            self.query_one("#edit_person").disabled = False
        else:
            self.query_one("#edit_person").disabled = True

class AddPersonScreen(ModalScreen):

    CSS_PATH = "styles/popup.tcss"

    def __init__(self, type: IdType):
        super().__init__(id = "popup_base")

        self.type = type

        if self.type == IdType.DM:
            self.key = "dms"
        else:
            self.key = "spaces"

        num = str(len(data[self.key][current_uuid].people))

        self._name = "Temp Temp " + num
        self._email = "Temp_" + num + "@temp.temp"

    def compose(self) -> ComposeResult:
        yield CenterMiddle(
            Horizontal(
                Label("Name: "),
                Input(placeholder=self._name, id = "name")
            ),
            Horizontal(
                Label("Email: "),
                Input(placeholder=self._email, id = "email")
            ),
            Horizontal(
                Button("Cancel", id = "cancel"),
                Button("Save", id = "save")
            ),
            id = "popup"
        )
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "cancel":
            app.pop_screen()
        elif event.button.id == "save":
            data[self.key][current_uuid].add_person(Person(self._name, self._email))
            app.pop_screen()

            if self.type == IdType.DM:
                app.switch_screen("DM Creation Menu")
            else:
                app.switch_screen("Space Creation Menu")
    
    def on_input_changed(self, event: Input.Changed):
        if (event.input.id == "name"):
            self._name = event.input.value
        else:
            self._email = event.input.value

class RemovePopup(ModalScreen):
    CSS_PATH = "styles/popup.tcss"

    def __init__(self, index: int, type: IdType):
        super().__init__(id = "popup_base")
        self.index = index
        self._name = data["spaces"][current_uuid].people[self.index].name
        self.type = type

        if self.type == IdType.DM:
            self.key = "dms"
        else:
            self.key = "spaces"

    def compose(self) -> ComposeResult:
        yield CenterMiddle(
            Label('Are you sure you want to remove "' + self._name + '"'),
            Horizontal(
                Button("No", id = "no"),
                Button("Yes", id = "yes")
            ),
            id = "popup"
        )
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "no":
            app.pop_screen()
        elif event.button.id == "yes":
            data[self.key][current_uuid].people.pop(self.index)
            app.pop_screen()

            if self.type == IdType.DM:
                app.switch_screen("DM Creation Menu")
            else:
                app.switch_screen("Space Creation Menu")

class EditPersonMenu(ModalScreen):

    CSS_PATH = "styles/popup.tcss"

    def __init__(self, index: int, type: IdType):
        super().__init__(id = "popup_base")

        self.index = index

        self._name = data["spaces"][current_uuid].people[self.index].name
        self._email = data["spaces"][current_uuid].people[self.index].email
        self.type = type

        if self.type == IdType.DM:
            self.key = "dms"
        else:
            self.key = "spaces"

    def compose(self) -> ComposeResult:
        yield CenterMiddle(
            Horizontal(
                Label("Name: "),
                Input(placeholder=self._name, id = "name")
            ),
            Horizontal(
                Label("Email: "),
                Input(placeholder=self._email, id = "email")
            ),
            Horizontal(
                Button("Cancel", id = "cancel"),
                Button("Save", id = "save")
            ),
            id = "popup"
        )
    
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "cancel":
            app.pop_screen()
        elif event.button.id == "save":
            data["spaces"][current_uuid].people[self.index].name = self._name 
            data["spaces"][current_uuid].people[self.index].email = self._email 
            app.pop_screen()
            
            if self.type == IdType.DM:
                app.switch_screen("DM Creation Menu")
            else:
                app.switch_screen("Space Creation Menu")
    
    def on_input_changed(self, event: Input.Changed):
        if (event.input.id == "name"):
            self._name = event.input.value
        else:
            self._email = event.input.value

class DataEditingMenu(Container):
    def __init__(self, edit_name: bool):
        super().__init__()
        self.edit_name = edit_name

    def compose(self) -> ComposeResult:
        yield Horizontal(
            Label("Month:"),
            Input(
                placeholder="9",
                validators=[
                Number(minimum=1, maximum=12),  
                ],
            ),
            Label("Day:"),
            Input(
                placeholder="4",
                validators=[
                Number(minimum=1, maximum=31),  
                ],
            ),
            Label("Year:"),
            Input(
                placeholder="1998",
                validators=[
                Number(minimum=1998),  
                ],
            ),
            Label("Hour"),
            Input(
                placeholder="0",
                validators=[
                Number(minimum=0, maximum=23),  
                ],
            ),
            Label("Minute"),
            Input(
                placeholder="0",
                validators=[
                Number(minimum=0, maximum=59),  
                ],
            ),
            Label("Second"),
            Input(
                placeholder="0",
                validators=[
                Number(minimum=0, maximum=59),  
                ],
            )
        )
        
    def on_mount(self) -> None:
        if self.edit_name:
            self.mount(
                Horizontal(
                    Label("Name"),
                    Input(
                            placeholder="Temp",
                            validators=[
                            Number(minimum=1, maximum=12),  
                            ],
                        ),
                )
            )

class LicenceScreen(ModalScreen):

    def __init__(self):
        super().__init__(id="popup_base") 

    BINDINGS = [("l", "close", "Close Licence")]        

    CSS_PATH = ["styles/popup.tcss", "styles/licence_screen.tcss"]

    LICENCE_TEXT = """
    Chronovisor archive generator tool.
    Copyright (C) 2026  greywolfcode

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published byl
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA."""

    def compose(self) -> ComposeResult:
        yield CenterMiddle(
            Label(self.LICENCE_TEXT, id="text"),
            Button(label = "Done", id = "done"),
            id = "popup"
        )
            
    def on_button_pressed(self, event: Button.Pressed) -> None:
        if event.button.id == "done":
            self.close()

    def action_close(self):
        self.close()
    
    def close(self):
        app.pop_screen()

class ArchiveGeneratorApp(App):

    def __init__(self):
        super().__init__()
        self.state = State.MAIN_MENU

    BINDINGS = [("d", "toggle_dark", "Toggle dark mode"), ("l", "show_licence", "Show Licence")]        

    def action_toggle_dark(self) -> None:
        """An action to toggle dark mode."""
        self.theme = (
            "textual-dark" if self.theme == "textual-light" else "textual-light"
        )
    
    def action_show_licence(self):
        self.push_screen(LicenceScreen())
    
    def set_state(self, new_state: State) -> None:
        self.state = new_state
    
    def on_mount(self) -> None:
        self.install_screen(MainMenu(), name = "Main Menu")
        self.push_screen("Main Menu")

if __name__ == '__main__':
    app = ArchiveGeneratorApp()
    app.run()