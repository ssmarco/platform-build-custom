FROM silverstripe/platform-build:1.0.2 AS build

# super locked-down to current version running in production
FROM cheddam/silverstripe-lamp@sha256:12f1d19d156249cdd5706d9a08907ec680113fb4123f376e74917d2246f2ac42

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
