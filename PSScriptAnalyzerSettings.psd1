@{
  RuleSettings = @{
    # Security and high-risk rules are errors
    PSAvoidUsingPlainTextForPassword = @{ Severity = 'Error' }
    PSUseShouldProcessForStateChangingCommands = @{ Severity = 'Error' }

    # Style/maintainability as warnings
    PSAvoidGlobalVars = @{ Severity = 'Warning' }
    PSUseDeclaredVarsMoreThanAssignments = @{ Severity = 'Warning' }
    PSAvoidUsingWriteHost = @{ Severity = 'Warning' }

    # You can add or tune rules as the project evolves
  }
}
