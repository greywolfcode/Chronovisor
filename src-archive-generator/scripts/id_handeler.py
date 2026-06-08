import base64
from enum import Enum
import uuid

class IdType(Enum):
    SPACE = 0,
    DM = 1

    @staticmethod
    def gen_id(type: IdType) -> str:
        """
        Generates a unique filesystem/url safe id for spaces/dms
        """

        id_bytes = uuid.uuid4().bytes
        id_base64 = base64.urlsafe_b64encode(id_bytes)

        if type == IdType.SPACE:
            return "Space " + id_base64.decode("utf-8")
        elif type == IdType.DM:
            return "DM " + id_base64.decode("utf-8")