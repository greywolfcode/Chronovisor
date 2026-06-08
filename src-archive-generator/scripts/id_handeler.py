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

import base64
from enum import Enum
import uuid

class IdType(Enum):
    SPACE = 0,
    DM = 1

    @staticmethod
    def gen_id(type) -> str:
        """
        Generates a unique filesystem/url safe id for spaces/dms
        """

        id_bytes = uuid.uuid4().bytes
        id_base64 = base64.urlsafe_b64encode(id_bytes)

        if type == IdType.SPACE:
            return "Space " + id_base64.decode("utf-8")
        elif type == IdType.DM:
            return "DM " + id_base64.decode("utf-8")