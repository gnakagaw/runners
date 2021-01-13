s = Runners::Testing::Smoke

s.add_test_with_git_metadata(
  "success",
  { type: "success",
    issues: [
      {
        id: "metrics_fileinfo",
        path: "hello.rb",
        location: nil,
        message: "hello.rb: loc = 7, last commit datetime = 2020-01-01T10:00:00+09:00",
        links: [],
        object: {
          line_of_code: 10,
          last_commit_datetime: "2020-01-01T10:00:00+09:00"
        },
        git_blame_info: nil
      }
    ],
    analyzer: { name: "Metrics File Info", version: "8.30" } }
)
