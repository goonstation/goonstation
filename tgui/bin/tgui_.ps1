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
$targetdir = Resolve-Path "$($rootdir)\browserassets\tgui"
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
  yarn run webpack-cli @Args
}

## Runs a development server
function task-dev-server {
  yarn node --experimental-modules "packages/tgui-dev-server/index.js" @Args
}

## Run a linter through all packages
function task-lint {
  yarn run tsc
  Write-Output "tgui: type check passed"
  yarn run eslint packages --ext ".js,.cjs,.ts,.tsx" @Args
  Write-Output "tgui: eslint check passed"
}

## Installs merge drivers and git hooks
function task-install-git-hooks() {
  Set-Location $basedir
  $git_root = "$(git rev-parse --show-toplevel)"
  $git_base_dir = "${basedir}/${git_root}/.}"
  git config --replace-all merge.tgui-merge-bundle.driver \
    "${git_base_dir}/bin/tgui --merge=bundle %O %A %B %L %P"
  Write-Output "tgui: Merge drivers have been successfully installed!"
}

function task-test {
  yarn run jest
}

## Mr. Proper
function task-clean {
  Remove-Quiet -Recurse -Force ../browserassets/tgui/.tmp
  Remove-Quiet -Force ../browserassets/tgui/*.map
  Remove-Quiet -Force ../browserassets/tgui/*.chunk.*
  Remove-Quiet -Force ../browserassets/tgui/*.bundle.*
  Remove-Quiet -Force ../browserassets/tgui/*.hot-update.*
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
}


## Main
## --------------------------------------------------------

if ($Args.Length -gt 0) {
  if ($Args[0] -eq "--clean") {
    task-clean
    exit 0
  }

  if ($Args[0] -eq "--dev") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-dev-server @Rest
    exit 0
  }

  if ($Args[0] -eq "--lint") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint @Rest
    exit 0
  }

  if ($Args[0] -eq "--lint-harder") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint -c ".eslintrc-harder.yml" @Rest
    exit 0
  }

  if ($Args[0] -eq "--fix") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-lint --fix @Rest
    exit 0
  }

  if ($Args[0] -eq "--test") {
    $Rest = $Args | Select-Object -Skip 1
    task-install
    task-test @Rest
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
