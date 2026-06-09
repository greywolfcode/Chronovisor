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

class Message():
    def __init__(self, message: str):
        self.message = message

class Archive():
    def __init__(self, uuid: str):
        self.uuid = uuid
        self.messages = []
        self.people = []
    def add_message(self, message: Message):
        self.messages.append(Message)
    def add_person(self, person: Person):
        self.people.append(person)

class Person():
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email