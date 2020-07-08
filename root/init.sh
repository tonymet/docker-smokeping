mkdir -p \
	/config/site-confs \
	/run/apache2 \
	/var/cache/smokeping
# make symlinks
[[ ! -L /var/www/localhost/smokeping ]] && \
	ln -sf /usr/share/webapps/smokeping /var/www/localhost/smokeping

[[ ! -L /var/www/localhost/smokeping/cache ]] && \
	ln -sf	/var/cache/smokeping /var/www/localhost/smokeping/cache

# permissions
chown -R apache:apache \
	/config \
	/data \
	/run/apache2 \
	/usr/share/webapps/smokeping \
	/var/cache/smokeping \
	/var/www/localhost/smokeping

# Start the first process
/usr/sbin/httpd -DFOREGROUND&
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start /usr/sbin/httpd: $status"
  exit $status
fi

# Start the second process
su apache -s /bin/sh -c '/usr/bin/smokeping --config="/etc/smokeping/config" --nodaemon'&
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start /usr/bin/smokeping: $status"
  exit $status
fi

wait 
