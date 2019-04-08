FROM silverstripe/platform-build:1.0.2 AS build

# super locked-down to current version running in production
FROM ssmarco/php71node8x:1.0.0

# run the ./tools/
RUN mkdir -p ~/.ssh
RUN chmod 0700 ~/.ssh
RUN printf "Host *\nStrictHostKeyChecking no\nUserKnownHostsFile /dev/null\n" > ~/.ssh/config
RUN chmod 400 ~/.ssh/config

RUN composer self-update
# run the same composer logic has in our current platform builder
RUN composer global require silverstripe/vendor-plugin-helper

COPY --from=build /funcs.sh /funcs.sh
COPY docker-entrypoint.sh /docker-entrypoint.sh

WORKDIR "/app"
ENTRYPOINT ["/docker-entrypoint.sh"]
