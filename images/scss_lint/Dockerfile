# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE: DO *NOT* EDIT THIS FILE. IT IS GENERATED.
# PLEASE UPDATE Dockerfile.erb INSTEAD OF THIS FILE.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FROM sider/devon_rex_ruby:2.41.0


ARG RUNNERS_DIR=${RUNNER_USER_HOME}/runners

# Install required gems first (due to slow download)
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} Gemfile Gemfile.lock runners.gemspec analyzers.yml ${RUNNERS_DIR}/
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} lib/runners/version.rb ${RUNNERS_DIR}/lib/runners/

RUN cd "${RUNNERS_DIR}" && \
    bundle config set --global jobs 4 && \
    bundle config set --global retry 3 && \
    bundle config && \
    BUNDLE_WITHOUT=development bundle install && \
    bundle list && \
    echo 'Checking if the Bundler version is expected...' && \
    lockfile_bundler_version=$(bundle exec ruby -e 'puts Bundler.locked_gems.bundler_version') && \
    bundle version | grep "Bundler version ${lockfile_bundler_version}"

# Install the default version
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} images/scss_lint/Gemfile ${RUNNER_USER_HOME}/scss_lint_Gemfile
RUN cd "${RUNNER_USER_HOME}" && \
    mkdir scss_lint && \
    mv scss_lint_Gemfile scss_lint/Gemfile && \
    cd scss_lint && \
    bundle config set --local system 'true' && \
    bundle install --gemfile=Gemfile && \
    bundle config unset --local system && \
    cd .. && \
    rm -rf scss_lint && \
    gem info --local --exact --quiet scss_lint | grep scss_lint

COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} images/scss_lint/scss-lint.default.yml ${RUNNER_USER_HOME}/.scss-lint.yml


# Copy the main source code
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} exe ${RUNNERS_DIR}/exe
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} lib ${RUNNERS_DIR}/lib

ENV PATH ${RUNNERS_DIR}/exe:${PATH}

# Run as non-root user
USER $RUNNER_USER
WORKDIR $RUNNER_USER_HOME

COPY images/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh", "runners", "--analyzer=scss_lint"]
