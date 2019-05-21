workflow "Release" {
  on = "push"
  resolves = ["goreleaser"]
}

action "only tags" {
  uses = "actions/bin/filter@3c0b4f0e63ea54ea5df2914b4fabf383368cd0da"
  args = "tag"
}

action "goreleaser" {
  uses = "docker://goreleaser/goreleaser"
  secrets = ["GORELEASER_GITHUB_TOKEN"]
  args = "release"
  needs = ["only tags"]
}

workflow "Test" {
  on = "push"
  resolves = ["send coverage to codecov"]
}

action "run tests" {
  uses = "docker://golang:latest"
  runs = "go test -race -coverprofile=coverage.txt -covermode=atomic"
}

action "send coverage to codecov" {
  uses = "docker://golang:latest"
  needs = ["run tests"]
  runs = "bash <(curl -s https://codecov.io/bash)"
  secrets = ["CODECOV_TOKEN"]
}
