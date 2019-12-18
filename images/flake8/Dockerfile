# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# NOTE: DO *NOT* EDIT THIS FILE.  IT IS GENERATED.
# PLEASE UPDATE Dockerfile.erb INSTEAD OF THIS FILE
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
FROM sider/devon_rex_python:dev

ARG RUNNERS_DIR=${RUNNER_USER_HOME}/runners

# Install required gems first (due to slow download)
COPY --chown=analyzer_runner:nogroup Gemfile* ${RUNNERS_DIR}/
RUN cd ${RUNNERS_DIR} && \
    bundle config --global jobs 4 && \
    bundle config --global retry 3 && \
    bundle config && \
    bundle install --without='development test'

# Install the default version
COPY images/flake8/Pipfile /tmp/flake8/Pipfile
USER root
RUN cd /tmp/flake8 && \
    pipenv install --system --skip-lock && \
    cd .. && \
    rm -rf /tmp/flake8 && \
    flake8 --version

# TODO: Python 2 will be unsupported in January 2020. Then, this hack should be unnecessary.
# Install Python 2 via pyenv
USER $RUNNER_USER
ENV PATH ${RUNNER_USER_HOME}/.pyenv/shims:${RUNNER_USER_HOME}/.pyenv/bin:${PATH}
ENV PYTHON2_VERSION 2.7.16
COPY --chown=analyzer_runner:nogroup images/flake8/Pipfile /tmp/flake8/
RUN cd /tmp/flake8 && \
    curl -fsSL https://pyenv.run | bash && \
    PATH="${RUNNER_USER_HOME}/.pyenv/shims:${RUNNER_USER_HOME}/.pyenv/bin:${PATH}" && \
    pyenv install ${PYTHON2_VERSION} && \
    pyenv global ${PYTHON2_VERSION} && \
    pip install --upgrade pip && \
    pip install pipenv && \
    pipenv install --system --skip-lock && \
    pyenv rehash && \
    pyenv which flake8 && \
    pyenv global system && \
    pyenv versions && \
    rm -rf /tmp/flake8

COPY --chown=analyzer_runner:nogroup images/flake8/sider_config.ini ${RUNNER_USER_HOME}/.config/flake8
COPY --chown=analyzer_runner:nogroup images/flake8/ignored-config.ini ${RUNNER_USER_HOME}/.config/ignored-config.ini

# Copy the main source code
COPY --chown=analyzer_runner:nogroup bin ${RUNNERS_DIR}/bin
COPY --chown=analyzer_runner:nogroup lib ${RUNNERS_DIR}/lib

ENV PATH ${RUNNERS_DIR}/bin:${PATH}

# Run as non-root user
USER $RUNNER_USER
WORKDIR $RUNNER_USER_HOME

ENTRYPOINT ["/usr/bin/timeout", "--signal=SIGUSR2", "--kill-after=10s", "30m", "runners", "--analyzer=flake8"]
