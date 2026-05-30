Set-StrictMode -Version Latest

Task test_pester get_module_command, {
    Invoke-Pester
}

#### ## test_ps_script_analyzer
#### ### - execute the script rules and output to Generated/
Task test_ps_script_analyzer test_pester, {
    New-Item -Path "Generated" -ItemType Directory
    Invoke-ScriptAnalyzer -Path .\ -Recurse -IncludeDefaultRules -IncludeSuppressed -SaveDscDependency |
        Out-File -FilePath (Join-Path -Path "$PSScriptRoot" -ChildPath "Generated" -AdditionalChildPath "ScriptAnalyzer.txt")
}

Task publish_ps_gallery {

}

Task git_flow_release {

}

Task write_directory_hashes test_ps_script_analyzer, {
    Write-DirectoryHashes $PSScriptRoot
}

#### ## get_module_command
#### ### - write the syntax of the functions in each over
#### - Pester
#### - PSScriptAnalyzer
#### - InvokeBuild
#### - OptimusSharp.PSSecurity
Task get_module_command {
    Get-Command -Module Pester -Syntax
    Get-Command -Module PSScriptAnalyzer -Syntax
    Get-Command -Module InvokeBuild -Syntax
    Get-Command -Module OptimusSharp.PSSecurity -Syntax
}
