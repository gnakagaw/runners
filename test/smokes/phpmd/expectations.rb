Smoke = Runners::Testing::Smoke

Smoke.add_test("success", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [
    { path: "app.php",
      location: { :start_line => 5, :end_line => 5 },
      id: "UnusedLocalVariable",
      message: "Avoid unused local variables such as '$hoge'.",
      links: ["https://phpmd.org/rules/unusedcode.html#unusedlocalvariable"],
      object: nil,
    }
  ],
  analyzer: {
    name: "phpmd",
    version: "2.7.0"
  },
})

Smoke.add_test("invalid_rule", {
  guid: "test-guid",
  timestamp: :_,
  type: "error",
  class: "Runners::Shell::ExecError",
  backtrace: :_,
  inspect: :_
})

Smoke.add_test("valid_options", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [
    { path: "app/index.php",
      location: { start_line: 20, end_line: 20 },
      id: "UnusedLocalVariable",
      message: "Avoid unused local variables such as '$hoge'.",
      links: ["https://phpmd.org/rules/unusedcode.html#unusedlocalvariable"],
      object: nil,
    },
    { path: "foo.phtml",
      location: { start_line: 5, end_line: 5 },
      id: "UnusedLocalVariable",
      message: "Avoid unused local variables such as '$var'.",
      links: ["https://phpmd.org/rules/unusedcode.html#unusedlocalvariable"],
      object: nil,
    },
  ],
  analyzer: {
    name: "phpmd",
    version: "2.7.0"
  },
}, {
  warnings: [{ message: <<~MSG.strip, file: "sideci.yml" }],
    DEPRECATION WARNING!!!
    The `$.linter.phpmd.options` option(s) in your `sideci.yml` are deprecated and will be removed in the near future.
    Please update to the new option(s) according to our documentation (see https://help.sider.review/tools/php/phpmd ).
  MSG
})

Smoke.add_test("syntax_error", {
  guid: "test-guid",
  timestamp: :_,
  type: "failure",
  message: :_,
  analyzer: {
    name: "phpmd",
    version: "2.7.0",
  },
})

Smoke.add_test("php_7.1", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [
    { path: "SomeClass.php",
      location: { :start_line => 11, :end_line => 11 },
      id: "UnusedPrivateField",
      message: "Avoid unused private fields such as '$unusedVariable'.",
      links: ["https://phpmd.org/rules/unusedcode.html#unusedprivatefield"],
      object: nil,
    },
  ],
  analyzer: {
    name: "phpmd",
    version: "2.7.0",
  }
})

Smoke.add_test("php_7.3", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [
    { path: "app.php",
      location: { :start_line => 7, :end_line => 7 },
      id: "UnusedLocalVariable",
      message: "Avoid unused local variables such as '$hoge'.",
      links: ["https://phpmd.org/rules/unusedcode.html#unusedlocalvariable"],
      object: nil,
    }
  ],
  analyzer: {
    name: "phpmd",
    version: "2.7.0"
  },
})

Smoke.add_test("with_php_version", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [],
  analyzer: {
    name: "phpmd",
    version: "2.7.0",
  }
})

Smoke.add_test("broken_sideci_yml", {
  guid: "test-guid",
  timestamp: :_,
  type: "failure",
  message: "Invalid configuration in `sideci.yml`: unexpected value at config: `$.linter.phpmd.minimumpriority`",
  analyzer: nil
})

Smoke.add_test("custom_rule", {
  guid: "test-guid",
  timestamp: :_,
  type: "success",
  issues: [
    {
      path: "foo.php",
      location: { start_line: 3, end_line: 5 },
      id: "NoFunctions",
      message: "Please do not use functions.",
      links: ["https://example.com/phpmd/rules/no-functions"],
      object: nil,
    },
    {
      path: "Custom_NoFunctions.php",
      location: { start_line: 6, end_line: 9 },
      id: "NoMethods",
      message: "Please do not use methods.",
      links: ["https://example.com/phpmd/rules/no-methods"],
      object: nil,
    },
    {
      path: "custom/rules/NoMethods.php",
      location: { start_line: 8, end_line: 11 },
      id: "NoMethods",
      message: "Please do not use methods.",
      links: ["https://example.com/phpmd/rules/no-methods"],
      object: nil,
    },
  ],
  analyzer: { name: "phpmd", version: "2.7.0" },
})
