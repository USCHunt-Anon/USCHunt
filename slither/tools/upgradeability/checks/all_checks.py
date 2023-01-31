# pylint: disable=unused-import
from .variables_order import (
    MissingVariable,
    ExtraVariablesProxy,
    ExtraVariablesNewContract,
    DifferentVariableContractProxy,
    DifferentVariableContractNewContract
)
from .variable_initialization import (
    CheckClassification
)
from .functions_ids import (
    FunctionShadowing,
    IDCollision
)
from .constant import (
    WereConstant,
    BecameConstant
)
from .initialization import (
    MissingCalls,
    MissingInitializerModifier,
    MultipleCalls,
    MultipleInitTarget,
    InitializeTarget,
    InitializableInitializer,
    InitializablePresent,
    InitializableInherited
)
from .diff_with_v2 import (
    DiffContractV1ContractV2
)
