Smoke = Runners::Testing::Smoke

# a normal case
Smoke.add_test(
  'success',
  {
    guid: 'test-guid',
    timestamp: :_,
    type: 'success',
    issues: [
      {
        path: 'Program.cs',
        location: { start_line: 9, start_column: 31, end_line:9, end_column:45 },
        id: 'CA1303',
        message: "Method 'void Program.Main(string[] args)' passes a literal string as parameter 'value' of a call to 'void Console.WriteLine(string value)'. Retrieve the following string(s) from a resource table instead: \"Hello World!\".",
        object: nil,
        git_blame_info: nil,
        links: []
      },
      {
        path: 'Program.cs',
        location: { start_line: 7, start_column: 35, end_line:7, end_column:39 },
        id: 'CA1801',
        message: 'Parameter args of method Main is never used. Remove the parameter or use it in the method body.',
        object: nil,
        git_blame_info: nil,
        links: []
      }
    ],
    analyzer: { name: 'FxCop Analyzers', version: '2.9.8' }
  }
)

# a project don't have .NET Core Project file (csproj)
Smoke.add_test(
  'no_csproj',
  {
    guid: 'test-guid',
    timestamp: :_,
    type: 'failure',
    message: :_,
    analyzer: :_,
  }
)

# a project have invalid .NET Core Project file (csproj)
Smoke.add_test(
  'invalid_csproj',
  {
    guid: 'test-guid',
    timestamp: :_,
    type: 'failure',
    message: :_,
    analyzer: :_,
  }
)
