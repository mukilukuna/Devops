Describe "Get-AzAlertBudget Tests" {
    BeforeAll {
        Set-Item function:Get-AzAlertBudget ([ScriptBlock]::Create((Get-Content -Raw $PSScriptRoot\..\scripts\Get-AzAlertBudget.ps1)))
    }
    Context "Script Validation" {
        It "Has expected parameters" {
            Get-Command Get-AzAlertBudget | Should -Not -BeNullOrEmpty
            Get-Command Get-AzAlertBudget | Should -HaveParameter Name -Type "string"
            Get-Command Get-AzAlertBudget | Should -HaveParameter Scope -Type "string"
            Get-Command Get-AzAlertBudget | Should -HaveParameter ResourceGroupName -Type "string"
            Get-Command Get-AzAlertBudget | Should -HaveParameter SubscriptionId -Type "string"
        }
    }
    Context "Get non existent subscription scope budget" {
        BeforeAll {

            $BudgetName = 'NonExistentBudget'
            $BudgetScope = 'SubscriptionId'

            Mock -CommandName Get-AzAlertBudget -ParameterFilter {
                $Name -eq "Budget"
                $Scope -eq "Subscription"
            }


        }

        It "Should run Invoke-AzRestMethod" {
            Get-AzAlertBudget -Name $BudgetName -Scope $BudgetScope
            Mock -CommandName "Get-Date"
            Should -Invoke "Get-AzAlertBudget" -Exactly 1
            Should -Invoke "Get-Date" -Exactly 1
        }
    }
}