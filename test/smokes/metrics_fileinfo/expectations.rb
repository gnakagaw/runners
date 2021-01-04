s = Runners::Testing::Smoke

s.add_test(
  "success",
  { type: "success",
    issues: [
      {
        id: "metrics_fileinfo",
        path: "dummy.txt",
        location: nil,
        message: nil,
        links: [],
        object: {
          line_of_code: 10,
          last_commit_datetime: "2020-01-04"

        }
      }
    ] }
)
