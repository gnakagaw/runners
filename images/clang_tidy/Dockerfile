# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE: DO *NOT* EDIT THIS FILE. IT IS GENERATED.
# PLEASE UPDATE Dockerfile.erb INSTEAD OF THIS FILE.
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FROM sider/devon_rex_base:2.41.0

COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} images/clang_tidy/packages.list ${RUNNER_USER_HOME}/

ARG LLVM_VERSION=11

USER root
RUN curl -fsSL https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add - && \
    add-apt-repository "deb http://apt.llvm.org/buster/ llvm-toolchain-buster-${LLVM_VERSION} main" && \
    apt-get update && \
    grep -v "^\s*#" "${RUNNER_USER_HOME}/packages.list" | xargs apt-get install -qq -y --no-install-recommends "clang-tidy-${LLVM_VERSION}" && \
    apt-get clean && \
    update-alternatives --install /usr/local/bin/clang-tidy clang-tidy "/usr/lib/llvm-${LLVM_VERSION}/bin/clang-tidy" 20 && \
    clang-tidy --version | grep "LLVM version ${LLVM_VERSION}"
USER $RUNNER_USER


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

# Copy the main source code
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} exe ${RUNNERS_DIR}/exe
COPY --chown=${RUNNER_USER}:${RUNNER_GROUP} lib ${RUNNERS_DIR}/lib

ENV PATH ${RUNNERS_DIR}/exe:${PATH}

# Run as non-root user
USER $RUNNER_USER
WORKDIR $RUNNER_USER_HOME

COPY images/docker-entrypoint.sh /
ENTRYPOINT ["/docker-entrypoint.sh", "runners", "--analyzer=clang_tidy"]
