# super locked-down to current version running in production
FROM cheddam/silverstripe-lamp@sha256:12f1d19d156249cdd5706d9a08907ec680113fb4123f376e74917d2246f2ac42

# run the same composer logic has in our current platform builder
RUN composer global require silverstripe/vendor-plugin-helper

# run the ./tools/
RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
RUN ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts
RUN ssh-keyscan -p222 code.platform.silverstripe.com >> ~/.ssh/known_hosts

COPY docker-entrypoint.sh /docker-entrypoint.sh
COPY git.sh /git.sh

WORKDIR "/app"
ENTRYPOINT ["/docker-entrypoint.sh"]
