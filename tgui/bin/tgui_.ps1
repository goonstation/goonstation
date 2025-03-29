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

## Runs webpack
function task-webpack {
  $env:BROWSERSLIST_IGNORE_OLD_DATA = $true
  yarn run webpack-cli @Args
}

## Runs a development server
function task-dev-server {
  yarn run tgui:dev @Args
}

## Runs benchmarking tests
function task-bench {
  yarn run webpack-cli --env TGUI_BENCH=1
  yarn node "packages/tgui-bench/index.js"
  Stop-Process -processname "iexplore"
  Stop-Process -processname "ielowutil"
}

## Run a linter through all packages
function task-lint {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run tgui:eslint @Args
  Write-Output "tgui: eslint check passed"
  yarn run tgui:prettier @Args
  Write-Output "tgui: prettier check passed"
}

function task-test {
  yarn run tgui:test
}

function task-test-ci {
  yarn run tgui:test-ci
}

function task-sonar {
  yarn run tgui:sonar
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
  Remove-Quiet -Recurse -Force ".yarn\webpack"
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
  $diff = git diff --text ../browserassets/src/tgui/*
  if ($diff) {
    Write-Output "Error: our build differs from the build committed into git."
    Write-Output "Please rebuild tgui."
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

  if ($Args[0] -eq "--sonar") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-sonar @Rest
    exit 0
  }

  ## Analyze the bundle
  if ($Args[0] -eq "--analyze") {
    task-install
    task-webpack --mode=production --analyze
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
    task-webpack --mode=production
    task-validate-build
    exit 0
  }
}

## Make a production webpack build
if ($Args.Length -eq 0) {
  task-install
  task-lint
  task-webpack --mode=production
  exit 0
}

## Run webpack with custom flags
task-install
task-webpack @Args
