s = Runners::Testing::Smoke

s.add_test_with_git_metadata(
  "success",
  { type: "success",
    issues: [
      {
        id: "metrics_fileinfo",
        path: "hello.rb",
        location: nil,
        message: "hello.rb: loc = 7, last commit datetime = 2021-01-01T10:00:00+09:00",
        links: [],
        object: {
          line_of_code: 7,
          last_commit_datetime: "2021-01-01T10:00:00+09:00"
        },
        git_blame_info: nil
      }
    ],
    analyzer: { name: "Metrics File Info", version: "8.30" } }
)

s.add_test_with_git_metadata(
  "binary_files",
  { type: "success",
    issues: [
      {
        id: "metrics_fileinfo",
        path: "image.png",
        location: nil,
        message: "image.png: loc = (nil), last commit datetime = 2021-01-01T13:00:00+09:00",
        links: [],
        object: {
          line_of_code: nil,
          last_commit_datetime: "2021-01-01T13:00:00+09:00"
        },
        git_blame_info: nil
      }, {
        id: "metrics_fileinfo",
        path: "no_text.txt",
        location: nil,
        message: "no_text.txt: loc = (nil), last commit datetime = 2021-01-01T14:00:00+09:00",
        links: [],
        object: {
          line_of_code: nil,
          last_commit_datetime: "2021-01-01T14:00:00+09:00"
        },
        git_blame_info: nil
      }
    ],
    analyzer: { name: "Metrics File Info", version: "8.30" } }
)

s.add_test_with_git_metadata(
  "unknown_extension",
  { type: "success",
    issues: [
      {
        id: "metrics_fileinfo",
        path: "foo.my_original_extension",
        location: nil,
        message: "foo.my_original_extension: loc = 2, last commit datetime = 2021-01-01T11:00:00+09:00",
        links: [],
        object: {
          line_of_code: 2,
          last_commit_datetime: "2021-01-01T11:00:00+09:00"
        },
        git_blame_info: nil
      }
    ],
    analyzer: { name: "Metrics File Info", version: "8.30" } }
)
