@{
    Severity            = @('Error', 'Warning', 'Information')
    IncludeDefaultRules = $true

    Rules               = @{
        PSReviewUnusedParameter = @{
            CommandsToTraverse = @(
                'Where-Object',
                'Remove-PodeRoute'
            )
        }
        AvoidNewObjectRule      = @{
            Severity = 'Warning'
        }
    }

    ExcludeRules = @()

}