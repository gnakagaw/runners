Smoke = Runners::Testing::Smoke

Smoke.add_test(
  "success",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "sample.go",
        location: {start_line: 9},
        id: "errcheck",
        message: "Error return value of `validate` is not checked",
        links: [],
        object: nil,
        git_blame_info: nil
      },
    ],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "no_error",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

# Smoke.add_test(
#   "warning_in_test",
#   {
#     guid: "test-guid",
#     timestamp: :_,
#     type: "success",
#     issues: [],
#     analyzer: {name: "golangci-lint", version: "1.22.2"}
#   }
# )

Smoke.add_test(
  "failure",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "Running error",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "timeout",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "Timeout exceeded: try increase it by passing --timeout option",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "no_go_file",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "No go files to analyze",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "config_sample",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "sample.go",
        location: {start_line: 11},
        id: "structcheck",
        message: "`birthDay` is unused",
        links: [],
        object: nil,
        git_blame_info: nil
      },
   ],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "disable_option",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "sample.go",
        location: {start_line: 8},
        id: "varcheck",
        message: "`unused` is unused",
        links: [],
        object: nil,
        git_blame_info: nil
      },
    ],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "enable_option",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "sample.go",
        location: {start_line: 8},
        id: "misspell",
        message: "`Amercia` is a misspelling of `America`",
        links: [],
        object: nil,
        git_blame_info: nil
      },
    ],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "disable-all_option",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "sample.go",
        location: {start_line: 8},
        id: "unused",
        message: "var `unused` is unused",
        links: [],
        object: nil,
        git_blame_info: nil
      },
    ],
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "disable_only",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "Must enable at least one linter",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "enable_disable_same_linter",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "Can't be disabled and enabled at one moment",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)

Smoke.add_test(
  "duplicate_disable",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message: "can't combine options --disable-all and --disable",
    analyzer: {name: "golangci-lint", version: "1.22.2"}
  }
)
