Smoke = Runners::Testing::Smoke

Smoke.add_test(
  "success",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "readme.md",
        location: { start_line: 1 },
        id: "list-item-indent",
        message: "Incorrect list-item indent: add 2 spaces",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "readme.md",
        location: { start_line: 3, end_line: 3 },
        id: "no-undefined-references",
        message: "Found reference to undefined definition",
        links: [],
        object: nil,
        git_blame_info: nil
      }
    ],
    analyzer: { name: "remark-lint", version: "6.0.5" }
  }
)

Smoke.add_test(
  "rc_path",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "readme.md",
        location: { start_line: 4, end_line: 4 },
        id: "no-auto-link-without-protocol",
        message: "All automatic links must start with a protocol",
        links: [],
        object: nil,
        git_blame_info: nil
      }
    ],
    analyzer: { name: "remark-lint", version: "6.0.5" }
  }
)

Smoke.add_test(
  "external_rules",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "readme.md",
        location: { start_line: 1, end_line: 1 },
        id: "books-links",
        message: "Missing PDF indication",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "readme.md",
        location: { start_line: 1, end_line: 1 },
        id: "books-links",
        message: "Missing a space before author",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "readme.md",
        location: { start_line: 2, end_line: 2 },
        id: "books-links",
        message: "Missing PDF indication",
        links: [],
        object: nil,
        git_blame_info: nil
      }
    ],
    analyzer: { name: "remark-lint", version: "6.0.5" }
  }
)

Smoke.add_test(
  "broken_sideci_yml",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "failure",
    message:
      "The value of the attribute `$.linter.remark.rc-path` in your `sideci.yml` is invalid. Please fix and retry.",
    analyzer: nil
  }
)

Smoke.add_test(
  "with_options",
  {
    guid: "test-guid",
    timestamp: :_,
    type: "success",
    issues: [
      {
        path: "src/content.md",
        location: { start_line: 1 },
        id: "blockquote-indentation",
        message: "Remove 1 space between blockquote and content",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "src/content.md",
        location: { start_line: 5 },
        id: "blockquote-indentation",
        message: "Remove 2 spaces between blockquote and content",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "readme.md",
        location: { start_line: 1, end_line: 1 },
        id: "heading-style",
        message: "Headings should use atx",
        links: [],
        object: nil,
        git_blame_info: nil
      },
      {
        path: "readme.md",
        location: { start_line: 5, end_line: 6 },
        id: "heading-style",
        message: "Headings should use atx",
        links: [],
        object: nil,
        git_blame_info: nil
      }
    ],
    analyzer: { name: "remark-lint", version: "6.0.5" }
  }
)
