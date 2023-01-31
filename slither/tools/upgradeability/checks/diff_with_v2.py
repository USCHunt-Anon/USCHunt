from slither.tools.upgradeability.checks.abstract_checks import (
    CheckClassification,
    AbstractCheck,
)


class DiffContractV1ContractV2(AbstractCheck):
    ARGUMENT = "diff-v1-v2"
    IMPACT = CheckClassification.INFORMATIONAL

    HELP = "Diff between v1 and v2"
    WIKI = "https://github.com/crytic/slither/wiki/Upgradeability-Checks#differences-between-v1-and-v2"
    WIKI_TITLE = "Differences between v1 and v2"

    # region wiki_description
    WIKI_DESCRIPTION = """
    Detect all differences between the original contract and the updated one.
    """
    # endregion wiki_description

    # region wiki_exploit_scenario
    WIKI_EXPLOIT_SCENARIO = """
    Not an exploit, just informational.
    """
    # endregion wiki_exploit_scenario

    # region wiki_recommendation
    WIKI_RECOMMENDATION = """
    Use with targeted differential fuzzing to detect any unexpected discrepancies.
    """
    # endregion wiki_recommendation

    REQUIRE_CONTRACT = True
    REQUIRE_PROXY = False
    REQUIRE_CONTRACT_V2 = True

    def _contract1(self):
        return self.contract

    def _contract2(self):
        return self.contract_v2

    def _check(self):
        contract1 = self._contract1()
        contract2 = self._contract2()
        order_vars1 = [variable for variable in contract1.state_variables if not variable.is_constant]
        order_vars2 = [variable for variable in contract2.state_variables if not variable.is_constant]
        func_sigs1 = [function.solidity_signature for function in contract1.functions]
        func_sigs2 = [function.solidity_signature for function in contract2.functions]

        results = []

        if len(order_vars2) <= len(order_vars1):
            # Handle by MissingVariable
            return results

        new_modified_functions = []
        for sig in func_sigs2:
            function = contract2.get_function_from_signature(sig)
            if sig not in func_sigs1:
                new_modified_functions.append(function)
                info = [
                    "New function in ",
                    contract2,
                    "\n",
                ]
            # TODO: Find a better way to determine if a function has been modified
            else:
                orig_function = contract1.get_function_from_signature(sig)
                if function.get_summary() != orig_function.get_summary():
                    new_modified_functions.append(function)
                    info = [
                        "Modified function in ",
                        contract2,
                        "\n",
                    ]
                else:
                    continue
            info += ["\t ", function, "\n"]
            state_variables_read = function.state_variables_read
            state_variables_written = function.state_variables_written
            additional_fields = {
                "signature": sig,
                "visibility": function.visibility,
                "state_variables_read": [var.canonical_name for var in state_variables_read],
                "state_variables_written": [var.canonical_name for var in state_variables_written]
            }
            json = self.generate_result(info, additional_fields)
            results.append(json)

        # List unmodified functions that call new/modified functions
        for function in contract2.functions:
            if function in new_modified_functions:
                continue
            modified_calls = [func for func in new_modified_functions if func in function.internal_calls]
            if len(modified_calls) > 0:
                info = [
                    "Call to new/modified function(s) by unmodified function ",
                    function,
                    "\n",
                ]
                for func in modified_calls:
                    info += ["\t ", func, "\n"]
                additional_fields = {
                    "signature": function.solidity_signature,
                    "visibility": function.visibility,
                    "new/modified calls": [func.solidity_signature for func in modified_calls]
                }
                json = self.generate_result(info, additional_fields)
                results.append(json)

        for idx, var in enumerate(order_vars2):
            # Handle incorrect variable order in DifferentVariableContractNewContract
            slot = contract2.state_variable_slots[var][0]
            read_by = contract2.get_functions_reading_from_variable(var)
            written_by = contract2.get_functions_writing_to_variable(var)
            # print(f"Variable {idx}, {var} at slot {slot}")
            if len(order_vars1) <= idx:
                info = [
                    "New variable in ",
                    contract2,
                    " at slot ",
                    str(slot),
                    "\n",
                ]
            elif any([func in read_by for func in new_modified_functions]):
                info = [
                    "Variable read by new/modified function(s) in ",
                    contract2,
                    " at slot ",
                    str(slot),
                    "\n",
                ]
            elif any([func in written_by for func in new_modified_functions]):
                info = [
                    "Variable written by new/modified function(s) in ",
                    contract2,
                    " at slot ",
                    str(slot),
                    "\n",
                ]
            else:
                continue
            info += ["\t ", var, "\n"]
            additional_fields = {
                "slot": str(slot),
                "read_by": [func.canonical_name for func in read_by],
                "written_by": [func.canonical_name for func in written_by]
            }
            json = self.generate_result(info, additional_fields)
            results.append(json)
            continue

        return results
