# Changelog

All notable changes to this project will be documented in this file.

## Unreleased

[Full diff](https://github.com/sider/runners/compare/0.20.0...HEAD)

- Show stderr of git-blame(1) [#756](https://github.com/sider/runners/pull/756)
- [FxCop Analyzers] New support [#731](https://github.com/sider/runners/pull/731)

## 0.20.0

[Full diff](https://github.com/sider/runners/compare/0.19.4...0.20.0)

- [RuboCop] Update rubocop requirement from 0.79.0 to 0.80.0 [#752](https://github.com/sider/runners/pull/752)
- [HAML-Lint] Update rubocop requirement from 0.79.0 to 0.80.0 [#753](https://github.com/sider/runners/pull/753)
- [RuboCop] [HAML-Lint] Set an upper limit for constraints [#755](https://github.com/sider/runners/pull/755)

## 0.19.4

[Full diff](https://github.com/sider/runners/compare/0.19.3...0.19.4)

- Show Runners version and GUID to trace [#744](https://github.com/sider/runners/pull/744)

## 0.19.3

[Full diff](https://github.com/sider/runners/compare/0.19.2...0.19.3)

- [RuboCop] Add `gitlab-styles` to optional gem list [#743](https://github.com/sider/runners/pull/743)

## 0.19.2

[Full diff](https://github.com/sider/runners/compare/0.19.1...0.19.2)

- Add more plugins to OPTIONAL_GEMS in haml_lint.rb [#734](https://github.com/sider/runners/pull/734)

## 0.19.1

[Full diff](https://github.com/sider/runners/compare/0.19.0...0.19.1)

- Set UserKnownHostsFile to avoid error message [#730](https://github.com/sider/runners/pull/730)

## 0.19.0

[Full diff](https://github.com/sider/runners/compare/0.18.1...0.19.0)

- [RuboCop] Add more plugins to OPTIONAL_GEMS [#683](https://github.com/sider/runners/pull/683)
- [Flake8] Add warnings if the analysis tries to use Python 2 [#702](https://github.com/sider/runners/pull/702)
- [SwiftLint] Bump SwiftLint from 0.38.1 to 0.38.2 [#669](https://github.com/sider/runners/pull/669)
- [HAML-Lint] Bump rubocop-rails from 2.4.1 to 2.4.2 [#680](https://github.com/sider/runners/pull/680)
- [Checkstyle][Security] Bump checkstyle from 8.28 to 8.29 [#685](https://github.com/sider/runners/pull/685)
- [PHP_CodeSniffer] Bump squizlabs/php_codesniffer from 3.5.3 to 3.5.4 [#686](https://github.com/sider/runners/pull/686)
- [PHP_CodeSniffer] Bump escapestudios/symfony2-coding-standard from 3.10.0 to 3.11.0 [#688](https://github.com/sider/runners/pull/688)
- [TSLint] Bump typescript from 3.7.4 to 3.7.5 [#681](https://github.com/sider/runners/pull/691)
- [TyScan] Bump typescript from 3.7.4 to 3.7.5 [#692](https://github.com/sider/runners/pull/692)
- [PMD Java] Bump pmd-java from 6.20.0 to 6.21.0 [#695](https://github.com/sider/runners/pull/695)
- [Reek] Update reek requirement from 5.5.0 to 5.6.0 [#694](https://github.com/sider/runners/pull/694)
- [JSHint] Bump jshint from 2.10.3 to 2.11.0 [#690](https://github.com/sider/runners/pull/690)
- [stylelint] Bump stylelint from 12.0.1 to 13.0.0 [#693](https://github.com/sider/runners/pull/693)
- [TSLint] Bump tslint from 5.20.1 to 6.0.0 [#689](https://github.com/sider/runners/pull/689)
- [HAML-Lint] Update haml_lint requirement from 0.34.1 to 0.34.2 [#705](https://github.com/sider/runners/pull/705)
- [ESLint] Drop older versions of ESLint [#721](https://github.com/sider/runners/pull/721)
- [RuboCop] Drop older versions of RuboCop [#726](https://github.com/sider/runners/pull/726)
- Bump devon_rex images from 2.12.0 to 2.14.0 [#727](https://github.com/sider/runners/pull/727)
- [HAML-Lint] Update rubocop-rspec requirement from 1.37.1 to 1.38.0 [#720](https://github.com/sider/runners/pull/720)

## 0.18.1

[Full diff](https://github.com/sider/runners/compare/0.18.0...0.18.1)

- [TSLint] Loosen the version constraint allowing v6 [#681](https://github.com/sider/runners/pull/681)

## 0.18.0

[Full diff](https://github.com/sider/runners/compare/0.17.1...0.18.0)

- [hadolint] New support [#625](https://github.com/sider/runners/pull/625)

## 0.17.1

[Full diff](https://github.com/sider/runners/compare/0.17.0...0.17.1)

- Handle the empty externalInfoUrl in phpmd [#657](https://github.com/sider/runners/pull/657)
- Add #add_git_blame_info [#655](https://github.com/sider/runners/pull/655)

## 0.17.0

[Full diff](https://github.com/sider/runners/compare/0.16.0...0.17.0)

- [Brakeman] Quiet output [#647](https://github.com/sider/runners/pull/647)
- Bump devon_rex images from 2.11.0 to 2.12.0 [#646](https://github.com/sider/runners/pull/646)
- Bump Cppcheck from 1.89 to 1.90 [#628](https://github.com/sider/runners/pull/628)
- [HAML-Lint] Bump rubocop-rails from 2.4.0 to 2.4.1 [#629](https://github.com/sider/runners/pull/629)
- Bump checkstyle from 8.27 to 8.28 in /images/checkstyle [#635](https://github.com/sider/runners/pull/635)
- Bump typescript from 3.7.2 to 3.7.4 in /images/tyscan [#636](https://github.com/sider/runners/pull/636)
- Bump typescript from 3.7.2 to 3.7.4 in /images/tslint [#640](https://github.com/sider/runners/pull/640)
- Bump ktlint from 0.35.0 to 0.36.0 in /images/ktlint [#638](https://github.com/sider/runners/pull/638)
- Bump eslint from 6.7.2 to 6.8.0 in /images/eslint [#637](https://github.com/sider/runners/pull/637)
- Bump phpmd/phpmd from 2.7.0 to 2.8.1 in /images/phpmd [#641](https://github.com/sider/runners/pull/641)
- Bump stylelint from 12.0.0 to 12.0.1 in /images/stylelint [#639](https://github.com/sider/runners/pull/639)
- Bump php_codesniffer from 3.5.2 to 3.5.3 in /images/code_sniffer [#642](https://github.com/sider/runners/pull/642)
- Bump SwiftLint from 0.38.0 to 0.38.1 [#645](https://github.com/sider/runners/pull/645)
- [HAML-Lint] Bump rubocop from 0.78.0 to 0.79.0 [#650](https://github.com/sider/runners/pull/650)
- Bump rubocop from 0.78.0 to 0.79.0 in /images/rubocop [#651](https://github.com/sider/runners/pull/651)

## 0.16.0

[Full diff](https://github.com/sider/runners/compare/0.15.0...0.16.0)

- Add git_blame_info field in the Issue schema [#630](https://github.com/sider/runners/pull/630)

## 0.15.0

[Full diff](https://github.com/sider/runners/compare/0.14.0...0.15.0)

- Renewal trace [#624](https://github.com/sider/runners/pull/624)

## 0.14.0

[Full diff](https://github.com/sider/runners/compare/0.13.2...0.14.0)

- [HAML-Lint] Bump rubocop-rspec from 1.37.0 to 1.37.1 [#601](https://github.com/sider/runners/pull/601)
- [HAML-Lint] Bump rubocop from 0.77.0 to 0.78.0 [#613](https://github.com/sider/runners/pull/613)
- Bump rubocop from 0.77.0 to 0.78.0 [#608](https://github.com/sider/runners/pull/608)

## 0.13.2

[Full diff](https://github.com/sider/runners/compare/0.13.1...0.13.2)

- Truncate long message on trace [#605](https://github.com/sider/runners/pull/605)

## 0.13.1

[Full diff](https://github.com/sider/runners/compare/0.13.0...0.13.1)

- [Flake8] Fix error if `.python-version` file exists [#602](https://github.com/sider/runners/pull/602)

## 0.13.0

[Full diff](https://github.com/sider/runners/compare/0.12.0...0.13.0)

- Bump jshint from 2.10.2 to 2.10.3 [#543](https://github.com/sider/runners/pull/543)
- Bump pmd-java from 6.19.0 to 6.20.0 [#539](https://github.com/sider/runners/pull/539)
- Bump checkstyle from 8.26 to 8.27 [#540](https://github.com/sider/runners/pull/540)
- Bump reek from 5.4.0 to 5.5.0 [#541](https://github.com/sider/runners/pull/541)
- Bump symfony2-coding-standard from 3.9.2 to 3.10.0 [#542](https://github.com/sider/runners/pull/542)
- Bump eslint from 6.6.0 to 6.7.2 [#544](https://github.com/sider/runners/pull/544)
- Bump wpcs from 2.1.1 to 2.2.0 [#546](https://github.com/sider/runners/pull/546)
- Bump cakephp-codesniffer from 3.1.2 to 3.3.0 [#561](https://github.com/sider/runners/pull/561)
- Bump SwiftLint from 0.37.0 to 0.38.0 [#557](https://github.com/sider/runners/pull/557)
- [PMD Java] Find design issues by default [#563](https://github.com/sider/runners/pull/563)
- [PMD Java] Save issue details [#565](https://github.com/sider/runners/pull/565)
- [Reek] Improve issue message [#566](https://github.com/sider/runners/pull/566)
- [HAML-Lint] Save issue link and severity [#567](https://github.com/sider/runners/pull/567)
- Bump devon_rex images from 2.10.0 to master [#568](https://github.com/sider/runners/pull/568)
- Bump devon_rex images from master to 2.11.0 [#578](https://github.com/sider/runners/pull/578)
- Show runtime version as possible [#575](https://github.com/sider/runners/pull/575)
- Bump haml_lint from 0.34.0 to 0.34.1 [#576](https://github.com/sider/runners/pull/576)
- [PHPMD] Output report to file instead of STDOUT [#577](https://github.com/sider/runners/pull/577)
- Filter issues with the "diff lines" [#584](https://github.com/sider/runners/pull/584)
- [PHPMD] Reduce trace size [#588](https://github.com/sider/runners/pull/588)
- [PHPMD] Handle invalid output XML [#589](https://github.com/sider/runners/pull/589)
- [HAML-Lint] Add warnings if RuboCop fails [#587](https://github.com/sider/runners/pull/587)
- Bump goodcheck from 2.4.4 to 2.4.5 [#591](https://github.com/sider/runners/pull/591)
- Hide userinfo of HTTP URI from the traces [#585](https://github.com/sider/runners/pull/585)
- [PHPCS] Empower runner [#592](https://github.com/sider/runners/pull/592)
- Use Yarn when duplicate lock files are found [#593](https://github.com/sider/runners/pull/593)

## 0.12.0

[Full diff](https://github.com/sider/runners/compare/0.11.1...0.12.0)

- Add Workspace::Git to fetch source code via Git [#548](https://github.com/sider/runners/pull/548)

## 0.11.1

[Full diff](https://github.com/sider/runners/compare/0.11.0...0.11.1)

- Add a feature to mask secure strings on TraceWriter [#537](https://github.com/sider/runners/pull/537)
- [ShellCheck] No warnings when no analyzed files [#538](https://github.com/sider/runners/pull/538)

## 0.11.0

[Full diff](https://github.com/sider/runners/compare/0.10.0...0.11.0)

- Bump devon_rex images from 2.9.0 to 2.10.0 [#527](https://github.com/sider/runners/pull/527)
- [HAML-Lint] Fix incompatibility with RuboCop [#533](https://github.com/sider/runners/pull/533)
- [RuboCop] Bump rubocop from 0.76.0 to 0.77.0 [#529](https://github.com/sider/runners/pull/529)
- [HAML-Lint] Bump rubocop from 0.76.0 to 0.77.0 [#530](https://github.com/sider/runners/pull/530)
- [HAML-Lint] Bump rubocop-rspec from 1.36.0 to 1.37.0 [#531](https://github.com/sider/runners/pull/531)
- [HAML-Lint] Bump rubocop-rails from 2.3.2 to 2.4.0 [#532](https://github.com/sider/runners/pull/532)
- Configure instance_profile_credentials_* for Aws::S3::Client [#526](https://github.com/sider/runners/pull/526)
- [RuboCop] Bump Ruby from 2.5.6 to 2.5.7 [#534](https://github.com/sider/runners/pull/534)
- [cpplint] Fix error when the output line number is `None` [#536](https://github.com/sider/runners/pull/536)

## 0.10.0

[Full diff](https://github.com/sider/runners/compare/0.9.2...0.10.0)

- Bump devon_rex images from 2.8.0 to 2.9.0 [#500](https://github.com/sider/runners/pull/500)
- Wrap Workspace with Harness [#501](https://github.com/sider/runners/pull/501)
- Bump goodcheck from 2.4.3 to 2.4.4 [#505](https://github.com/sider/runners/pull/505)
- Mark the result "failure" when `sider.yml` is broken [#504](https://github.com/sider/runners/pull/504)
- Bump stylelint from 11.1.1 to 12.0.0 [#508](https://github.com/sider/runners/pull/508)

## 0.9.2

[Full diff](https://github.com/sider/runners/compare/0.9.1...0.9.2)

- Flush content whenever its size reaches the buffer max limit [#497](https://github.com/sider/runners/pull/497)

## 0.9.1

[Full diff](https://github.com/sider/runners/compare/0.9.0...0.9.1)

- [RuboCop] Fix `Ruby#installed_gem_versions` [#489](https://github.com/sider/runners/pull/489)

## 0.9.0

[Full diff](https://github.com/sider/runners/compare/0.8.2...0.9.0)

- Update scss_lint from 0.58.0 to 0.59.0 [#432](https://github.com/sider/runners/pull/432)
- Bump pmd_java from 6.18.0 to 6.19.0 [#433](https://github.com/sider/runners/pull/433)
- Bump flake8 from 3.7.8 to 3.7.9 [#436](https://github.com/sider/runners/pull/436)
- Bump haml_lint from 0.33.0 to 0.34.0 [#440](https://github.com/sider/runners/pull/440)
- Bump checkstyle from 8.25 to 8.26 [#441](https://github.com/sider/runners/pull/441)
- Bump ktlint from 0.34.2 to 0.35.0 [#442](https://github.com/sider/runners/pull/442)
- Bump php_codesniffer from 3.5.0 to 3.5.2 [#444](https://github.com/sider/runners/pull/444)
- Bump tslint from 5.20.0 to 5.20.1 [#469](https://github.com/sider/runners/pull/469)
- Bump eslint from 6.5.1 to 6.6.0 [#431](https://github.com/sider/runners/pull/431)
- Bump goodcheck from 2.4.0 to 2.4.3 [#468](https://github.com/sider/runners/pull/468)
- Bump rubocop from 0.75.0 to 0.76.0 [#434](https://github.com/sider/runners/pull/434)
- Bump devon_rex images from 2.7.0 to 2.8.0 [#474](https://github.com/sider/runners/pull/474)
- Bump SwiftLint from 0.36.0 to 0.37.0 [#473](https://github.com/sider/runners/pull/473)
- [RuboCop] Empower runner [#472](https://github.com/sider/runners/pull/472)
- [checkstyle] Empower runner [#475](https://github.com/sider/runners/pull/475)
- [SwiftLint] Show a warning when no linting files [#478](https://github.com/sider/runners/pull/478)
- Bump JavaSee from 0.1.2 to 0.1.3 [#479](https://github.com/sider/runners/pull/479)
- Bump stylelint from 11.0.0 to 11.1.1 [#438](https://github.com/sider/runners/pull/438)
- [Cppcheck] Show warning and succeed when no linting files [#480](https://github.com/sider/runners/pull/480)
- Deprecate `linter.*.options` option [#482](https://github.com/sider/runners/pull/482)

## 0.8.2

[Full diff](https://github.com/sider/runners/compare/0.8.1...0.8.2)

- Add Runners version and set it to result [#449](https://github.com/sider/runners/pull/449)
- Always output the exit status to trace [#451](https://github.com/sider/runners/pull/451)
- Configure :endpoint if S3_ENDPOINT is set [#462](https://github.com/sider/runners/pull/462)

## 0.8.1

[Full diff](https://github.com/sider/runners/compare/0.8.0...0.8.1)

- [ESLint] Fix type error when no location info [#456](https://github.com/sider/runners/pull/456)

## 0.8.0

[Full diff](https://github.com/sider/runners/compare/0.7.5...0.8.0)

- Bugsnag notify on `rescue` block [#445](https://github.com/sider/runners/pull/445)
- [stylelint] Empower runner [#420](https://github.com/sider/runners/pull/420)
- [cpplint] New support [#417](https://github.com/sider/runners/pull/417)
- **[BREAKING]** Add Options module and delete insecure options [#415](https://github.com/sider/runners/pull/415)
- Output an unexpected error message to the trace log [#446](https://github.com/sider/runners/pull/446)
- [ESLint] Use `--output-file` option to fix JSON parse error [#447](https://github.com/sider/runners/pull/447)
- Suppress `npm ls` output [#448](https://github.com/sider/runners/pull/448)

## 0.7.5

[Full diff](https://github.com/sider/runners/compare/0.7.4...0.7.5)

- Improve deprecation message for older versions [#419](https://github.com/sider/runners/pull/419)
- [SwiftLint] Treat as success when no linting files [#422](https://github.com/sider/runners/pull/422)
- [JSHint] Improve error message when output XML parse is failed [#423](https://github.com/sider/runners/pull/423)

## 0.7.4

[Full diff](https://github.com/sider/runners/compare/0.7.3...0.7.4)

- Report message and metadata on `Shell::ExecError` to Bugsnag [#414](https://github.com/sider/runners/pull/414)
- Fix error for issue sorting when location is nil [#416](https://github.com/sider/runners/pull/416)

## 0.7.3

[Full diff](https://github.com/sider/runners/compare/0.7.2...0.7.3)

- Remove a warning for Node.js analyzers without dependencies [#410](https://github.com/sider/runners/pull/410)

## 0.7.2

[Full diff](https://github.com/sider/runners/compare/0.7.1...0.7.2)

- [JSHint] Show runtime versions [#407](https://github.com/sider/runners/pull/407)
- Copy `ARGV` for notifying to Bugsnag correctly [#408](https://github.com/sider/runners/pull/408)

## 0.7.1

[Full diff](https://github.com/sider/runners/compare/0.7.0...0.7.1)

- Set Bugsnag `release_stage` explicitly [#404](https://github.com/sider/runners/pull/404)
- Improve Bugsnag settings [#405](https://github.com/sider/runners/pull/405)
- [ESLint] Allow `recommended` as string [#406](https://github.com/sider/runners/pull/406)

## 0.7.0

[Full diff](https://github.com/sider/runners/compare/0.6.0...0.7.0)

- [JSHint] Consider broken package.json [#327](https://github.com/sider/runners/pull/327)
- Bump devon_rex images from master to 2.6.0 and bump Ruby from 2.6.4 to 2.6.5 [#332](https://github.com/sider/runners/pull/332)
- Trap SIGTERM to exit with an arbitrary status [#344](https://github.com/sider/runners/pull/344)
- Bump JavaSee from 0.1.1 to 0.1.2 [#362](https://github.com/sider/runners/pull/362)
- Optimize generated Gemfile [#359](https://github.com/sider/runners/pull/359)
- Use `COPY --chown` format in Dockerfile [#369](https://github.com/sider/runners/pull/369)
- Use pre-installed gems as possible [#367](https://github.com/sider/runners/pull/367)
- Bump SwiftLint from 0.34.0 to 0.36.0 [#363](https://github.com/sider/runners/pull/363)
- Bump devon_rex images from 2.6.0 to 2.7.0 (many PRs!)
- Empower ESLint runner [#401](https://github.com/sider/runners/pull/401)

## 0.6.0

[Full diff](https://github.com/sider/runners/compare/0.5.2...0.6.0)

- Reconsider issue data structure [#313](https://github.com/sider/runners/pull/313)
- Fix PHPMD target files with `suffixes` option [#318](https://github.com/sider/runners/pull/318)
- Fix Checkstyle output XML parse error [#319](https://github.com/sider/runners/pull/319)
- Improve Goodcheck error message [#321](https://github.com/sider/runners/pull/321)
- Improve Checkstyle invalid XML error message [#322](https://github.com/sider/runners/pull/322)
- Improve PHPMD custom rule support [#323](https://github.com/sider/runners/pull/323)
- Make timeout(1) call SIGUSR2 and trap it in bin/runners [#320](https://github.com/sider/runners/pull/320)
- Bump devon_rex images from 2.4.0 to 2.5.0 [#324](https://github.com/sider/runners/pull/324)

## 0.5.2

[Full diff](https://github.com/sider/runners/compare/0.5.1...0.5.2)

- Notify exception if the result is "error" [#312](https://github.com/sider/runners/pull/312)
- Set ConnectTimeout for ssh(1) to avoid waiting for a long time [#309](https://github.com/sider/runners/pull/309)

## 0.5.1

[Full diff](https://github.com/sider/runners/compare/0.5.0...0.5.1)

- Add Bugsnag to notify any errors [#304](https://github.com/sider/runners/pull/304)
- Use timeout(1) to forcefully terminate too late Runners [#306](https://github.com/sider/runners/pull/306)

## 0.5.0

[Full diff](https://github.com/sider/runners/compare/0.4.1...0.5.0)

- Add ShellCheck runner [#289](https://github.com/sider/runners/pull/289)
- Install PHP_CodeSniffer and its dependencies via Composer [#290](https://github.com/sider/runners/pull/290)
- Bump phpmd/phpmd from 2.6.1 to 2.7.0 [#291](https://github.com/sider/runners/pull/291)
- Bump escapestudios/symfony2-coding-standard from 3.4.1 to 3.9.2 [#292](https://github.com/sider/runners/pull/292)
- Bump cakephp/cakephp-codesniffer from 3.1.1 to 3.1.2 [#293](https://github.com/sider/runners/pull/293)
- Bump wp-coding-standards/wpcs from 2.0.0 to 2.1.1 [#294](https://github.com/sider/runners/pull/294)
- Bump squizlabs/php_codesniffer from 3.4.2 to 3.5.0 [#295](https://github.com/sider/runners/pull/295)
- Bump all devon_rex images from 2.3.1 to 2.4.0 (see [changelog](https://github.com/sider/devon_rex/blob/master/CHANGELOG.md#240))

## 0.4.1

[Full diff](https://github.com/sider/runners/compare/0.4.0...0.4.1)

- Retrieve --head, --head-key, --base, and --base-key from env [#249](https://github.com/sider/runners/pull/249)

## 0.4.0

[Full diff](https://github.com/sider/runners/compare/0.3.1...0.4.0)

- Update eslint requirement from 5.16.0 to 6.4.0 [#100](https://github.com/sider/runners/pull/100)
- Show deprecation warning for too old ESLint [#209](https://github.com/sider/runners/pull/209)
- Update tslint requirement from 5.18.0 to 5.20.0 [#101](https://github.com/sider/runners/pull/101)
- Update typescript requirement from 3.5.3 to 3.6.3 [#104](https://github.com/sider/runners/pull/104)
- Bump default stylelint and stylelint-config-recommended [#210](https://github.com/sider/runners/pull/210)
- Add `.npmrc` for common settings [#211](https://github.com/sider/runners/pull/211)
- Update rubocop-rspec from 1.33.0 to 1.35.0 for HAML-Lint [#116](https://github.com/sider/runners/pull/116)
- Update typescript from 3.5.3 to 3.6.3 for TyScan [#103](https://github.com/sider/runners/pull/103)
- Update sass from 3.7.3 to 3.7.4 for rails_best_practices [#117](https://github.com/sider/runners/pull/117)
- Update scss_lint from 0.57.1 to 0.58.0 [#121](https://github.com/sider/runners/pull/121)
- Update rubocop from 0.71.0 to 0.74.0 for haml_lint [#115](https://github.com/sider/runners/pull/115)
- Update sassc from 2.0.1 to 2.2.1 for rails_best_practices [#119](https://github.com/sider/runners/pull/119)
- Bump flake8 from 3.7.7 to 3.7.8 [#124](https://github.com/sider/runners/pull/124)
- Update haml from 5.0.4 to 5.1.2 for rails_best_practices [#120](https://github.com/sider/runners/pull/120)
- Update haml_lint from 0.32.0 to 0.33.0 [#118](https://github.com/sider/runners/pull/118)
- Update tyscan from 0.2.1 to 0.3.1 [#212](https://github.com/sider/runners/pull/212)
- Bump checkstyle from 8.23 to 8.25 [#221](https://github.com/sider/runners/pull/221)
- Add "security" to the default rulesets of PMD Java [#226](https://github.com/sider/runners/pull/226)
- Bump pmd-java from 6.17.0 to 6.18.0 [#225](https://github.com/sider/runners/pull/225)
- Show Java runtime versions for Java based tools [#227](https://github.com/sider/runners/pull/227)
- Receive an SSH key with an environment variable [#206](https://github.com/sider/runners/pull/206)
- Add deprecation warning for too old RuboCop versions [#228](https://github.com/sider/runners/pull/228)
- Update rubocop-rails from 2.0.1 to 2.3.2 for haml_lint [#232](https://github.com/sider/runners/pull/232)
- Update rubocop-rspec from 1.35.0 to 1.36.0 for haml_lint [#233](https://github.com/sider/runners/pull/233)
- Update rubocop from 0.74.0 to 0.75.0 for haml_lint [#236](https://github.com/sider/runners/pull/236)
- Bump default eslint from 6.4.0 to 6.5.1 [#235](https://github.com/sider/runners/pull/235)
- Bump devon_rex images to 2.3.1 [#244](https://github.com/sider/runners/pull/244)
- Bump rubocop from 0.74.0 to 0.75.0 [#229](https://github.com/sider/runners/pull/229)

## 0.3.1

[Full diff](https://github.com/sider/runners/compare/0.3.0...0.3.1)

- Make #presence available [#204](https://github.com/sider/runners/pull/204)

## 0.3.0

[Full diff](https://github.com/sider/runners/compare/0.2.1...0.3.0)

- Add IO::AwsS3 to upload traces to AWS S3 [#162](https://github.com/sider/runners/pull/162)
- Fix ktlint bug [#201](https://github.com/sider/runners/pull/201)

## 0.2.1

[Full diff](https://github.com/sider/runners/compare/0.2.0...0.2.1)

- Fix missing ktlint settings in CircleCI [#198](https://github.com/sider/runners/pull/198)
- Fix ktlint bug [#201](https://github.com/sider/runners/pull/201)

## 0.2.0

[Full diff](https://github.com/sider/runners/compare/0.1.0...0.2.0)

- Fix `npm install` for TyScan [#163](https://github.com/sider/runners/pull/163)
- Support ktlint [#192](https://github.com/sider/runners/pull/192)
- Optimize Cppcheck Docker image via multi-stage [#195](https://github.com/sider/runners/pull/195)
- Bump devon_rex images from 2.2.0 to 2.2.2 (thanks to Dependabot!)

## 0.1.0

[Full diff](https://github.com/sider/runners/compare/0.0.7...0.1.0)

- Rename namespace: `NodeHarness` -> `Runners` [#96](https://github.com/sider/runners/pull/96)
- Install default npm tools via `package.json` [#99](https://github.com/sider/runners/pull/99)
- Set Bundler config: `jobs`, `retry` [#107](https://github.com/sider/runners/pull/107)
- Change owner and group of runner's home directory [#109](https://github.com/sider/runners/pull/109)
- Remove useless `BUNDLE_GEMFILE` from `Dockerfile` [#122](https://github.com/sider/runners/pull/122)
- Install default gems via `Gemfile` [#110](https://github.com/sider/runners/pull/110)
- Use Pipenv to address the dependency of Flake8 [#111](https://github.com/sider/runners/pull/111)
- Normalize version strings of Go tools [#123](https://github.com/sider/runners/pull/123)

## 0.0.7

[Full diff](https://github.com/sider/runners/compare/0.0.6...0.0.7)

- Show Node.js runtime versions [#83](https://github.com/sider/runners/pull/83)
- Improve error message when `root_dir` is not found [#84](https://github.com/sider/runners/pull/84)
- Improve messages in markdown format [#85](https://github.com/sider/runners/pull/85)
- Show Ruby runtime versions [#87](https://github.com/sider/runners/pull/87)
- Bump devon_rex images from 2.1.0 to 2.2.0 [#89](https://github.com/sider/runners/pull/89)
- Fix `stylelint-config-recommended` version [#93](https://github.com/sider/runners/pull/93)

## 0.0.6

[Full diff](https://github.com/sider/runners/compare/0.0.5...0.0.6)

- Bump devon_rex images from 2.0.3 to 2.1.0 [#75](https://github.com/sider/runners/pull/75)
