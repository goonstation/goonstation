## Copyright (c) 2020 Aleksej Komarov
## SPDX-License-Identifier: MIT

## Initial set-up
## --------------------------------------------------------

## Enable strict mode and stop of first cmdlet error
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"
$PSDefaultParameterValues['*:ErrorAction'] = 'Stop'

## Validates exit code of external commands
function Throw-On-Native-Failure {
  if (-not $?) {
    exit 1
  }
}

## Normalize current directory
$basedir = Split-Path $MyInvocation.MyCommand.Path
$basedir = Resolve-Path "$($basedir)\.."
$rootdir = Resolve-Path "$($basedir)\.."
$targetdir = Resolve-Path "$($rootdir)\browserassets\src\tgui"
Set-Location $basedir
[Environment]::CurrentDirectory = $basedir


## Functions
## --------------------------------------------------------

function yarn {
  $YarnRelease = Get-ChildItem -Filter ".yarn\releases\yarn-*.cjs" | Select-Object -First 1
  node ".yarn\releases\$YarnRelease" @Args
  Throw-On-Native-Failure
}

function Remove-Quiet {
  Remove-Item -ErrorAction SilentlyContinue @Args
}

function task-install {
  yarn install
}

## Runs rspack
function task-rspack {
  $env:BROWSERSLIST_IGNORE_OLD_DATA = $true
  yarn run rspack @Args
}

## Runs a development server
function task-dev-server {
  yarn run tgui:dev @Args
}

## Runs benchmarking tests
function task-bench {
  yarn run rspack --env TGUI_BENCH=1
  yarn node "packages/tgui-bench/index.js"
  Stop-Process -processname "iexplore"
  Stop-Process -processname "ielowutil"
}

## Run a linter through all packages
function task-lint {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run tgui:lint @Args
  Write-Output "tgui: lint check passed"
  yarn run tgui:prettier @Args
  Write-Output "tgui: prettier check passed"
}

## Run a linter & fix through all packages
function task-lint-fix {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run tgui:lint-fix @Args
  Write-Output "tgui: lint check & fix passed"
  yarn run tgui:prettier-fix @Args
  Write-Output "tgui: prettier check & fix  passed"
}

function task-test {
  yarn run tgui:test
}

function task-test-ci {
  yarn run tgui:test-ci
}

## Mr. Proper
function task-clean {
  Remove-Quiet -Recurse -Force ../browserassets/src/tgui/.tmp
  Remove-Quiet -Force ../browserassets/src/tgui/*.map
  Remove-Quiet -Force ../browserassets/src/tgui/*.chunk.*
  Remove-Quiet -Force ../browserassets/src/tgui/*.bundle.*
  Remove-Quiet -Force ../browserassets/src/tgui/*.hot-update.*
  ## Yarn artifacts
  Remove-Quiet -Recurse -Force ".yarn\cache"
  Remove-Quiet -Recurse -Force ".yarn\unplugged"
  Remove-Quiet -Recurse -Force ".yarn\webpack" # Kept to clean up old webpack if still present
  Remove-Quiet -Recurse -Force ".yarn\rspack"
  Remove-Quiet -Force ".yarn\build-state.yml"
  Remove-Quiet -Force ".yarn\install-state.gz"
  Remove-Quiet -Force ".yarn\install-target"
  Remove-Quiet -Force ".pnp.*"
  ## NPM artifacts
  Get-ChildItem -Path "." -Include "node_modules" -Recurse -File:$false | Remove-Item -Recurse -Force
  Remove-Quiet -Force "package-lock.json"
  ## Build artifacts
  Set-Location $targetdir
  Remove-Quiet -Recurse -Force ".tmp"
  Remove-Quiet -Force "*.map"
  Remove-Quiet -Force "*.hot-update.*"
  Set-Location $basedir
  Write-Output "tgui: All artifacts cleaned"
}

## Validates current build against the build stored in git
function task-validate-build {
  $diff = git diff --ignore-all-space ../browserassets/src/tgui/*
  if ($diff) {
    Write-Output "Error: our build differs from the build committed into git."
    Write-Output "Please rebuild tgui."

    # Check if the difference might just be line endings
    $crlfCheck = git diff --ignore-all-space --ignore-cr-at-eol ../browserassets/src/tgui/*
    if (-not $crlfCheck) {
      Write-Output "Note: The only difference appears to be line endings (LF vs CRLF)."
      Write-Output "You may want to check your git core.autocrlf config."

      # Examine a sample of the differing files to show line endings
      $diffFiles = git diff --name-only ../browserassets/src/tgui/*
      if ($diffFiles) {
        $sampleFile = $diffFiles -split "`n" | Select-Object -First 1
        if ($sampleFile) {
          Write-Output "Examining line endings in file: $sampleFile"
          $fileContent = Get-Content -Raw $sampleFile
          $hasLF = $fileContent -match "`n" -and $fileContent -notmatch "`r`n"
          $hasCRLF = $fileContent -match "`r`n"
          Write-Output "File contains LF (Unix) line endings: $hasLF"
          Write-Output "File contains CRLF (Windows) line endings: $hasCRLF"
        }
      }
    } else {
      Write-Output "There are content differences beyond just line endings."

      Write-Output "Changed files:"
      git diff --name-only ../browserassets/src/tgui/*

      Write-Output ""
      $diffFiles = git diff --name-only ../browserassets/src/tgui/*
      foreach ($file in ($diffFiles -split "`n")) {
        if (-not [string]::IsNullOrWhiteSpace($file)) {
          Write-Output "=== Character-level diff for: $file ==="
          # Use full repository path for the diff to avoid path issues
          Push-Location $rootdir
          git diff --text --word-diff=color --word-diff-regex=. -- "$file"
          Pop-Location
          Write-Output ""
        }
      }
    }
    exit 1
  }
  Write-Output "tgui: build is ok"
}

## Installs merge drivers and git hooks
function task-install-git-hooks () {
    Set-Location $global:basedir
    git config --replace-all merge.tgui-merge-bundle.driver "tgui/bin/tgui --merge=bundle %P %O %A %B %L"
    Write-Output "tgui: Merge drivers have been successfully installed!"
}

## Main
## --------------------------------------------------------

if ($Args.Length -gt 0) {
  if ($Args[0] -eq "--install-git-hooks") {
    task-install-git-hooks
    exit 0
  }

  if ($Args[0] -eq "--dev") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-dev-server @Rest
    exit 0
  }

    if ($Args[0] -eq "--bench") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-bench @Rest
    exit 0
  }

  if ($Args[0] -eq "--lint") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint @Rest
    exit 0
  }

    if ($Args[0] -eq "--lint-fix") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint-fix @Rest
    exit 0
  }

  if ($Args[0] -eq "--test") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-test @Rest
    exit 0
  }

  if ($Args[0] -eq "--test-ci") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-test-ci @Rest
    exit 0
  }

  ## Analyze the bundle
  if ($Args[0] -eq "--analyze") {
    task-install
    task-rspack --mode=production --analyze
    exit 0
  }

  ## Hook install
  if ($Args[0] -eq "--install-git-hooks") {
    task-install-git-hooks
    exit 0
  }

  if ($Args[0] -eq "--clean") {
    task-clean
    exit 0
  }

  if ($Args[0] -eq "--ci") {
    $Rest = $Args | Select-Object -Skip 1
    task-clean
    task-install
    task-test-ci
    task-lint @Rest
    task-rspack --mode=production
    task-validate-build
    exit 0
  }
}

## Make a production rspack build
if ($Args.Length -eq 0) {
  task-install
  task-lint
  task-rspack --mode=production
  exit 0
}

## Run rspack with custom flags
task-install
task-rspack @Args
