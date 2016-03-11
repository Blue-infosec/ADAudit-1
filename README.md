# ADAudit

## Description
This Windows PowerShell module is to provide functions to aid in the collection of information from AD for the purpose of auditing its configuration for security purposes. 

## License

The ADAudit project and all individual scripts are under the BSD 3-Clause license unless explicitly noted otherwise.

## Usage

Refer to the comment-based help in each individual script for detailed usage information.

To install this module, drop the entire ADAudit folder into one of your module directories. The default PowerShell module paths are listed in the $Env:PSModulePath environment variable.

The default per-user module path is: "$Env:HomeDrive$Env:HOMEPATH\Documents\WindowsPowerShell\Modules"
The default computer-level module path is: "$Env:windir\System32\WindowsPowerShell\v1.0\Modules"

Once you've placed PowerSploit into your module path, run the following one-liner:
`$Env:PSModulePath.Split(';') |
 % { if ( Test-Path (Join-Path $_ ADAudit) )
 {Get-ChildItem $_ -Recurse | Unblock-File} }`

To use the module, type `Import-Module ADAudit`

To see the commands imported, type `Get-Command -Module ADAudit`

For help on each individual command, Get-Help is your friend.

Note: The tools contained within this module were all designed such that they can be run individually. Including them in a module simply lends itself to increased portability.

## Contribution Rules

New additions will require the following:

* The script must adhere to the [style guide](https://github.com/PoshCode/PowerShellPracticeAndStyle). Any exceptions to the guide line would need an explicit, valid reason.
* Make sure to run [Microsoft PowerShell Script Analyzer](https://github.com/PowerShell/PSScriptAnalyzer) against the files you add and modify to ensure basic best practices are followed and nothing was missed.
* The module manifest needs to be updated to reflect the new function being added.
* A brief description of the function should be added to this README.md
* Pester tests must accompany all new functions. See the Tests folder for examples but we are looking for tests that at least cover the basics by testing for expected/unexpected input/output and that the function exhibits desired functionality. Make sure the function is passing all tests (preferably in multiple OSes) prior to submitting a pull request. Thanks!
* All pull request should be done against the dev branch.